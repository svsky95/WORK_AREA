create table cz.t_skew as select * from dba_objects;
create index cz.idx_t_skew on cz.t_skew(object_id);
update cz.t_skew set object_id=3 where object_id>3;
commit;

--��ѯ������б
SQL> select object_id, count(*) from cz.t_skew group by object_id;

 OBJECT_ID   COUNT(*)
---------- ----------
                   15
         2          1
         3     116588

--�ռ�ͳ����Ϣ
exec dbms_stats.gather_table_stats('CZ','T_SKEW');

--�鿴ֱ��ͼ��Ϣ
select owner, table_name, column_name, histogram from dba_tab_col_statistics where table_name = 'T_SKEW' and column_name = 'OBJECT_ID';

OWNER      TABLE_NAME           COLUMN_NAME     HISTOGRAM
---------- -------------------- --------------- ---------------
CZ         T_SKEW               OBJECT_ID       FREQUENCY

Ƶ��ֱ��ͼ��Frequency,Freq����Ƶ��ֱ��ͼֻ������Ŀ���е�distinctֵС�ڻ��ߵ���254������
�߶�ƽ��ֱ��ͼ��Height Balanced,HtBal������distinctֵ����254����ôֻ��ʹ�ø߶�ƽ��ֱ��ͼ

SQL>alter session set statistics_level=all;      
SQL> var v1 number;
SQL> exec :v1 := 2;

PL/SQL procedure successfully completed.

Elapsed: 00:00:00.00
SQL> select count(*) from cz.t_skew where object_id = :v1;

  COUNT(*)
----------
         1

Elapsed: 00:00:00.00
SQL> select * from table(dbms_xplan.display_cursor(null,null,'allstats'));

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID  32za3hbgxn09x, child number 1
-------------------------------------
select count(*) from cz.t_skew where object_id = :v1

Plan hash value: 3167530345

------------------------------------------------------------------------------------------
| Id  | Operation         | Name       | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |            |      1 |        |      1 |00:00:00.01 |       3 |
|   1 |  SORT AGGREGATE   |            |      1 |      1 |      1 |00:00:00.01 |       3 |
|*  2 |   INDEX RANGE SCAN| IDX_T_SKEW |      1 |      1 |      1 |00:00:00.01 |       3 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OBJECT_ID"=:V1)


19 rows selected.

Elapsed: 00:00:00.02
SQL> var v1 number;
SQL> exec :v1 := 3;

PL/SQL procedure successfully completed.

Elapsed: 00:00:00.00
SQL> select count(*) from cz.t_skew where object_id = :v1;
select * from table(dbms_xplan.display_cursor(null,null,'allstats'));

  COUNT(*)
----------
    116588

Elapsed: 00:00:00.02
SQL> 
PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQL_ID  32za3hbgxn09x, child number 2
-------------------------------------
select count(*) from cz.t_skew where object_id = :v1

Plan hash value: 2333720604

----------------------------------------------------------------------------------------------
| Id  | Operation             | Name       | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |            |      1 |        |      1 |00:00:00.02 |     716 |
|   1 |  SORT AGGREGATE       |            |      1 |      1 |      1 |00:00:00.02 |     716 |
|*  2 |   INDEX FAST FULL SCAN| IDX_T_SKEW |      1 |    117K|    116K|00:00:00.01 |     716 |
----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("OBJECT_ID"=:V1)


19 rows selected.

���Կ��������ڶ���ִ�а󶨱���ֵΪ3��SQLʱ��ִ�мƻ�����Ӧ�����ˡ�


--�鿴���ɵ��α�
-�鿴sql_id
SELECT * FROM v$sql t WHERE t."SQL_TEXT" like 'select count(*) from t_skew%';

SELECT CHILD_NUMBER,
       EXECUTIONS,
       BUFFER_GETS,
       IS_BIND_SENSITIVE AS "BS",
       IS_BIND_AWARE     AS "BA",
       IS_SHAREABLE      AS "SH",
       PLAN_HASH_VALUE
  FROM V$SQL
 WHERE SQL_ID = '7gg7pv66krych';
 
 
-��1��IS_BIND_SENSITIVE��ָʾ�α��Ƿ�Ϊ�԰����У�ֵΪYES | NO��������������Ĳ�ѯ��Ϊ�԰����еĲ�ѯ������ν��ѡ����ʱ�Ż�����Ϊ��ɨ�Ӱ󶨱���ֵ�����Ұ󶨱���ֵ�ĸ��Ŀ��ܵ��²�ͬ�ƻ���
-��2��IS_BIND_AWARE��ָʾ�α��Ƿ�Ϊ�ܱ�ʶ�󶨵��αֵ꣬ΪYES | NO���α���ٻ������ѱ��Ϊʹ����ʶ��󶨵��α깲����α��Ϊ�ܱ�ʶ�󶨵��αꡣ
-��3��IS_SHAREABLE��Y�ɹ���N���ɹ���
CHILD_NUMBER EXECUTIONS BUFFER_GETS B B S PLAN_HASH_VALUE
------------ ---------- ----------- - - - ---------------
           0          2         407 Y N N      3167530345
           1          2        1432 Y Y Y      2333720604
           2          3        2148 Y N Y      2333720604
           
select * from V$SQL_CS_HISTOGRAM where sql_id = '7gg7pv66krych';

--�ڿ⻺�������SQL��ִ�мƻ�
SQL> select sql_id, ADDRESS, HASH_VALUE from v$sqlarea where sql_id = '7gg7pv66krych';
SQL_ID          ADDRESS          HASH_VALUE
--------------- ---------------- ----------
7gg7pv66krych   0000001D78C84468 2368469392

SQL> exec sys.DBMS_SHARED_POOL.PURGE('0000001D78C84468,2368469392','C');



--bind peeking��acs���ԵĹر�
--��Ϊ��̬����
--bind peeking���󶨱�����̽��
alter system set "_optim_peek_user_binds"=false;

--acs(adaptive cursor sharing)
alter system set "_optimizer_extended_cursor_sharing_rel"=NONE;
alter system set "_optimizer_extended_cursor_sharing"=NONE;
alter system set "_optimizer_adaptive_cursor_sharing"=false;

�ر�ע�⣺���bind peeking�ǹرյģ�ʵ����acsҲ�Ͳ��������ã�
����������ֻ��_optim_peek_user_binds��������Ϊfalse���ٴΰ���3.2�����ظ�ͬ��ʵ�飬��ѯ������£������õ�acs���ԣ���ʹ��û����ʾ���õ�acs��Ӧ�Ĳ���