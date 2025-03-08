##主RAC+单实例dataguard搭建##
ADG能提供更多的就是你能使DG库以只读状态打开，同时DG库保持和主库的同步。而对于普通的DG，你以只读形式打开DG库，必须暂停同步进程。
#环境说明：主库的RAC相当于生产，有数据，可使用。
           备库：单实例，只安装了数据库软件，没有DBCA建库
1、将数据库改为强制日志模式 （此步骤只在实例1上做）

[oracle@pri ~]$ sqlplus / as sysdba

查看主库是否强制日志模式：
#这一点非常的重要，要是没有开启，当有主库有nologging的操作时，没有传到DG库，那么在DG库查询的时候就会报错，提示：data block was loaded using the nologging option的错误。

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

2、在racdb实例1上创建密码文件
在主库上修改sys的密码，要是记得，就不用修改，归档日志的传输，都需要sys用户。
SQL> alter user sys identified by "foresee_abc";

[oracle@racnode01 ~]$ cd $ORACLE_HOME/dbs
[oracle@racnode01 dbs]$ ls
hc_racdb1.dat  init.ora  initracdb1.ora  orapwracdb1  snapcf_racdb1.f   --orapwracdb1 为密码文件

[oracle@pri dbs]$ orapwd file=orapwracdb1 password=foresee_abc force=y
这条命令可以手动生成密码文件，force=y的意思是强制覆盖当前已有的密码文件

#racdb节点1的密码文件拷贝到节点2上
scp orapwracdb1 10.10.8.223:$ORACLE_HOME/dbs/orapwracdb2

#拷贝密码文件到备库，并重命名 备库的实例名为：racdbdg
[oracle@racnode01 dbs]$ scp orapwracdb1 10.10.8.55:$ORACLE_HOME/dbs/orapwracdbdg


3、查看主库的redo log
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
         
原则：

#standby redo log的文件大小与primary 数据库online redo log 文件大小相同
#standby redo log日志文件组的个数依照下面的原则进行计算：
Standby redo log组数公式>=(每个instance日志组个数+1)*instance个数
假如只有一个节点，这个节点有三组redolog，
所以Standby redo log组数>=(3+1)*1 == 4
所以至少需要创建4组Standby redo log
对于这个rac库，需要创建：(3+1)*2=8 

#在RACDB节点1上添加standby日志组，实例1和实例2都会产生

alter database add standby logfile thread 1 group 11 '+DATA/racdb/onlinelog/standby_11_thread_1.log' size 50M; 
alter database add standby logfile thread 2 group 12 '+DATA/racdb/onlinelog/standby_12_thread_2.log' size 50M; 
alter database add standby logfile thread 1 group 13 '+DATA/racdb/onlinelog/standby_13_thread_1.log' size 50M; 
alter database add standby logfile thread 2 group 14 '+DATA/racdb/onlinelog/standby_14_thread_2.log' size 50M; 
alter database add standby logfile thread 1 group 15 '+DATA/racdb/onlinelog/standby_15_thread_1.log' size 50M; 
alter database add standby logfile thread 2 group 16 '+DATA/racdb/onlinelog/standby_16_thread_2.log' size 50M; 
alter database add standby logfile thread 1 group 17 '+DATA/racdb/onlinelog/standby_17_thread_1.log' size 50M; 
alter database add standby logfile thread 2 group 18 '+DATA/racdb/onlinelog/standby_18_thread_2.log' size 50M;

#查看standby log
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
        
        
3、创建主库的参数文件
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +DATA/racdb/spfileracdb.ora
SQL> create pfile='/tmp/spfile_bak.ora' from spfile;

File created.  

#修改并添加Primary DB 参数：
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

--添加如下内容：
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

#PS:DB_FILE_NAME_CONVERT 在SELECT * FROM dba_data_files;
   :LOG_FILE_NAME_CONVERT 在SELECT * FROM v$logfile;

#为了验证参数的正确性，需要先关闭节点2，在节点1上用参数启动，否则会报参数在两个节点不一致的错误。
startup pfile='/tmp/spfile_bak.ora';
-启动成功无误后，在ASM中生成spfile，两个节点再启动。
create spfile='+DATA/racdb/spfileracdb.ora' from pfile='/tmp/spfile_bak.ora';

#备库参数：
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

--参照racdb的spfile_bak进行修改 （fal_server <fetch archive log>  获取主服务器的服务名）
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


在DG上创建缺省目录
su - oracle
mkdir -p /u01/app/oracle/data/arch
mkdir -p /u01/app/oracle/admin/racdb/adump
mkdir -p /u01/app/oracle/data/racdbdg/datafile
mkdir -p /u01/app/oracle/data/racdbdg/onlinelog
mkdir -p /u01/app/oracle/data/racdbdg/controlfile

4、配置RACDB节点1、节点2及备库的TNS
#RACDB节点1、节点2及备库的TNS，用于实例解析：
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
  
#备库配置:
cd /u01/app/oracle/product/11.2.0/db_1/network/admin
-配置listener的静态注册
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

-配置TNS
vim tnsnames.ora 
RACDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.10.8.219)(PORT = 1521))   --因为很多操作都是在RACDB的实例1上做的，这里可以只配置实例1，用于rman连接实例恢复。
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
  
#启动备库的监听：
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

#检查，在RACDB的实例1及实例2上tnsping racdbdg  
       在DG上tnsping racdb的实例1都要是通的才正常。

5、rman进行备份
#首先启动备库到nomount模式
[oracle@data_guard01 dbs]$ sqlplus / as sysdba
SQL> startup pfile=pfile.ora nomount;
-若可以启动到nomount状态，生成spfile,以便参数修改
SQL> create spfile from pfile='pfile.ora';
shutdown immdiate
startup nomount
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /u01/app/oracle/product/11.2.0
                                                 /db_1/dbs/spfileracdbdg.ora
                                                
#在RACDB实例1上或者备库上使用rman进行备份恢复
[oracle@racnode01 admin]$ rman target=sys/foresee_abc@racdb auxiliary=sys/foresee_abc@racdbdg
Recovery Manager: Release 11.2.0.4.0 - Production on Thu Nov 14 14:43:09 2019
Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.
connected to target database: RACDB (DBID=1009242311)
connected to auxiliary database: RACDB (not mounted)

configure device type disk parallelism 4;
duplicate target database for standby from active database nofilenamecheck;

#启动备库，并开始日志应用
alter database open;

-开启redo log 应用
SQL> alter database recover managed standby database using current logfile disconnect from session;

-也可设置主库与备库之间的数据更新间隔，此处为60分钟。
也就是当主库误删除时，备库有60分钟的‘后悔药’时间
SQL> alter database recover managed standby database delay 60 disconnect from session;

-查看主库和备库状态
-主库
select t.inst_id,open_mode, switchover_status, database_role from gv$database t;

   INST_ID OPEN_MODE            SWITCHOVER_STATUS    DATABASE_ROLE
---------- -------------------- -------------------- ----------------
         1 READ WRITE           SESSIONS ACTIVE      PRIMARY
         2 READ WRITE           SESSIONS ACTIVE      PRIMARY
         
-备库
SQL>  select t.inst_id,open_mode, switchover_status, database_role from gv$database t;

   INST_ID OPEN_MODE            SWITCHOVER_STATUS    DATABASE_ROLE
---------- -------------------- -------------------- ----------------
         1 READ ONLY WITH APPLY NOT ALLOWED          PHYSICAL STANDBY
         

##dataguard启动顺序
startup nomount;
挂载数据库
alter database mount standby database;
启用应用重做
alter database recover managed standby database disconnect from session;
停止重做
alter database recover managed standby database cancel;
启动到只读状态
alter database open read only;
在“READ ONLY”状态下进一步启动备库的恢复，实时应用主库日志。
alter database recover managed standby database using current logfile disconnect;


