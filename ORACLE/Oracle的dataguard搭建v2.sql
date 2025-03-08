（1）
主库安装数据库，备库只安装软件，我们可以采用在主库装完软件的时候对虚拟机进行复制。
主库在用dbca建库的时候，全局数据库选择szscpdb，sid选择szsc。


（2）
配置主库和备库信息
主库：
操作系统：oracle liunx 6.7
主机名：DG1
ip地址：10.10.8.21
oracle_sid：DG1                   --oracle的SID,为了区别应该与主机名不同
db_unqiue_name：DG1
service_name：DG1
global_name：DG1
监听名、端口：listener、1521


备库：
操作系统：oracle liunx 6.7
主机名：DG2
ip地址：10.10.8.22
oracle_sid：DG1
db_unqiue_name：DG2
service_name:DG2
global_name：DG2
监听名、端口：listener、1521

--主库配置文件
export PATH
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
ORACLE_SID=DG1
PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin
LD_LIBRARY_PATH=$ORACLE_HOME/lib
export ORACLE_BASE ORACLE_HOME ORACLE_SID PATH LD_LIBRARY_PATH
export NLS_LANG=AMERICAN_AMERICA.UTF8
umask 022

--备库配置文件
export PATH
export PATH
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
ORACLE_SID=DG1                                         --主备连接的实例名相同
PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin
LD_LIBRARY_PATH=$ORACLE_HOME/lib
export ORACLE_BASE ORACLE_HOME ORACLE_SID PATH LD_LIBRARY_PATH
export NLS_LANG=AMERICAN_AMERICA.UTF8
umask 022


（3）
查看主库和备库的hosts文件，确定ip和主机名的解析：
主库：
[oracle@SZSCPDB szscpdb]$ cat /etc/hosts
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1       localhost.localdomain localhost
::1             localhost6.localdomain6 localhost6
10.10.8.21  DG1
10.10.8.22  DG2


备库：
[oracle@SZSCSTB szscstb]$ cat /etc/hosts
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1       localhost.localdomain localhost
::1             localhost6.localdomain6 localhost6
10.10.8.21  DG1
10.10.8.22  DG2




（4）
--主库
给主库配置静态注册

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = DG1)
      (SID_NAME = DG1)
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST =DG1)(PORT = 1521))
    )
  )
ADR_BASE_LISTENER = /u01/app/oracle
--查看状态
[oracle@SZSCPDB szscpdb]$ lsnrctl status


LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 15-DEC-2013 15:30:42


Copyright (c) 1991, 2011, Oracle.  All rights reserved.


Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=SZSCPDB)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.4.0 - Production
Start Date                03-OCT-2017 01:23:13
Uptime                    0 days 9 hr. 47 min. 59 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/DG1/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=DG1)(PORT=1521)))
Services Summary...
Service "DG1" has 2 instance(s).
  Instance "DG1", status UNKNOWN, has 1 handler(s) for this service...
  Instance "DG1", status READY, has 1 handler(s) for this service...
Service "DG1XDB" has 1 instance(s).
  Instance "DG1", status READY, has 1 handler(s) for this service...
The command completed successfully

--TNS配置
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
      (SERVICE_NAME = DG1)
    )
  )




（5）
--备库
给备库配置静态注册
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = DG1)
      (SID_NAME = DG1)
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST =DG2)(PORT = 1521))
    )
  )
--备库TNS与主库的相同
--可以吧配置好的文件直接拷贝到备库相应的位置
--测试主库和备库的连通性
tnsping DG1
tnsping DG2


（6）
--主库
配置主库为归档模式：
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /arch/szscpdb
Oldest online log sequence     3
Next log sequence to archive   5
Current log sequence           5


更改主库为force logging
SQL> alter database force logging;
Database altered.


--创建主库的密码文件
修改sys的密码
SQL>alter user sys identified by "1234567";
[root@SZSCPDB dbs]# cd /u01/app/oracle/product/11.2.0/db_1/dbs/
[root@SZSCPDB dbs]# orapwd file=$ORACLE_HOME/dbs/orapwszsc password=1234567 entries=30;   --生成sys的密码，用于连接RMAN



（10）
修改主库的参数文件：
--1、生成参数文件
create pfile from spfile.
--2、编辑参数文件
[oracle@DG1 dbs]$ vi initDG1.ora   --在最后添加如下内容
*.DB_UNIQUE_NAME='DG1'
*.db_file_name_convert='/oracle/dg2/','/oracle/dg1/'
*.log_file_name_convert='/oracle/dg2/','/oracle/dg1/'
*.fal_client='DG1'
*.fal_server='DG2'
*.log_archive_config='DG_CONFIG=(DG1,DG2)'
*.log_archive_dest_1='LOCATION=/oracle/dg1_archlog LGWR VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DG1'
*.log_archive_dest_2='SERVICE=DG2 ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DG2'
*.log_archive_dest_state_1='ENABLE'
*.log_archive_dest_state_2='ENABLE'
*.standby_file_management='AUTO'
--使用pfile启动数据库，或者用pfile重新生成spfile
startup pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initDG1.ora'


