--Ϊ�˱�֤SQL���ߵ���ȷʹ�ã���Ҫȷ������������
SQL> show parameter optimizer_capture_sql_plan_baselines //���Զ�ʹ�û���

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
optimizer_capture_sql_plan_baselines boolean     FALSE

SQL> alter system set "_optimizer_use_feedback"=FALSE scope=both sid='*'; //��ֹ�Զ����ɻ��ߣ�����������Ӱ����ߵ�ѡ��
���ز�������Ҫ���ı䣬���ܲ����

   
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

##��ȡSQL
��plsql dev�������ִ�У��ն�ִ�б�����ִ�м��Σ������ҵ�SQL_ID�������ʽһ�£�ӦΪһ���ո񣬶��ᵼ��SQL_ID��ͬ��
variable 1 varchar2
exec :1 := '106195'
variable 2 varchar2
exec :2 := 'SP_TJ_FDJZCLXSWDJHSBGB'
SELECT * FROM cz.test t WHERE t.object_id=:1 and t.object_name=:2;

##�鿴SQL_ID
SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t.sql_text,t."VERSION_COUNT",t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_TEXT" like 'SELECT * FROM cz.test t%' order by t."LAST_ACTIVE_TIME" desc;

--δ��hint
3	87mbaqxgm912z	1	4	4163565473	<CLOB>

--��hint
SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t.sql_text,t."VERSION_COUNT",t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_TEXT" like 'SELECT * FROM cz.test t%' order by t."LAST_ACTIVE_TIME" desc;
3	ckyyunckw50ac	1	4	1357081020	<CLOB>

--�ֱ����ɻ���
DECLARE
k1 pls_integer;
begin
k1 := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (
sql_id=>'ckyyunckw50ac',
plan_hash_value=>1357081020
);
end;
/

--�鿴����
select sql_handle,plan_name,t.last_modified,sql_text,ACCEPTED,fixed from dba_sql_plan_baselines t order by t.last_modified desc;

--�鿴ִ�мƻ�
select * from table(dbms_xplan.display_sql_plan_baseline(sql_handle=>'SQL_469861d355640f52',plan_name => 'SQL_PLAN_4d631udaq83uk37b9c349'));

--ָ������
declare
x pls_integer;
begin
x :=dbms_spm.load_plans_from_cursor_cache(
sql_id => 'ckyyunckw50ac',              --��hit
plan_hash_value => '1357081020',        --��hit 
sql_handle => 'SQL_722b5d6d075f4247'  --ԭʼ��䣨δ��hit��
);
dbms_output.put_line(x);
end;
/

--�������µ�һ����Ȼ��ɾ������hint��һ��
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

##���
�����а󶨱����Ĵ��ڣ������ն���ִ�в��ɹ��ģ�ֻ��ͨ��plsql dev������ڣ����������ķ���ȥ��ִ�мƻ��������ֱ�Ӹ�ֵ����ִ�мƻ��ǲ���ȷ�ġ�
##�鿴����
##����v$sqlarea�м�¼������ִ�е�SQL
1@�鿴��ǰSQL��ִ�мƻ���
SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t."LOADED_VERSIONS",t."VERSION_COUNT",t.sql_text,t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_ID"='&sql_id' order by t."LAST_ACTIVE_TIME" desc;
#version_count ���ж��ٸ����α꣬Ҳ���������˶��ٸ�ִ�мƻ��������2����ô������2����cursor_child_no����0,1����ֵ
-LOADED_VERSIONS һ�����ص����������Ƕ�Ӧv$sql�������
-VERSION_COUNT  ��ʷ�����α������

2@�鿴plan_hash_value --��ʵ�����õ����µ�һ���ƻ�
SELECT t."SQL_ID",t."CHILD_NUMBER",t."PLAN_HASH_VALUE",t."LAST_ACTIVE_TIME" FROM v$sql t WHERE t."SQL_ID"='&sql_id' order by t."LAST_ACTIVE_TIME" desc;

3@�鿴��Ӧchild_number CHILD_NUMBER
select * from table(dbms_xplan.display_cursor(sql_id => '&sql_id',cursor_child_no => '&CHILD_NUMBER',format => 'advanced'));



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