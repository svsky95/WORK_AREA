��1��
���ⰲװ���ݿ⣬����ֻ��װ��������ǿ��Բ���������װ�������ʱ�����������и��ơ�
��������dbca�����ʱ��ȫ�����ݿ�ѡ��szscpdb��sidѡ��szsc��


��2��
��������ͱ�����Ϣ
���⣺
����ϵͳ��oracle liunx 6.7
��������DG1
ip��ַ��10.10.8.21
oracle_sid��DG1                   --oracle��SID,Ϊ������Ӧ������������ͬ
db_unqiue_name��DG1
service_name��DG1
global_name��DG1
���������˿ڣ�listener��1521


���⣺
����ϵͳ��oracle liunx 6.7
��������DG2
ip��ַ��10.10.8.22
oracle_sid��DG1
db_unqiue_name��DG2
service_name:DG2
global_name��DG2
���������˿ڣ�listener��1521

--���������ļ�
export PATH
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
ORACLE_SID=DG1
PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin
LD_LIBRARY_PATH=$ORACLE_HOME/lib
export ORACLE_BASE ORACLE_HOME ORACLE_SID PATH LD_LIBRARY_PATH
export NLS_LANG=AMERICAN_AMERICA.UTF8
umask 022

--���������ļ�
export PATH
export PATH
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
ORACLE_SID=DG1                                         --�������ӵ�ʵ������ͬ
PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin
LD_LIBRARY_PATH=$ORACLE_HOME/lib
export ORACLE_BASE ORACLE_HOME ORACLE_SID PATH LD_LIBRARY_PATH
export NLS_LANG=AMERICAN_AMERICA.UTF8
umask 022


��3��
�鿴����ͱ����hosts�ļ���ȷ��ip���������Ľ�����
���⣺
[oracle@SZSCPDB szscpdb]$ cat /etc/hosts
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1       localhost.localdomain localhost
::1             localhost6.localdomain6 localhost6
10.10.8.21  DG1
10.10.8.22  DG2


���⣺
[oracle@SZSCSTB szscstb]$ cat /etc/hosts
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1       localhost.localdomain localhost
::1             localhost6.localdomain6 localhost6
10.10.8.21  DG1
10.10.8.22  DG2




��4��
--����
���������þ�̬ע��

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
--�鿴״̬
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

--TNS����
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




��5��
--����
���������þ�̬ע��
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
--����TNS���������ͬ
--���԰����úõ��ļ�ֱ�ӿ�����������Ӧ��λ��
--��������ͱ������ͨ��
tnsping DG1
tnsping DG2


��6��
--����
��������Ϊ�鵵ģʽ��
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /arch/szscpdb
Oldest online log sequence     3
Next log sequence to archive   5
Current log sequence           5


��������Ϊforce logging
SQL> alter database force logging;
Database altered.


--��������������ļ�
�޸�sys������
SQL>alter user sys identified by "1234567";
[root@SZSCPDB dbs]# cd /u01/app/oracle/product/11.2.0/db_1/dbs/
[root@SZSCPDB dbs]# orapwd file=$ORACLE_HOME/dbs/orapwszsc password=1234567 entries=30;   --����sys�����룬��������RMAN



��10��
�޸�����Ĳ����ļ���
--1�����ɲ����ļ�
create pfile from spfile.
--2���༭�����ļ�
[oracle@DG1 dbs]$ vi initDG1.ora   --����������������
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
--ʹ��pfile�������ݿ⣬������pfile��������spfile
startup pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initDG1.ora'


--�޸ı���Ĳ����ļ�
���������ɵ�pfile�ļ��������ļ�������������ͬ��λ�ã��мǲ�Ҫ�����֣�
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

                                                                                            
--�����ⴴ����Ӧ���ļ���,Ŀ¼��ͬ�Ҷ�Ӧ ʹ��oracle�û�����                                                                                        
�ڱ����ϴ�����Ӧ��Ŀ¼����Ϊ���⿪ʼû�д������ݿ⣬��ЩĿ¼�ǲ����ļ���û�еġ�
1��
audit_file_dest��
[oracle@SZSCSTB ~]$ mkdir -p /u01/app/oracle/admin/DG2/adump


2��
control_files��
[oracle@SZSCSTB ~]$ mkdir -p /oracle/ora_data/DG2
                    mkdir -p /oracle/fast_recovery_area/DG2

3��fast_recovery_area 
mkdir -p /oracle/fast_recovery_area

4������һ���鵵Ŀ¼���������⴫�ݵĹ鵵��־
mkdir -p /oracle/dg2_archlog

5������һ�������ļ���λ�ã��Ȼ�����Ὣ���ݴ��ݹ�����
--��ſ����ļ�����
mkdir -p /oracle/oraclebackup/controlfile     
--�浵�����ļ�����
mkdir -p /oracle/oraclebackup/datafile
6������Ŀ¼
mkdir -p /oracle/dg2/

��15��
����������rman��һ��ȫ����Ҳ��Ҫ�������ݵ�Ŀ¼��
rman target /
--�����Զ������ļ�����
configure controlfile autobackup format for device type disk to '/oracle/oraclebackup/controlfile/%F';
--ִ��ȫ��������ݹ鵵��־
backup device type disk format '/oracle/oraclebackup/datafile/%U' database plus archivelog;
 

��16��
������ı����ļ��������ļ����ݵ������ϣ�
[oracle@DG1 oracle]$ cd oraclebackup/controlfile/
scp * dg2:/oracle/oraclebackup/controlfile
[oracle@DG1 oracle]$ cd /oracle/oraclebackup/datafile/
scp * dg2:/oracle/oraclebackup/datafile/


��17��
--������������nomount״̬,ʹ��DG1���ɵĲ����ļ�������
startup nomount pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initDG1.ora'

--����
�ڱ�����ִ�лָ�
rman target sys/1234567@dg1 auxiliary sys/1234567@dg2
duplicate target database to DG1  from active database nofilenamecheck;

--�������
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




��21��
ִ�б���ָ�ģʽ�����ڱ�����ִ�У�
SQL> select instance_name,status from v$instance;
INSTANCE_NAME    STATUS
---------------- ------------
szsc               MOUNTED


SQL> alter database recover managed standby database disconnect from session;
Database altered.

--ֻ������ʱ�ᱨ��
ORA-01665: control file is not a standby control file
��Ҫ�ڱ�����ִ�п����ļ��ָ�
1�������������ɱ��ݿ����ļ�
RMAN>backup current controlfile for standby format '/oracle/dg1ctl.stdy'; 

2�����Ƶ�����
scp dg1ctl.stdy dg2:/oracle

3��ִ�б���ָ�--������봦��nomount״̬
RMAN> restore standby controlfile from '/oracle/dg1ctl.stdy'; 

�����ļ��ָ�����Ҫ�������ݿ⵽mount״̬��
SQL> alter database mount

4������ִ�н��ʻָ�
RMAN>restore database
RMAN>recover database    --����ʾ�Ҳ���ĳ��SCN�ţ�û�й�ϵ

--�ر����ݿ�
SQL> shutdown immediate

--ָ�������ļ�����
startup nomount pfile='initDG2.ora';

5�����ݿ���Իָ������ļ��󣬼��v$database��controlfile_type���Ѿ���������Ҫ�������ˡ� 

SQL> alter database mount standby database; 

Database altered. 

SQL> select controlfile_type from v$database; 

CONTROL 
------- 
STANDBY 


��22��
�鿴��־ͬ�������ȷ����־��Ӧ���ˡ�
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

��23��
����standby logfile������ͱ��ⶼҪ��ӡ�
���⣺
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg1/sredo01.log' size 512M; 
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg1/sredo02.log' size 512M; 
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg1/sredo03.log' size 512M; 


���⣺
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg2/sredo01.log' size 512M; 
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg2/sredo02.log' size 512M; 
SQL> ALTER DATABASE ADD STANDBY LOGFILE '/oracle/dg2/sredo03.log' size 512M; 




��24��
ʵ����־ͬ������������ִ�У�
--�����л���־����ſɿ�������
SQL> alter database recover managed standby database disconnect from session;
--ʵʱӦ����־
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;

���֮�󣬽�������ָ����̣�������Ҳ����
SQL> alter database recover managed standby database cancel;
PS��ֹͣstandby��redoӦ�� ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;ע�⣬��ʱֻ����ʱredo Ӧ�ã�������ֹͣStandby ���ݿ⣬standby �Իᱣ�ֽ���ֻ����������Ӧ�ý��յ��Ĺ鵵��ֱ�����ٴ�����redo Ӧ��Ϊֹ������mysql�����stop slave����;

������������open read only��״̬��
SQL> alter database open read only;
--��ʱ�����ֱ���ã���������ʱҲ��read only ״̬
alter database open;

--�鿴״̬
SQL> select open_mode from v$database;

OPEN_MODE
------------------------------------------------------------
READ ONLY WITH APPLY

--�����Զ�ͬ����������������Ҫ���¿����Զ�ͬ����
�����Ͻ������ݣ����Զ�ͬ����
SQL> alter database recover managed standby database using current logfile disconnect from session;
Database altered.

��25��
�鿴����ͱ������־ͬ�������ȷ���Ѿ�ͬ���������û��ͬ����������24����
���⣺
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /arch/szscpdb
Oldest online log sequence     21
Next log sequence to archive   23
Current log sequence           23


���⣺
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /arch/szscstb
Oldest online log sequence     21
Next log sequence to archive   0
Current log sequence           23

