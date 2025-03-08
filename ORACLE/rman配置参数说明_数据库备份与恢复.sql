#数据文件SCN说明
1、系统检查点scn
当一个检查点动作完成后，Oracle就把系统检查点的SCN存储到控制文件中。
select checkpoint_change# from v$database;
2，数据文件检查点scn
当一个检查点动作完成后，Oracle就把每个数据文件的scn单独存放在控制文件中。
select name,checkpoint_change# from v$datafile;
3，启动scn
Oracle把这个检查点的scn存储在每个数据文件的文件头中，这个值称为启动scn，因为它用于在数据库实例启动时，
检查是否需要执行数据库恢复。
select name,checkpoint_change# from v$datafile_header;
4、终止scn
每个数据文件的终止scn都存储在控制文件中,非正常关闭，终止SCN为空
select name,last_change# from v$datafile;

#####RMAN参数说明#####
--查看配置
RMAN> show all;
#CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 5 DAYS;
备份保留策略，保留几天的备份文件，包括数据文件备份集归档日志等相关备份 
我现在的时间是6月11日16:42，如果我设置了上述备份保留策略并进行备份，则该备份在6月16日16:42之后会被标识为废弃。
 
#CONFIGURE RETENTION POLICY TO REDUNDANCY 3;
保留3次的0级备份，在做完第四次0级备份的时候，第一次备份结果将被标识为废弃。
ORACLE11G默认的备份保留策略是用该方法设置的，且REDUNDANCY为1。
可以使用命令CONFIGURE RETENTION POLICY CLEAR恢复策略为默认值。
还可以用命令CONFIGURE RETENTION POLICY TO NONE进行策略设置，此时REPORT OBSOLETE和DELETE OBSOLETE将不把任何备份文件视为废弃。

#开启备份优化
CONFIGURE BACKUP OPTIMIZATION ON; # default
CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default

#开启控制文件的自动备份并同时开始spfile备份
CONFIGURE CONTROLFILE AUTOBACKUP ON;

#控制文件的输出格式(默认放在快速回复区的+ORA_DATA/db_name/AUTOBACKUP下，show parameter db_recovery_file_dest)
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO 'ctrl_%F';
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '+DATA/RACDB/BACKUPSET/ctrl_%F';

#备份的并行度
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO BACKUPSET;

#备份多个数据文件副本
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default

#备份多个归档日志副本
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default

#排除不需要备份的表空间
CONFIGURE exclude for tablespace tps_name;

#RAC环境备份时，需要把控制文件快照放在共享存储中
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DATA/RACDB/BACKUPSET/snapcf_crsdb2.f'

#开启块跟踪（为了实现快速备份）
[oracle@zx ~]$ sqlplus / as sysdba
SQL> alter database enable block change tracking using file '+FRA_DATA' ;    --指定存放块更改跟踪文件的共享存储路径
查看
SQL> col filename for a50
SQL> select * from v$block_change_tracking;
STATUS     FILENAME                                         BYTES
---------- -------------------------------------------------- ----------
ENABLED    +RCY1/zx/changetracking/ctf.298.861133721        11599872

##备份集查看
SELECT * FROM v$rman_backup_job_details;
SELECT * FROM v$rman_configuration;   --非默认配置查看
SELECT * FROM v$rman_backup_subjob_details t WHERE t.status='COMPLETED' order by t."SESSION_KEY"  ;
SELECT * FROM v$backup;
SELECT * FROM v$backup_set;
SELECT * FROM v$backup_set_summary;

1、修改rman备份路径
configure channel device type disk format '/oracle/rman_back/%d_db_%u';
2、显示失效的备份
report obsolete
3、删除失效的备份
delete obsolete
4、查看备份情况
RMAN> list backupset summary;
5、查看是否还有文件需要备份
RMAN> report need backup;
6、查看控制文件备份
RMAN> list backup of controlfile;
7、查看参数文件
RMAN> list backup of spfile;

List of Backups
===============
Key     TY LV S Device Type Completion Time     #Pieces #Copies Compressed Tag
------- -- -- - ----------- ------------------- ------- ------- ---------- ---
1       B  A  A DISK        2019/06/12 10:54:39 1       1       NO         SXFXDB_LV0
2       B  A  A DISK        2019/06/12 10:55:26 1       1       NO         SXFXDB_LV0
3       B  A  A DISK        2019/06/12 10:59:26 1       1       NO         SXFXDB_LV0
5       B  A  A DISK        2019/06/12 11:13:52 1       1       NO         SXFXDB_LV0
6       B  A  A DISK        2019/06/12 11:20:10 1       1       NO         USERS_LV0

