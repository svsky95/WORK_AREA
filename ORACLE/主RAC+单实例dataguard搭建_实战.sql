##��RAC+��ʵ��dataguard�##
ADG���ṩ����ľ�������ʹDG����ֻ��״̬�򿪣�ͬʱDG�Ᵽ�ֺ������ͬ������������ͨ��DG������ֻ����ʽ��DG�⣬������ͣͬ�����̡�
#����˵���������RAC�൱�������������ݣ���ʹ�á�
           ���⣺��ʵ����ֻ��װ�����ݿ������û��DBCA����
1�������ݿ��Ϊǿ����־ģʽ ���˲���ֻ��ʵ��1������

[oracle@pri ~]$ sqlplus / as sysdba

�鿴�����Ƿ�ǿ����־ģʽ��
#��һ��ǳ�����Ҫ��Ҫ��û�п���������������nologging�Ĳ���ʱ��û�д���DG�⣬��ô��DG���ѯ��ʱ��ͻᱨ����ʾ��data block was loaded using the nologging option�Ĵ���

SQL> select name,log_mode,force_logging from v$database;   

NAME                 LOG_MODE     FOR
-------------------- ------------ ---
RACDB                ARCHIVELOG   NO

SYS@pri> alter database force logging;
Database altered.

SQL> select name,log_mode,force_logging from v$database;

NAME                 LOG_MODE     FOR
-------------------- ------------ ---
RACDB                ARCHIVELOG   YES

2����racdbʵ��1�ϴ��������ļ�
���������޸�sys�����룬Ҫ�Ǽǵã��Ͳ����޸ģ��鵵��־�Ĵ��䣬����Ҫsys�û���
SQL> alter user sys identified by "foresee_abc";

[oracle@racnode01 ~]$ cd $ORACLE_HOME/dbs
[oracle@racnode01 dbs]$ ls
hc_racdb1.dat  init.ora  initracdb1.ora  orapwracdb1  snapcf_racdb1.f   --orapwracdb1 Ϊ�����ļ�

[oracle@pri dbs]$ orapwd file=orapwracdb1 password=foresee_abc force=y
������������ֶ����������ļ���force=y����˼��ǿ�Ƹ��ǵ�ǰ���е������ļ�

#racdb�ڵ�1�������ļ��������ڵ�2��
scp orapwracdb1 10.10.8.223:$ORACLE_HOME/dbs/orapwracdb2

#���������ļ������⣬�������� �����ʵ����Ϊ��racdbdg
[oracle@racnode01 dbs]$ scp orapwracdb1 10.10.8.55:$ORACLE_HOME/dbs/orapwracdbdg


3���鿴�����redo log
SQL> SELECT a."THREAD#",c."INSTANCE_NAME",a."GROUP#",a."STATUS",b."MEMBER",a."BYTES"/1024/1024 SIZE_M FROM v$log a,v$logfile b,gv$instance c where a."GROUP#"=b."GROUP#" and a."THREAD#"=c."THREAD#" order by 1,3;

   THREAD# INSTANCE_NAME        GROUP# STATUS           MEMBER                                                           SIZE_M
---------- ---------------- ---------- ---------------- ------------------------------------------------------------ ----------
         1 racdb1                    1 INACTIVE         +DATA/racdb/onlinelog/group_1.259.1011625547                         50
         1 racdb1                    1 INACTIVE         +DATA/racdb/onlinelog/group_1.258.1011625547                         50
         1 racdb1                    2 CURRENT          +DATA/racdb/onlinelog/group_2.260.1011625547                         50
         1 racdb1                    2 CURRENT          +DATA/racdb/onlinelog/group_2.261.1011625547                         50
         1 racdb1                    5 INACTIVE         +DATA/racdb/onlinelog/group_5.810.1022411397                         50
         1 racdb1                    5 INACTIVE         +DATA/racdb/onlinelog/redo5.rdo                                      50
         2 racdb2                    3 INACTIVE         +DATA/racdb/onlinelog/group_3.268.1011627295                         50
         2 racdb2                    3 INACTIVE         +DATA/racdb/onlinelog/group_3.269.1011627295                         50
         2 racdb2                    4 CURRENT          +DATA/racdb/onlinelog/group_4.270.1011627295                         50
         2 racdb2                    4 CURRENT          +DATA/racdb/onlinelog/group_4.271.1011627295                         50
         2 racdb2                    6 UNUSED           +DATA/racdb/onlinelog/group_6.935.rdo                                50
         2 racdb2                    6 UNUSED           +DATA/racdb/onlinelog/group_6.934.1024246183                         50
         
ԭ��

#standby redo log���ļ���С��primary ���ݿ�online redo log �ļ���С��ͬ
#standby redo log��־�ļ���ĸ������������ԭ����м��㣺
Standby redo log������ʽ>=(ÿ��instance��־�����+1)*instance����
����ֻ��һ���ڵ㣬����ڵ�������redolog��
����Standby redo log����>=(3+1)*1 == 4
����������Ҫ����4��Standby redo log
�������rac�⣬��Ҫ������(3+1)*2=8 

#��RACDB�ڵ�1�����standby��־�飬ʵ��1��ʵ��2�������

alter database add standby logfile thread 1 group 11 '+DATA/racdb/onlinelog/standby_11_thread_1.log' size 50M; 
alter database add standby logfile thread 2 group 12 '+DATA/racdb/onlinelog/standby_12_thread_2.log' size 50M; 
alter database add standby logfile thread 1 group 13 '+DATA/racdb/onlinelog/standby_13_thread_1.log' size 50M; 
alter database add standby logfile thread 2 group 14 '+DATA/racdb/onlinelog/standby_14_thread_2.log' size 50M; 
alter database add standby logfile thread 1 group 15 '+DATA/racdb/onlinelog/standby_15_thread_1.log' size 50M; 
alter database add standby logfile thread 2 group 16 '+DATA/racdb/onlinelog/standby_16_thread_2.log' size 50M; 
alter database add standby logfile thread 1 group 17 '+DATA/racdb/onlinelog/standby_17_thread_1.log' size 50M; 
alter database add standby logfile thread 2 group 18 '+DATA/racdb/onlinelog/standby_18_thread_2.log' size 50M;

#�鿴standby log
SQL> select group#,sequence#,status, bytes/1024/1024 from v$standby_log;

    GROUP#  SEQUENCE# STATUS     BYTES/1024/1024
---------- ---------- ---------- ---------------
         7          0 UNASSIGNED              50
         8          0 UNASSIGNED             100
         9          0 UNASSIGNED             100
        10          0 UNASSIGNED             100
        11          0 UNASSIGNED             100
        12          0 UNASSIGNED             100
        13          0 UNASSIGNED             100

7 rows selected.

Elapsed: 00:00:00.01
SQL> col MEMBER for a50
SQL> select group#,type, member from v$logfile;

    GROUP# TYPE       MEMBER
---------- ---------- --------------------------------------------------
         1 ONLINE     +DATA/racdb/onlinelog/group_1.258.1011625547
         1 ONLINE     +DATA/racdb/onlinelog/group_1.259.1011625547
         2 ONLINE     +DATA/racdb/onlinelog/group_2.260.1011625547
         2 ONLINE     +DATA/racdb/onlinelog/group_2.261.1011625547
         3 ONLINE     +DATA/racdb/onlinelog/group_3.268.1011627295
         3 ONLINE     +DATA/racdb/onlinelog/group_3.269.1011627295
         4 ONLINE     +DATA/racdb/onlinelog/group_4.270.1011627295
         4 ONLINE     +DATA/racdb/onlinelog/group_4.271.1011627295
         5 ONLINE     +DATA/racdb/onlinelog/group_5.810.1022411397
         5 ONLINE     +DATA/racdb/onlinelog/redo5.rdo
         6 ONLINE     +DATA/racdb/onlinelog/group_6.934.1024246183

    GROUP# TYPE       MEMBER
---------- ---------- --------------------------------------------------
         6 ONLINE     +DATA/racdb/onlinelog/group_6.935.rdo
         7 STANDBY    +DATA/racdb/onlinelog/group_7.931.1024246591
         8 STANDBY    +DATA/racdb/onlinelog/group_8.928.1024248127
         9 STANDBY    +DATA/racdb/onlinelog/group_9.927.1024248127
        10 STANDBY    +DATA/racdb/onlinelog/group_10.926.1024248127
        11 STANDBY    +DATA/racdb/onlinelog/group_11.923.1024248129
        12 STANDBY    +DATA/racdb/onlinelog/group_12.920.1024248131
        13 STANDBY    +DATA/racdb/onlinelog/group_13.919.102424813
        
        
3����������Ĳ����ļ�
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +DATA/racdb/spfileracdb.ora
SQL> create pfile='/tmp/spfile_bak.ora' from spfile;

File created.  

#�޸Ĳ����Primary DB ������
vim /tmp/spfile_bak.ora

