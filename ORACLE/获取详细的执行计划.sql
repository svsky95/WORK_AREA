##获取详细的执行计划 该SQL会被真实的执行
SELECT /*+ gather_plan_statistics */ count(t2.col2)
FROM t1 ,t2 WHERE t1.id=t2.id and t1.col1 = 666;
SELECT * FROM table(dbms_xplan.display_cursor(NULL,NULL,'allstats last'));
PS：A-ROWS 真实返回行数
    E-ROWS 预估行数
当E-ROWS远远小于A-ROWS的行数时，可能问题有，统计信息过期，数据严重倾斜

##查找v$sqlarea中记录了正在执行的SQL，注意RAC环境，看好哪个节点发生的问题，就在哪个节点上执行
1@查看当前SQL的执行计划及执行次数：
SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t.sql_text,t."LOADED_VERSIONS",t."VERSION_COUNT",t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_TEXT" like 'select count(1) from DZDZ.DZDZ_FPXX_PTFP ZB%' order by t."LAST_ACTIVE_TIME" desc;

SELECT t."SQL_ID",t."EXECUTIONS",t."PLAN_HASH_VALUE" ,t."LAST_ACTIVE_TIME",t."LOADED_VERSIONS",t."VERSION_COUNT",t.sql_text,t."SQL_FULLTEXT" FROM v$sqlarea t where t."SQL_ID"='&sql_id' order by t."LAST_ACTIVE_TIME" desc;
#version_count 是有多少个子游标，也就是生成了多少个执行计划。如果是2，那么就是有2个，cursor_child_no就是0,1两个值
-LOADED_VERSIONS 一共加载的数量，就是对应v$sql里的条数
-VERSION_COUNT  历史总子游标的数量

2@查看plan_hash_value --其实就是用的最新的一条的执行计划
SELECT t."SQL_ID",t."CHILD_NUMBER",t."PLAN_HASH_VALUE",t."LAST_ACTIVE_TIME" FROM v$sql t WHERE t."SQL_ID"='&sql_id' order by t."LAST_ACTIVE_TIME" desc;

3@查看对应child_number CHILD_NUMBER=
select * from table(dbms_xplan.display_cursor(sql_id => '&sql_id',cursor_child_no => '&CHILD_NUMBER',format => 'advanced'));


--处理方法
1、当遇到很多个子游标的时候，可以先看v$sqlarea中的执行计划，确定执行的计划。
2、若有很多，可以查看下，执行计划是否是都是相同的，若有不同，可能需要多次执行，看下，执行计划是否一致。
3、可以使用trace的方法跟踪，也可以获取详细的执行计划。
4、若第一次执行很快，第二次执行很慢，那么就要考虑是否是基数反馈引起的。
5、关掉基数反馈，查看执行计划。

--关闭动态采样（默认开启，不建议关闭）
alter session set optimizer_dynamic_sampling=0;

--阶段查看SQL的执行次数
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

--查看SQL的物理读与逻辑读
set autotrace traceonly

24 consistent gets
9 physical reads --物理读越少越好
