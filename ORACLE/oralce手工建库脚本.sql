原来一直用dbca来创建数据库，虽然方便，但有些参数就没有办法指定 ，所以这次参照网上的资料，整理了一个Linux 下手工创建数据库的脚本，步骤如下：（只有这样，才可以批量初始化，创建数据库，不然就图形界面的，要大规模的部署，还是有受限制的）

1 设置环境变量 ORACLE_HOME ORACLE_BASE ORACLE_SID
ORACLE_BASE=/u01/app/Oracle
ORACLE_HOME=$ORACLE_BASE/product/10.2.0/dbs
ORACLE_SID=center
PATH=$PATH:$ORACLE_HOME/BIN
NLS_LANG=AMERICAN_AMERICA.ZHS16GBK

export ORACLE_BASE ORACLE_HOME ORACEL_SID
export PATH NLS_LANG

2 系统规划 db_name=center oracle_sid=center
3 手工创建目录
mkdir -p /u01/app/oracle/admin/center/adump
mkdir -p /u01/app/oracle/admin/center/bdump
mkdir -p /u01/app/oracle/admin/center/cdump
mkdir -p /u01/app/oracle/admin/center/dpdump
mkdir -p /u01/app/oracle/admin/center/pfile
mkdir -p /u01/app/oracle/admin/center/udump

mkdir -p /u02/oradata/center/
mkdir -p /u02/oradata/center/archive

4建立密码文件：

orapwd file=/u01/app/oracle/product/10.2.0/db_1/dbs/orapwd_center password=zdsoft

5---修改参数文件：

实例：/u01/app/oracle/product/10.2.0/dbs/initcenter.ora

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

可将此文件复制到：/u01/app/oracle/admin/center/pfile/initcenter.ora

6--- 登陆oracle：

> sqlplus / as sysdba

7--- 启动实例：

SQL> startup nomount pfile=/u01/app/oracle/admin/center/pfile/initcenter.ora

8--- 创建数据库的脚本：

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

9--- 运行如下文件(安照下面的先后顺序)：

sql>@$ORACLE_HOME/rdbms/admin/catalog.sql

sql>@$ORACLE_HOME/rdbms/admin/catproc.sql

sql>conn system/manager

sql>@$ORACLE_HOME/sqlplus/admin/pupbld.sql

10--- 创建相关表空间与用户：

CREATE SMALLFILE TABLESPACE "TBS_NETDISK" DATAFILE '/u02/oradata/center/netdisk01.dbf' SIZE 200M AUTOEXTEND ON NEXT 250M MAXSIZE UNLIMITED LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;

CREATE SMALLFILE TABLESPACE "TBS_CENTER" DATAFILE '/u02/oradata/center/center01.dbf' SIZE 200M AUTOEXTEND ON NEXT 250M MAXSIZE UNLIMITED LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE TBS_INDX DATAFILE '/u02/oradata/center/indx01.dbf' SIZE 100M;

CREATE USER "ZDCENTER" PROFILE "DEFAULT" IDENTIFIED BY zdsoft DEFAULT TABLESPACE "TBS_CENTER" TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK

GRANT CREATE SESSION,CREATE TABLE,CONNECT,RESOURCE TO "ZDCENTER"

11--- 一点注意的地方：

1>.相关文件的目录要设置正确，有数据文件，控制文件，参数文件等，还有就是它们的位置要与控制文件中指定的要一致。

2>.init.ora中的undo_tablespace的名字必须要与create database的相同，包括大小写等注意。否则很麻烦，报的错误你都不知道是不是在忽悠你！总之，一句话，控制文件中的内容要和init文件中的内容以及要和实际文件的实际情况要相同。

3>.分析数据库出错可以到/u01/app/oracle/admin/center/bdump/alert_center.log中查找。

btw: 删除用户和表空间的脚本

删除用户

drop user user_name cascade；

删除表空间

DROP TABLESPACE data01 INCLUDING CONTENTS AND DATAFILES;