KEY：每个备份的唯一标识符
TY：B-备份集   P-代理副本 
LV：F-完整的数据库备份集   A-归档日志   lv0-全量备份   lv1-增量备份
S：备份状态 A-可用   U-不可用  X-备份集已经过期

--显示备份明细
RMAN> list backupset 6; 

SELECT * FROM  v$backup_set;
SELECT * FROM  v$backup_piece;
7、设置恢复并行度
restore database parallel 4;
8、查询恢复的进度
SELECT * FROM v$recovery_progress;
select sid,SERIAL# ,CONTEXT,SOFAR,TOTALWORK,round(SOFAR/TOTALWORK*100,2) "_%"
from v$session_longops where OPNAME like 'RMAN%' and SOFAR<>TOTALWORK and  TOTALWORK<>0;

--显示快速恢复区的使用情况
SELECT substr(name, 1, 30) name, space_limit/1024/1024/1024 AS quota_G,
space_used/1024/1024/1024 AS used_G,
space_reclaimable/1024/1024/1024 AS reclaimable,
number_of_files AS files 
FROM v$recovery_file_dest ;



#####数据库恢复操作#####
--参数文件恢复
startup nomount;
RMAN> restore pfile to '/home/oracle/spfile.resore' from autobackup;
#指定恢复的路径
restore spfile to '/tmp/spfile.resore' from autobackup;
#拷贝参数文件：
RMAN> backup as copy spfile format '/u01/oracle/bak/spfileorcl.ora';




#####RAC备份#####
#在默认的情况下，备份是放在快速恢复区中的。
-backupset 目录下存放，每天备份
-autobackup 存放自动备份的控制文件及参数文件

#RAC的rman备份与非RAC的唯一的不同是可以设置备份的负载均衡。
1、配置服务
srvctl add service -d CRSDB -s rdb_main -r crsdb1 crsdb2
-d Unique name for the database 
-s service _name --名字随意指定
-r instance_name
2、验证两个节点服务已经开启
srvctl status service -d crsdb
3、两个节点配置TNS

rdb_main =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST =racnod1)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = rdb_main)
    )
  )
4、rman 配置均衡
RMAN> configure device type disk parallelism 2; --配置均衡

-- 快照的控制文件放在共享存储中
configure snapshot controlfile name to '+ORA_DATA\snapcf_rdb';


--rman恢复顾问(不适用于RAC)
list failure;
advise failure;
repair failure preview;   --提供修复的准确预览
repair failure;


--为了保证备份的有效性，需要定期验证备份的有效性。
#验证命令并不会真正执行恢复，所以可以免去异机测试的麻烦，同时又可以检查备份的有效性，是应当定期执行的操作。

restore validate controlfile;
restore validate spfile;
restore validate database;
restore validate archivelog all;


#####密码文件恢复#####
如果这个口令文件丢失，会发生什么，用户不能登录吗？这个问题提的好，如果是这个文件丢失，只是用sysdba方式没办法登录，登录会报错，普通用于远程登录不受影响

进入到口令文件所在目录
cd $ORACLE_HOME/dbs

文件删除，模拟丢失
rm orapwora10g;     （密码文件命名规则：orapw$ORACLE_SID）

