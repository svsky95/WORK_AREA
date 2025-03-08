--主库配置
--开启FORCE LOGGING
SQL> select force_logging from v$database;
 
FOR
---
NO
 
SQL> alter database force logging;
 
Database altered.

--配置standby log files
select * from v$log;
SQL> alter database add standby logfile size 50M;
 
Database altered.
 
SQL> 
SQL> alter database add standby logfile size 50M;
 
Database altered.
 
SQL> alter database add standby logfile size 50M;
 
Database altered.
 
SQL> alter database add standby logfile size 50M;
 
Database altered.
 
SQL> 
 
SQL> select * from v$logfile;

--配置确认归档模式
SQL> show parameter db_name
 
NAME                                 TYPE       VALUE
------------------------------------ ---------- ------------------------------
db_name                              string     dg1
SQL> show parameter db_unique_name
 
NAME                                 TYPE       VALUE
------------------------------------ ---------- ------------------------------
db_unique_name                       string     dg1
SQL> alter system set log_archive_config='dg_config=(dg1,dg2)';
 
System altered.
 
SQL> alter system set log_archive_dest_2=
  2  'service=dg2 async valid_for=(online_logfile,primary_role) db_unique_name=dg2';
 
System altered.
 
SQL> alter system set standby_file_management=AUTO;  
 
System altered.
 
SQL> 
 
SQL> archive log list;
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     7
Next log sequence to archive   9
Current log sequence           9
SQL> exit;

--主库配置TNS
DG1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = DG1)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = DG1)
    )
  )

DG2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = DG2)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = DG2)
    )
  )
  

--备库环境变量
[oracle@DG2 ~]$ more .bash_profile
export PATH
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
ORACLE_SID=DG2
PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin
LD_LIBRARY_PATH=$ORACLE_HOME/lib
export ORACLE_BASE ORACLE_HOME ORACLE_SID PATH LD_LIBRARY_PATH
export NLS_LANG=AMERICAN_AMERICA.UTF8
umask 022

--创建密码文件
方法1、
orapwd file='/u01/app/oracle/product/11.2.0/db_1/dbs/orapwsxfxdb' password=12345678 entries=10
scp orapwDG1 dg2:/u01/app/oracle/product/11.2.0/db_1/dbs/orapwDG2
方法2、修改主库的sys用户密码，之后直接把密码文件拷贝到备库
alter user sys identified by "12345678";

--拷贝参数文件并编辑
scp initDG1.ora dg2:/u01/app/oracle/product/11.2.0/db_1/dbs/initDG2.ora

DG2.__db_cache_size=1895825408
DG2.__java_pool_size=33554432
DG2.__large_pool_size=50331648
DG2.__oracle_base='/u01/app/oracle'#ORACLE_BASE set from environment
DG2.__pga_aggregate_target=1077721600
DG2.__sga_target=2506582400
DG2.__shared_io_pool_size=0
DG2.__shared_pool_size=503316480
DG2.__streams_pool_size=0
*.memory_target=3584866816
*.audit_file_dest='/u01/app/oracle/admin/DG2/adump'
*.audit_trail='db'
*.compatible='11.2.0.4.0'
*.control_files='/oracle/ora_data/DG2/control01.ctl','/oracle/fast_recovery_area/DG2/control02.ctl'     
*.db_block_size=8192
*.db_domain=''
*.db_name='DG2'
*.db_recovery_file_dest='/oracle/fast_recovery_area'
*.db_recovery_file_dest_size=10737418240
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=DG1XDB)'
*.log_archive_dest_1='LOCATION=/oracle/ARCH'
*.log_archive_format='%t_%s_%r.dbf'
*.open_cursors=300
*.processes=150
*.remote_login_passwordfile='EXCLUSIVE'
*.sessions=170
*.undo_tablespace='UNDOTBS1'
*.DB_UNIQUE_NAME='DG2'
*.db_file_name_convert='/oracle/ora_data/DG1/','/oracle/ora_data/DG2/'     --需要改变数据文件的存放路径  --DG1 存放数据文件的位置/oracle/ora_data/DG1/  --DG2 重新指定存放数据文件的位置/oracle/ora_data/DG2/
*.log_file_name_convert='/oracle/ora_data/DG1/','/oracle/ora_data/DG2/'    --重新定向redo.log 的位置
*.fal_client='DG2'
*.fal_server='DG1'
*.log_archive_config='DG_CONFIG=(DG1,DG2)'
*.log_archive_dest_1='LOCATION=/oracle/dg2_archlog LGWR VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DG2'  --DG2归档日志存放路径
*.log_archive_dest_2='SERVICE=DG1 ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DG1'
*.log_archive_dest_state_1='ENABLE'
*.log_archive_dest_state_2='ENABLE'
*.standby_file_management='AUTO'


