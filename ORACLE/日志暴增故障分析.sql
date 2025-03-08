--日志暴增故障分析
脚本如下：
--1、redo大量产生必然是由于大量产生"块改变"。从awr视图中找出"块改变"最多的segments。
select * from (
SELECT to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI') snap_time,
       dhsso.object_name,
       SUM(db_block_changes_delta)
  FROM dba_hist_seg_stat     dhss,
       dba_hist_seg_stat_obj dhsso,
       dba_hist_snapshot     dhs
 WHERE dhs.snap_id = dhss. snap_id
   AND dhs.instance_number = dhss. instance_number
   AND dhss.obj# = dhsso. obj#
   AND dhss.dataobj# = dhsso.dataobj#
   AND begin_interval_time> sysdate - 60/1440      --查找一天之内，  sysdate -10  查找10天之内            
 GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'),
          dhsso.object_name
 order by 3 desc)
 where rownum<=5;

--------------------------------------------------------------------------------------------

--2、从awr视图中找出步骤1中排序靠前的对象涉及到的SQL。
SELECT to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'),
       dbms_lob.substr(sql_text, 4000, 1),
       dhss.instance_number,
       dhss.sql_id,
       executions_delta,
       rows_processed_delta
  FROM dba_hist_sqlstat dhss, dba_hist_snapshot dhs, dba_hist_sqltext dhst
 WHERE UPPER(dhst.sql_text) LIKE '%这里写对象名大写%'
   AND dhss.snap_id = dhs.snap_id
   AND dhss.instance_Number = dhs.instance_number
   AND dhss.sql_id = dhst.sql_id;

--------------------------------------------------------------------------------------------

--3、从ASH相关视图中找出执行这些SQL的session、module和machine。
select * from dba_hist_active_sess_history WHERE sql_id = '';
select * from v$active_session_history where sql_Id = '';

--------------------------------------------------------------------------------------------

--4. dba_source 看看是否有存储过程包含这个SQL

--以下操作产生大量的redo,可以用上述的方法跟踪它们。
drop table   test_redo  purge;
create table test_redo as select * from dba_objects;
insert into  test_redo select * from test_redo;
insert into  test_redo select * from test_redo;
insert into  test_redo select * from test_redo;
insert into  test_redo select * from test_redo;
insert into  test_redo select * from test_redo;
exec dbms_workload_repository.create_snapshot();

--------------------------------------------------------------------------------------------

解决过程
--执行了大量的针对test_redo表的INSERT操作后，我们开始按如下方法进行跟踪，看能否发现更新的是哪张表，是哪些语句。
select * from (
SELECT to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI') snap_time,dhsso.object_name,SUM(db_block_changes_delta)
  FROM dba_hist_seg_stat dhss,dba_hist_seg_stat_obj dhsso,dba_hist_snapshot  dhs
 WHERE dhs.snap_id = dhss. snap_id
   AND dhs.instance_number = dhss. instance_number AND dhss.obj# = dhsso. obj# AND dhss.dataobj# = dhsso.dataobj#
   AND begin_interval_time> sysdate - 60/1440
 GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'), dhsso.object_name order by 3 desc) 
  where rownum<=3;

SELECT to_char(begin_interval_time,'YYYY_MM_DD HH24:MI'),dbms_lob.substr(sql_text,4000,1),dhss.sql_id,executions_delta,rows_processed_delta
  FROM dba_hist_sqlstat dhss, dba_hist_snapshot dhs, dba_hist_sqltext dhst
 WHERE UPPER(dhst.sql_text) LIKE '%TEST_REDO%' AND dhss.snap_id = dhs.snap_id 
  AND dhss.instance_Number = dhs.instance_number AND dhss.sql_id = dhst.sql_id;