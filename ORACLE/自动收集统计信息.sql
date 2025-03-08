SELECT * FROM sys.mon_mods_all$;

SELECT * FROM dba_objects t WHERE t.OBJECT_ID='100116';

--自动收集统计信息任务查询
SELECT * FROM dba_autotask_task;

--自动收集统计信息收集窗口
SELECT * FROM dba_autotask_window_clients;

--查看每天收集任务的详细信息
SELECT * FROM dba_scheduler_windows;

--查看任务的执行状态
SELECT * FROM dba_scheduler_job_run_details t WHERE t.JOB_NAME like 'ORA$AT_OS_OPT%' order by t.ACTUAL_START_DATE desc;
SELECT * FROM ( SELECT * FROM dba_autotask_job_history t WHERE t.CLIENT_NAME='auto optimizer stats collection' order by t.WINDOW_START_TIME desc) where rownum<=5;

--自动收集表统计信息的标准
--sys.mon_mods_all 表中会记录自上次统计信息收集作业完成后，对所有表的dml及truncate操作的记录数近似值,当统计信息收集后，记录机会被清空、
--收集统计信息的标准，是delete+insert+update 的数量总和大于TAB$,或者此表被truncate
SELECT * FROM sys.mon_mods_all$; /*flags：1-有truncate    0-没有truncate

--若要修改每天执行的时间，请参考“基于oracle的SQL优化|自动统计信息收集”



