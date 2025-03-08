
#####sql_plan_baseline#####
--����Ƿ���
ͨ��OPTIMIZER_USE_SQL_PLAN_BASELINE������Oracle�Ƿ�ʹ�û��ߣ�Ĭ��ֵΪTRUE�������Զ�ʹ�û��ߣ�11g��Ĭ���ǲ����Զ��������ߡ�
--ԭʼSQL
��plsql dev�������ִ�У��ն�ִ����Ч��
variable 1 number
exec :1 := 1100
select * from cz_obj t WHERE t.object_id=:1; 

--hitSQL 
variable 1 number
exec :1 := 1100
select /*+full(t)*/  * from cz_obj t WHERE t.object_id=:1;

--��ȡ����sql_id 
select sql_text,sql_id,hash_value,child_number,plan_hash_value,to_char(LAST_ACTIVE_TIME,'hh24:mi:ss') time from v$sql a where sql_text like '%select * from cz_obj %' and sql_text not like '%v$sql%';

1����ԭʼSQL��������
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

--��������
DECLARE
k1 pls_integer;
begin
k1 := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (
sql_id=>'5vryg31gucrsh',
plan_hash_value=>4253750672
);
end;
/


2����hit���ִ��
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

--��������
DECLARE
k1 pls_integer;
begin
k1 := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (
sql_id=>'d8ka42gmr7tmu',
plan_hash_value=>330362096
);
end;
/

3���鿴��������
col SQL_TEXT for a70
select sql_handle,plan_name,dbms_lob.substr(sql_text,60,1) sql_text,ACCEPTED from dba_sql_plan_baselines t;

SQL_HANDLE                     PLAN_NAME                      SQL_TEXT                                                               ACC
------------------------------ ------------------------------ ---------------------------------------------------------------------- ---
SQL_456364994422086b           SQL_PLAN_4asv4m522423bb1b8b050 select * from cz_obj t WHERE t.object_id=:1                            YES
SQL_9724a12126016c93           SQL_PLAN_9f95144m02v4m725c4061 select /*+full(t)*/  * from cz_obj t WHERE t.object_id=:1              YES

4���鿴���������Ƿ���ȷ-����ִ�мƻ��鿴
select * from table(dbms_xplan.display_sql_plan_baseline(sql_handle=>'SQL_469861d355640f52',plan_name => 'SQL_PLAN_4d631udaq83uk37b9c349'));

5���Ѽ�hit��ִ�мƻ����뵽ԭʼSQL��δ��hit���Ļ�����
declare
x pls_integer;
begin
x :=dbms_spm.load_plans_from_cursor_cache(
sql_id => 'd8ka42gmr7tmu',              --��hit
plan_hash_value => '330362096',        --��hit 
sql_handle => 'SQL_456364994422086b'  --ԭʼ��䣨δ��hit��
);
dbms_output.put_line(x);
end;
/

6��ɾ����֮ǰ(δ��hint)��ԭʼ����
declare
x pls_integer;
begin
x :=dbms_spm.drop_sql_plan_baseline(
plan_name => 'SQL_PLAN_4asv4m522423bb1b8b050',
sql_handle => 'SQL_456364994422086b'
);
end;
/

6����֤
�����ڴ����Ļ��ߵ�ʱ����ͨ���󶨱�����ȡ��sql_id������������ explain plan for select  * from cz.cz_obj t WHERE t.object_id=:1;�ķ�ʽȥ�鿴��ִ�мƻ��Ƿ���Ч��
����Ǵ�ֵ�ģ���ôsql_id�ͻ᲻һ������Ȼִ�мƻ��������Ͳ�����Ч�������ڳ����У����ǰ󶨱���������ִ�е�SQL��


#####base_line�е����ȼ�#####
һ��SQL����Ӧ�Ļ��ߣ��ҽ����ǹ���Ϊ����״̬
accepted���ɽ��ܣ���ֻ������״̬�Ļ��ߣ��Ż����Żῼ�Ǵ˻����е�ִ�мƻ�
no-accepted�����ɽ��ܣ�������״̬�Ļ��ߣ��Ż�����SQL�������ڼ䲻�ῼ�ǡ�����״̬�Ļ��߱���ͨ���ݻ�����֤ͨ����ת��Ϊaccepted״̬�󣬲Żᱻ�Ż�������ʹ��
fixedΪyes���̶���������״̬�Ļ��߹���������ȼ���������������߶�Ҫ���ȿ���


--��������ִ��fixedΪyes
SET SERVEROUTPUT ON
DECLARE
K1 PLS_INTEGER;
BEGIN
K1 := DBMS_SPM.alter_sql_plan_baseline(sql_handle => 'SQL_456364994422086b',plan_name => 'SQL_PLAN_4asv4m522423b725c4061',
attribute_name => 'fixed',attribute_value => 'YES');
DBMS_OUTPUT.put_line('Plans Altered: ' ||K1 );
END;
/

##�Զ��������
ͨ��OPTIMIZER_USE_SQL_PLAN_BASELINE������Oracle�Ƿ�ʹ�û��ߣ�Ĭ��ֵΪTRUE�������Զ�ʹ�û��ߡ�
�Զ�������ߣ�ͨ����optimizer_capture_sql_plan_baselines����Ϊtrue���Ż���Ϊ�ظ�ִ���������ϵ�SQL������ɲ�������ߣ�����ϵͳ����Ự���޸ģ�



