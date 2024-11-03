##��ȡ��ϸ��ִ�мƻ� ��SQL�ᱻ��ʵ��ִ��
SELECT /*+ gather_plan_statistics */ count(t2.col2)
FROM t1 ,t2 WHERE t1.id=t2.id and t1.col1 = 666;
SELECT * FROM table(dbms_xplan.display_cursor(NULL,NULL,'allstats last'));
PS��A-ROWS ��ʵ��������
    E-ROWS Ԥ������
��E-ROWSԶԶС��A-ROWS������ʱ�����������У�ͳ����Ϣ���ڣ�����������б

##����v$sqlarea�м�¼������ִ�е�SQL��ע��RAC�����������ĸ��ڵ㷢�������⣬�����ĸ��ڵ���ִ��
1@�鿴��ǰSQL��ִ�мƻ���ִ�д�����
SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t.sql_text,t."LOADED_VERSIONS",t."VERSION_COUNT",t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_TEXT" like 'select count(1) from DZDZ.DZDZ_FPXX_PTFP ZB%' order by t."LAST_ACTIVE_TIME" desc;

SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t."LOADED_VERSIONS",t."VERSION_COUNT",t.sql_text,t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_ID"='&sql_id' order by t."LAST_ACTIVE_TIME" desc;
#version_count ���ж��ٸ����α꣬Ҳ���������˶��ٸ�ִ�мƻ��������2����ô������2����cursor_child_no����0,1����ֵ
-LOADED_VERSIONS һ�����ص����������Ƕ�Ӧv$sql�������
-VERSION_COUNT  ��ʷ�����α������

2@�鿴plan_hash_value --��ʵ�����õ����µ�һ����ִ�мƻ�
SELECT t."SQL_ID",t."CHILD_NUMBER",t."PLAN_HASH_VALUE",t."LAST_ACTIVE_TIME" FROM v$sql t WHERE t."SQL_ID"='&sql_id' order by t."LAST_ACTIVE_TIME" desc;

3@�鿴��Ӧchild_number CHILD_NUMBER=
select * from table(dbms_xplan.display_cursor(sql_id => '&sql_id',cursor_child_no => '&CHILD_NUMBER',format => 'advanced'));


--������
1���������ܶ�����α��ʱ�򣬿����ȿ�v$sqlarea�е�ִ�мƻ���ȷ��ִ�еļƻ���
2�����кܶ࣬���Բ鿴�£�ִ�мƻ��Ƿ��Ƕ�����ͬ�ģ����в�ͬ��������Ҫ���ִ�У����£�ִ�мƻ��Ƿ�һ�¡�
3������ʹ��trace�ķ������٣�Ҳ���Ի�ȡ��ϸ��ִ�мƻ���
4������һ��ִ�кܿ죬�ڶ���ִ�к�������ô��Ҫ�����Ƿ��ǻ�����������ġ�
5���ص������������鿴ִ�мƻ���

--�رն�̬������Ĭ�Ͽ�����������رգ�
alter session set optimizer_dynamic_sampling=0;

--�׶β鿴SQL��ִ�д���
select *
from (select BEGIN_INTERVAL_TIME,
a.instance_number,
plan_hash_value,
EXECUTIONS_DELTA exec,
round(BUFFER_GETS_DELTA / EXECUTIONS_DELTA) per_get,
round(ROWS_PROCESSED_DELTA / EXECUTIONS_DELTA, 1) per_rows,
round(ELAPSED_TIME_DELTA / EXECUTIONS_DELTA / 1000000, 2) time_s,
round(DISK_READS_DELTA / EXECUTIONS_DELTA, 2) per_read
from dba_hist_SQLstat a, DBA_HIST_SNAPSHOT b
where a.snap_id = b.snap_id
and EXECUTIONS_DELTA <> 0
and a.instance_number = b.instance_number
and a.SQL_id = '337tbk13hdzxn'
order by 1 desc)
where rownum < 30;

--�鿴SQL����������߼���
set autotrace traceonly

24 consistent gets
9 physical reads --�����Խ��Խ��
