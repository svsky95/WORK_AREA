create table cz.t_skew as select * from dba_objects;
create index cz.idx_t_skew on cz.t_skew(object_id);
update cz.t_skew set object_id=3 where object_id>3;
commit;

--查询数据倾斜
SQL> select object_id, count(*) from cz.t_skew group by object_id;

 OBJECT_ID   COUNT(*)
---------- ----------
                   15
         2          1
         3     116588

--收集统计信息
exec dbms_stats.gather_table_stats('CZ','T_SKEW');

--查看直方图信息
select owner, table_name, column_name, histogram from dba_tab_col_statistics where table_name = 'T_SKEW' and column_name = 'OBJECT_ID';

OWNER      TABLE_NAME           COLUMN_NAME     HISTOGRAM
---------- -------------------- --------------- ---------------
CZ         T_SKEW               OBJECT_ID       FREQUENCY

频率直方图（Frequency,Freq）：频率直方图只适用于目标列的distinct值小于或者等于254的情形
高度平衡直方图（Height Balanced,HtBal）：当distinct值大于254，那么只能使用高度平衡直方图

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

可以看到，当第二次执行绑定变量值为3的SQL时，执行计划自适应调整了。


--查看生成的游标
-查看sql_id
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
 
 
-（1）IS_BIND_SENSITIVE：指示游标是否为对绑定敏感，值为YES | NO。符合以下情况的查询称为对绑定敏感的查询：计算谓词选择性时优化程序为其扫视绑定变量值，并且绑定变量值的更改可能导致不同计划。
-（2）IS_BIND_AWARE：指示游标是否为能标识绑定的游标，值为YES | NO。游标高速缓存中已标记为使用能识别绑定的游标共享的游标称为能标识绑定的游标。
-（3）IS_SHAREABLE：Y可共享、N不可共享
CHILD_NUMBER EXECUTIONS BUFFER_GETS B B S PLAN_HASH_VALUE
------------ ---------- ----------- - - - ---------------
           0          2         407 Y N N      3167530345
           1          2        1432 Y Y Y      2333720604
           2          3        2148 Y N Y      2333720604
           
select * from V$SQL_CS_HISTOGRAM where sql_id = '7gg7pv66krych';

--在库缓存中清除SQL的执行计划
SQL> select sql_id, ADDRESS, HASH_VALUE from v$sqlarea where sql_id = '7gg7pv66krych';
SQL_ID          ADDRESS          HASH_VALUE
--------------- ---------------- ----------
7gg7pv66krych   0000001D78C84468 2368469392

SQL> exec sys.DBMS_SHARED_POOL.PURGE('0000001D78C84468,2368469392','C');



--bind peeking和acs特性的关闭
--均为动态参数
--bind peeking（绑定变量窥探）
alter system set "_optim_peek_user_binds"=false;

--acs(adaptive cursor sharing)
alter system set "_optimizer_extended_cursor_sharing_rel"=NONE;
alter system set "_optimizer_extended_cursor_sharing"=NONE;
alter system set "_optimizer_adaptive_cursor_sharing"=false;

特别注意：如果bind peeking是关闭的，实际上acs也就不会起作用，
比如我这里只将_optim_peek_user_binds参数设置为false，再次按照3.2步骤重复同样实验，查询结果如下，不会用到acs特性，即使我没有显示禁用掉acs对应的参数