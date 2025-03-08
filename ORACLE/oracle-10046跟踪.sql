##10046����
--���ټ���
1--���ñ�׼��SQL_TRACE���ܣ��ȼ���sql_trace
4--level 1 + ��ֵ��bind values) [ bind=true ]��
8--level 1 + �ȴ��¼�����[ wait=true ]
12-- level 1 + level 4 +level 8
16 -- Ϊÿ�ε�SQLִ������stat��Ϣ����� [ plan_stat=all_executions ]
32 -- ��ת��ִ��ͳ����Ϣ [ plan_stat=never ]
64 -- ����Ӧ��STATת�� [ plan_stat=adaptive ]


set linesize 266
set timing on
set pagesize 5000
alter session set events = '10046 trace name context  forever,level 12';    --��������
---�˴�ִ����Ĵ洢���̡�����sql���ȡ�
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

alter session set events '10046 trace name context  off';   --�رո���

-�鿴�����ļ�λ��
select value TRACE_FILE from v$diag_info where name='Default Trace File';

-�ļ���ʽת�� oracle�û�ִ��
tkprof /u01/app/oracle/diag/rdbms/dg1/DG1/trace/DG1_arc2_2780.trc ./res_10046.txt sys=no sort=prsela,exeela,fchela

##SID����
1@��ȡSID
select sid,serial#,username from v$session where username is not null;
SID SERIAL# USERNAME
---------- ---------- ------------------------------
7   284 IFLOW
11  214 IFLOW
12  164 SYS
16  1042 IFLOW

2@���ø���
SQL> exec dbms_system.set_SQL_trace_in_session(7,284,true)

3@����һ��ʱ��󣬹رո���
SQL> exec dbms_system.set_SQL_trace_in_session(7,284,false)
SQL> exec dbms_system.set_SQL_trace_in_session(11,214,false)
SQL> exec dbms_system.set_SQL_trace_in_session(16,1042,false)

3@�鿴�����ļ�
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

##SQL����(ʵ�ʲ�ִ��SQL���)##
1���鿴��ǰ�Ľ��̺�SPID
SQL> select spid,s.sid,s.serial#,p.username,p.program from v$process p,v$session s where p.addr = s.paddr and s.sid = (select sid from v$mystat where rownum = 1);

SPID                            SID    SERIAL# USERNAME        PROGRAM
------------------------ ---------- ---------- --------------- ------------------------------------------------
2267                            265      17428 oracle          oracle@racnode1 (TNS V1-V3)

2�������Ự��sql_trace
alter session set sql_trace true;
--������Ҫ���ٵ����
select * from dba_users;
alter session set sql_trace false;

3���鿴���ɵĸ����ļ�
�����ļ�����instance_name_ora_spid��ɵģ����Դ������ط��鿴��
select * from v$diag_info;
Diag Trace           /u01/app/oracle/diag/rdbms/oradb/oradb1/trace
Default Trace File   /u01/app/oracle/diag/rdbms/oradb/oradb1/trace/oradb1_ora_2267.trc

4����ʽ�������ļ�
SQL> !tkprof /u01/app/oracle/diag/rdbms/oradb/oradb1/trace/oradb1_ora_2267.trc 2267_trace.sql

##autotrace(ʵ��ִ��SQL���)##
��ʾ������߼���
set autotrace on(��ʾ����) |  set autotrace traceonly
--sql���
set autotrace off