删除之后，用以下命令重新建立一个文件,entries的意思(DBA的用户最多有5个）
orapwd file=orapwora10g password=oracle entries=5; 

#####控制文件的恢复#####
--控制文件恢复
startup nomount;
RMAN>  restore controlfile from AUTOBACKUP;
RMAN> alter database mount;
RMAN> recover database ;
RMAN> alter database open resetlogs;
#拷贝控制文件：
RMAN> backup as copy current controlfile  format '/u01/oracle/bak/control01.ctl';
RMAN> restore controlfile from '/u01/app/oracle/product/11.2.0/db_1/dbs/c-1009242311-20200518-00';


--由于目前的数据文件的检查点与控制文件中的检查点不同，所以需要推进检查点。
应用自恢复控制文件以来，的归档日志及redo log;
RMAN> recover database;

由于恢复了控制文件，并且控制文件是之前时间点的，而数据文件是当前最新的时间点，所以无论是resetlog或者noresetlog都会报错，所以要推进controlfile，需要recover database;
SQL> alter database open resetlogs;
重置了v$log的SEQUENCE#和archived_log的SEQUENCE#。




#####指定表空间备份及恢复#####
##表空间备份
source /home/oracle/.bash_profile
#########rman-back leve0
rman target sys/oracle_4U log=/oracle/rman_back/back0-`date +%Y%m%d-%H%M`.log <<EOF
run {
sql'alter system switch logfile';
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
backup incremental level 0 tag 'users_lv0' tablespace users,cz_test
format "/home/oracle/rman_bak/users_lv0_%d_%T_%U" 
plus archivelog 
format "/home/oracle/rman_bak/arch_lv0_%d_%T_%U" 
delete all input;
release channel ch1;
release channel ch2;
}
EOF
exit

--lv 1
run {
sql'alter system switch logfile';
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
backup incremental level 1 tag 'users_lv1' tablespace users,cz_test
format "/home/oracle/rman_bak/users_lv1_%d_%T_%U" 
plus archivelog 
format "/home/oracle/rman_bak/arch_lv1_%d_%T_%U" 
delete all input;
release channel ch1;
release channel ch2;
}


##表空间恢复
查看表空间状态:
select FILE_NAME,STATUS,ONLINE_STATUS from dba_data_files;
sql 'alter tablespace cz_test offline';
可以在数据库处于mount或者open状态时，将表空间置为offline
run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
restore tablespace cz_test;
recover tablespace cz_test;
sql 'alter tablespace cz_test online';
release channel ch1;
release channel ch2;
}

#####坏块恢复#####
一、rman恢复坏快数据
rman> recover datafile 7 block 3 datafile 2 block 19;

rman> blockrecover datafile 6 block 3893;
 
--查看坏块
SELECT * FROM gv$database_block_corruption;
--修复坏块列表
RMAN> recover corruption list;

二、跳过坏快

1、创建管理表
exec DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE',1,1,'USERS');     //可以把这个管理表放在其它的表空间中

2、创建索引表
exec DBMS_REPAIR.ADMIN_TABLES('ORPHAN_TABLE',2,1,'USERS');  

3、检查坏块
SQL> SET SERVEROUTPUT ON
declare
cc number;
begin
dbms_repair.check_object(schema_name => 'HWJ',object_name => 'TEST',corrupt_count => cc);
dbms_output.put_line(a => to_char(cc));
end;
/

1    --输出为1，说明有1个坏块

4、check完之后，在我们刚在创建的REPAIR_TABLE中查看块损坏信息：
SQL> SELECT object_name, relative_file_id, block_id,marked_corrupt,corrupt_description, repair_description,CHECK_TIMESTAMP from repair_table;
          
5、跳过坏块 （跳过的坏块会导致块上的数据丢失）
exec dbms_repair.skip_corrupt_blocks(schema_name => 'HWJ',object_name => 'TEST',flags => 1);

6、处理索引
SQL> declare
  cc number;
  begin
  dbms_repair.dump_orphan_keys(schema_name => 'HWJ',object_name => 'IDX_TEST',object_type => 2,
  repair_table_name => 'REPAIR_TABLE',orphan_table_name => 'ORPHAN_TABLE',key_count => CC);
  end;
 /

也可以重建表上索引
 SELECT * FROM ORPHAN_TABLE;
          

  




#####数据文件恢复######
alter tablespace DZDA_DAT online
*
ERROR at line 1:
ORA-01157: cannot identify/lock data file 6 - see DBWR trace file
ORA-01110: data file 6: '/u01/oracle/oradata/NFZCDB/dzda_dat.dbf'

RMAN> restore datafile 6;
RMAN> recover datafile 6;

SQL> alter tablespace DZDA_DAT online;
SQL> alter database open;

#####数据库恢复#####
##一致性恢复
#关闭数据库
SQL> shutdown immediate;
SQL> startup mount;

run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
restore database;
recover database;
sql 'alter database open';
release channel ch1;
release channel ch2;
}

#查看状态：
select sid,SERIAL# ,CONTEXT,SOFAR,TOTALWORK,round(SOFAR/TOTALWORK*100,2) "_%"
from v$session_longops where OPNAME like 'RMAN%' and SOFAR<>TOTALWORK and  TOTALWORK<>0;