#验证，在RACDB上的实例1和实例2，切换日志，查看备库的日志情况
实例1：
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

-查看各实例的最大SEQ
SELECT MAX(SEQUENCE#), THREAD# FROM V$ARCHIVED_LOG WHERE RESETLOGS_CHANGE# = (SELECT MAX(RESETLOGS_CHANGE#) FROM V$ARCHIVED_LOG) GROUP BY THREAD#;
MAX(SEQUENCE#)    THREAD#
-------------- ----------
           567          1
           524          2
           
备库:
#日志应用情况
SELECT INST_ID, SEQUENCE#, FIRST_TIME, NEXT_TIME,applied FROM gV$ARCHIVED_LOG ORDER BY SEQUENCE#;


   INST_ID  SEQUENCE# FIRST_TIME          NEXT_TIME           APPLIED
         1        562 2019-11-18 10:00:13 2019-11-18 10:22:32 YES
         1        563 2019-11-18 10:22:32 2019-11-18 10:31:29 YES
         1        564 2019-11-18 10:31:29 2019-11-18 10:35:49 YES
         1        565 2019-11-18 10:35:49 2019-11-18 10:38:02 YES
         1        566 2019-11-18 10:38:02 2019-11-18 10:39:03 YES

SQL> select process,client_process,sequence#,status from v$managed_standby;   -MRP0 为日志应用进程

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

#查看备库与主是否有延迟
SELECT * FROM V$ARCHIVE_GAP;
THREAD# LOW_SEQUENCE# HIGH_SEQUENCE#
----------- ------------- --------------
1              7            10

上述有输出，说明当前备库丢失了实例1，sequence 7 to sequence 10

-找到实例1中缺少log files的路径
SELECT NAME FROM V$ARCHIVED_LOG WHERE THREAD#=1 AND DEST_ID=1 AND SEQUENCE# BETWEEN 7 AND 10;
NAME
--------------------------------------------------------------------------------
/primary/thread1_dest/arcr_1_7.arc
/primary/thread1_dest/arcr_1_8.arc
/primary/thread1_dest/arcr_1_9.arc

#补救方法
拷贝实例1中arcr_1_7.arc、arcr_1_8.arc、arcr_1_9.arc文件到备库中的路径（/u01/app/oracle/data/arch），然后进行应用。
-DG中的路径：
SQL> archive log list;
Archive destination            /u01/app/oracle/data/arch

ALTER DATABASE REGISTER LOGFILE '/physical_standby1/thread1_dest/arcr_1_7.arc';
恢复后，GAP记录消失。

#若缺失的log file是不连续的，那么需要把中间连续的补齐。
SQL> SELECT THREAD#, SEQUENCE#, FILE_NAME FROM DBA_LOGSTDBY_LOG L
WHERE NEXT_CHANGE# NOT IN
(SELECT FIRST_CHANGE# FROM DBA_LOGSTDBY_LOG WHERE L.THREAD# = THREAD#)
ORDER BY THREAD#, SEQUENCE#;
THREAD# SEQUENCE# FILE_NAME
---------- ---------- -----------------------------------------------
1 6 /disk1/oracle/dbs/log-1292880008_6.arc
1 10 /disk1/oracle/dbs/log-1292880008_10.arc

6到10之间有间隔，所以需要拷贝7、8、9三个文件到DG上，进行register
SQL> ALTER DATABASE REGISTER LOGICAL LOGFILE
> '/disk1/oracle/dbs/log-1292880008_7.arc';

#查看RACDB实例1和实例2的日志状态
-正常没有报错，有报错，会有报错原因，若确保，错误已经解决，但是，状态还是error,可以等等，有业务写入主库，状态就会正常了。
select * from v$archive_dest_status;


##修改DG的三种模式
alter system set cluster_database=false scope=spfile;
startup mount
ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE {AVAILABILITY | PERFORMANCE | PROTECTION};
alter system set cluster_database=true scope=spfile;
-查看模式
SELECT PROTECTION_MODE FROM V$DATABASE;

DataGuard的三种数据保护模式：
 1. 最大保护（Maximum Protection）
这种模式能够确保绝无数据丢失。要实现这一步当然是有代价的，它要求所有的事务在提交前其REDO不仅被写入到本地的Online Redologs，还要同时写入到Standby数据库的Standby Redologs，并确认REDO数据至少在一个Standby数据库中可用（如果有多个的话），然后才会在Primary数据库上提交。如果出现了什么故障导致Standby数据库不可用的话（比如网络中断），Primary数据库会被Shutdown，以防止数据丢失。
使用这种方式要求Standby Database 必须配置Standby Redo Log，而Primary Database必须使用LGWR，SYNC，AFFIRM 方式归档到Standby Database.

2. 最高可用性（Maximum availability）
这种模式在不影响Primary数据库可用前提下，提供最高级别的数据保护策略。其实现方式与最大保护模式类似，也是要求本地事务在提交前必须至少写入一台Standby数据库的Standby Redologs中，不过与最大保护模式不同的是，如果出现故障导致Standby数据库无法访问，Primary数据库并不会被Shutdown，而是自动转为最高性能模式，等Standby数据库恢复正常之后，Primary数据库又会自动转换成最高可用性模式。
这种方式虽然会尽量避免数据丢失，但不能绝对保证数据完全一致。这种方式要求Standby Database 必须配置Standby Redo Log，而Primary Database必须使用LGWR，SYNC，AFFIRM 方式归档到Standby Database.

3. 最高性能（Maximum performance）
默认模式。这种模式在不影响Primary数据库性能前提下，提供最高级别的数据保护策略。事务可以随时提交，当前Primary数据库的REDO数据至少需要写入一个Standby数据库，不过这种写入可以是不同步的。如果网络条件理想的话，这种模式能够提供类似最高可用性的数据保护，而仅对Primary数据库的性能有轻微影响。这也是创建Standby数据库时，系统的默认保护模式。
这种方式可以使用LGWR ASYNC 或者 ARCH 进程实现，Standby Database也不要求使用Standby Redo Log。

#####主备切换前提：主和备的实例的OPEN，且没有故障的情况下######
##主库与DG库的Switchover（Performing a Switchover to a Physical Standby Database）
-转换前：
主库：RAC
备库：单实例
-装换后:
主库：单实例
备库：RAC

-主库检测状态 状态为 TO STANDBY or SESSIONS ACTIVE 都可以进行角色装换
SQL> select t.inst_id,open_mode, switchover_status, database_role from gv$database t;

   INST_ID OPEN_MODE            SWITCHOVER_STATUS    DATABASE_ROLE
---------- -------------------- -------------------- ----------------
         1 READ WRITE           SESSIONS ACTIVE      PRIMARY
         2 READ WRITE           SESSIONS ACTIVE      PRIMARY

-备库库状态检测
SQL> select t.inst_id,open_mode, switchover_status, database_role from gv$database t;

   INST_ID OPEN_MODE            SWITCHOVER_STATUS    DATABASE_ROLE
---------- -------------------- -------------------- ----------------
         1 READ ONLY WITH APPLY NOT ALLOWED          PHYSICAL STANDBY

#主库RAC中的一个实例或者但是单实例执行。
切换主库为：cluster_database=false 
alter system set cluster_database=false scope=spfile;
关闭实例1和实例2，启动实例1进行操作。

SQL>ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

-备库  查看备库的状态，（TO PRIMARY or SESSIONS ACTIVE ）说明角色转移成功
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;
SWITCHOVER_STATUS
-----------------
TO_PRIMARY

-备库上执行 转主操作
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
SQL> ALTER DATABASE OPEN;

#在源RAC主库上，两个实例都要做，执行归档日志应用
alter system set cluster_database=true scope=spfile;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

##检查：
-源主库变备
SQL> select open_mode from v$database;

OPEN_MODE
--------------------
READ ONLY WITH APPLY

-备库转主：
SQL>SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
SESSIONS ACTIVE

#PS：在装换完成后，dataguard为RAC的库，只要应用来自单实例传来的日志，但是，这个应用的进程，只存在于一个实例中。
-此时实例1，存在MRP0 日志应用进程。
关掉实例1，实例2状态如下：
SQL> select process,client_process,sequence#,status from v$managed_standby;

PROCESS   CLIENT_P  SEQUENCE# STATUS
--------- -------- ---------- ------------
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED

-启动日志应用：
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

Database altered.
-实例2进程出现：
SQL> select process,client_process,sequence#,status from v$managed_standby;

PROCESS   CLIENT_P  SEQUENCE# STATUS
--------- -------- ---------- ------------
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
ARCH      ARCH              0 CONNECTED
MRP0      N/A             600 APPLYING_LOG


##迁移回原架构
转换前：
主库：单实例
备库：RAC

-装换后:
主库：RAC
备库：单实例

-主库检测状态 状态为 TO STANDBY or SESSIONS ACTIVE 都可以进行角色转换
SQL>SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
SESSIONS ACTIVE

-备库库状态检测
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
NOT ALLOWED

#切换前，要检查log file是否两端应用一致
SELECT INST_ID, SEQUENCE#, FIRST_TIME, NEXT_TIME,applied FROM gV$ARCHIVED_LOG ORDER BY SEQUENCE#;

#主库单实例切备，命令执行完，实例关闭。
SQL>ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;

#备库RAC切主
实例1上执行
alter system set cluster_database=false scope=spfile;
关闭实例1和实例2，启动实例1进行操作。

-转主操作
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
SQL> select status from v$instance;
STATUS
------------
MOUNTED

SQL> alter system set cluster_database=true scope=spfile sid='*';
关闭实例1，重新启动实例1和实例2

#在备库单实例上执行归档日志应用
启动备库：startup
select count(*) from cz.test16;

##检查：
-RAC主库
SQL> select open_mode from v$database;

OPEN_MODE
--------------------
READ ONLY WITH APPLY

-单实例备库：
SQL>SELECT SWITCHOVER_STATUS FROM V$DATABASE;

SWITCHOVER_STATUS
--------------------
SESSIONS ACTIVE



#####主备切换前提：主库挂掉，备库正常，切换完成后，当主库恢复后，主备架构丢失。######
##情况1  主库可以启动到mount 状态
#启动实例1
startup mount
SQL> ALTER SYSTEM FLUSH REDO TO 'racdbdg';

#启动实例2
startup mount
SQL> ALTER SYSTEM FLUSH REDO TO 'racdbdg';
-确保实例1和实例2都执行完成

#登录备库，进行转主操作
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

##主库彻底宕机，无法启动，需要拷贝归档日志恢复##
详见：11.2 官方参考文档data_guard.pdf 的104页


##DG的数据延迟
在主库进行DDL及DML操作，可能会出现，主库表已经执行完成，但是DG库，还是没有应用的情况。
原因是，主库没有切换归档导致的，切DG库没有应用日志导致的，当主库切换几次归档后，DG库就应用了。

#查看主备延迟
SELECT name, value, datum_time, time_computed FROM V$DATAGUARD_STATS WHERE name like 'apply lag';
SELECT * FROM V$STANDBY_EVENT_HISTOGRAM WHERE NAME = 'apply lag' AND COUNT > 0;

########主备性能监控表#######
##Monitor Redo Apply
-主库 
■ Alert log
■ V$ARCHIVE_DEST_STATUS
-备库
■ Alert log
■ V$ARCHIVED_LOG
■ V$LOG_HISTORY
■ V$MANAGED_STANDBY

##Monitor redo transport
-主库
■ V$ARCHIVE_DEST_STATUS
■ V$ARCHIVED_LOG
■ V$ARCHIVE_DEST
■ Alert log
-备库
■ V$ARCHIVED_LOG
■ Alert log库

##RAC到RAC ADG库启动方法
##实例1
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

##实例2 
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