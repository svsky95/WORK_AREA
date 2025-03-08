--查询隐藏参数
set linesize 333
col name for a35
col description for a66
col value for a30
SELECT   i.ksppinm name,  
   i.ksppdesc description,  
   CV.ksppstvl VALUE
FROM   sys.x$ksppi i, sys.x$ksppcv CV  
   WHERE   i.inst_id = USERENV ('Instance')  
   AND CV.inst_id = USERENV ('Instance')  
   AND i.indx = CV.indx  
   AND i.ksppinm LIKE '%&param%' 
ORDER BY   REPLACE (i.ksppinm, '_', '');  

--SGA 各组件实际大小
set linesize 100
col name for a25
col value for a15
col describ for a40
select x.ksppinm name,y.ksppstvl value,x.ksppdesc describ
from sys.x$ksppi x,sys.x$ksppcv y
where x.inst_id=userenv('instance')
and y.inst_id=userenv('instance')
and x.indx=y.indx
and x.ksppinm like '%&par%';

--tail_alert
select '!tail -100f ' || (SELECT VALUE FROM V$PARAMETER WHERE NAME='background_dump_dest')||
 '/alert_'||(SELECT VALUE FROM V$PARAMETER WHERE NAME='instance_name')||'.log' c FROM DUAL;

--time_format
alter session set NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
alter session set NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

--dbtime
set linesize 200 ;
set pagesize 20000 ;
col DATE_TIME  for a45 ;
col STAT_NAME  for a10 ;
WITH sysstat AS
 (SELECT sn.begin_interval_time begin_interval_time,
         sn.end_interval_time end_interval_time,
         ss.stat_name stat_name,
         ss. VALUE e_value,
         lag(ss. VALUE, 1) over(ORDER BY ss.snap_id) b_value
    FROM DBA_HIST_SYS_TIME_MODEL ss, dba_hist_snapshot sn
   WHERE trunc(sn.begin_interval_time) >= sysdate - 7
     AND ss.snap_id = sn.snap_id
     AND ss.dbid = sn.dbid
     AND ss.instance_number = sn.instance_number
     AND ss.dbid = (SELECT dbid FROM v$database)
     AND ss.instance_number = (SELECT instance_number FROM v$instance)
     AND ss.stat_name = 'DB time')
SELECT to_char(BEGIN_INTERVAL_TIME, 'yyyy-mm-dd hh24:mi') ||
       to_char(END_INTERVAL_TIME, ' hh24:mi') date_time,
       stat_name,
       round((e_value - nvl(b_value, 0)) / 60 / 1000 / 1000, 2) dbtime_value
  FROM sysstat
 WHERE (e_value - nvl(b_value, 0)) > 0
   AND nvl(b_value, 0) > 0;

--tablespace
set lines 400 pages 999
select TABLESPACE_NAME,
       (TABLESPACE_SIZE - USED_SPACE) * 8 / 1024 / 1024 free_space,
       USED_SPACE * 8 / 1024 / 1024 USED_SPACE,
       TABLESPACE_SIZE * 8 / 1024 / 1024 TABLESPACE_SIZE,
       USED_PERCENT
  from DBA_TABLESPACE_USAGE_METRICS
 order by 5;
 
--datafiles
col file_name for a50
select file_id, file_name, bytes / 1024 / 1024 / 1024, AUTOEXTENSIBLE
  from dba_data_files
 where tablespace_name = '&TBS_NAME'
 order by 1, 2;
 
--db_file_size(GB)
select sum(bytes / 1024 / 1024 / 1024) "GB" from dba_data_files;

--session_roles
select * from session_roles;

--session_privs
select * from session_privs;
1.operation
--event
set pages 900
col event for a30
select inst_id, event, count(*)
  from gv$session
 where wait_class# <> 6
 group by inst_id, event
 order by 3 desc;
  
--event2
set line 234 pagesize 9999
col event for a35
col machine for a20
select sid,
       SERIAL#,
       inst_id,
       sql_id,
       event,
       MACHINE,
       username,
       blocking_session,
       count(*)
  from gv$session
 where wait_class <> 'Idle'
 group by sid,
          SERIAL#,
          inst_id,
          sql_id,
          event,
          MACHINE,
          username,
          blocking_session
 order by 1, 4;
 
--blocking
set lines 180
col program for a30
col machine for a20
select inst_id,
       SID,
       SERIAL#,
       USERNAME,
       program,
       machine,
       sql_id,
       blocking_session,
       blocking_instance
  from gv$session
 where blocking_session is not null;
  
