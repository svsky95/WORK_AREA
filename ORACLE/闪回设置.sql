#######闪回设置#######
#闪回技术
为了使数据库能够从任何逻辑错误中迅速恢复，oracle推出了闪回技术。采用该技术，可以对行级和事物级的数据变化进行恢复，减少了数据恢复的时间，而且操作简单。通过SQL语句就可以实现数据的恢复，大大提高了数据库恢复的效率。闪回技术是数据库恢复技术历史上一次重大的进步，从根本上改变了数据恢复。

闪回技术包括以下各项：

闪回查询：（FLASHBACK QUERY）：查询过去某个时间点或某个SCN值时表中的数据信息

闪回版本查询（FLASHBACK Version query）：查询过去某个时间段或某个SCN段内表中数据变化的情况。

闪回事物查询（FLASHBACK Transaction Query）:查看某个事物或所有事物在过去一段时间对数据进行的修改。

闪回数据库（FLASHBACK Database）:将数据库恢复到过去某个时间点或某个SCN值时的状态

闪回删除（FLASHBACK drop）：将已经删除的表及其关联的对象恢复到删除前的状态。

闪回表（FLASHBACK table）:将表恢复到过去的某个时间点或某个SCN值时的状态。

SCN是当oracle数据库更新后，有DBMS自动维护而累积递增的一个数字。可以通过查询数据字典V$DATABASE中的CURRENT_SCN获得当前的SCN号。

#闪回含义
oracle推荐指定一个闪回恢复区（FLASHRECOVERY AERA）作为存放备份与恢复相关的默认位置，这样ORACLE就可以实现自动的基于磁盘的备份与恢复。闪回恢复区是一块用来存储恢复相关的文件的存储空间，允许用户集中存储所有恢复相关的文件。
以下几种文件可以存放在闪回恢复区：
控制文件
归档日志文件
闪回日志
控制文件和SPFILE自动备份
RMAN备份集
数据文件拷贝

-闪回恢复区主要通过以下3个初始化参数来设置和管理：

db_recovery_file_dest：指定闪回恢复区的位置

db_recovery_file_dest_size：指定闪回恢复区的可用空间

db_flashback_retention_target：该参数用来控制闪回日志中数据保留的时间，或者说，希望闪回数据库能够恢复到的最早的时间点。单位为min，默认是1440min,即一天。当然实际上可回退的时间还取决于闪回恢复区的大小，因为里面保存了回退所需要的闪回日志，所以这个参数要和db_recovery_file_dest_size配合修改。

-撤销闪回恢复区：
把初始化参数DB_RECOVERY_FILE_DEST的值清空。
db_recovery_file_dest_size只有在DB_RECOVERY_FILE_DEST清空之后才可以清空

##设置闪回数据库
--闪回数据库能够使数据迅速的回滚到以前的某个时间点或者某个SCN上，这对数据库从逻辑错误中恢复特别有用。而且也是大多数发生逻辑损坏时恢复数据库最佳的选择。
--闪回数据库操作的限制：
数据文件损坏或丢失等介质故障不能使用闪回数据库进行恢复。闪回数据库只能基于当前正常运行的数据文件
闪回数据库功能启动后，如果发生数据控制文件重建或利用备份恢复控制文件，则不能使用闪回数据库
不能使用闪回数据库进行数据文件收缩操作
不能使用闪回数据库将数据库恢复到在闪回日志中可获得的最早的SCN之前的SCN，因为闪回日志文件在一定的条件下被删除，而不是始终保存在闪回恢复区中


1、数据库处于归档模式
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     3
Next log sequence to archive   5
Current log sequence           5

2、启用闪回
SQL> alter database FLASHBACK on;
SQL> select flashback_on from v$database;
FLASHBACK_ON
------------------
YES

alter system set db_recovery_file_dest='+DATA' scope=both sid='*';
alter system set db_recovery_file_dest_size=30G scope=both sid='*';
alter system set db_flashback_retention_target=1440 scope=both sid='*';     1440min=1day

此时会在ASM磁盘组中创建FLASHBACK文件夹

-1@基于SCN号的闪回
记录当前SCN号
SQL> select current_scn from v$database;

          CURRENT_SCN
---------------------
             15723709
             
-对数据库进行增删改的操作

-闪回操作
关闭所有实例
[oracle@racnode01 ~]$ srvctl stop database -d racdb
[oracle@racnode01 ~]$ srvctl status database -d racdb

-启动实例1
SQL> startup mount
SQL> flashback database to scn 15723709;
SQL> alter database open resetlogs;

-启动实例2
SQL>startup

-查询闪回记录
SELECT * FROM v$flashback_database_log t;

2@基于时间点的闪回
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
SQL>   select sysdate from dual;
SYSDATE
-------------------
2019-11-21 10:58:24

-同样步骤，关闭所有实例，启动实例1
flashback database to timestamp(to_timestamp('2019-11-21 10:58:24','yy-mm-dd hh24:mi:ss')); 

##设置闪回表
闪回表是将表恢复到过去的某个时间点或者指定的SCN而不用恢复数据文件，为DBA提供了一种在线、快速、便捷的恢复方式，可以恢复对表进行的修改、删除、插入等错误的操作。
利用闪回表技术恢复表中的数据的过程，实际上是对表进行DML操作的过程。oracle自动维护与表相关联的索引、触发器、约束等。

用户具有FALSHBACKANY TABLE系统权限，或者具有所操作表的FLASHBACK对象权限
用户具有所操作表的SELECT/INSERT/DELETE/ALTER对象权限
启动被操作表的ROW MOVEMENT特性，可以采用下列方式进行：
SQL> ALTER TABLE 表名 ENABLE ROWMOVEMENT;

闪回表语法格式：
FLASHBACK TABLE [schema].table TO SCN |TIMESTAMP expression [ENABLE|DISABLE TRIGGERS]

参数说明:
SCN:将表恢复到指定的SCN时的状态
TIMESTAMP:将表恢复到指定额时间点
ENABLE|DISABLETRIGGERS:在恢复表中数据的过程中，表上的触发器时禁用还是激活（默认是引用）

1、确定闪回SCN号或者时间点 （使用范围：INSERT/DELETE 不适用：truncate/drop ）
-启动恢复表的行移动，一张表，可以根据时间点，闪回多次。
alter table cz.test17 enable row movement;
flashback table cz.test17 to timestamp(to_timestamp('2019-11-21 11:34:46','yy-mm-dd hh24:mi:ss'));
--flashback table cz.test17 to scn 15723709;
alter table cz.test17 disable row movement;

PS: unable to read data - table definition has changed 这个错误意味着，不能闪回到此时间点。