--��֤
�������ϴ������鿴�����ͬ�����
���28��û�����⣬��ô�ʹ������DG���óɹ��ˡ���һ�׶ξ���ʵ��switchover�ˡ�


##��������鵵��־��˵��
1����Data Guard�������棬�Թ鵵��־������Ҫ�ﵽ���¼��������Ҫ�����˵������

���ܹ�����ɾ�����鵵��־���鵵��־��ʧ�ᵼ��Data Guard��Ҫ���´��
��������ʹ��RMANɾ���鵵��־������ͬ���ᵼ��Data Guard��Ҫ���´��
��ʹ��RMAN���ݺ�����鵵û�б����ͻ�Ӧ�õ������ϣ���ôRMAN��Ӧ��ɾ���鵵��־������Data Guard��Ҫ�Ĺ鵵�ͱ���ӱ������滹ԭ������������ά����������
��RMAN�ı��ݽű�û���ر��Ҫ�󣬷���ű�����Ķ������ܻᵼ��Data Guard��Ҫ�Ĺ鵵��־��ɾ����
�鵵Ӧ���������ڴ����ϣ��Ա���Data Guard��ʱ��ά��ʱ�鵵��ɾ����
����Ĺ鵵��־����Ҫ������ȥά�����Զ�ɾ���Ѿ�Ӧ�ù��Ĺ鵵��־��

2�����˵��ǣ���11g�������棬�����ļ�������׾����㣬�Ǿ���ֻ��Ҫ�������¼��㣺

ʹ�ÿ��ٻָ���(fast recovery area)����10g�汾���ĵ��г�Ϊ���ػָ�����flash recovery area������ʵ˵��һֱ��̫����Ϊʲôȡ�������ػָ������ѵ�����Ϊ10g�������ݿ����ع��ܣ���RAC�У��������ʿ��ٻָ���������÷���ASM�ϡ�
Ϊ���ٻָ���ָ�����ʵĿռ䡣����������ҪԤ��һ������Ĺ鵵����ʱ�䳤���������ڱ���ϵͳ�����Data Guard�������⡢ά���ȣ���Ҫ�鵵������ʱ�䳤�ȡ�������24Сʱ��������һ���ڹ鵵������24Сʱ֮�ڣ����ж������Ĺ鵵��һ����˵�����������ݴ����ʱ��鵵����󣬼�����24Сʱ֮�ڹ鵵���Ϊ200G��ע�����RAC��˵�����нڵ�����24Сʱ�Ĺ鵵��֮�͡����Ϊ���ٻָ���ָ����Ҫ�Ŀռ�������ͨ������db_recovery_file_dest_sizeָ�����ٻָ����Ĵ�С������ͬ��������ٻָ����Ǵ�Ź鵵��־��
�ڱ�����ָ�����ٻָ����Լ�Ϊ���ٻָ���ָ�����ʵĴ�С���ڱ�����ָ�����ٻָ����Ĵ�С��Ҫ���ǵ��ǣ��л���Ϊ�����鵵��־�������������鵵����ѹ���󣬱����ܷ�洢����Ĺ鵵��־�Ա����ͨ�����������ݹ鵵��־��
������ͱ���ʹ��RMAN���ù鵵ɾ�����ԣ�CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;

3�����1��2�������裬���Ի�������Ҫ��
�鵵��־���û��Ӧ�õ����⣬��ô��RMAN��ʹ��backup .... delete inputs all��delete archivelog all���Ὣ�鵵��־ɾ������������ע�������ʹ��delete force�������ɾ�����鵵�����ܹ鵵��û�б�Ӧ�õ����⡣
����鵵��־�Ѿ�Ӧ�õ��˱��⣬��ô��RMAN��ʹ��backup .... delete inputs all��delete archivelog all����ɾ���鵵��־������������£����ڹ鵵��־���ܺܿ�Ӧ�õ�Data Guard��������RMAN����֮���������ɾ���鵵��־��RMANҲ����Ҫʹ���ر�ı��ݽű���Ҳ���ص�����Ϊ��С��ʹ�á�delete archivelog all����ɾ���˹鵵��
����Ĺ鵵��־�洢�����ٻָ����У�����Ŀ��ٻָ����ռ����ʱ�����Զ�ɾ���Ѿ�Ӧ�ù��Ľ���Ĺ鵵��־���ͷſռ䣬���������ʵ�ֱ���Ĺ鵵��־��ȫ�Զ�����
������ڱ����쳣��Data Guard�쳣���ڿ��ٻָ����ռ����ʱ��Oracle���л���־ʱ�����Զ�ɾ�����Ѿ�Ӧ�ù��Ĺ鵵��־�����ͷſռ䡣��������鵵��־û��Ӧ�õ�Data Guard����ô�鵵��־���ᱻɾ������������£����ٻָ����Ĺ鵵���ܻ����ӵ��ռ�ľ������ͻ�������ݿⲻ�ܹ鵵�����ݿ��������⡣