--blocking2
select inst_id,
       SID,
       SERIAL#,
       USERNAME,
       program,
       machine,
       sql_id,
       blocking_instance,
       blocking_session
  from gv$session
 where sid = &sid;
  
--数据库活动会话监控：
 select inst_id,
        sid,
        username,
        machine,
        program,
        module,
        action,
        sql_id,
        event,
        blocking_session,
        logon_time,
        prev_exec_start,
        client_info
   from gv$session
  where status = 'ACTIVE'
    and type <> 'BACKGROUND'
  order by inst_id, sid;

--
select sess.sid,
       sess.serial#,
       lo.oracle_username,
       lo.os_user_name,
       ao.object_name,
       lo.locked_mode,
       sess.STATUS,
       sess.LOGON_TIME,
       'alter system kill session ' || '''' || sess.sid || ',' ||
       sess.serial# || ''';',
       sess.LAST_CALL_ET
  from v$locked_object lo, dba_objects ao, v$session sess
 where ao.object_id = lo.object_id
   and lo.session_id = sess.sid
   and sess.STATUS = 'ACTIVE'
   and sess.LAST_CALL_ET > 20;

--cascade blocking
select *
  from (select a.sid,
               a.sql_id,
               a.event,
               a.status,
               connect_by_isleaf as isleaf,
               sys_connect_by_path(SID, '<-') tree,
               level as tree_level
          from v$session a
         start with a.blocking_session is not null
                and event like 'library cache lock'
        connect by nocycle a.sid = prior a.blocking_session)
 where isleaf = 1
 order by tree_level asc;

--cascade blocking@gv$session
select *
  from (select a.inst_id, a.sid, a.serial#,
               a.sql_id,
               a.event,
               a.status,
               connect_by_isleaf as isleaf,
               sys_connect_by_path(a.SID||'@'||a.inst_id, ' <- ') tree,
               level as tree_level
          from gv$session a
         start with a.blocking_session is not null
        connect by (a.sid||'@'||a.inst_id) = prior (a.blocking_session||'@'||a.blocking_instance))
 where isleaf = 1
 order by tree_level asc;

--sql_id
select sql_id, count(*)
  from v$session
 where event = '&event'
 group by sql_id
 order by 2;

--sql_fulltext
select sql_fulltext from v$sqlarea where sql_id = '&sql_id';

--long session
set lines 800 pages 900 long 9999
col inst_id for 9
col username for a15
col machine for a15
col program for a31
col sid for 99999
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select *
  from (select inst_id,
               username,
               sql_id,
               last_call_et / 60,
               logon_time,
               machine,
               program,
               sid
          from gv$session
         where sql_id is not null
           and status = 'ACTIVE'
           and user# <> 0
         order by 4 desc)
 where rownum < 21;

--long sql
select *
  from (select s.inst_id,
               s.sid,
               s.username,
               s.sql_id,
               s.last_call_et / 60,
               q.sql_fulltext
          from gv$session s, v$sqlarea q
         where s.sql_id is not null
           and s.user# <> 0
           and s.status = 'ACTIVE'
           and s.sql_id = q.sql_id
         order by 5 desc)
 where rownum < 11;

--long operation
col opname for a20
col target for a30
col username for a15
set lines 500 pages 900
select inst_id,
       sid,
       username,
       opname,
       target,
       sofar,
       totalwork,
       sofar * 100 / totalwork
  from gv$session_longops
 where sofar < totalwork;

--kill session
alter system kill session '&sid,&serial' immediate;