racdb2.__db_cache_size=1795162112
racdb1.__db_cache_size=1811939328
racdb2.__java_pool_size=33554432
racdb1.__java_pool_size=33554432
racdb1.__large_pool_size=50331648
racdb2.__large_pool_size=50331648
racdb2.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
racdb1.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
racdb2.__pga_aggregate_target=838860800
racdb1.__pga_aggregate_target=838860800
racdb2.__sga_target=2516582400
racdb1.__sga_target=2516582400
racdb2.__shared_io_pool_size=0
racdb1.__shared_io_pool_size=0
racdb2.__shared_pool_size=603979776
racdb1.__shared_pool_size=587202560
racdb2.__streams_pool_size=0
racdb1.__streams_pool_size=0
*._optimizer_use_feedback=FALSE
*.audit_file_dest='/u01/app/oracle/admin/racdb/adump'
*.audit_trail='db'
*.cluster_database=true
*.compatible='11.2.0.4.0'
*.control_files='+DATA/racdb/controlfile/current.256.1011625547','+DATA/racdb/controlfile/current.257.1011625547'
*.db_block_size=8192
*.db_create_file_dest='+DATA'
*.db_create_online_log_dest_1='+DATA'
*.db_domain=''
*.db_name='racdb'
*.db_recovery_file_dest='+DATA'
*.db_recovery_file_dest_size=53687091200
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=racdbXDB)'
*.enable_ddl_logging=TRUE
racdb2.instance_number=2
racdb1.instance_number=1
*.log_archive_format='%t_%s_%r.dbf'
*.open_cursors=300
*.pga_aggregate_target=836763648
*.processes=500
*.remote_listener='scan-ip:1521'
*.remote_login_passwordfile='exclusive'
*.sga_target=2510290944
racdb2.thread=2
racdb1.thread=1
racdb2.undo_tablespace='UNDOTBS2'
racdb1.undo_tablespace='UNDOTBS1'

--����������ݣ�
*.log_archive_config='DG_CONFIG=(racdb,racdbdg)' 
*.log_archive_dest_1='LOCATION=USE_DB_RECOVERY_FILE_DEST LGWR VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=racdb' 
*.log_archive_dest_2='SERVICE=racdbdg LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=racdbdg' 
*.log_archive_dest_state_1=enable 
*.log_archive_dest_state_2=enable 
*.db_file_name_convert='+DATA/racdb/datafile/','/u01/app/oracle/data/racdbdg/datafile/' 
*.log_file_name_convert='+DATA/racdb/onlinelog/','/u01/app/oracle/data/racdbdg/onlinelog/'
*.fal_client='racdb'
*.fal_server='racdbdg'
*.standby_file_management=auto

#PS:DB_FILE_NAME_CONVERT ��SELECT * FROM dba_data_files;
   :LOG_FILE_NAME_CONVERT ��SELECT * FROM v$logfile;

#Ϊ����֤��������ȷ�ԣ���Ҫ�ȹرսڵ�2���ڽڵ�1���ò�������������ᱨ�����������ڵ㲻һ�µĴ���
startup pfile='/tmp/spfile_bak.ora';
-�����ɹ��������ASM������spfile�������ڵ���������
create spfile='+DATA/racdb/spfileracdb.ora' from pfile='/tmp/spfile_bak.ora';

#���������
vim /u01/app/oracle/product/11.2.0/db_1/dbs/pfile.ora

DB_UNIQUE_NAME=racdbdg
*._optimizer_use_feedback=FALSE
*.audit_file_dest='/u01/app/oracle/admin/racdb/adump'
*.audit_trail='db'
*.compatible='11.2.0.4.0'
*.db_block_size=8192
*.db_domain=''
*.db_name='racdb'
*.diagnostic_dest='/u01/app/oracle'
*.log_archive_format='%t_%s_%r.dbf'
*.open_cursors=300
*.remote_login_passwordfile='exclusive'

--����racdb��spfile_bak�����޸� ��fal_server <fetch archive log>  ��ȡ���������ķ�������
*.log_archive_config='DG_CONFIG=(racdbdg ,racdb)' 
*.log_archive_dest_1='LOCATION=/u01/app/oracle/data/arch LGWR VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=racdbdg' 
*.log_archive_dest_2='SERVICE=racdb LGWR ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=racdb' 
*.log_archive_dest_state_1=enable 
*.log_archive_dest_state_2=enable 
*.db_file_name_convert='+DATA/racdb/datafile/','/u01/app/oracle/data/racdbdg/datafile/' 
*.log_file_name_convert='+DATA/racdb/onlinelog/','/u01/app/oracle/data/racdbdg/onlinelog/'
*.fal_client='racdbdg'
*.fal_server='racdb'
*.standby_file_management=auto


��DG�ϴ���ȱʡĿ¼
su - oracle
mkdir -p /u01/app/oracle/data/arch
mkdir -p /u01/app/oracle/admin/racdb/adump
mkdir -p /u01/app/oracle/data/racdbdg/datafile
mkdir -p /u01/app/oracle/data/racdbdg/onlinelog
mkdir -p /u01/app/oracle/data/racdbdg/controlfile