--依次在库中创建缺少的目录及存放备份文件的目录
--创建audit文件
mkdir -p /u01/app/oracle/admin/DG2/adump
--创建控制文件
mkdir -p /oracle/ora_data/dg2  
mkdir -p /oracle/fast_recovery_area/dg2
--归档日志文件
mkdir -p /oracle/dg2_archlog



[oracle@DG1 admin]$ scp listener.ora tnsnames.ora dg2:/u01/app/oracle/product/11.2.0/db_1/network/

--vi listener.ora
SID_LIST_LISTENER =  
  (SID_LIST =  
    (SID_DESC =  
      (GLOBAL_DBNAME = DG2)  
      (SID_NAME = DG2)  
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)  
    )  
  )  
  
LISTENER =  
  (DESCRIPTION_LIST =  
    (DESCRIPTION =  
      (ADDRESS = (PROTOCOL = TCP)(HOST = DG2)(PORT = 1521))  
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC0))  
    )  
  )  
  
--vi tnsnames.ora
DG1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = DG1)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = DG1)
    )
  )

DG2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = DG2)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = DG2)
    )
  )
  
--查看监听状态
lsnrctl status
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.4.0 - Production
Start Date                29-SEP-2017 22:00:02
Uptime                    0 days 2 hr. 24 min. 12 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/DG2/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DG2)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC0)))
Services Summary...
Service "DG2" has 2 instance(s).
  Instance "DG2", status UNKNOWN, has 1 handler(s) for this service...
  Instance "DG2", status READY, has 1 handler(s) for this service...
The command completed successfully

--启动备库
startup nomount pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initDG2.ora'

--给主库进行全库备份
rman target /
--配置自动控制文件备份
configure controlfile autobackup format for device type disk to '/oracle/oraclebackup/controlfile/%F';
--执行全备命令并备份归档日志
backup device type disk format '/oracle/oraclebackup/datafile/%U' database plus archivelog;

--备份复制及备库还原（在主库上执行）
rman target sys/12345678@DG1 auxiliary sys/12345678@DG2
connected to target database: DG1 (DBID=1937275811)
connected to auxiliary database: DG2 (not mounted)

--执行复制
duplicate target database to DG2 from active database nofilenamecheck;




run {
allocate channel prmy1 type disk;
allocate channel prmy2 type disk;
allocate channel prmy3 type disk;
allocate channel prmy4 type disk;
allocate channel prmy5 type disk;
allocate auxiliary channel stby1 type disk;
duplicate target database for standby from active database nofilenamecheck
spfile
set 'db_unique_name'='DG2'
set control_files='/oracle/ora_data/DG2/control01.ctl','/oracle/fast_recovery_area/DG2/control02.ctl'
set db_recovery_file_dest='/oracle/fast_recovery_area'
set DB_RECOVERY_FILE_DEST_SIZE='100G'
set db_file_name_convert='/oracle/ora_data/DG1/','/oracle/ora_data/DG2/'
set log_file_name_convert='/oracle/ora_data/dg1/','/oracle/ora_data/DG2/'
set log_archive_config='DG_CONFIG=(DG1,DG2)'
set log_archive_dest_1='LOCATION=/oracle/dg2_archlog LGWR VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DG2'
set log_archive_dest_2='SERVICE=DG1 ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DG1'
set standby_file_management='AUTO';
}

