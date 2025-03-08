--为了保证SQL基线的正确使用，需要确定两个参数：
SQL> show parameter optimizer_capture_sql_plan_baselines //不自动使用基线

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
optimizer_capture_sql_plan_baselines boolean     FALSE

SQL> alter system set "_optimizer_use_feedback"=FALSE scope=both sid='*'; //防止自动生成基线，基数反馈会影响基线的选择
隐藏参数，需要被改变，才能查出来

   
SQL> explain plan for SELECT * FROM cz.test t WHERE t.object_id=:1 and t.object_name=:2;

Explained.

Elapsed: 00:00:00.01
SQL> select * from table(dbms_xplan.display);

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 4163565473

-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |   156 | 32292 |    17   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| TEST        |   156 | 32292 |    17   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_ID_NAME |    13 |       |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T"."OBJECT_ID"=TO_NUMBER(:1) AND "T"."OBJECT_NAME"=:2)

Note
-----
   - dynamic sampling used for this statement (level=2)

18 rows selected.

SQL> explain plan for SELECT /*+full(t)*/ * FROM cz.test t WHERE t.object_id=:1 and t.object_name=:2;

Explained.

Elapsed: 00:00:00.01
SQL> select * from table(dbms_xplan.display);

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 1357081020

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |   156 | 32292 |  6422   (1)| 00:01:18 |
|*  1 |  TABLE ACCESS FULL| TEST |   156 | 32292 |  6422   (1)| 00:01:18 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("T"."OBJECT_NAME"=:2 AND "T"."OBJECT_ID"=TO_NUMBER(:1))

Note
-----
   - dynamic sampling used for this statement (level=2)

##获取SQL
在plsql dev的命令窗口执行，终端执行报错，多执行几次，才能找到SQL_ID，建议格式一致，应为一个空格，都会导致SQL_ID不同。
variable 1 varchar2
exec :1 := '106195'
variable 2 varchar2
exec :2 := 'SP_TJ_FDJZCLXSWDJHSBGB'
SELECT * FROM cz.test t WHERE t.object_id=:1 and t.object_name=:2;

##查看SQL_ID
SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t.sql_text,t."VERSION_COUNT",t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_TEXT" like 'SELECT * FROM cz.test t%' order by t."LAST_ACTIVE_TIME" desc;

--未加hint
3	87mbaqxgm912z	1	4	4163565473	<CLOB>

--加hint
SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t.sql_text,t."VERSION_COUNT",t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_TEXT" like 'SELECT * FROM cz.test t%' order by t."LAST_ACTIVE_TIME" desc;
3	ckyyunckw50ac	1	4	1357081020	<CLOB>

--分别生成基线
DECLARE
k1 pls_integer;
begin
k1 := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (
sql_id=>'ckyyunckw50ac',
plan_hash_value=>1357081020
);
end;
/

--查看基线
select sql_handle,plan_name,t.last_modified,sql_text,ACCEPTED,fixed from dba_sql_plan_baselines t order by t.last_modified desc;

--查看执行计划
select * from table(dbms_xplan.display_sql_plan_baseline(sql_handle=>'SQL_469861d355640f52',plan_name => 'SQL_PLAN_4d631udaq83uk37b9c349'));

--指定基线
declare
x pls_integer;
begin
x :=dbms_spm.load_plans_from_cursor_cache(
sql_id => 'ckyyunckw50ac',              --加hit
plan_hash_value => '1357081020',        --加hit 
sql_handle => 'SQL_722b5d6d075f4247'  --原始语句（未加hit）
);
dbms_output.put_line(x);
end;
/

--保留最新的一条，然后删除不加hint的一条
select sql_handle,plan_name,t.last_modified,sql_text,ACCEPTED,fixed from dba_sql_plan_baselines t order by t.last_modified desc;

declare
x pls_integer;
begin
x :=dbms_spm.drop_sql_plan_baseline(
plan_name => 'SQL_PLAN_74auxdn3pyhk768bc2187',
sql_handle => 'SQL_722b5d6d075f4247'
);
end;
/

##检查
由于有绑定变量的存在，所以终端是执行不成功的，只能通过plsql dev的命令窗口，声明变量的方法去看执行计划，如果是直接赋值看看执行计划是不正确的。
##查看方法
##查找v$sqlarea中记录了正在执行的SQL
1@查看当前SQL的执行计划：
SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t."LOADED_VERSIONS",t."VERSION_COUNT",t.sql_text,t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_ID"='&sql_id' order by t."LAST_ACTIVE_TIME" desc;
#version_count 是有多少个子游标，也就是生成了多少个执行计划。如果是2，那么就是有2个，cursor_child_no就是0,1两个值
-LOADED_VERSIONS 一共加载的数量，就是对应v$sql里的条数
-VERSION_COUNT  历史总子游标的数量

2@查看plan_hash_value --其实就是用的最新的一条计划
SELECT t."SQL_ID",t."CHILD_NUMBER",t."PLAN_HASH_VALUE",t."LAST_ACTIVE_TIME" FROM v$sql t WHERE t."SQL_ID"='&sql_id' order by t."LAST_ACTIVE_TIME" desc;

3@查看对应child_number CHILD_NUMBER
select * from table(dbms_xplan.display_cursor(sql_id => '&sql_id',cursor_child_no => '&CHILD_NUMBER',format => 'advanced'));



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