ԭ��һֱ��dbca���������ݿ⣬��Ȼ���㣬����Щ������û�а취ָ�� ��������β������ϵ����ϣ�������һ��Linux ���ֹ��������ݿ�Ľű����������£���ֻ���������ſ���������ʼ�����������ݿ⣬��Ȼ��ͼ�ν���ģ�Ҫ���ģ�Ĳ��𣬻����������Ƶģ�

1 ���û������� ORACLE_HOME ORACLE_BASE ORACLE_SID
ORACLE_BASE=/u01/app/Oracle
ORACLE_HOME=$ORACLE_BASE/product/10.2.0/dbs
ORACLE_SID=center
PATH=$PATH:$ORACLE_HOME/BIN
NLS_LANG=AMERICAN_AMERICA.ZHS16GBK

export ORACLE_BASE ORACLE_HOME ORACEL_SID
export PATH NLS_LANG

2 ϵͳ�滮 db_name=center oracle_sid=center
3 �ֹ�����Ŀ¼
mkdir -p /u01/app/oracle/admin/center/adump
mkdir -p /u01/app/oracle/admin/center/bdump
mkdir -p /u01/app/oracle/admin/center/cdump
mkdir -p /u01/app/oracle/admin/center/dpdump
mkdir -p /u01/app/oracle/admin/center/pfile
mkdir -p /u01/app/oracle/admin/center/udump

mkdir -p /u02/oradata/center/
mkdir -p /u02/oradata/center/archive

4���������ļ���

orapwd file=/u01/app/oracle/product/10.2.0/db_1/dbs/orapwd_center password=zdsoft

5---�޸Ĳ����ļ���

ʵ����/u01/app/oracle/product/10.2.0/dbs/initcenter.ora

---------------------------------------------------

center.__db_cache_size=331350016

center.__java_pool_size=4194304

center.__large_pool_size=8388608

center.__shared_pool_size=138412032

center.__streams_pool_size=0

*._kgl_large_heap_warning_threshold=8388608

*.audit_file_dest='/u01/app/oracle/admin/center/adump'

*.background_dump_dest='/u01/app/oracle/admin/center/bdump'

*.compatible='10.2.0.1.0'

*.control_files='/u01/app/oracle/admin/center/control01.ctl','/u02/oradata/center/control02.ctl','/u02/oradata/center/control03.ctl'

*.core_dump_dest='/u01/app/oracle/admin/center/cdump'

*.db_2k_cache_size=33554432

*.db_block_size=8192

*.db_domain=''

*.db_file_multiblock_read_count=128

*.db_files=4000

*.db_name='center'

*.db_recovery_file_dest_size=4294967296

*.db_recovery_file_dest=''

*.log_archive_dest='/u02/oradata/center/archive'

*.log_checkpoints_to_alert=FALSE

*.open_cursors=300

*.parallel_execution_message_size=65535

*.parallel_max_servers=128

*.pga_aggregate_target=209715200

*.processes=150

*.recyclebin='ON'

*.remote_login_passwordfile='EXCLUSIVE'

*.replication_dependency_tracking=FALSE

*.session_cached_cursors=100

*.sga_target=500m

*.shared_pool_size=100m

*.undo_management='AUTO'

*.undo_retention=0

*.undo_tablespace='UNDOTS'

*.user_dump_dest='/u01/app/oracle/admin/center/udump'

*.workarea_size_policy='AUTO'

_allow_resetlogs_corruption=true

---------------------------------------------------

�ɽ����ļ����Ƶ���/u01/app/oracle/admin/center/pfile/initcenter.ora

6--- ��½oracle��

> sqlplus / as sysdba

7--- ����ʵ����

SQL> startup nomount pfile=/u01/app/oracle/admin/center/pfile/initcenter.ora

8--- �������ݿ�Ľű���

-----------------------------------------------------------

CREATE DATABASE center
LOGFILE
GROUP 1 ('/u02/oradata/center/redo01.log','/u02/oradata/center/redo01_1.log') size 500m reuse,
GROUP 2 ('/u02/oradata/center/redo02.log','/u02/oradata/center/redo02_1.log') size 500m reuse,
GROUP 3 ('/u02/oradata/center/redo03.log','/u02/oradata/center/redo03_1.log') size 500m reuse
MAXLOGFILES 50
MAXLOGMEMBERS 5
MAXLOGHISTORY 200
MAXDATAFILES 500
MAXINSTANCES 5
ARCHIVELOG
CHARACTER SET ZHS16GBK
NATIONAL CHARACTER SET AL16UTF16
DATAFILE '/u02/oradata/center/system01.dbf' SIZE 1000M EXTENT MANAGEMENT LOCAL
SYSAUX DATAFILE '/u02/oradata/center/sysaux01.dbf' SIZE 1000M
UNDO TABLESPACE UNDOTS DATAFILE '/u02/oradata/center/undo.dbf' SIZE 500M
DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE '/u02/oradata/center/temp.dbf' SIZE 500M;

-----------------------------------------------------------

9--- ���������ļ�(����������Ⱥ�˳��)��

sql>@$ORACLE_HOME/rdbms/admin/catalog.sql

sql>@$ORACLE_HOME/rdbms/admin/catproc.sql

sql>conn system/manager

sql>@$ORACLE_HOME/sqlplus/admin/pupbld.sql

10--- ������ر�ռ����û���

CREATE SMALLFILE TABLESPACE "TBS_NETDISK" DATAFILE '/u02/oradata/center/netdisk01.dbf' SIZE 200M AUTOEXTEND ON NEXT 250M MAXSIZE UNLIMITED LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;

CREATE SMALLFILE TABLESPACE "TBS_CENTER" DATAFILE '/u02/oradata/center/center01.dbf' SIZE 200M AUTOEXTEND ON NEXT 250M MAXSIZE UNLIMITED LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TBS_INDX DATAFILE '/u02/oradata/center/indx01.dbf' SIZE 100M;

CREATE USER "ZDCENTER" PROFILE "DEFAULT" IDENTIFIED BY zdsoft DEFAULT TABLESPACE "TBS_CENTER" TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK

GRANT CREATE SESSION,CREATE TABLE,CONNECT,RESOURCE TO "ZDCENTER"

11--- һ��ע��ĵط���

1>.����ļ���Ŀ¼Ҫ������ȷ���������ļ��������ļ��������ļ��ȣ����о������ǵ�λ��Ҫ������ļ���ָ����Ҫһ�¡�

2>.init.ora�е�undo_tablespace�����ֱ���Ҫ��create database����ͬ��������Сд��ע�⡣������鷳�����Ĵ����㶼��֪���ǲ����ں����㣡��֮��һ�仰�������ļ��е�����Ҫ��init�ļ��е������Լ�Ҫ��ʵ���ļ���ʵ�����Ҫ��ͬ��

3>.�������ݿ������Ե�/u01/app/oracle/admin/center/bdump/alert_center.log�в��ҡ�

btw: ɾ���û��ͱ�ռ�Ľű�

ɾ���û�

drop user user_name cascade��

ɾ����ռ�

DROP TABLESPACE data01 INCLUDING CONTENTS AND DATAFILES;