1����Ӧ��������ping���ݿ������鿴�Ƿ����ӳ٣�����traceroute�鿴�м�������������
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

2���������ݿ������ϵ���־
--�澯��־
show parameter background_dump_dest;
--���Ȳ鿴��������
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

--�鿴���������
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

--�޸�
�޸�processes��sessionsֵ

����SQL> alter system set processes=300 scope=spfile;

����ϵͳ�Ѹ��ġ�

����SQL> alter system set sessions=335 scope=spfile;

����ϵͳ�Ѹ��ġ�

����3. �޸�processes��sessionsֵ��������oracle������������Ч

����ORACLE��������(sessions)��������ļ��еĽ�����(process)�йأ����ǵĹ�ϵ���£�

����sessions=(1.1*process+5)

--RAC����
SQL> alter system set processes=1000 scope=spfile sid='*';

System altered.

SQL> alter system set sessions=1150 scope=spfile sid='*';

--�����������ϴ󣬿��ܵ���sqlplus �ڱ�����Ҳ�޷���¼��������Ҫ��ɱ��Զ���˽�����Ľ��̡�
netstat -an| grep 1521
ps x|grep oraclesxfxdb  |grep -v grep |awk '{print $1}'| xargs kill -9

--�鿴��ǰ����������������
��ѯ���ݿ⵱ǰ���̵���������

����select count(*) from v$process;

�����鿴���ݿ⵱ǰ�Ự����������

����select count(*) from v$session;

�����鿴���ݿ�Ĳ�����������

����select count(*) from v$session where status='ACTIVE';

�����鿴��ǰ���ݿ⽨���ĻỰ�����

����select sid,serial#,username,program,machine,status from v$session;
    �鿴��ǰ�û���ʹ���������
    select osuser,a.username,cpu_time/executions/1000000||'s',sql_fulltext,machine from v$session a,v$sqlarea b where a.sql_address = b.address order by cpu_time/executions desc;

--�澯��־��
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

--������־
Listener Log File         /home/oracle/app/diag/tnslsnr/127/listener/alert/log.xml
</msg>
<msg time='2017-06-28T17:58:01.913+08:00' org_id='oracle' comp_id='tnslsnr'
 type='UNKNOWN' level='16' host_id='127.0.0.1'
 host_addr='127.0.0.1'>
 <txt>28-JUN-2017 17:58:01 * (CONNECT_DATA=(CID=(PROGRAM=)(HOST=__jdbc__)(USER=etlusr))(SERVICE_NAME=nfzcdb)(CID=(PROGRAM=)(HOST=__jdbc__)(USER=etlusr))) * (
ADDRESS=(PROTOCOL=tcp)(HOST=10.10.8.98)(PORT=33823)) * establish * nfzcdb * 0
 </txt>
</msg>

--------------------------������------------------------------
sqlnet.ora ���õ�adminĿ¼��   --���������ƿ��Ը�Ϊ0
sqlnet.inbound_connect_timeout =300

����listener.ora 
inbound_connect_timeout_LISTENER=290
--��֤�Ƿ���Ч
LSNRCTL> show inbound_connect_timeout
Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.10.8.94)(PORT=1521)))
LISTENER parameter "inbound_connect_timeout" set to 290
The command completed successfully