--修改备库的参数文件
把主库生成的pfile文件及密码文件拷贝到备库相同的位置（切记不要改名字）
[oracle@DG2 dbs]$ vi initDG1.ora
*.DB_UNIQUE_NAME='DG2'
*.db_file_name_convert='/oracle/dg1/','/oracle/dg2/'
*.log_file_name_convert='/oracle/dg1/','/oracle/dg2/'
*.fal_client='DG2'
*.fal_server='DG1'
*.log_archive_config='DG_CONFIG=(DG1,DG2)'
*.log_archive_dest_1='LOCATION=/oracle/dg2_archlog LGWR VALID_FOR=(ALL_LOGFILES,ALL_ROLES) DB_UNIQUE_NAME=DG2'
*.log_archive_dest_2='SERVICE=DG1 ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=DG1'
*.log_archive_dest_state_1='ENABLE'
*.log_archive_dest_state_2='ENABLE'
*.standby_file_management='AUTO'

                                                                                            
--主备库创建相应的文件夹,目录相同且对应 使用oracle用户创建                                                                                        
在备库上创建相应的目录，因为备库开始没有创建数据库，有些目录是参数文件中没有的。
1、
audit_file_dest：
[oracle@SZSCSTB ~]$ mkdir -p /u01/app/oracle/admin/DG2/adump


2、
control_files：
[oracle@SZSCSTB ~]$ mkdir -p /oracle/ora_data/DG2
                    mkdir -p /oracle/fast_recovery_area/DG2

3、fast_recovery_area 
mkdir -p /oracle/fast_recovery_area

4、创建一个归档目录，接收主库传递的归档日志
mkdir -p /oracle/dg2_archlog

5、创建一个备份文件的位置，等会主库会将备份传递过来：
--存放控制文件备份
mkdir -p /oracle/oraclebackup/controlfile     
--存档数据文件备份
mkdir -p /oracle/oraclebackup/datafile
6、创建目录
mkdir -p /oracle/dg2/

（15）
在主库上用rman做一个全备，也需要创建备份的目录：
rman target /
--配置自动控制文件备份
configure controlfile autobackup format for device type disk to '/oracle/oraclebackup/controlfile/%F';
--执行全备命令并备份归档日志
backup device type disk format '/oracle/oraclebackup/datafile/%U' database plus archivelog;
 

（16）
将主库的备份文件及控制文件传递到备库上：
[oracle@DG1 oracle]$ cd oraclebackup/controlfile/
scp * dg2:/oracle/oraclebackup/controlfile
[oracle@DG1 oracle]$ cd /oracle/oraclebackup/datafile/
scp * dg2:/oracle/oraclebackup/datafile/


（17）
--将备库启动到nomount状态,使用DG1生成的参数文件启动：
startup nomount pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initDG1.ora'

--备库
在备库上执行恢复
rman target sys/1234567@dg1 auxiliary sys/1234567@dg2
duplicate target database to DG1  from active database nofilenamecheck;