##非一致性恢复
--基于时间点：
startup mount;
restore database until time "to_date('2015-04-20 08:13:50','yyyy-mm-dd hh24:mi:ss')";
recover database until time "to_date('2015-04-20 08:13:50','yyyy-mm-dd hh24:mi:ss')";
alter database open resetlogs;                  

##基于scn号：
--故障问题：
RMAN-06025: no backup of archived log for thread 1 with sequence 6 and starting SCN of 2435400 found to restore
--处理方法
startup mount;
restore database until scn 2435400;（也可以直接restore database）
recover database until scn 2435400;
alter database open resetlogs;                  

##基于归档日志序列号的恢复:
startup mount;
restore database until sequence 123 thread 1；
recover database until sequence 123 thread 1；
alter database open resetlogs; 
//基于归档文件
sys@SYBO2SZ> recover database until cancel;     --> 基于 cancel 恢复数据库  
ORA-00279: change 494124 generated at 08/22/2012 17:02:30 needed for thread 1  
ORA-00289: suggestion : /u02/database/SYBO2SZ/archive/arch_792003491_1_4.arc  
ORA-00280: change 494124 for thread 1 is in sequence #4  
  
Specify log: {<RET>=suggested | filename | AUTO | CANCEL}  
/u02/database/SYBO2SZ/archive/arch_792003491_1_4.arc     -->恢复到尾数为4的归档日志  
ORA-00279: change 494189 generated at 08/22/2012 17:04:46 needed for thread 1  
ORA-00289: suggestion : /u02/database/SYBO2SZ/archive/arch_792003491_1_5.arc  
ORA-00280: change 494189 for thread 1 is in sequence #5  
ORA-00278: log file '/u02/database/SYBO2SZ/archive/arch_792003491_1_4.arc' no longer needed for this recovery  
  
Specify log: {<RET>=suggested | filename | AUTO | CANCEL}  
cancel                                                 -->第5个日志文件丢失，输入cancel  
Media recovery cancelled.  
sys@SYBO2SZ> alter database open resetlogs;            --> resetlogs 方式打开数据库 


#####自动备份autobackup#####
1、开启并设置快速回复区
2、备份脚本
#全量备份
crosscheck archivelog all;
delete noprompt expired archivelog all;
sql 'alter system archive log current';
backup as compressed backupset full tag 'orcldb-full' database     //压缩备份集
plus archivelog
delete all input;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;

#增量0级
crosscheck archivelog all;
delete noprompt expired archivelog all;
sql 'alter system archive log current';
backup incremental level=0  tag 'orcldb-level0' database
plus archivelog
delete all input;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;

#增量1级
crosscheck archivelog all;
delete noprompt expired archivelog all;
sql 'alter system archive log current';
backup incremental level=1  tag 'orcldb-level1' database
plus archivelog
delete all input;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;

#备份完成后，会看到控制文件及参数文件的信息
RMAN> list backupset;
Piece Name: +ORA_DATA/ORCLDB/AUTOBACKUP/2020_08_26/s_1049474734.268.1049474737
Control File Included: Ckp SCN: 1436711      Ckp time: 2020/08/26 16:45:34

#####QA#####
##开库异常
SQL> alter database open resetlogs;

alter database open resetlogs

*

ERROR at line 1:

ORA-01194: file 1 needs more recovery to be consistent

ORA-01110: data file 1: '+ZHAOJINGYU/jy/datafile/system.256.839673875'

说明：这个环境是模拟数据文件1丢失，最终从备份restore出来一个旧的文件，但由于种种原因，总之没有后续的归档去做recover，导致无法追平。
此时就可尝试使用_allow_resetlogs_corruption隐藏参数强制开库：
--或者添加在pfile里面
alter system set "_allow_resetlogs_corruption" = true scope=spfile;
alter system set "_corrupted_rollback_segments" = true scope=spfile;
alter system set "_offline_rollback_segments" = true scope=spfile;

SQL> shutdown immediate

SQL> startup mount

SQL> alter database open resetlogs;

此时再去查询数据文件头的SCN已经一致：

SQL> select checkpoint_change# from v$datafile_header;


############################################################################