4������RACDB�ڵ�1���ڵ�2�������TNS
#RACDB�ڵ�1���ڵ�2�������TNS������ʵ��������
cd /u01/app/oracle/product/11.2.0/db_1/network/admin
vim tnsnames.ora

RACDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = scan-ip)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

racdbdg =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.10.8.55)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdbdg)
    )
  )
  
#��������:
cd /u01/app/oracle/product/11.2.0/db_1/network/admin
-����listener�ľ�̬ע��
vim listener.ora

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = racdbdg)
      (SID_NAME = racdbdg)
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST =10.10.8.55)(PORT = 1521))
    )
  )

-����TNS
vim tnsnames.ora 
RACDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.10.8.219)(PORT = 1521))   --��Ϊ�ܶ����������RACDB��ʵ��1�����ģ��������ֻ����ʵ��1������rman����ʵ���ָ���
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdb)
    )
  )

racdbdg =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.10.8.55)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = racdbdg)
    )
  )
  
#��������ļ�����
lsnrctl start

[oracle@data_guard01 admin]$ lsnrctl status 

LSNRCTL for Linux: Version 11.2.0.4.0 - Production on 14-NOV-2019 17:32:57

Copyright (c) 1991, 2013, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.4.0 - Production
Start Date                14-NOV-2019 11:23:36
Uptime                    0 days 6 hr. 9 min. 20 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/data_guard01/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=10.10.8.55)(PORT=1521)))
Services Summary...
Service "racdbdg" has 2 instance(s).
  Instance "racdbdg", status UNKNOWN, has 1 handler(s) for this service...
  Instance "racdbdg", status READY, has 1 handler(s) for this service...
The command completed successfully

#��飬��RACDB��ʵ��1��ʵ��2��tnsping racdbdg  
       ��DG��tnsping racdb��ʵ��1��Ҫ��ͨ�Ĳ�������

5��rman���б���
#�����������⵽nomountģʽ
[oracle@data_guard01 dbs]$ sqlplus / as sysdba
SQL> startup pfile=pfile.ora nomount;
-������������nomount״̬������spfile,�Ա�����޸�
SQL> create spfile from pfile='pfile.ora';
shutdown immdiate
startup nomount
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /u01/app/oracle/product/11.2.0
                                                 /db_1/dbs/spfileracdbdg.ora
                                                
#��RACDBʵ��1�ϻ��߱�����ʹ��rman���б��ݻָ�
[oracle@racnode01 admin]$ rman target=sys/foresee_abc@racdb auxiliary=sys/foresee_abc@racdbdg
Recovery Manager: Release 11.2.0.4.0 - Production on Thu Nov 14 14:43:09 2019
Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.
connected to target database: RACDB (DBID=1009242311)
connected to auxiliary database: RACDB (not mounted)

configure device type disk parallelism 4;
duplicate target database for standby from active database nofilenamecheck;

#�������⣬����ʼ��־Ӧ��
alter database open;

-����redo log Ӧ��
SQL> alter database recover managed standby database using current logfile disconnect from session;

-Ҳ�����������뱸��֮������ݸ��¼�����˴�Ϊ60���ӡ�
Ҳ���ǵ�������ɾ��ʱ��������60���ӵġ����ҩ��ʱ��
SQL> alter database recover managed standby database delay 60 disconnect from session;

-�鿴����ͱ���״̬
-����
select t.inst_id,open_mode, switchover_status, database_role from gv$database t;

   INST_ID OPEN_MODE            SWITCHOVER_STATUS    DATABASE_ROLE
---------- -------------------- -------------------- ----------------
         1 READ WRITE           SESSIONS ACTIVE      PRIMARY
         2 READ WRITE           SESSIONS ACTIVE      PRIMARY
         
-����
SQL>  select t.inst_id,open_mode, switchover_status, database_role from gv$database t;

   INST_ID OPEN_MODE            SWITCHOVER_STATUS    DATABASE_ROLE
---------- -------------------- -------------------- ----------------
         1 READ ONLY WITH APPLY NOT ALLOWED          PHYSICAL STANDBY
         

##dataguard����˳��
startup nomount;
�������ݿ�
alter database mount standby database;
����Ӧ������
alter database recover managed standby database disconnect from session;
ֹͣ����
alter database recover managed standby database cancel;
������ֻ��״̬
alter database open read only;
�ڡ�READ ONLY��״̬�½�һ����������Ļָ���ʵʱӦ��������־��
alter database recover managed standby database using current logfile disconnect;


#��֤����RACDB�ϵ�ʵ��1��ʵ��2���л���־���鿴�������־���
ʵ��1��
SQL>  alter system switch logfile;