--输出内容
channel ORA_AUX_DISK_1: starting datafile backup set restore
channel ORA_AUX_DISK_1: restoring control file
channel ORA_AUX_DISK_1: reading from backup piece /BACKUP/0lo3vm4i_1_1
channel ORA_AUX_DISK_1: piece handle=/backup/0lo3vm4i_1_1 tag=TAG20130308T022752
channel ORA_AUX_DISK_1: restored backup piece 1
channel ORA_AUX_DISK_1: restore complete, elapsed time: 00:00:02
output file name=/u01/app/oracle/oradata/szscstb/control01.ctl
output file name=/u01/app/oracle/oradata/szscstb/control02.ctl
Finished restore at 08-MAR-13
contents of Memory Script.:
{
   sql clone 'alter database mount standby database';
}
executing Memory Script
sql statement: alter database mount standby database
contents of Memory Script.:
{
   set newname for tempfile  1 to 
 "/u01/app/oracle/oradata/szscstb/temp01.dbf";
   switch clone tempfile all;
   set newname for datafile  1 to 
 "/u01/app/oracle/oradata/szscstb/system01.dbf";
   set newname for datafile  2 to 
 "/u01/app/oracle/oradata/szscstb/sysaux01.dbf";
   set newname for datafile  3 to 
 "/u01/app/oracle/oradata/szscstb/undotbs01.dbf";
   set newname for datafile  4 to 
 "/u01/app/oracle/oradata/szscstb/users01.dbf";
   restore
   clone database
   ;
}
executing Memory Script
executing command: SET NEWNAME
renamed tempfile 1 to /u01/app/oracle/oradata/szscstb/temp01.dbf in control file
executing command: SET NEWNAME
executing command: SET NEWNAME
executing command: SET NEWNAME
executing command: SET NEWNAME
Starting restore at 08-MAR-13
using channel ORA_AUX_DISK_1
channel ORA_AUX_DISK_1: starting datafile backup set restore
channel ORA_AUX_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_AUX_DISK_1: restoring datafile 00001 to //u01/app/oracle/oradata/szscstb/system01.dbf
channel ORA_AUX_DISK_1: restoring datafile 00002 to /u01/app/oracle/oradata/szscstb/sysaux01.dbf
channel ORA_AUX_DISK_1: restoring datafile 00003 to /u01/app/oracle/oradata/szscstb/undotbs01.dbf
channel ORA_AUX_DISK_1: restoring datafile 00004 to /u01/app/oracle/oradata/szscstb/users01.dbf
channel ORA_AUX_DISK_1: reading from backup piece /backup/0ko3vm18_1_1
channel ORA_AUX_DISK_1: piece handle=/backup/0ko3vm18_1_1 tag=TAG20130308T022752
channel ORA_AUX_DISK_1: restored backup piece 1
channel ORA_AUX_DISK_1: restore complete, elapsed time: 00:02:05
Finished restore at 08-MAR-13
contents of Memory Script.:
{
   switch clone datafile all;
}
executing Memory Script
datafile 1 switched to datafile copy
input datafile copy RECID=2 STAMP=809491977 file name=/u01/app/oracle/oradata/szscstb/system01.dbf
datafile 2 switched to datafile copy
input datafile copy RECID=3 STAMP=809491977 file name=/u01/app/oracle/oradata/szscstb/sysaux01.dbf
datafile 3 switched to datafile copy
input datafile copy RECID=4 STAMP=809491977 file name=/u01/app/oracle/oradata/szscstb/undotbs01.dbf
datafile 4 switched to datafile copy
input datafile copy RECID=5 STAMP=809491977 file name=/u01/app/oracle/oradata/szscstb/users01.dbf
Finished Duplicate Db at 08-MAR-13




（21）
执行备库恢复模式。（在备库上执行）
SQL> select instance_name,status from v$instance;
INSTANCE_NAME    STATUS
---------------- ------------
szsc               MOUNTED


SQL> alter database recover managed standby database disconnect from session;
Database altered.

--只是启动时会报错
ORA-01665: control file is not a standby control file
需要在备库上执行控制文件恢复
1、在主库上生成备份控制文件
RMAN>backup current controlfile for standby format '/oracle/dg1ctl.stdy'; 

2、复制到备库
scp dg1ctl.stdy dg2:/oracle

3、执行备库恢复--备库必须处于nomount状态
RMAN> restore standby controlfile from '/oracle/dg1ctl.stdy'; 

控制文件恢复后，需要启动数据库到mount状态。
SQL> alter database mount

4、备库执行介质恢复
RMAN>restore database
RMAN>recover database    --会提示找不到某个SCN号，没有关系

--关闭数据库
SQL> shutdown immediate

--指定参数文件启动
startup nomount pfile='initDG2.ora';

5、数据库可以恢复控制文件后，检查v$database的controlfile_type，已经是我们需要的类型了。 

SQL> alter database mount standby database; 

Database altered. 

SQL> select controlfile_type from v$database; 

CONTROL 
------- 
STANDBY 


（22）
查看日志同步情况，确保日志都应用了。
SQL> SELECT SEQUENCE#, REGISTRAR, FIRST_TIME, NEXT_TIME, APPLIED
  2  FROM V$ARCHIVED_LOG ORDER BY SEQUENCE#;
 SEQUENCE# REGISTRAR             FIRST_TIME      NEXT_TIME       APPLIED
---------- --------------------- --------------- --------------- ---------------------------
        27 SRMN                  03-OCT-17       03-OCT-17       YES
        28 SRMN                  03-OCT-17       03-OCT-17       YES
        29 RFS                   03-OCT-17       03-OCT-17       YES
        30 RFS                   03-OCT-17       03-OCT-17       YES
        31 RFS                   03-OCT-17       03-OCT-17       YES
        32 RFS                   03-OCT-17       03-OCT-17       YES
        33 RFS                   03-OCT-17       03-OCT-17       YES

（23）
创建standby logfile。主库和备库都要添加。
主库：
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg1/sredo01.log' size 512M; 
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg1/sredo02.log' size 512M; 
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg1/sredo03.log' size 512M; 


备库：
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg2/sredo01.log' size 512M; 
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg2/sredo02.log' size 512M; 
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg2/sredo03.log' size 512M; 




（24）
实现日志同步。（备库上执行）
--主库切换日志备库才可看到数据
SQL> alter database recover managed standby database disconnect from session;
--实时应用日志
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;

完成之后，结束这个恢复进程：不结束也可以
SQL> alter database recover managed standby database cancel;
PS：停止standby的redo应用 ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;注意，此时只是暂时redo 应用，并不是停止Standby 数据库，standby 仍会保持接收只不过不会再应用接收到的归档，直到你再次启动redo 应用为止。类似mysql里面的stop slave功能;

将备库启动到open read only的状态。
SQL> alter database open read only;
--有时候可以直接用，备库启动时也是read only 状态
alter database open;

--查看状态
SQL> select open_mode from v$database;

OPEN_MODE
------------------------------------------------------------
READ ONLY WITH APPLY

--配置自动同步（备库重启后，需要重新开启自动同步）
备库上接收数据，并自动同步：
SQL> alter database recover managed standby database using current logfile disconnect from session;
Database altered.

（25）
查看主库和备库的日志同步情况，确保已经同步。（如果没有同步，继续第24步）
主库：
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /arch/szscpdb
Oldest online log sequence     21
Next log sequence to archive   23
Current log sequence           23


备库：
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /arch/szscstb
Oldest online log sequence     21
Next log sequence to archive   0
Current log sequence           23

--验证
在主库上创建表，查看备库的同步情况
如果28步没有问题，那么就代表你的DG配置成功了。下一阶段就是实现switchover了。


##关于主库归档日志的说明
1、在Data Guard环境里面，对归档日志管理需要达到以下几个方面的要求或者说是需求：

不能够随意删除掉归档日志，归档日志丢失会导致Data Guard需要重新搭建。
不能随意使用RMAN删除归档日志，否则同样会导致Data Guard需要重新搭建。
在使用RMAN备份后，如果归档没有被传送或应用到备库上，那么RMAN不应该删除归档日志，否则Data Guard需要的归档就必须从备份里面还原出来，增加了维护工作量。
对RMAN的备份脚本没有特别的要求，否则脚本意外改动，可能会导致Data Guard需要的归档日志被删除。
归档应尽量保存在磁盘上，以避免Data Guard长时间维护时归档被删除。
备库的归档日志不需要花精力去维护，自动删除已经应用过的归档日志。

2、幸运的是，在11g环境里面，上述的几点很容易就满足，那就是只需要做到以下几点：

使用快速恢复区(fast recovery area)，在10g版本的文档中称为闪回恢复区（flash recovery area），老实说，一直不太明白为什么取名叫闪回恢复区，难道是因为10g有了数据库闪回功能？在RAC中，毫无疑问快速恢复区最好是置放在ASM上。
为快速恢复区指定合适的空间。首先我们需要预估一个合理的归档保留时间长。比如由于备份系统问题或Data Guard备库问题、维护等，需要归档保留的时间长度。假设是24小时，再评估一下在归档量最大的24小时之内，会有多少量的归档？一般来说是在批量数据处理的时候归档量最大，假设这24小时之内归档最大为200G。注意对于RAC来说是所有节点在这24小时的归档量之和。最后为快速恢复区指定需要的空间量，比通过参数db_recovery_file_dest_size指定快速恢复区的大小。这里同样假设快速恢复区们存放归档日志。
在备库上指定快速恢复区以及为快速恢复区指定合适的大小，在备库上指定快速恢复区的大小主要考虑的是：切换成为主库后归档日志容量；如果主库归档容量压力大，备库能否存储更多的归档日志以便可以通过备库来备份归档日志。
对主库和备份使用RMAN配置归档删除策略：CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;

3、完成1和2两个步骤，可以基本满足要求：
归档日志如果没有应用到备库，那么在RMAN中使用backup .... delete inputs all和delete archivelog all不会将归档日志删除。但但是请注意如果是使用delete force命令则会删除掉归档，不管归档有没有被应用到备库。
如果归档日志已经应用到了备库，那么在RMAN中使用backup .... delete inputs all和delete archivelog all可以删除归档日志，在正常情况下，由于归档日志可能很快应用到Data Guard，所以在RMAN备份之后可以正常删除归档日志。RMAN也不需要使用特别的备份脚本，也不必担心人为不小心使用。delete archivelog all命令删除了归档。
备库的归档日志存储到快速恢复区中，备库的快速恢复区空间紧张时，会自动删除已经应用过的较早的归档日志以释放空间，这样便可以实现备库的归档日志完全自动管理。
如果由于备份异常或Data Guard异常，在快速恢复区空间紧张时，Oracle在切换日志时，会自动删除掉已经应用过的归档日志，以释放空间。但是如果归档日志没有应用到Data Guard，那么归档日志不会被删除。这种情况下，快速恢复区的归档可能会增加到空间耗尽，最后就会出现数据库不能归档，数据库挂起的问题。
