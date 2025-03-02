第一部分 日常维护
一 正确打开主库和备库
1 主库:
SQL> STARTUP MOUNT;
SQL> ALTER DATABASE ARCHIVELOG;
SQL> ALTER DATABASE OPEN;
2 备库:
SQL> STARTUP MOUNT;
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

二 正确关闭顺序
1 备库:
SQL> ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;
SQL>SHUTDOWN IMMEDIATE;
2 主库
SQL>SHUTDOWN IMMEDIATE; ---先于standby执行

三 备库Read-Only模式打开
当前主库正常OPEN状态
备库处于日志传送状态.
1 在备库停止日志传送
SQL> alter database recover managed standby database cancel;
2 备库Read-only模式打开
SQL> alter database open read only;
3 备库回到日志传送模式
SQL>alter database recover managed standby database disconnect from session;
Media recovery complete.
SQL> select status from v$instance;
STATUS
------------
MOUNTED

四 日志传送状态监控
1 主库察看当前日志状况
SQL> select sequence#,status from v$log;
SEQUENCE# STATUS
---------- ----------------
51 ACTIVE
52 CURRENT
50 INACTIVE
2 备库察看RFS(Remote File Service)接收日志情况和MRP应用日志同步主库情况
SQL> SELECT PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS FROM V$MANAGED_STANDBY;
PROCESS STATUS THREAD# SEQUENCE# BLOCK# BLOCKS
--------- ------------ ---------- ---------- ---------- ----------
ARCH CONNECTED 0 0 0 0
ARCH CONNECTED 0 0 0 0
RFS RECEIVING 0 0 0 0
MRP0 WAIT_FOR_LOG 1 52 0 0
RFS RECEIVING 0 0 0 0
可以看到备库MPR0正等待SEQUENCE#为52的redo.
3 察看备库是否和主库同步
SQL> SELECT ARCHIVED_THREAD#, ARCHIVED_SEQ#, APPLIED_THREAD#, APPLIED_SEQ#  FROM V$ARCHIVE_DEST_STATUS;
ARCHIVED_THREAD# ARCHIVED_SEQ# APPLIED_THREAD# APPLIED_SEQ#
---------------- ------------- --------------- ------------
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
1 51 1 50
可以看到备库已经将SEQUENCE#51的日志归档,已经将SEQUENCE#50的redo应用到备库.
由于已经将SEQUENCE#51的日志归档,所以SEQUENCE#51以前的数据不会丢失.
4 察看备库已经归档的redo
SQL> SELECT REGISTRAR, CREATOR, THREAD#, SEQUENCE#, FIRST_CHANGE#,NEXT_CHANGE# FROM V$ARCHIVED_LOG;
REGISTR CREATOR THREAD# SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
------- ------- ---------- ---------- ------------- ------------
SRMN SRMN 1 37 572907 573346
RFS ARCH 1 38 573346 573538
RFS ARCH 1 39 573538 573623
RFS ARCH 1 40 573623 573627
RFS ARCH 1 41 573627 574326
RFS ARCH 1 42 574326 574480
RFS ARCH 1 43 574480 590971
RFS ARCH 1 44 590971 593948
RFS FGRD 1 45 593948 595131
RFS FGRD 1 46 595131 595471
FGRD FGRD 1 46 595131 595471
REGISTR CREATOR THREAD# SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
------- ------- ---------- ---------- ------------- ------------
RFS ARCH 1 47 595471 595731
RFS ARCH 1 48 595731 601476
RFS ARCH 1 49 601476 601532
RFS ARCH 1 50 601532 606932
RFS ARCH 1 51 606932 607256

