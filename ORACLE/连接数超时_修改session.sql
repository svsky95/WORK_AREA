1、在应用主机上ping数据库主机查看是否有延迟，并用traceroute查看中间的网络连接情况
[root@slave04 ~]# traceroute 10.10.8.94
traceroute to 10.10.8.94 (10.10.8.94), 30 hops max, 60 byte packets
 1  10.10.8.94 (10.10.8.94)  0.167 ms  0.163 ms  0.130 ms
[root@slave04 ~]# ping 10.10.8.94
PING 10.10.8.94 (10.10.8.94) 56(84) bytes of data.
64 bytes from 10.10.8.94: icmp_seq=1 ttl=64 time=0.158 ms
64 bytes from 10.10.8.94: icmp_seq=2 ttl=64 time=0.136 ms
64 bytes from 10.10.8.94: icmp_seq=3 ttl=64 time=0.123 ms
64 bytes from 10.10.8.94: icmp_seq=4 ttl=64 time=0.135 ms
64 bytes from 10.10.8.94: icmp_seq=5 ttl=64 time=0.135 ms

2、分析数据库主机上的日志
--告警日志
show parameter background_dump_dest;
--首先查看最大进程数
SQL> show parameter processes;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
aq_tm_processes                      integer     1
db_writer_processes                  integer     5
gcs_server_processes                 integer     0
global_txn_processes                 integer     1
job_queue_processes                  integer     1000
log_archive_max_processes            integer     4
processes                            integer     3000

--查看最大连接数
SQL> show parameter session;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
java_max_sessionspace_size           integer     0
java_soft_sessionspace_limit         integer     0
license_max_sessions                 integer     0
license_sessions_warning             integer     0
session_cached_cursors               integer     50
session_max_open_files               integer     10
sessions                             integer     4560
shared_server_sessions               integer

--修改
修改processes和sessions值

　　SQL> alter system set processes=300 scope=spfile;

　　系统已更改。

　　SQL> alter system set sessions=335 scope=spfile;

　　系统已更改。

　　3. 修改processes和sessions值必须重启oracle服务器才能生效

　　ORACLE的连接数(sessions)与其参数文件中的进程数(process)有关，它们的关系如下：

　　sessions=(1.1*process+5)

--RAC环境
SQL> alter system set processes=1000 scope=spfile sid='*';

System altered.

SQL> alter system set sessions=1150 scope=spfile sid='*';

--由于连接数较大，可能导致sqlplus 在本地上也无法登录，所以需要先杀掉远程了解过来的进程。
netstat -an| grep 1521
ps x|grep oraclesxfxdb  |grep -v grep |awk '{print $1}'| xargs kill -9

--查看当前的连接数及进程数
查询数据库当前进程的连接数：

　　select count(*) from v$process;

　　查看数据库当前会话的连接数：

　　select count(*) from v$session;

　　查看数据库的并发连接数：

　　select count(*) from v$session where status='ACTIVE';

　　查看当前数据库建立的会话情况：

　　select sid,serial#,username,program,machine,status from v$session;
    查看当前用户的使用数据情况
    select osuser,a.username,cpu_time/executions/1000000||'s',sql_fulltext,machine from v$session a,v$sqlarea b where a.sql_address = b.address order by cpu_time/executions desc;

--告警日志：
/home/oracle/app/diag/rdbms/nfzcdb/nfzcdb/trace

Fatal NI connect error 12170.

  VERSION INFORMATION:
        TNS for Linux: Version 11.2.0.4.0 - Production
        Oracle Bequeath NT Protocol Adapter for Linux: Version 11.2.0.4.0 - Production
        TCP/IP NT Protocol Adapter for Linux: Version 11.2.0.4.0 - Production
  Time: 28-JUN-2017 22:58:40
  Tracing not turned on.
  Tns error struct:
    ns main err code: 12535
    
TNS-12535: TNS:operation timed out
    ns secondary err code: 12606
    nt main err code: 0
    nt secondary err code: 0
    nt OS err code: 0
  Client address: (ADDRESS=(PROTOCOL=tcp)(HOST=10.10.8.98)(PORT=35959))
WARNING: inbound connection timed out (ORA-3136)
Wed Jun 28 22:58:40 2017

--监听日志
Listener Log File         /home/oracle/app/diag/tnslsnr/127/listener/alert/log.xml
</msg>
<msg time='2017-06-28T17:58:01.913+08:00' org_id='oracle' comp_id='tnslsnr'
 type='UNKNOWN' level='16' host_id='127.0.0.1'
 host_addr='127.0.0.1'>
 <txt>28-JUN-2017 17:58:01 * (CONNECT_DATA=(CID=(PROGRAM=)(HOST=__jdbc__)(USER=etlusr))(SERVICE_NAME=nfzcdb)(CID=(PROGRAM=)(HOST=__jdbc__)(USER=etlusr))) * (
ADDRESS=(PROTOCOL=tcp)(HOST=10.10.8.98)(PORT=33823)) * establish * nfzcdb * 0
 </txt>
</msg>

--------------------------处理方法------------------------------
sqlnet.ora 配置到admin目录下   --若都不限制可以改为0
sqlnet.inbound_connect_timeout =300

配置listener.ora 
inbound_connect_timeout_LISTENER=290
--验证是否生效
LSNRCTL> show inbound_connect_timeout
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.10.8.94)(PORT=1521)))
LISTENER parameter "inbound_connect_timeout" set to 290
The command completed successfully