1.关于RMAN备份的相关参数介绍：
命令行参数 描述
TARGET 为目标数据库定义的一个连接字符串，当连接到一个目标数据库时，该连续是SYSDBA连接。该用户拥有启动和关闭数据库的权利，必须属于OSDBA组，必须建立一个口令文件允许SYSDBA连接。
CATALOG 连接到恢复目录。
NOCATALOG 不运用恢复目录。与CATALOG参数互斥
CMDFILE 定义了输出命令文件名称的字符串。当运行RMAN时，可以运行命令文件或者交互式运行
LOG & MSGLOG 定义了包含RMAN输出信息的文件的字符串，LOG参数只能特别运用在命令行中。不能在RMAN中启动SPOOLING，当应用日志文件时，输出的信息并不在屏幕上显示
TRACE 类似于log参数，将产生一个显示RMAN输入信息的文件。使用TRACE在屏幕上也显示。
APPEND 特殊用法，如果消息日志文件存在则将消息追加到该文件中。经常与LOG联合使用
数据库OPEN时归档模式下RMAN可以备份。
数据库OPEN时非归档模式下RMAN只能备份READ ONLY或OFFLINE有表空间或数据文件。
归档模式下RMAN全库备份时：
在数据库OPEN、MOUNT阶段都可以备份。数据库实例未启动，或者启动到NOMOUNT状态均不能备份。
非归档模式下RMAN全库备份时：
只能在MOUNT状态下备份。
.注意一：让RMAN输出日志的方法有：
rman log='/home/oracle/app/oradataback/db_rman1.log' append <<EOF
connect target /;

rman log /home/oracle/rman-arch`date +%Y%m%d-%H:%M`.log <<EOF
connect target /;
注意二：关于归档日志的删除参数delete all input：
backup archivelog all delete all input命令在删除备份归档时delete all input与 delete input区别
如果只配置了一个归档目录，两个参数没有区别。
如果配置了一个以上归档目录--log_archive_dest_n参数，比如两个，则：
DELETE ALL INPUT 会将两个归档目录下的归档日志都删除
DELETE INPUT则只删除其中一个--比如备份时是使用log_archive_dest_1中的归档日志，则删除log_archive_dest_1中的归档日志。

注意三：备份归档日志时，可以考虑在脚本前写上cross check archivelog all;命令。
如果在使用RMAN备份时，在操作系统中删除归档日志未在RMAN中执行cross check archivelog all;时，备份会报错：RMAN-06059: expected archived log not found, loss of archived log compromises recoverability 。这时，可以手动执行cross check archivelog all;命令后再进行备份，也可以直接把cross check archivelog all;命令写到备份脚本里。
我这里并未将此语句写入到备份脚本中，因为考虑生产环境中如果归档日志不全可能导致在后期的数据库恢复中不能完全恢复，所以宁肯备份报错以便及早发现问题。
说明：分享的脚本在安装在LINUX的ORACLE 11G测试环境经过测试，如在自己环境使用请修改相应参数。使用类似source /home/oracle/.bash_profile语句可以确保在LINUX定时任务中执行成功，如果需要在WIN下使用，请酌情修改。
注意四：控制文件自动备份的开启
应该开启控制文件自动备份，命令是：
CONFIGURE CONTROLFILE AUTOBACKUP ON;      
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/home/oracle/%F';  
---以下有脚本默认开启控制文件自动备份。
注意五：写备份脚本的小技巧：
可以在备份前增加备份前--校验归档日志文件
crosscheck archivelog all;
delete noprompt expired archivelog all;
备份后-校验备份集并删除过期及误删除的备份信息
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;
2.关于差异与增量备份概念的简单介绍：
差异增量Differential--  默认的方式：    备份同一级或上一级备份后的变化
第一次0级备份，是全备。
然后1级是第0级备份以来的变化的备份。
此时再做1级备份，备份的是从上一个1级备份后的变化。
再做2级备份，则是从第二个1级备份后的变化。
此时再做1级备份，则备份从第二个1级备份后的变化，---忽略2级备份的。