5 察看备库已经应用的redo
SQL> SELECT THREAD#, SEQUENCE#, FIRST_CHANGE#, NEXT_CHANGE# FROM V$LOG_HISTORY;
THREAD# SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
---------- ---------- ------------- ------------
1 1 366852 368222
1 2 368222 369590
1 3 369590 371071
1 4 371071 372388
1 5 372388 376781
1 6 376781 397744
1 7 397744 407738
1 8 407738 413035
1 9 413035 413037
1 10 413037 413039
1 11 413039 413098
THREAD# SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
---------- ---------- ------------- ------------
1 12 413098 428161
1 13 428161 444373
1 14 444373 457815
1 15 457815 463016
1 16 463016 476931
1 17 476931 492919
1 18 492919 505086
1 19 505086 520683
1 20 520683 530241
1 21 530241 545619
1 22 545619 549203
THREAD# SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
---------- ---------- ------------- ------------
1 23 549203 552403
1 24 552403 553230
1 25 553230 553398
1 26 553398 553695
1 27 553695 554327
1 28 554327 557569
1 29 557569 561279
1 30 561279 561385
1 31 561385 566069
1 32 566069 566825
1 33 566825 570683
THREAD# SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
---------- ---------- ------------- ------------
1 34 570683 571627
1 35 571627 571867
1 36 571867 572907
1 37 572907 573346
1 38 573346 573538
1 39 573538 573623
1 40 573623 573627
1 41 573627 574326
1 42 574326 574480
1 43 574480 590971
1 44 590971 593948
THREAD# SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
---------- ---------- ------------- ------------
1 45 593948 595131
1 46 595131 595471
1 47 595471 595731
1 48 595731 601476
1 49 601476 601532
1 50 601532 606932
1 51 606932 607256
可以看到备库已经将SEQUENCE#为51的归档文件应用到备库.
6 察看备库接收,应用redo数据过程.
SQL> SELECT MESSAGE FROM V$DATAGUARD_STATUS;
MESSAGE
--------------------------------------------------------------------------------
ARC0: Archival started
ARC0: Becoming the 'no FAL' ARCH
ARC0: Becoming the 'no SRL' ARCH
ARC1: Archival started
ARC1: Becoming the heartbeat ARCH
Redo Shipping Client Connected as PUBLIC
-- Connected User is Valid
RFS[1]: Assigned to RFS process 19740
RFS[1]: Identified database type as 'physical standby'
Primary database is in MAXIMUM PERFORMANCE mode
Attempt to start background Managed Standby Recovery process
MESSAGE
--------------------------------------------------------------------------------
MRP0: Background Managed Standby Recovery process started
Managed Standby Recovery not using Real Time Apply
Clearing online redo logfile 7 /oraguard/redo1/redo_7_1.log
Clearing online redo logfile 7 complete
Media Recovery Waiting for thread 1 sequence 47
RFS[1]: No standby redo logfiles created
Redo Shipping Client Connected as PUBLIC
-- Connected User is Valid
RFS[2]: Assigned to RFS process 19746
RFS[2]: Identified database type as 'physical standby'
Primary database is in MAXIMUM PERFORMANCE mode
MESSAGE
--------------------------------------------------------------------------------
Committing creation of archivelog '/arch/1_47_552308270.arc'
Media Recovery Log /arch/1_47_552308270.arc
Media Recovery Waiting for thread 1 sequence 48
MRP0: Background Media Recovery cancelled with status 16037
MRP0: Background Media Recovery process shutdown
Managed Standby Recovery Canceled
Attempt to start background Managed Standby Recovery process
MRP0: Background Managed Standby Recovery process started
Managed Standby Recovery not using Real Time Apply
Media Recovery Waiting for thread 1 sequence 48
RFS[1]: No standby redo logfiles created
MESSAGE
--------------------------------------------------------------------------------
Committing creation of archivelog '/arch/1_48_552308270.arc'
Media Recovery Log /arch/1_48_552308270.arc
Media Recovery Waiting for thread 1 sequence 49
RFS[1]: No standby redo logfiles created
Committing creation of archivelog '/arch/1_49_552308270.arc'
Media Recovery Log /arch/1_49_552308270.arc
Media Recovery Waiting for thread 1 sequence 50
RFS[1]: No standby redo logfiles created
Committing creation of archivelog '/arch/1_50_552308270.arc'
Media Recovery Log /arch/1_50_552308270.arc
Media Recovery Waiting for thread 1 sequence 51
MESSAGE
--------------------------------------------------------------------------------
RFS[1]: No standby redo logfiles created
Committing creation of archivelog '/arch/1_51_552308270.arc'
Media Recovery Log /arch/1_51_552308270.arc
Media Recovery Waiting for thread 1 sequence 52
可以看到RFS接收到sequence#为51的归档文件并存至备库归档目录/arch/1_51_552308270.arc.
Oracle自动应用文件/arch/1_51_552308270.arc进行备库与主库同步
Oracle继续等待主库sequence 52的归档文件

