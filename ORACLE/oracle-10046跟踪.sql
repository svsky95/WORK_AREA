##10046跟踪
--跟踪级别
1--启用标准的SQL_TRACE功能，等价于sql_trace
4--level 1 + 绑定值（bind values) [ bind=true ]）
8--level 1 + 等待事件跟踪[ wait=true ]
12-- level 1 + level 4 +level 8
16 -- 为每次的SQL执行生成stat信息的输出 [ plan_stat=all_executions ]
32 -- 不转储执行统计信息 [ plan_stat=never ]
64 -- 自适应的STAT转储 [ plan_stat=adaptive ]


set linesize 266
set timing on
set pagesize 5000
alter session set events = '10046 trace name context  forever,level 12';    --开启跟踪
---此处执行你的存储过程、包、sql语句等。
select d.value
|| '/'
|| LOWER (RTRIM(i.INSTANCE, CHR(0)))
|| '_ora_'
|| p.spid
|| '.trc' trace_file_name
from (select p.spid
from v$mystat m,v$session s, v$process p
where  m.statistic#=1 and s.sid=m.sid and p.addr=s.paddr) p,
(select t.INSTANCE
FROM v$thread t,v$parameter v
WHERE v.name='thread'
AND(v.VALUE=0 OR t.thread#=to_number(v.value))) i,
(select value
from v$parameter
where name='user_dump_dest') d;

alter session set events '10046 trace name context  off';   --关闭跟踪

-查看跟踪文件位置
select value TRACE_FILE from v$diag_info where name='Default Trace File';

-文件格式转换 oracle用户执行
tkprof /u01/app/oracle/diag/rdbms/dg1/DG1/trace/DG1_arc2_2780.trc ./res_10046.txt sys=no sort=prsela,exeela,fchela

##SID跟踪
1@获取SID
select sid,serial#,username from v$session where username is not null;
SID SERIAL# USERNAME
---------- ---------- ------------------------------
7   284 IFLOW
11  214 IFLOW
12  164 SYS
16  1042 IFLOW

2@启用跟踪
SQL> exec dbms_system.set_SQL_trace_in_session(7,284,true)

3@跟踪一段时间后，关闭跟踪
SQL> exec dbms_system.set_SQL_trace_in_session(7,284,false)
SQL> exec dbms_system.set_SQL_trace_in_session(11,214,false)
SQL> exec dbms_system.set_SQL_trace_in_session(16,1042,false)

3@查看生成文件
select value TRACE_FILE from v$diag_info where name='Default Trace File';



SQL> select status from v$instance;

STATUS
------------
MOUNTED

SQL> oradebug setmypid;
Statement processed.
SQL> oradebug event 10046 trace name context forever,level 12;
Statement processed.
SQL> alter database open;
SQL> oradebug event 10046 trace name context  off; 
SQL> oradebug tracefile_name;
/u01/app/oracle/diag/rdbms/racdb/racdb1/trace/racdb1_ora_11248.trc

##SQL跟踪(实际不执行SQL语句)##
1、查看当前的进程号SPID
SQL> select spid,s.sid,s.serial#,p.username,p.program from v$process p,v$session s where p.addr = s.paddr and s.sid = (select sid from v$mystat where rownum = 1);

SPID                            SID    SERIAL# USERNAME        PROGRAM
------------------------ ---------- ---------- --------------- ------------------------------------------------
2267                            265      17428 oracle          oracle@racnode1 (TNS V1-V3)

2、开启会话的sql_trace
alter session set sql_trace true;
--输入需要跟踪的语句
select * from dba_users;
alter session set sql_trace false;

3、查看生成的跟踪文件
跟踪文件是以instance_name_ora_spid组成的，可以从两个地方查看：
select * from v$diag_info;
Diag Trace           /u01/app/oracle/diag/rdbms/oradb/oradb1/trace
Default Trace File   /u01/app/oracle/diag/rdbms/oradb/oradb1/trace/oradb1_ora_2267.trc

4、格式化跟踪文件
SQL> !tkprof /u01/app/oracle/diag/rdbms/oradb/oradb1/trace/oradb1_ora_2267.trc 2267_trace.sql

##autotrace(实际执行SQL语句)##
显示物理和逻辑读
set autotrace on(显示所有) |  set autotrace traceonly
--sql语句
set autotrace off