累积增量Cumulative--需要指定：   备份上一级备份后的变化
第一次0级备份，是全备。然后1级是第0级备份以来的变化的备份。
此时再做1级备份，备份的是从上一个0级备份后的变化。   --------------也就是同级别的备份不被认同。
做2级备份，则是从第二个1级备份后的变化。
此时再做1级备份，则备份从0级备份后的变化
3.只备份归档文件，指定备份目录及备份文件格式
指定的生成日志及备份文件的文件位置、格式。日志格式类似这样：rman-arch20130912-1634.log
[oracle@bys001 ~]$ cat archback.sh 
#!/bin/sh
source /home/oracle/.bash_profile
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/rman-arch`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run{
backup archivelog all delete input
format '/backup/archlog/arch_%d_%T_%s';
}
exit
如果归档日志需要备份两份，在RMAN中可以直接设置进行修改。需要在备份集中用%c的命令格式能备份成功。示例如下：
 %c Copy number for multiple copies in a duplexed backup   备份片的多个copy的序号
 
RMAN> CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 2;
RMAN> backup archivelog all format '/home/oracle/backup/%t_%d_%u_%c.arc';
4.删除归档日志的脚本：我这里是删除一天前的归档日志
#!/bin/sh
#su - oracle
source /home/oracle/.bash_profile
#########back arch test 0704
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/rman-arch`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run{
crosscheck archivelog all;
delete noprompt expired archivelog all;
delete noprompt archivelog until time 'sysdate-1' ;
}
exit
5.全库备份脚本，包括归档日志及控制文件、SPFILE参数文件
[oracle@bys001 ~]$ cat fullback.sh 
#!/bin/sh
source /home/oracle/.bash_profile
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/backfull-`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run {
backup full tag 'bys001-full' database
format "/backup/full/bys001full_%d_%t_%s"
plus archivelog
format "/backup/full/bys001arch_%d_%t_%s"
delete all input;
}
exit
###############下面是加强版：
[oracle@bys001 ~]$ cat fullback.sh
#!/bin/sh
source /home/oracle/.bash_profile
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/backfull-`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run {
crosscheck archivelog all;
delete noprompt expired archivelog all;
backup full tag 'bys001-full' database
format "/backup/full/bys001full_%d_%t_%s"
plus archivelog
format "/backup/full/bys001arch_%d_%t_%s"
delete all input;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;
}
exit
6.差异增量Differential备份脚本--有0、1、2三级%%%这是默认的增量备份方式；差异增量Differential是默认备份方式，
0级差异增量备份脚本
[oracle@bys001 ~]$ cat back0.sh 
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level0
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/back0-`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run {
backup incremental level=0 tag 'bys001-0' database
format "/backup/full/bys001full_%d_%t_%s" 
plus archivelog 
format "/backup/full/bys001arch_%d_%t_%s" 
delete all input;
}
exit
1级差异增量备份脚本
[oracle@bys001 ~]$ cat back1.sh 
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level 1
##########
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/back1-`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run {
backup incremental level=1 tag 'bys001-1' database
format "/backup/full/bys001full_%d_%t_%s" 
plus archivelog 
format "/backup/full/bys001arch_%d_%t_%s" 
delete all input;
}
exit

