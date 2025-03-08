--RAC环境开启归档
#查看归档
SQL> archive log list;
Database log mode              No Archive Mode
Automatic archival             Disabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     49
Current log sequence           50

--可修改归档位置
#查看归档位置
SQL> show parameter log_archive_dest（1-31，最多可以指定31个归档路径）

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
log_archive_dest                     string      +DATA/ARCHIVELOG
log_archive_dest_1                   string

#修改归档的ASM存档路径,RAC中所有实例写入同一个ASM目录下。
alter diskgroup DATA add directory '+DATA/ARCHIVELOG';     (DADA 磁盘组名称)
alter system set log_archive_dest='+DATA/ARCHIVELOG' scope=spfile sid='*';
#修改归档格式
SQL> show parameter log_archive_format

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
log_archive_format                   string      %t_%s_%r.dbf

alter system set log_archive_format='%t_%s_%r.dbf' scope=spfile sid='*';


#在一个实例1上执行
alter system set cluster_database=false scope=spfile sid='crsdb1';

#关闭数据库
[oracle@racnod1 dbs]$ srvctl stop database -d crsdb
[oracle@racnod1 dbs]$ srvctl status database -d crsdb
Instance crsdb1 is not running on node racnod1
Instance crsdb2 is not running on node racnod2

#使用当前实例挂载数据库
SQL> startup mount;

#开启归档
SQL> alter database archivelog;

#在一个实例1上执行
alter system set cluster_database=true scope=spfile sid='crsdb1';

#关闭当前实例
SQL> shutdown immediate

#启动数据库
[oracle@racnod1 dbs]$ srvctl start database -d crsdb
[oracle@racnod1 dbs]$ srvctl status database -d crsdb
Instance crsdb1 is running on node racnod1
Instance crsdb2 is running on node racnod2

-QA
今天打开数据库，想修改Oracle的归档模式结果出现以下错误：
SQL> alter database archivelog;
alter database archivelog
*
ERROR at line 1:
ORA-00265: instance recovery required, cannot set ARCHIVELOG mode
上网查了下，原来是上次系统的非正常关闭导致。需要重新打开数据库，使数据文件，控制文件，日志文件同步，再修改归档模式。
 
 
【解决方法】
将已经处于mount阶段的数据库打开（置于open阶段），然后再关闭，重启到mount阶段。
 
SQL> alter database open;
 
Database altered.
 
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup mount;
ORACLE instance started.
 
Total System Global Area  623546368 bytes
Fixed Size                  1338308 bytes
Variable Size             436208700 bytes
Database Buffers          180355072 bytes
Redo Buffers                5644288 bytes
Database mounted.
 
SQL> alter database archivelog;
 
Database altered.
 
SQL> alter database open;
 
Database altered.
