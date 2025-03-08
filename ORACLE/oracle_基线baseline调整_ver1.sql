
#####sql_plan_baseline#####
--检查是否开启
通过OPTIMIZER_USE_SQL_PLAN_BASELINE来控制Oracle是否使用基线，默认值为TRUE，即会自动使用基线，11g中默认是不会自动创建基线。
--原始SQL
在plsql dev的命令窗口执行，终端执行无效。
variable 1 number
exec :1 := 1100
select * from cz_obj t WHERE t.object_id=:1; 

--hitSQL 
variable 1 number
exec :1 := 1100
select /*+full(t)*/  * from cz_obj t WHERE t.object_id=:1;

--获取两个sql_id 
select sql_text,sql_id,hash_value,child_number,plan_hash_value,to_char(LAST_ACTIVE_TIME,'hh24:mi:ss') time from v$sql a where sql_text like '%select * from cz_obj %' and sql_text not like '%v$sql%';

1、给原始SQL创建基线
variable 1 number
exec :1 := 1100
select * from cz.cz_obj t WHERE t.object_id=:1; --5vryg31gucrsh

SQL_ID  5vryg31gucrsh, child number 0
-------------------------------------
select * from cz_obj t WHERE t.object_id=:1

Plan hash value: 4253750672

--------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              |       |       |    15 (100)|          |
|   1 |  TABLE ACCESS BY INDEX ROWID| CZ_OBJ       |  1549 |   313K|    15   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_CZ_OBJID |   620 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

--创建基线
DECLARE
k1 pls_integer;
begin
k1 := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (
sql_id=>'5vryg31gucrsh',
plan_hash_value=>4253750672
);
end;
/


2、加hit后的执行
select /*+full(t)*/  * from cz_obj t WHERE t.object_id=:1; --d8ka42gmr7tmu 
select sql_text,sql_id,hash_value,child_number,plan_hash_value,to_char(LAST_ACTIVE_TIME,'hh24:mi:ss') time from v$sql a where sql_text like '%select /*+full(t)*/ %' and sql_text not like '%v$sql%';

SQL_ID  d8ka42gmr7tmu, child number 0
-------------------------------------
select /*+full(t)*/  * from cz_obj t WHERE t.object_id=:1

Plan hash value: 330362096

----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |       |       |   649 (100)|          |
|*  1 |  TABLE ACCESS FULL| CZ_OBJ |  1549 |   313K|   649   (1)| 00:00:08 |
----------------------------------------------------------------------------

--创建基线
DECLARE
k1 pls_integer;
begin
k1 := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (
sql_id=>'d8ka42gmr7tmu',
plan_hash_value=>330362096
);
end;
/

3、查看两条基线
col SQL_TEXT for a70
select sql_handle,plan_name,dbms_lob.substr(sql_text,60,1) sql_text,ACCEPTED from dba_sql_plan_baselines t;

SQL_HANDLE                     PLAN_NAME                      SQL_TEXT                                                               ACC
------------------------------ ------------------------------ ---------------------------------------------------------------------- ---
SQL_456364994422086b           SQL_PLAN_4asv4m522423bb1b8b050 select * from cz_obj t WHERE t.object_id=:1                            YES
SQL_9724a12126016c93           SQL_PLAN_9f95144m02v4m725c4061 select /*+full(t)*/  * from cz_obj t WHERE t.object_id=:1              YES

4、查看索引基线是否正确-基线执行计划查看
select * from table(dbms_xplan.display_sql_plan_baseline(sql_handle=>'SQL_469861d355640f52',plan_name => 'SQL_PLAN_4d631udaq83uk37b9c349'));

5、把加hit的执行计划加入到原始SQL（未加hit）的基线中
declare
x pls_integer;
begin
x :=dbms_spm.load_plans_from_cursor_cache(
sql_id => 'd8ka42gmr7tmu',              --加hit
plan_hash_value => '330362096',        --加hit 
sql_handle => 'SQL_456364994422086b'  --原始语句（未加hit）
);
dbms_output.put_line(x);
end;
/

6、删除掉之前(未建hint)的原始基线
declare
x pls_integer;
begin
x :=dbms_spm.drop_sql_plan_baseline(
plan_name => 'SQL_PLAN_4asv4m522423bb1b8b050',
sql_handle => 'SQL_456364994422086b'
);
end;
/

6、验证
由于在创建的基线的时候，是通过绑定变量获取的sql_id，索引必须用 explain plan for select  * from cz.cz_obj t WHERE t.object_id=:1;的方式去查看，执行计划是否生效。
如果是带值的，那么sql_id就会不一样，自然执行计划看起来就不会生效，但是在程序中，都是绑定变量，传参执行的SQL。


#####base_line中的优先级#####
一个SQL语句对应的基线，我将它们归纳为三种状态
accepted（可接受），只有这种状态的基线，优化器才会考虑此基线中的执行计划
no-accepted（不可接受），这种状态的基线，优化器在SQL语句解析期间不会考虑。这种状态的基线必须通过演化和验证通过后，转变为accepted状态后，才会被优化器考虑使用
fixed为yes（固定），这种状态的基线固有最高优先级！比其他两类基线都要优先考虑


--以下语句可执行fixed为yes
SET SERVEROUTPUT ON
DECLARE
K1 PLS_INTEGER;
BEGIN
K1 := DBMS_SPM.alter_sql_plan_baseline(sql_handle => 'SQL_456364994422086b',plan_name => 'SQL_PLAN_4asv4m522423b725c4061',
attribute_name => 'fixed',attribute_value => 'YES');
DBMS_OUTPUT.put_line('Plans Altered: ' ||K1 );
END;
/

##自动捕获基线
通过OPTIMIZER_USE_SQL_PLAN_BASELINE来控制Oracle是否使用基线，默认值为TRUE，即会自动使用基线。
自动捕获基线，通过将optimizer_capture_sql_plan_baselines设置为true，优化器为重复执行两次以上的SQL语句生成并保存基线（可以系统级或会话级修改）