--rollback force
select 'rollback force  ''' || local_tran_id || ''';',
       local_tran_id,
       state,
       fail_time,
       force_time
  from DBA_2PC_PENDING
 where state = 'prepared';

--machine,program
select machine, program, count(*) from v$session group by machine, program order by 3;
2.backup&recovery
--find an object using file_id & block_id
SELECT OWNER, 
       SEGMENT_NAME, 
       SEGMENT_TYPE, 
       TABLESPACE_NAME 
FROM   DBA_EXTENTS 
WHERE  FILE_ID =&FILE_ID
       AND &BLOCK_ID BETWEEN BLOCK_ID AND BLOCK_ID + BLOCKS - 1;

--checkpoint_change#
col checkpoint_change# for 9999999999999999
select checkpoint_change# from v$database;
select checkpoint_change# from v$datafile;
select checkpoint_change# from v$datafile_header;

--v$archived_log
select thread#, dest_id, max(sequence#)
  from v$archived_log
 where applied = 'YES'
 group by thread#, dest_id;

--arch_per_day
select trunc(completion_time) as "Date",
       count(*) as "Count",
       sum(blocks * block_size) / 1024 / 1024 as "MB"
  from v$archived_log
 where dest_id = 1
 group by trunc(completion_time)
 order by 1;

--v$log
select * from v$log order by 3, 2, 1;
3.Tuning
--CPU in 10m
--查询最近10分钟，最消耗CPU资源的SQL语句
set line 234
col sql_text for a70
select sql_id, cnt, pctload, substr(sql_text, 1, 70) sql_text
  from (select ash.sql_id,
               count(*) cnt,
               max(s.sql_text) sql_text,
               max(s.parsing_schema_name) parsing_schema_name,
               round(count(*) / sum(count(*)) over(), 2) pctload
          from v$active_session_history ash, v$sqlarea s
         where ash.sql_id = s.sql_id
           and sample_time > sysdate - 10 / (24 * 60)
           and session_type <> 'BACKGROUND'
           and session_state = 'ON CPU'
         group by ash.sql_id
         order by count(*) desc)
 where rownum <= 20;

--IO in 30m
--查询最近30分钟，最消耗IO资源的会话
set line 234
col sql_text for a70
select session_id, cnt, substr(sql_text, 1, 70) sql_text
  from (select ash.session_id,
               count(*) cnt,
               max(s.sql_text) sql_text,
               max(s.parsing_schema_name) parsing_schema_name,
               round(count(*) / sum(count(*)) over(), 2) pctload
          from v$active_session_history ash, v$sqlarea s
         where ash.sql_id = s.sql_id(+)
           and sample_time > sysdate - 30 / (24 * 60)
           and session_type <> 'BACKGROUND'
           and session_state = 'WAITING'
           and wait_class = 'User I/O'
         group by ash.session_id
         order by count(*) desc)
 where rownum <= 20;

--TOPSQL by IO
--根据io消耗前十sql的会话id，查出操作系统号并组合杀进程语句
set line 234
col sql_text for a70
select session_id, session_serial#, cnt, substr(sql_text, 1, 70) sql_text
  from (select ash.session_id,
               ash.session_serial#,
               count(*) cnt,
               max(s.sql_text) sql_text,
               max(s.parsing_schema_name) parsing_schema_name,
               round(count(*) / sum(count(*)) over(), 2) pctload
          from v$active_session_history ash, v$sqlarea s
         where ash.sql_id = s.sql_id(+)
           and sample_time > sysdate - 5 / (24 * 60)
           and session_type <> 'BACKGROUND'
           and session_state = 'WAITING'
           and wait_class = 'User I/O'
         group by ash.session_id, ash.session_serial#
         order by count(*) desc)
 where rownum <= 10;

--TOP by ospid
select s.sid, s.program, s.MODULE, s.action, s.event, sq.sql_text
  from v$process p, v$session s, v$sqlarea sq
 where p.addr = s.paddr
   and s.sql_id = sq.sql_id(+)
   and p.spid = '&ospid';
4.RAC
--TFA收集最近5h的日志
tfactl diagcollect –all –since 5h

--crsctl stat res -t
crsctl stat res -t

--crsctl stat res -t -init
crsctl stat res -t -init

--disktimeout
crsctl get css disktimeout

--misscount
crsctl get css misscount

--votedisk
crsctl query css votedisk

--ocrcheck
ocrcheck

--crs_stat
crs_stat -t -v
5.DG
--gv$database
SELECT inst_id,
       name,
       open_mode,
       database_role,
       switchover_status,
       force_logging,
       dataguard_broker,
       guard_status
  FROM gv$database;
  
--v$dataguard_stats
set lines 1000
select * from v$dataguard_stats;

--check_dg
select app.thread#,
       app.max_applied_seq,
       arc.max_seq,
       arc.max_seq - app.max_applied_seq gap
  from (select thread#, max(sequence#) max_applied_seq
          from v$archived_log
         where applied = 'YES'
         group by thread#) app,
       (select thread#, max(sequence#) max_seq
          from v$archived_log
         where 1 = 1
         group by thread#) arc
 where app.thread# = arc.thread#;

--current_scn
select current_scn || '' from v$database;

--archivelog
select thread#, sequence#, applied
  from v$archived_log
 where applied <> 'YES'
 order by 1, 2;
 
--cancel apply
alter database recover managed standby database cancel;

--switch_log
alter system switch logfile;

--v$archive_dest
select error from v$archive_dest where dest_id=&dest_id;

--switch_phy
alter database commit to switchover to physical standby with session shutdown;

--switch_pri
alter database commit to switchover to primary with session shutdown;

--recover_std
alter database recover managed standby database disconnect from session;

--recover_std_real
alter database recover managed standby database using current logfile disconnect from session;

--message
select message from v$dataguard_status;
6.ASM
--v$asm_diskgroup
select group_number,
       name,
       total_mb,
       free_mb,
       USABLE_FILE_MB,
       offline_disks,
       state,
       type
  from v$asm_diskgroup;

--v$asm_diskgroup_2
select group_number,
       name,
       TYPE,
       total_mb / 1024 TOTAL_GB,
       free_mb / 1024 FREE_GB,
       free_mb / total_mb * 100 free_percent,
       state
  from v$ASM_DISKGROUP;

--v$asm_disk
col path for a50
select group_number, disk_number, name, path, failgroup, mode_status, voting_file
  from v$asm_disk
 order by 1, 2;
7.OGG
--ggsci
./ggsci
8.Report
--create snapshot
exec DBMS_WORKLOAD_REPOSITORY.create_snapshot();

--AWR
@?/rdbms/admin/awrrpt

--ASH
@?/rdbms/admin/ashrpt

--SQRPT
@?/rdbms/admin/awrsqrpt

--ADDM
@?/rdbms/admin/addmrpt

--awrddrpt
@?/rdbms/admin/awrddrpt

--awrgrpt
@?/rdbms/admin/awrgrpt

--awrextr
@?/rdbms/admin/awrextr

--awrload
@?/rdbms/admin/awrload
9.Trace
--10046
alter session set events '10046 trace name context forever, level 12';

--10046 off
alter session set events '10046 trace name context off';

--10046_2
exec dbms_monitor.session_trace_enable(&sid,&serial,waits=>true,binds=>true);

--10046_2 off
exec dbms_monitor.session_trace_disable(&sid,&serial);

--10046 trace
SELECT d.VALUE || '/' || LOWER(RTRIM(i.INSTANCE, CHR(0))) || '_ora_' ||
       p.spid || '.trc' AS "trace_file_name"
  FROM (SELECT p.spid
          FROM v$mystat m, v$session s, v$process p
         WHERE m.statistic# = 1
           AND s.SID = m.SID
           AND p.addr = s.paddr) p,
       (SELECT t.INSTANCE
          FROM v$thread t, v$parameter v
         WHERE v.NAME = 'thread'
           AND (v.VALUE = 0 OR t.thread# = TO_NUMBER(v.VALUE))) i,
       (SELECT VALUE FROM v$parameter WHERE NAME = 'user_dump_dest') d;

--tkprof

--oradebug
oradebug dump ashdumpseconds 30

--hanganalyze
单实例
sqlplus / as sysdba
oradebug setmypid
oradebug unlimit
oradebug hanganalyze 3
--wait about 1 min..
oradebug hanganalyze 3

多实例RAC 
sqlplus / as sysdba
oradebug setmypid
oradebug unlimit
oradebug setinst all
oradebug -g all hanganalyze 3
--wait about 1 min..
oradebug -g all hanganalyze 3

--systemstate
主要有l不同级别的，258 266 267 10

单实例
sqlplus / as sysdba
oradebug setmypid
oradebug unlimit
oradebug dump systemstate 266
--wait about 1 min..
oradebug dump systemstate 266
oradebug tracefile_name


多实例RAC
sqlplus / as sysdba
oradebug setorapname reco
oradebug unlimit
oradebug -g all dump systemstate 266
--wait about 1 min..
oradebug -g all dump systemstate 266
oradebug tracefile_name

10.kill
--kill session
alter system kill session '&sid,&serial' immediate;

--os_kill_by_sid
select 'kill -9 ' || p.spid
  from v$process p, v$session s
 where p.addr = s.paddr
   and s.sid = &sid
   and s.serial# = &serial;
 
--os_kill_by_sqlid
select 'kill -9 ' || p.spid
  from v$process p, v$session s
 where p.addr = s.paddr
   and s.sql_id = '&sql_id';

--kill_all_session
select 'alter system disconnect session '''||sid||','||serial#||''''||' immediate;' from v$session where username = '&username';
11.RMAN
--conn
rman target /

