--计划任务-自动统计信息收集
--1、查看自动收集统计信息的任务及状态：
select client_name,status from dba_autotask_client;
--禁用统计信息收集
exec DBMS_AUTO_TASK_ADMIN.DISABLE(client_name => 'auto optimizer stats collection',operation => NULL,window_name => NULL);
--启用统计信息收集
exec DBMS_AUTO_TASK_ADMIN.ENABLE(client_name => 'auto optimizer stats collection',operation => NULL,window_name => NULL);
--获得统计信息执行时间
select t1.window_name,t1.repeat_interval,t1.duration from dba_scheduler_windows t1,dba_scheduler_wingroup_members t2
 where t1.window_name=t2.window_name and t2.window_group_name in ('MAINTENANCE_WINDOW_GROUP','BSLN_MAINTAIN_STATS_SCHED');

CLIENT_NAME                                                      STATUS
---------------------------------------------------------------- --------
auto optimizer stats collection                                  ENABLED
auto space advisor                                               ENABLED
sql tuning advisor                                               ENABLED

--修改时间
1.停止任务：
SQL> BEGIN
   DBMS_SCHEDULER.DISABLE(
   name => '"SYS"."FRIDAY_WINDOW"',
   force => TRUE);
 END;
 /

PL/SQL 过程已成功完成。
2.修改任务的持续时间，单位是分钟：
SQL> BEGIN
   DBMS_SCHEDULER.SET_ATTRIBUTE(
   name => '"SYS"."FRIDAY_WINDOW"',
   attribute => 'DURATION',
   value => numtodsinterval(180,'minute'));
 END;  
 /

PL/SQL 过程已成功完成。
3.开始执行时间，BYHOUR=2，表示2点开始执行：
SQL> BEGIN
   DBMS_SCHEDULER.SET_ATTRIBUTE(
   name => '"SYS"."FRIDAY_WINDOW"',
   attribute => 'REPEAT_INTERVAL',
   value => 'FREQ=WEEKLY;BYDAY=MON;BYHOUR=2;BYMINUTE=0;BYSECOND=0');
 END;
 /

PL/SQL 过程已成功完成。
4.开启任务：
SQL> BEGIN
   DBMS_SCHEDULER.ENABLE(
   name => '"SYS"."FRIDAY_WINDOW"');
 END;
 /

PL/SQL 过程已成功完成。
5.查看修改后的情况：
SQL> select t1.window_name,t1.repeat_interval,t1.duration from dba_scheduler_windows t1,dba_scheduler_wingroup_members t2
 where t1.window_name=t2.window_name and t2.window_group_name in ('MAINTENANCE_WINDOW_GROUP','BSLN_MAINTAIN_STATS_SCHED');
 
WINDOW_NAME                    REPEAT_INTERVAL                                                                  DURATION
------------------------------ -------------------------------------------------------------------------------- -------------------------------------------------------------------------------
WEDNESDAY_WINDOW               freq=daily;byday=WED;byhour=22;byminute=0; bysecond=0                            +000 04:00:00
FRIDAY_WINDOW                  FREQ=WEEKLY;BYDAY=MON;BYHOUR=2;BYMINUTE=0;BYSECOND=0                             +000 03:00:00
SATURDAY_WINDOW                freq=daily;byday=SAT;byhour=6;byminute=0; bysecond=0                             +000 20:00:00
THURSDAY_WINDOW                freq=daily;byday=THU;byhour=22;byminute=0; bysecond=0                            +000 04:00:00
TUESDAY_WINDOW                 freq=daily;byday=TUE;byhour=22;byminute=0; bysecond=0                            +000 04:00:00
SUNDAY_WINDOW                  freq=daily;byday=SUN;byhour=6;byminute=0; bysecond=0                             +000 20:00:00
MONDAY_WINDOW                  freq=daily;byday=MON;byhour=22;byminute=0; bysecond=0                            +000 04:00:00
rows selected
