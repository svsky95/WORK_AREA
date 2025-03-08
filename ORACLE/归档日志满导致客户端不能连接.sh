--归档日志占满磁盘，导致客户端不能链接数据库
1、首先查看了监听  lsnrctl status
2、查看了网络的端口连接 netstat -an |grep 1521
3、df -alh 查看发现有一个磁盘的空间已经基本用尽，所以可以判断是由于归档日志导致磁盘用尽
4、查看归档日志的位置：
----使用固定的目录
archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /u01/oracle/archive    --归档日志的位置
Oldest online log sequence     12892
Next log sequence to archive   12894
Current log sequence           12894

----使用快速恢复区
SQL> archive log list;
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST   --指向快速恢复区
Oldest online log sequence     881
Next log sequence to archive   883
Current log sequence           883

SQL> show parameter DB_RECOVERY_FILE_DEST

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest                string      /u01/app/oracle/fast_recovery_    --归档日志存在的位置
                                                 area
db_recovery_file_dest_size           big integer 20G                               --快速恢复区大小

当归档日志超过20G，也会提示归档日志错误

--查看归档日志剩余
 SQL> select * from v$flash_recovery_area_usage;

FILE_TYPE            PERCENT_SPACE_USED PERCENT_SPACE_RECLAIMABLE NUMBER_OF_FILE
-------------------- ------------------ ------------------------- --------------
CONTROL FILE                         .1                         0
REDO LOG                           2.48                         0
ARCHIVED LOG                      65.41  <--使用的百分比                       0             10 <--有多少文件
BACKUP PIECE                       3.06                         0
IMAGE COPY                        27.67                         0              1
FLASHBACK LOG                         0                         0
FOREIGN ARCHIVED LOG                  0                         0 



--修改归档体质位置
--如果是使用快速恢复区，必须先把快速恢复区设置为空
alter system set db_recovery_file_dest='';

--指定的新的归档日志的路名必须有oralce权限
drwxr-xr-x   2 oracle oinstall   4096 Aug  5 13:52 arch

alter system set log_archive_dest='/oracle/arch' scope=both;

--切换日志查看是否已经归档到新的路径
alter system switch logfile;



5、rman 删除归档日志
rman target /
DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-3';  --保留3天的归档日志
--如果删除报错，就需要找到归档日志的位置，手动删除一部分后，再执行就可以成功。


--------------------------------计划任务，定时执行rmang归档日志删除------------------------------
--root用户执行
[oracle@127 del_arch_log]$ more del_arch_log.sh                                                                 
export EDITOR=vi                               --由于在 root的用户下执行，需要把oracle的环境变量放在脚本的前面，more /home/oracle/.bash_profile
export ORACLE_SID=nfzcdb
export ORACLE_BASE=/home/oracle/app
export ORACLE_HOME=$ORACLE_BASE/oracle/product/11.2.0/dbhome_1
export GG_HOME=/home/oracle/ggs
export INVENTORY_LOCATION=/home/oracle/app/oraInventory
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib:/$GG_HOME:/$LD_LIBRARY_PATH
export NLS_LANG="American_america.zhs16gbk"
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:$GG_HOME
umask 022
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.141.x86_6
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

su - oracle <<EOF
${ORACLE_HOME}/bin/rman nocatalog log=/u01/oracle/del_arch_log/del_arch$(date +%Y-%m-%d).log;
connect target /
#crosscheck archivelog all;
#delete noprompt expired archivelog all;
DELETE noprompt ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2';
exit;
EOF

--oracle用户执行
${ORACLE_HOME}/bin/rman nocatalog log=/export/home/oracle/arch_del_logs/del_arch$(date +%Y-%m-%d).log <<EOF
connect target /
crosscheck archivelog all;
delete noprompt expired archivelog all;
DELETE noprompt ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2';
exit;
EOF

--solaris系统执行
--oracle用户下的环境变量
more /export/home/oracle/.profile

vim /export/home/oracle/clear_archivelog.sh
export ORACLE_SID=sngsnfdb2
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/sngsnfdb
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=.:$PATH:$ORACLE_HOME/bin
umask 022
export AWT_TOOLKIT=XToolkit
${ORACLE_HOME}/bin/rman nocatalog log=/export/home/oracle/arch_del_logs/del_arch$(date +%Y-%m-%d).log <<EOF
connect target /
crosscheck archivelog all;
delete noprompt expired archivelog all;
DELETE noprompt ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2';
exit;
EOF

--计划任务cron log 
/var/cron/log 

>  CMD: sh /export/home/oracle/clear_archivelog.sh 
>  oracle 20900 c Fri Mar  1 16:53:00 2019
<  oracle 20900 c Fri Mar  1 16:54:29 2019        <--如果后面有rc=127说明执行脚本有问题

--计划任务----
0 2 * * * /u01/oracle/del_arch_log/del_arch_log.sh