--show all
show all;

--report need backup
report need backup;

--del_arch
delete archivelog all completed before 'sysdate-1/12';

--rman_longops
SELECT SID, SERIAL#, CONTEXT, SOFAR, TOTALWORK, ROUND(SOFAR/TOTALWORK*100,2) "COMPLETE_%"
  FROM GV$SESSION_LONGOPS
 WHERE OPNAME LIKE 'RMAN%' AND OPNAME NOT LIKE '%aggregate%' AND TOTALWORK != 0 AND SOFAR <> TOTALWORK;

--v$rman_backup_job_details
select SESSION_KEY, SESSION_RECID, SESSION_STAMP, START_TIME, END_TIME, STATUS, ELAPSED_SECONDS from V$RMAN_BACKUP_JOB_DETAILS;

--v$rman_output
select output from V$RMAN_OUTPUT where SESSION_KEY=&SESSION_KEY and SESSION_RECID=&SESSION_RECID and SESSION_STAMP=&SESSION_STAMP;

--redo
SELECT TO_CHAR(first_time,'MM/DD') DAY, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'00',1,0)) H00
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'01',1,0)) H01
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'02',1,0)) H02
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'03',1,0)) H03
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'04',1,0)) H04
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'05',1,0)) H05
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'06',1,0)) H06
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'07',1,0)) H07
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'08',1,0)) H08
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'09',1,0)) H09
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'10',1,0)) H10
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'11',1,0)) H11
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'12',1,0)) H12
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'13',1,0)) H13
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'14',1,0)) H14
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'15',1,0)) H15
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'16',1,0)) H16
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'17',1,0)) H17
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'18',1,0)) H18
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'19',1,0)) H19
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'20',1,0)) H20
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'21',1,0)) H21
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'22',1,0)) H22
, SUM(DECODE(TO_CHAR(first_time, 'HH24'),'23',1,0)) H23
, COUNT(*)||'('||trim(to_char(sum(blocks*block_size)/1024/1024,'99,999.9'))||'M)' TOTAL 
FROM (select max(blocks) blocks,max(block_size) block_size,max(first_time) first_time from v$archived_log a where COMPLETION_TIME > sysdate - &day and dest_id = 1 group by sequence#)
group by TO_CHAR(first_time,'MM/DD'), TO_CHAR(first_time,'YYYY/MM/DD')
order by TO_CHAR(first_time,'YYYY/MM/DD') desc;
12.xplan
--temp_sql_id
temp_sql_id

--sql_hist_plan
set linesize 1000 pagesize 999
col BEGIN_INTERVAL_TIME for a25
col END_INTERVAL_TIME for a25
col instance_number for 99
select a.snap_id,
       a.sql_id,
       a.instance_number,
       b.BEGIN_INTERVAL_TIME,
       b.END_INTERVAL_TIME,
       a.EXECUTIONS_TOTAL,
       a.EXECUTIONS_DELTA,
       a.plan_hash_value,
       a.CPU_TIME_DELTA
  from wrh$_sqlstat a, wrm$_snapshot b
 where a.snap_id = b.snap_id
   and a.instance_number = b.instance_number
   and a.sql_id = '&sql_id'
 order by 4, 1, 3;

--current_schema
alter session set current_schema = &schema;

--explain plan for
set linesize 1000 pagesize 999
explain plan for
SQL Text;

--SQL Text
SQL_TEXT

--display
select * from table(dbms_xplan.display);

--display_cursor
select * from table(dbms_xplan.display_cursor(null,null,'advanced'));

--display_awr
select * from table(dbms_xplan.display_awr('&sqlid'));

--awrsqrpt
@?/rdbms/admin/awrsqrpt

--bind_value
select dbms_sqltune.extract_bind(bind_data, 1).value_string||'-'|| dbms_sqltune.extract_bind(bind_data, 2).value_string ||'-'|| dbms_sqltune.extract_bind(bind_data, 3)
        .value_string ||'-'|| dbms_sqltune.extract_bind(bind_data, 4).value_string ||'-'|| dbms_sqltune.extract_bind(bind_data, 5)
        .value_string ||'-'|| dbms_sqltune.extract_bind(bind_data, 6).value_string
   from wrh$_sqlstat
  where sql_id = '&sql_id';