2级差异增量备份脚本
[oracle@bys001 ~]$ cat back2sh 
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level 2
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/back2-`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run {
backup incremental level=2 tag 'bys001-2' database
format "/backup/full/bys001full_%d_%t_%s" 
plus archivelog 
format "/backup/full/bys001arch_%d_%t_%s" 
delete all input;
}
exit

7.cumulative累积增量备份--有0、1、2三级
0级累积增量备份脚本
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level 0 ---cumulative
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/back0-`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run {
backup incremental level=0 cumulative tag 'bys001-0' database 
format "/backup/full/bys001full_%d_%t_%s" 
plus archivelog 
format "/backup/full/bys001arch_%d_%t_%s" 
delete all input;
}
exit
1级累积增量备份脚本
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level 1 --cumulative
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/back1-`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run {
backup incremental level=1 cumulative tag 'bys001-1' database 
format "/backup/full/bys001full_%d_%t_%s" 
plus archivelog 
format "/backup/full/bys001arch_%d_%t_%s" 
delete all input;
}
exit

2级累积增量备份脚本
这个脚本里使用了服务名来登陆RMAN。最好先在RMAN中使用connect target sys/sys@192.168.1.212:1521/bys001;确认登陆正常再写入脚本。
当然也可以使用 rman target sys/sys@bys001
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level 2 ---cumulative
/u01/app/oracle/product/11.2.0/dbhome_1/bin/rman   log /home/oracle/back2-`date +%Y%m%d-%H%M`.log <<EOF
connect target sys/sys@192.168.1.212:1521/bys001;
run {
backup incremental level=2 cumulative  tag 'bys001-2' database 
format "/backup/full/bys001full_%d_%t_%s" 
plus archivelog 
format "/backup/full/bys001arch_%d_%t_%s" 
delete all input;
}
exit

--指定通道备份
run{
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
backup as compressed backupset database format '/data/backup/rmanback/db_%d_%T_%U';   --压缩备份
crosscheck backup;
release channel ch1;
release channel ch2;
}

--查看每天的备份集大小
select 
to_char(start_time,'yyyy-mm-dd') start_time,
to_char(start_time,'day') day, 
round(sum(OUTPUT_BYTES)/1024/1024/1024,2) SIZE_GB 
from v$backup_set_details
group by to_char(start_time,'yyyy-mm-dd'),to_char(start_time,'day') 
order by start_time desc;

--查看每天的备份片段大小
select 
to_char(start_time,'yyyy-mm-dd') start_time,
to_char(start_time,'day') day, 
round(sum(BYTES)/1024/1024/1024,2) SIZE_GB 
from v$backup_piece where handle is not null
group by to_char(start_time,'yyyy-mm-dd'),to_char(start_time,'day') 
order by start_time asc;

8.WINDOWS下的备份脚本：
先创建一个BAT文件 如下：调用f:\arch_rman.sql中的备份命令，所生成日志格式是：f:\backlog\arch20130304-2050.log
rman  target / cmdfile=f:\arch_rman.sql log f:\backlog\arch%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%.log
f:\arch_rman.sql中的备份命令：
list backup;
report obsolete;
delete obsolete;
run {
backup  database
format 'f:\backup\orclfullback_%d_%t_%s'
plus archivelog
format 'f:\backup\orclarch_%d_%t_%s' 
delete all input;
}
exit


============================================================================
show all 查看目前的设置
恢复5天内数据的rman备份：
RETENTION POLICY TO RECOVERY WINDOW OF 5 DAYS;
调整并行度：
CONFIGURE DEVICE TYPE DISK PARALLELISM 5 BACKUP TYPE TO BACKUPSET;
配置控制文件自动备份：
CONFIGURE CONTROLFILE AUTOBACKUP ON;







--生产脚本
0级备份是增量备份的基础，全备份不能当0级备份用。
全库备份可以做BLOLK块级的恢复，0级不可以。

--full 
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level0
rman target sys/oracle_4U log=/oracle/rman_back/backfull-`date +%Y%m%d-%H%M`.log <<EOF
run {
crosscheck archivelog all;
delete noprompt expired archivelog all;
backup full tag 'sxfxdb_full' database
format "/oracle/rman_back/sxfxdb_full_%d_%t_%s"
plus archivelog
format "/oracle/rman_back/sxfxdb_full_%d_%t_%s"
delete all input;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;
}
EOF
exit

--level 0
[oracle@bys001 ~]$ cat back_level_0.sh 
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level0
rman target sys/oracle_4U log=/oracle/rman_back/back0-`date +%Y%m%d-%H%M`.log <<EOF
run {
backup incremental level=0 tag 'sxfxdb_lv0' database
format "/oracle/rman_back/sxfxdb_lv0_%d_%t_%s" 
plus archivelog 
format "/oracle/rman_back/sxfxdb_lv0_%d_%t_%s" 
delete all input;
}
EOF
exit

--level 1
[oracle@bys001 ~]$ cat back_level_1.sh 
#!/bin/sh
source /home/oracle/.bash_profile
#########rman-back level 1
rman target sys/oracle_4U log=/oracle/rman_back/back1-`date +%Y%m%d-%H%M`.log <<EOF
connect target /;
run {
backup incremental level=1 tag 'sxfxdb_lv1' database
format "/oracle/rman_back/sxfxdb_lv1_%d_%t_%s" 
plus archivelog 
format "/oracle/rman_back/sxfxdb_lv1_%d_%t_%s" 
delete all input;
}
EOF
exit

计划任务
[oracle@localhost dbrman_scripts]$ crontab -e     
0  2  * * 0,1,2,4,5    /oracle/rman_backup_script/back_level_1.sh
0  2  * * 3,6          /oracle/rman_backup_script/back_level_0.sh