五 备库归档目录维护
1 找到备库归档目录
SQL> show parameter log_archive_dest_1
NAME TYPE
------------------------------------ --------------------------------
VALUE
------------------------------
log_archive_dest_1 string
LOCATION=/arch
VALID_FOR=(ALL_LOGFILES,ALL_RO
LES)
DB_UNIQUE_NAME=ora2
log_archive_dest_10 string
2 维护策略
每周2,4,7删除已经应用的归档文件
具体参见附录二


第二部分 主库正常切换

一 人工干预主库正常切换
1 在主库端检验数据库可切换状态
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;
SWITCHOVER_STATUS
-----------------
TO STANDBY
1 row selected
SWITCHOVER_STATUS:TO STANDBY表示可以正常切换.
如果SWITCHOVER_STATUS的值为SESSIONS ACTIVE,表示当前有会话处于ACTIVE状态

2 开始主库正常切换
如果SWITCHOVER_STATUS的值为TO STANDBY 则:
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY;
如果SWITCHOVER_STATUS的值为SESSIONS ACTIVE 则:
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;
成功运行这个命令后，主库被修改为备库

3 重启先前的主库

SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP MOUNT;

4 在备库验证可切换状态
SQL> SELECT SWITCHOVER_STATUS FROM V$DATABASE;
SWITCHOVER_STATUS
-----------------
TO_PRIMARY
1 row selected

5 将目标备库转换为主库
如果SWITCHOVER_STATUS的值为TO STANDBY 则:
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY;
如果SWITCHOVER_STATUS的值为SESSIONS ACTIVE 则:
SQL> ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
成功运行这个命令后，备库被修改为主库

6 重启目标备库
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP;
7 先前主库启动日志传送进程
SQL> alter database recover managed standby database disconnect;
总结: 这样主库的一次正常切换完成.切换后的状态,原先的主库变为备库,原先的备库变为主库.



二 通过运行脚本实现主库正常切换
1 主库切换为备库
在主库上运行脚本
/admin/dataGuard/switchover/primary_to_standby.sh

2 备库切换为主库
在备库上运行脚本
/admin/dataGuard/switchover/standby_to_primary.sh
脚本1成功运行后,再运行脚本2,不能同时运行两个脚本.
经过这次切换后原来的主库变为备库,原先的备库变为主数据并且OPEN对应用提供服务.
3 复原最初状态
在原备库上运行脚本
/admin/dataGuard/switchover/primary_to_standby.sh
成功完成后
在原主库上运行脚本
/admin/dataGuard/switchover/standby_to_primary.sh
第三部分 主库灾难切换
一 人工干预主库灾难切换
二 通过运行脚本实现主库灾难切换
SQL>alter database recover managed standby database cancel;
SQL>shutdown immediate
SQL>startup mount
SQL>ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PERFORMANCE;
SQL>alter database recover managed standby database finish;
-- switch
SQL>alter database commit to switchover to primary with session shutdown;
-- open
SQL>shutdown immediate
SQL>startup
附:
一 有选择察看redo传送与应用情况
select message from v$dataguard_status
where message_num>&message_num;


二 备库归档目录维护脚本
在crontab 中定制每日执行removeCommand.sh即可。
流程:每日11:50PM执行removeCommand.sh
假设今日2005-04-05 则删除04-04和04-03两日已应用归档日志.保留今日已应用归档日志

[oracle@db_gurid admin]$ crontab -l
50 23 * * * sh /oraguard/admin/removeCommand.sh>>removeArch.log
##################
[oracle@db_gurid admin]$ cat removeCommand.sh
#!/bin/sh
export ORACLE_BASE=/ora10g/app
export ORACLE_HOME=$ORACLE_BASE/product/10.1.0/db_1
export ORACLE_SID=ora2
cd /oraguard/admin
$ORACLE_HOME/bin/sqlplus /nolog<<EOF
conn / as sysdba
@/oraguard/admin/removeArch.sql
EOF
chmod +x /oraguard/admin/removeArch.sh
/oraguard/admin/removeArch.sh>>removeArch2.log
##################
[oracle@db_gurid admin]$ cat removeArch.sql
set feed off
set heading off
set echo off
spool removeArch.sh
select 'rm '||name from v$archived_log where applied='YES' and completion_time>trunc(sysdate-3) and completion_time<trunc(sysdate);
spool off
