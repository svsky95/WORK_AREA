online_Redo log 的添加与删除
--三种状态
CURRENT   当前的正在使用的
INACTIVE  归档已完成，可以进行删除的
ACTIVE    实例恢复需要的

1 查看redo 信息


--自动归档时间

SQL> show parameter ARCHIVE_LAG_TARGET

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------ --默认是0 
archive_lag_target                   integer     0


ARCHIVE_LAG_TARGET = 1800


3 修改Online redo

RAC中实例1和实例2是使用各自的redolog文件。
在单实例中，redolog由于不做归档，所以当一个redolog写满后，就切换到下一个，采用覆盖的方式轮询写redolog。

--查看relog_file及状态
--下图可以看出：
实例1 用的日志组只能是1、2、5
实例2 用的日志组只能是3、4、6
SQL> SELECT a."THREAD#",c."INSTANCE_NAME",a."GROUP#",a."STATUS",b."MEMBER" FROM v$log a,v$logfile b,gv$instance c where a."GROUP#"=b."GROUP#" and a."THREAD#"=c."THREAD#" order by 1,3;

   THREAD# INSTANCE_NAME        GROUP# STATUS           MEMBER
---------- ---------------- ---------- ---------------- ----------------------------------------------------------------------------------------------------
         1 snsmbs1                   1 ACTIVE           +DATA/snsmbs/onlinelog/group_1.294.1006970993
         1 snsmbs1                   2 ACTIVE           +DATA/snsmbs/onlinelog/group_2.293.1006970993
         1 snsmbs1                   5 CURRENT          +DATA/snsmbs/onlinelog/group_5.2020.1008242247
         2 snsmbs2                   3 ACTIVE           +DATA/snsmbs/onlinelog/group_3.289.1006971051
         2 snsmbs2                   4 ACTIVE           +DATA/snsmbs/onlinelog/group_4.362.1006971051
         2 snsmbs2                   6 CURRENT          +DATA/snsmbs/onlinelog/group_6.2041.1008242287
       
--确认状态是INACTIVE的才可以修改 可以看出组2是可以操作的，但是一组至少保留一个成员
alter database drop logfile member '+ORA_DATA/crsdb/onlinelog/group_2.261.1004629265';
--添加文件创建的路径
SQL> show parameter db_create(1-5表示可以指定5组不同的位置)

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_create_file_dest                  string      +ORA_DATA
db_create_online_log_dest_1          string      +ORA_DATA   <--指定了一个组中的有两个成员1的位置
db_create_online_log_dest_2          string      +OCR_DATA   <--指定了一个组中的有两个成员2的位置
db_create_online_log_dest_3          string
db_create_online_log_dest_4          string
db_create_online_log_dest_5          string

alter system set db_create_online_log_dest_1='+ORA_DATA' sid='*' scope=both;
alter system set db_create_online_log_dest_2='+OCR_DATA' sid='*' scope=both;
--在哪个实例添加的日志组，哪个节点才能使用，另一个实例不可以使用。
alter database add logfile group 6 size 500M;
--也可以指定实例添加
alter database add logfile thread 1 group 8 size 500M; 

SQL> select thread#,group#,archived,status, bytes/1024/1024 size_M from gv$log order by 1,2;
              
--给组添加成员(创建的新成员与现有的成员大小相同)
ALTER DATABASE ADD LOGFILE MEMBER '+DATA/racdb/onlinelog/redo5.rdo' TO GROUP 5 ;

--成员组的重命名
When using the ALTER DATABASE statement, you can alternatively identify the target group by specifying all of the other members of the group in the TO clause, as shown in the following example:
ALTER DATABASE ADD LOGFILE MEMBER '/oracle/dbs/log2c.rdo'
    TO ('+DATA/racdb/onlinelog/group_5.810.1022411397', '+DATA/racdb/onlinelog/redo5.rdo'); 
    
alter system switch logfile;
强制性产生重做日志切换命令：

强制产生检查点命令：

alter system checkpoint;

设置FAST_START_MTTR_TARGET=900 强制900秒即15分钟产生一个检查点。这样实例 恢复时间不会超过900秒。

--删除一个组的成员
--由于组号在两个节点中是不重复的，所以只要直接指定组号删除就可以。
ALTER DATABASE DROP LOGFILE GROUP 2;

alter database add logfile group 5 '/opt/oracle/oradata/dbtest/redo05_1.log' SIZE 10M
alter database add logfile member '/opt/oracle/oradata/dbtest/redo04_3.log' to group 4
alter database drop logfile group 5
alter database drop logfile  ('/opt/oracle/oradata/dbtest/redo05_1.log','/opt/oracle/oradata/dbtest/redo05_2.log')         


###################################################################################
         

-- 物理文件没有删除，手工的把物理文件删除后，在创建：

--单个日志
SQL> alter database add logfile  group 1 ('/u01/app/oracle/oradata/xezf/redo01.log') size 100M;

Database altered.

--多路径添加
ALTER DATABASE ADD LOGFILE
  GROUP 4 ('/u01/logs/orcl/redo04a.log','/u01/logs/orcl/redo04b.log')
  SIZE 100M BLOCKSIZE 512 REUSE;
 
--给现有的组添加日志成员
Notice that filenames must be specified, but sizes need not be. The size of the new members is determined from the size of the existing members of the group.
ALTER DATABASE ADD LOGFILE MEMBER '/oracle/dbs/log2b.rdo' TO GROUP 2;

--删除日志组
SQL>  alter database drop logfile group 1; 
--删除standby 日志组
alter database drop STANDBY logfile group 9; 