--DataGuard Broker配置
1、主库和从库开启dg_broker
ALTER SYSTEM SET dg_broker_start=TRUE SCOPE=BOTH;
--主库
SQL> ! ps -ef | grep ora_dmon
oracle    4633     1  0 23:15 ?        00:00:00 ora_dmon_DG1

--备库
SQL> ! ps -ef | grep ora_dmon
oracle    5968     1  0 09:35 ?        00:00:00 ora_dmon_DG2

2、配置静态监听器（主从配置）
--主库
LISTENER =
  (ADDRESS_LIST=
       (ADDRESS=(PROTOCOL=tcp)(HOST=DG1)(PORT=1521))
       (ADDRESS=(PROTOCOL=ipc)(KEY=PNPKEY)))
SID_LIST_LISTENER=
   (SID_LIST=
       (SID_DESC=
          (GLOBAL_DBNAME=DG1)
          (SID_NAME=DG1)
          (ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1)
    )
   (SID_DESC=
          (GLOBAL_DBNAME=DG1_DGMGRL)
          (SID_NAME=DG1)
          (ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1)
    )
 )
ADR_BASE_LISTENER = /u01/app/oracle

Services Summary...
Service "DG1" has 1 instance(s).
  Instance "DG1", status UNKNOWN, has 1 handler(s) for this service...
Service "DG1_DGMGRL" has 1 instance(s).
  Instance "DG1", status UNKNOWN, has 1 handler(s) for this service...
The command completed successfully

--备库
LISTENER =
  (ADDRESS_LIST=
       (ADDRESS=(PROTOCOL=tcp)(HOST=DG2)(PORT=1521))
       (ADDRESS=(PROTOCOL=ipc)(KEY=PNPKEY)))
SID_LIST_LISTENER=
   (SID_LIST=
       (SID_DESC=
          (GLOBAL_DBNAME=DG2)
          (SID_NAME=DG2)
          (ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1)
    )
   (SID_DESC=
          (GLOBAL_DBNAME=DG2_DGMGRL)
          (SID_NAME=DG2)
          (ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1)
    )
 )
ADR_BASE_LISTENER = /u01/app/oracle

Services Summary...
Service "DG2" has 1 instance(s).
  Instance "DG2", status UNKNOWN, has 1 handler(s) for this service...
Service "DG2_DGMGRL" has 1 instance(s).
  Instance "DG2", status UNKNOWN, has 1 handler(s) for this service...
The command completed successfully

--创建broker的配置文件（主库执行）
此步骤一定要在主库上执行,<database name>指定的是DB_UNIQUE_NAME,而不是DB_NAME
--添加DG1
DGMGRL> create configuration 'DGConfig1' as primary database is 'DG1' CONNECT IDENTIFIER IS DG1;
Configuration "DGConfig1" created with primary database "DG1"
--添加DG2
DGMGRL> add database 'DG2' as connect identifier is DG2;
Database "DG2" added
DGMGRL> enable configuration;
Enabled.
DGMGRL>  show configuration;

Configuration - DGConfig1

  Protection Mode: MaxPerformance
  Databases:
    DG1 - Primary database
    DG2 - Physical standby database

Fast-Start Failover: DISABLED

Configuration Status:
SUCCESS

--查看节点配置 --因为配置的使用用户是引号，固定大写，所以一定要加单引号
show database verbose 'DG1';

--执行切换验证
DGMGRL> switchover to 'DG2';
Performing switchover NOW, please wait...
Operation requires a connection to instance "DG2" on database "DG2"
Connecting to instance "DG2"...
Connected.
New primary database "DG2" is opening...
Operation requires startup of instance "DG1" on database "DG1"
Starting instance "DG1"...
ORACLE instance started.
Database mounted.
Database opened.
Switchover succeeded, new primary is "DG2

--主库切换为standby
select database_role from v$database;
--
PHYSICAL STANDBY
--

--备库切换为主库
--
PRIMARY
--
切换完成后，原来的备库就有了写的权限，创建的数据，都会同步到原来的主库上。

--DG broker 管理
--查看配置
show configuration verbose;
--查看节点配置
DGMGRL> show configuration;