System altered.

Elapsed: 00:00:00.02
SQL> archive log list;
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     526
Next log sequence to archive   528
Current log sequence           528

alter system switch logfile;

-�鿴��ʵ�������SEQ
SELECT MAX(SEQUENCE#), THREAD# FROM V$ARCHIVED_LOG WHERE RESETLOGS_CHANGE# = (SELECT MAX(RESETLOGS_CHANGE#) FROM V$ARCHIVED_LOG) GROUP BY THREAD#;
MAX(SEQUENCE#)    THREAD#
-------------- ----------
           567          1
           524          2
           
����:
#��־Ӧ�����
SELECT INST_ID, SEQUENCE#, FIRST_TIME, NEXT_TIME,applied FROM gV$ARCHIVED_LOG ORDER BY SEQUENCE#;


   INST_ID  SEQUENCE# FIRST_TIME          NEXT_TIME           APPLIED
         1        562 2019-11-18 10:00:13 2019-11-18 10:22:32 YES
         1        563 2019-11-18 10:22:32 2019-11-18 10:31:29 YES
         1        564 2019-11-18 10:31:29 2019-11-18 10:35:49 YES
         1        565 2019-11-18 10:35:49 2019-11-18 10:38:02 YES
         1        566 2019-11-18 10:38:02 2019-11-18 10:39:03 YES

SQL> select process,client_process,sequence#,status from v$managed_standby;   -MRP0 Ϊ��־Ӧ�ý���

PROCESS   CLIENT_P  SEQUENCE# STATUS
--------- -------- ---------- ------------
ARCH      ARCH            538 CLOSING
ARCH      ARCH            506 CLOSING
ARCH      ARCH              0 CONNECTED
ARCH      ARCH            507 CLOSING
MRP0      N/A             508 WAIT_FOR_LOG
RFS       ARCH              0 IDLE
RFS       ARCH              0 IDLE
RFS       LGWR            539 IDLE
RFS       UNKNOWN           0 IDLE
RFS       ARCH              0 IDLE
RFS       UNKNOWN           0 IDLE

PROCESS   CLIENT_P  SEQUENCE# STATUS
--------- -------- ---------- ------------
RFS       LGWR            508 IDLE

SQL> select * from v$log;

    GROUP#    THREAD#  SEQUENCE#      BYTES  BLOCKSIZE    MEMBERS ARC STATUS           FIRST_CHANGE# FIRST_TIM NEXT_CHANGE# NEXT_TIME
---------- ---------- ---------- ---------- ---------- ---------- --- ---------------- ------------- --------- ------------ ---------
         1          1        534   52428800        512          2 YES CLEARING              14361530 14-NOV-19     14361309 14-NOV-19
         2          1        536   52428800        512          2 YES CURRENT               14362883 14-NOV-19   2.8147E+14
         3          2        487   52428800        512          2 YES CURRENT               14357161 14-NOV-19   2.8147E+14
         4          2          0   52428800        512          2 YES UNUSED                14343466 14-NOV-19     14346958 14-NOV-19
         5          1        535   52428800        512          2 YES CLEARING              14361860 14-NOV-19     14362883 14-NOV-19
         6          2          0   52428800        512          2 YES CLEARING              14346958 14-NOV-19   2.8147E+14

#�鿴���������Ƿ����ӳ�
SELECT * FROM V$ARCHIVE_GAP;
THREAD# LOW_SEQUENCE# HIGH_SEQUENCE#
----------- ------------- --------------
1              7            10

�����������˵����ǰ���ⶪʧ��ʵ��1��sequence 7 to sequence 10

-�ҵ�ʵ��1��ȱ��log files��·��
SELECT NAME FROM V$ARCHIVED_LOG WHERE THREAD#=1 AND DEST_ID=1 AND SEQUENCE# BETWEEN 7 AND 10;
NAME
--------------------------------------------------------------------------------
/primary/thread1_dest/arcr_1_7.arc
/primary/thread1_dest/arcr_1_8.arc
/primary/thread1_dest/arcr_1_9.arc

#���ȷ���
����ʵ��1��arcr_1_7.arc��arcr_1_8.arc��arcr_1_9.arc�ļ��������е�·����/u01/app/oracle/data/arch����Ȼ�����Ӧ�á�
-DG�е�·����
SQL> archive log list;
Archive destination            /u01/app/oracle/data/arch

ALTER DATABASE REGISTER LOGFILE '/physical_standby1/thread1_dest/arcr_1_7.arc';
�ָ���GAP��¼��ʧ��

#��ȱʧ��log file�ǲ������ģ���ô��Ҫ���м������Ĳ��롣
SQL> SELECT THREAD#, SEQUENCE#, FILE_NAME FROM DBA_LOGSTDBY_LOG L
WHERE NEXT_CHANGE# NOT IN
(SELECT FIRST_CHANGE# FROM DBA_LOGSTDBY_LOG WHERE L.THREAD# = THREAD#)
ORDER BY THREAD#, SEQUENCE#;
THREAD# SEQUENCE# FILE_NAME
---------- ---------- -----------------------------------------------
1 6 /disk1/oracle/dbs/log-1292880008_6.arc
1 10 /disk1/oracle/dbs/log-1292880008_10.arc

6��10֮���м����������Ҫ����7��8��9�����ļ���DG�ϣ�����register
SQL> ALTER DATABASE REGISTER LOGICAL LOGFILE
> '/disk1/oracle/dbs/log-1292880008_7.arc';

#�鿴RACDBʵ��1��ʵ��2����־״̬
-����û�б����б������б���ԭ����ȷ���������Ѿ���������ǣ�״̬����error,���Եȵȣ���ҵ��д�����⣬״̬�ͻ������ˡ�
select * from v$archive_dest_status;


##�޸�DG������ģʽ
alter system set cluster_database=false scope=spfile;
startup mount
ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE {AVAILABILITY | PERFORMANCE | PROTECTION};
alter system set cluster_database=true scope=spfile;
-�鿴ģʽ
SELECT PROTECTION_MODE FROM V$DATABASE;

DataGuard���������ݱ���ģʽ��
 1. ��󱣻���Maximum Protection��
����ģʽ�ܹ�ȷ���������ݶ�ʧ��Ҫʵ����һ����Ȼ���д��۵ģ���Ҫ�����е��������ύǰ��REDO������д�뵽���ص�Online Redologs����Ҫͬʱд�뵽Standby���ݿ��Standby Redologs����ȷ��REDO����������һ��Standby���ݿ��п��ã�����ж���Ļ�����Ȼ��Ż���Primary���ݿ����ύ�����������ʲô���ϵ���Standby���ݿⲻ���õĻ������������жϣ���Primary���ݿ�ᱻShutdown���Է�ֹ���ݶ�ʧ��
ʹ�����ַ�ʽҪ��Standby Database ��������Standby Redo Log����Primary Database����ʹ��LGWR��SYNC��AFFIRM ��ʽ�鵵��Standby Database.

2. ��߿����ԣ�Maximum availability��
����ģʽ�ڲ�Ӱ��Primary���ݿ����ǰ���£��ṩ��߼�������ݱ������ԡ���ʵ�ַ�ʽ����󱣻�ģʽ���ƣ�Ҳ��Ҫ�󱾵��������ύǰ��������д��һ̨Standby���ݿ��Standby Redologs�У���������󱣻�ģʽ��ͬ���ǣ�������ֹ��ϵ���Standby���ݿ��޷����ʣ�Primary���ݿⲢ���ᱻShutdown�������Զ�תΪ�������ģʽ����Standby���ݿ�ָ�����֮��Primary���ݿ��ֻ��Զ�ת������߿�����ģʽ��
���ַ�ʽ��Ȼ�ᾡ���������ݶ�ʧ�������ܾ��Ա�֤������ȫһ�¡����ַ�ʽҪ��Standby Database ��������Standby Redo Log����Primary Database����ʹ��LGWR��SYNC��AFFIRM ��ʽ�鵵��Standby Database.

3. ������ܣ�Maximum performance��
Ĭ��ģʽ������ģʽ�ڲ�Ӱ��Primary���ݿ�����ǰ���£��ṩ��߼�������ݱ������ԡ����������ʱ�ύ����ǰPrimary���ݿ��REDO����������Ҫд��һ��Standby���ݿ⣬��������д������ǲ�ͬ���ġ����������������Ļ�������ģʽ�ܹ��ṩ������߿����Ե����ݱ�����������Primary���ݿ����������΢Ӱ�졣��Ҳ�Ǵ���Standby���ݿ�ʱ��ϵͳ��Ĭ�ϱ���ģʽ��
���ַ�ʽ����ʹ��LGWR ASYNC ���� ARCH ����ʵ�֣�Standby DatabaseҲ��Ҫ��ʹ��Standby Redo Log��

#####�����л�ǰ�᣺���ͱ���ʵ����OPEN����û�й��ϵ������######
##������DG���Switchover��Performing a Switchover to a Physical Standby Database��
-ת��ǰ��
���⣺RAC
���⣺��ʵ��
-װ����:
���⣺��ʵ��
���⣺RAC

-������״̬ ״̬Ϊ TO STANDBY or SESSIONS ACTIVE �����Խ��н�ɫװ��
SQL> select t.inst_id,open_mode, switchover_status, database_role from gv$database t;

   INST_ID OPEN_MODE            SWITCHOVER_STATUS    DATABASE_ROLE
---------- -------------------- -------------------- ----------------
         1 READ WRITE           SESSIONS ACTIVE      PRIMARY
         2 READ WRITE           SESSIONS ACTIVE      PRIMARY

-�����״̬���
SQL> select t.inst_id,open_mode, switchover_status, database_role from gv$database t;

   INST_ID OPEN_MODE            SWITCHOVER_STATUS    DATABASE_ROLE
---------- -------------------- -------------------- ----------------
         1 READ ONLY WITH APPLY NOT ALLOWED          PHYSICAL STANDBY

#����RAC�е�һ��ʵ�����ߵ��ǵ�ʵ��ִ�С�
�л�����Ϊ��cluster_database=false 
alter system set cluster_database=false scope=spfile;
�ر�ʵ��1��ʵ��2������ʵ��1���в�����

SQL>ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

-����  �鿴�����״̬����TO PRIMARY or SESSIONS ACTIVE ��˵����ɫת�Ƴɹ�
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;
SWITCHOVER_STATUS
-----------------
TO_PRIMARY

-������ִ�� ת������
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
SQL> ALTER DATABASE OPEN;

#��ԴRAC�����ϣ�����ʵ����Ҫ����ִ�й鵵��־Ӧ��
alter system set cluster_database=true scope=spfile;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

##��飺
-Դ����䱸
SQL> select open_mode from v$database;

OPEN_MODE
--------------------
READ ONLY WITH APPLY

-����ת����
SQL>SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
SESSIONS ACTIVE

#PS����װ����ɺ�dataguardΪRAC�Ŀ⣬ֻҪӦ�����Ե�ʵ����������־�����ǣ����Ӧ�õĽ��̣�ֻ������һ��ʵ���С�
-��ʱʵ��1������MRP0 ��־Ӧ�ý��̡�
�ص�ʵ��1��ʵ��2״̬���£�
SQL> select process,client_process,sequence#,status from v$managed_standby;

PROCESS   CLIENT_P  SEQUENCE# STATUS
--------- -------- ---------- ------------
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED

-������־Ӧ�ã�
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

Database altered.
-ʵ��2���̳��֣�
SQL> select process,client_process,sequence#,status from v$managed_standby;

PROCESS   CLIENT_P  SEQUENCE# STATUS
--------- -------- ---------- ------------
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
MRP0      N/A             600 APPLYING_LOG


##Ǩ�ƻ�ԭ�ܹ�
ת��ǰ��
���⣺��ʵ��
���⣺RAC

-װ����:
���⣺RAC
���⣺��ʵ��

-������״̬ ״̬Ϊ TO STANDBY or SESSIONS ACTIVE �����Խ��н�ɫת��
SQL>SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
SESSIONS ACTIVE

-�����״̬���
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
NOT ALLOWED

#�л�ǰ��Ҫ���log file�Ƿ�����Ӧ��һ��
SELECT INST_ID, SEQUENCE#, FIRST_TIME, NEXT_TIME,applied FROM gV$ARCHIVED_LOG ORDER BY SEQUENCE#;

#���ⵥʵ���б�������ִ���꣬ʵ���رա�
SQL>ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

#����RAC����
ʵ��1��ִ��
alter system set cluster_database=false scope=spfile;
�ر�ʵ��1��ʵ��2������ʵ��1���в�����

-ת������
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
SQL> select status from v$instance;
STATUS
------------
MOUNTED

SQL> alter system set cluster_database=true scope=spfile sid='*';
�ر�ʵ��1����������ʵ��1��ʵ��2

#�ڱ��ⵥʵ����ִ�й鵵��־Ӧ��
�������⣺startup
select count(*) from cz.test16;

##��飺
-RAC����
SQL> select open_mode from v$database;

OPEN_MODE
--------------------
READ ONLY WITH APPLY

-��ʵ�����⣺
SQL>SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
SESSIONS ACTIVE



#####�����л�ǰ�᣺����ҵ��������������л���ɺ󣬵�����ָ��������ܹ���ʧ��######
##���1  �������������mount ״̬
#����ʵ��1
startup mount
SQL> ALTER SYSTEM FLUSH REDO TO 'racdbdg';

#����ʵ��2
startup mount
SQL> ALTER SYSTEM FLUSH REDO TO 'racdbdg';
-ȷ��ʵ��1��ʵ��2��ִ�����

#��¼���⣬����ת������
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE FINISH;
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
TO PRIMARY

SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
SQL> ALTER DATABASE OPEN;

SQL> select open_mode from v$database;

OPEN_MODE
--------------------
READ WRITE

##���⳹��崻����޷���������Ҫ�����鵵��־�ָ�##
�����11.2 �ٷ��ο��ĵ�data_guard.pdf ��104ҳ


##DG�������ӳ�
���������DDL��DML���������ܻ���֣�������Ѿ�ִ����ɣ�����DG�⣬����û��Ӧ�õ������
ԭ���ǣ�����û���л��鵵���µģ���DG��û��Ӧ����־���µģ��������л����ι鵵��DG���Ӧ���ˡ�

#�鿴�����ӳ�
SELECT name, value, datum_time, time_computed FROM V$DATAGUARD_STATS WHERE name like 'apply lag';
SELECT * FROM V$STANDBY_EVENT_HISTOGRAM WHERE NAME = 'apply lag' AND COUNT > 0;

########�������ܼ�ر�#######
##Monitor Redo Apply
-���� 
�� Alert log
�� V$ARCHIVE_DEST_STATUS
-����
�� Alert log
�� V$ARCHIVED_LOG
�� V$LOG_HISTORY
�� V$MANAGED_STANDBY

##Monitor redo transport
-����
�� V$ARCHIVE_DEST_STATUS
�� V$ARCHIVED_LOG
�� V$ARCHIVE_DEST
�� Alert log
-����
�� V$ARCHIVED_LOG
�� Alert log��

##RAC��RAC ADG����������
##ʵ��1
SQL> startup nomount;
ORACLE instance started.

Total System Global Area 6.8719E+10 bytes
Fixed Size		   30046992 bytes
Variable Size		 1.2885E+10 bytes
Database Buffers	 5.5700E+10 bytes
Redo Buffers		  104169472 bytes
SQL> alter database mount standby database;

Database altered.

SQL> ALTER DATABASE OPEN READ ONLY;

Database altered.

SQL> SELECT database_role, open_mode FROM v$database;

DATABASE_ROLE	 OPEN_MODE
---------------- --------------------
PHYSICAL STANDBY READ ONLY

SQL> alter database recover managed standby database using current logfile disconnect from session;

Database altered.

SQL> SELECT database_role, open_mode FROM v$database;

DATABASE_ROLE	 OPEN_MODE
---------------- --------------------
PHYSICAL STANDBY READ ONLY WITH APPLY

##ʵ��2 
SQL> startup nomount;
ORACLE instance started.

Total System Global Area 6.8719E+10 bytes
Fixed Size		   30046992 bytes
Variable Size		 1.2885E+10 bytes
Database Buffers	 5.5700E+10 bytes
Redo Buffers		  104169472 bytes
SQL> alter database mount;

Database altered.

SQL> ALTER DATABASE OPEN READ ONLY;

Database altered.

SQL> SELECT database_role, open_mode FROM v$database;

DATABASE_ROLE	 OPEN_MODE
---------------- --------------------
PHYSICAL STANDBY READ ONLY WITH APPLY

run {         
allocate channel t1 device type disk;         
allocate channel t2 device type disk;         
allocate auxiliary channel t3 device type disk;         
allocate auxiliary channel t4 device type disk;         
duplicate target database for standby from active database nofilenamecheck         
dorecover         
spfile                 
parameter_value_convert 'HBPROD','HBPRODADG'     
set audit_file_dest='/u01/app/oracle/admin/HBPROD/adump'     
set cluster_database='false'     
set control_files='/u01/app/oracle/data/HBPROD/controlfile/control01.ctl','/u01/app/oracle/data/HBPROD/controlfile/control02.ctl'     
set db_create_file_dest='/u01/app/oracle/data/HBPROD/datafile/'     
set open_cursors='500'     
set processes='2000'     
set memory_target='15G'     
set memory_max_target='15G'     
set remote_listener=''     
set undo_tablespace='UNDOTBS1'     
set DB_UNIQUE_NAME='HBPRODADG'     
set LOG_ARCHIVE_CONFIG='DG_CONFIG=(HBPROD,HBPRODADG)'     
set LOG_ARCHIVE_DEST_1='LOCATION=/u01/app/oracle/data/HBPROD/archivelog/ VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=HBPRODADG'     
set LOG_ARCHIVE_DEST_STATE_1='ENABLE'                 
set DB_FILE_NAME_CONVERT='+DATA/hbprod/datafile/','/u01/app/oracle/data/HBPROD/datafile/'                 
set LOG_FILE_NAME_CONVERT='+DATA/hbprod/onlinelog/','/u01/app/oracle/data/HBPROD/logfile'                 
set STANDBY_FILE_MANAGEMENT='AUTO';         
release channel t1;         
release channel t2;         
release channel t3;         
release channel t4;         
}