--删除日志组成员
ALTER DATABASE DROP LOGFILE MEMBER '/oracle/dbs/log3c.rdo';

--强制切换
ALTER SYSTEM SWITCH LOGFILE;
SQL>  select group#,thread#,archived,status, bytes/1024/1024 from v$log;  

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 YES UNUSED                       100

         2          1 NO  CURRENT                       50

         3          1 YES INACTIVE                      50

 

group1 搞定了。

 

SQL> alter database drop logfile group 3;

Database altered.

 

删除对应的物理文件，在添加

SQL> alter database add logfile  group 3 ('/u01/app/oracle/oradata/xezf/redo03.log') size 100M;

 

Database altered.

SQL> select group#,thread#,archived,status, bytes/1024/1024 from v$log;

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 YES UNUSED                       100

         2          1 NO  CURRENT                       50

         3          1 YES UNUSED                       100

 

group3 搞定。

 

切换一下logfile，在删除group2

 

SQL> alter system switch logfile;

System altered.

SQL>  select group#,thread#,archived,status, bytes/1024/1024 from v$log;

 

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 NO  CURRENT                      100

         2          1 YES ACTIVE                        50

       -- group 正在归档，我们等会在看一下

         3          1 YES UNUSED                       100

 

几分钟之后：

SQL> select group#,thread#,archived,status, bytes/1024/1024 from v$log;

 

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 NO  CURRENT                      100

         2          1 YES INACTIVE                      50

         3          1 YES UNUSED                       100

 

SQL>  alter database drop logfile group 2;

Database altered.

删除物理文件，在创建

SQL> alter database add logfile  group 2 ('/u01/app/oracle/oradata/xezf/redo02.log') size 100M;

Database altered.

SQL> select group#,thread#,archived,status, bytes/1024/1024 from v$log;

 

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 NO  CURRENT                      100

         2          1 YES UNUSED                       100

         3          1 YES UNUSED                       100
         
添加standby redo

SQL> ALTER DATABASE ADD STANDBY LOGFILE GROUP 4 ('/u01/app/oracle/oradata/xezf/std_redo04.log') size 100M;

Database altered.

SQL> ALTER DATABASE ADD STANDBY LOGFILE GROUP 5 ('/u01/app/oracle/oradata/xezf/std_redo05.log') size 100M;

Database altered.

SQL> ALTER DATABASE ADD STANDBY LOGFILE GROUP 6 ('/u01/app/oracle/oradata/xezf/std_redo06.log') size 100M;

Database altered.

SQL> ALTER DATABASE ADD STANDBY LOGFILE GROUP 7 ('/u01/app/oracle/oradata/xezf/std_redo07.log') size 100M;

Database altered.

2 修改standby redo

SQL> alter database drop logfile group 4;

Database altered.

SQL> alter database drop logfile group 5;

Database altered.

SQL> alter database drop logfile group 6;

Database altered.

SQL> alter database drop logfile group 7;

Database altered.

SQL> select group#,type, member from v$logfile;

    GROUP# TYPE    MEMBER

---------- ------- -------------------------------------------------------------

         3 ONLINE  /u01/app/oracle/oradata/xezf/redo03.log

         2 ONLINE  /u01/app/oracle/oradata/xezf/redo02.log

         1 ONLINE  /u01/app/oracle/oradata/xezf/redo01.log
 

SQL> select group#,type, member from v$logfile;

 

    GROUP# TYPE    MEMBER

---------- ------- -------------------------------------------------------------

         3 ONLINE  /u01/app/oracle/oradata/xezf/redo03.log

         2 ONLINE  /u01/app/oracle/oradata/xezf/redo02.log

         1 ONLINE  /u01/app/oracle/oradata/xezf/redo01.log

         4 STANDBY /u01/app/oracle/oradata/xezf/std_redo04.log

         5 STANDBY /u01/app/oracle/oradata/xezf/std_redo05.log

         6 STANDBY /u01/app/oracle/oradata/xezf/std_redo06.log

         7 STANDBY /u01/app/oracle/oradata/xezf/std_redo07.log

 

7 rows selected.

--清楚online_redolog
Clearing a Redo Log File
A redo log file might become corrupted while the database is open, and ultimately stop database activity because archiving cannot continue. In this situation the ALTER DATABASE CLEAR LOGFILE statement can be used to reinitialize the file without shutting down the database.

The following statement clears the log files in redo log group number 3:

ALTER DATABASE CLEAR LOGFILE GROUP 3;
This statement overcomes two situations where dropping redo logs is not possible:

If there are only two log groups
The corrupt redo log file belongs to the current group
If the corrupt redo log file has not been archived, use the UNARCHIVED keyword in the statement.

ALTER DATABASE CLEAR UNARCHIVED LOGFILE GROUP 3;
This statement clears the corrupted redo logs and avoids archiving them. The cleared redo logs are available for use even though they were not archived.

If you clear a log file that is needed for recovery of a backup, then you can no longer recover from that backup. The database writes a message in the alert log describing the backups from which you cannot recover.

Note:
If you clear an unarchived redo log file, you should make another backup of the database.
To clear an unarchived redo log that is needed to bring an offline tablespace online, use the UNRECOVERABLE DATAFILE clause in the ALTER DATABASE CLEAR LOGFILE statement.

If you clear a redo log needed to bring an offline tablespace online, you will not be able to bring the tablespace online again. You will have to drop the tablespace or perform an incomplete recovery. Note that tablespaces taken offline normal do not require recovery.