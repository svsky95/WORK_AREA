##rman异机恢复RAC到单实例
1、找到rac数据库的备份路径
+DATA/RACDB/BACKUPSET
ASMCMD> ls
2019_12_24/
2019_12_25/
--由于尚未找到从asm中拷贝文件夹到文件系统，只能逐个文件夹打开
cp +DATA/RACDB/BACKUPSET/2019_12_24/annnf0_CRSDB_LV0_0.1090.1027879367 /home/grid/backupset_racdb
cp +DATA/RACDB/BACKUPSET/2019_12_24/annnf0_CRSDB_LV0_0.1091.1027879367 /home/grid/backupset_racdb
cp +DATA/RACDB/BACKUPSET/2019_12_24/annnf0_CRSDB_LV0_0.960.1027879301  /home/grid/backupset_racdb
cp +DATA/RACDB/BACKUPSET/2019_12_24/nnndn0_CRSDB_LV0_0.1096.1027879325 /home/grid/backupset_racdb
cp +DATA/RACDB/BACKUPSET/2019_12_24/nnndn0_CRSDB_LV0_0.1097.1027879325 /home/grid/backupset_racdb
cp +DATA/RACDB/BACKUPSET/2019_12_24/nnndn0_CRSDB_LV0_0.1099.1027879325 /home/grid/backupset_racdb

cp +DATA/RACDB/BACKUPSET/2019_12_25/annnf0_CRSDB_LV1_0.343.1027933941 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/annnf0_CRSDB_LV1_0.348.1027933925 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/annnf0_CRSDB_LV1_0.450.1027933925 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/annnf0_CRSDB_LV1_0.503.1027933981 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/annnf0_CRSDB_LV1_0.650.1027933981 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/ncnnn1_CRSDB_LV1_0.318.1027933971 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/nnndn1_CRSDB_LV1_0.338.1027933949 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/nnndn1_CRSDB_LV1_0.342.1027933949 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/nnndn1_CRSDB_LV1_0.457.1027933949 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/nnndn1_CRSDB_LV1_0.458.1027933949 /home/grid/backupset_racdb 
cp +DATA/RACDB/BACKUPSET/2019_12_25/nnsnn1_CRSDB_LV1_0.341.1027933971 /home/grid/backupset_racdb 


2、在目标单实例上创建文件夹，并赋予权限
/home/oracle/backupset_racdb
scp -r /home/grid/backupset_racdb  /home/oracle/backupset_racdb 
chown -R oracle.oinstall backupset_racdb


3、目标单实例上使用基础参数文件启动数据库：
more init.ora

db_name='RACDB'
memory_target=1G
processes = 150
audit_file_dest='/home/oracle/adump'
audit_trail ='db'
db_block_size=8192
db_domain=''
#db_recovery_file_dest='<ORACLE_BASE>/flash_recovery_area'
#db_recovery_file_dest_size=2G
diagnostic_dest='/home/oracle'
dispatchers='(PROTOCOL=TCP) (SERVICE=ORCLXDB)'
open_cursors=300 
remote_login_passwordfile='EXCLUSIVE'
undo_tablespace='UNDOTBS1'
# You may want to ensure that control files are created on separate physical
# devices
control_files = (ora_control1, ora_control2)
compatible ='11.2.0'

--启动实例
startup nomount pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/init.ora'

--恢复参数文件(此处假设rac已完全损坏，无法通过rmand的 RMAN> list backupset; 找到参数文件具体在哪个备份集中 )
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.343.1027933941';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.348.1027933925';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.450.1027933925';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.503.1027933981';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.650.1027933981';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/ncnnn1_CRSDB_LV1_0.318.1027933971';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/nnndn1_CRSDB_LV1_0.338.1027933949';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/nnndn1_CRSDB_LV1_0.342.1027933949';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/nnndn1_CRSDB_LV1_0.457.1027933949';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/nnndn1_CRSDB_LV1_0.458.1027933949';
restore spfile to pfile '/tmp/pfile_racdb.ora' from  '/home/oracle/backupset_racdb/nnsnn1_CRSDB_LV1_0.341.1027933971';

--恢复完，参数文件后，根据/tmp/pfile_racdb.ora文件进行修改，注释掉rac的部分
*.audit_file_dest='/u01/app/oracle/admin/racdb/adump'
*.audit_trail='db'
*.compatible='11.2.0.4.0'
*.control_files=(ora_control1, ora_control2)
*.db_block_size=8192
*.db_create_file_dest='/home/oracle/data'
*.db_create_online_log_dest_1='/home/oracle/onlinelog'
*.log_archive_dest='/home/oracle/archivelog'
*.db_domain=''
*.db_name='racdb'
*.diagnostic_dest='/u01/app/oracle'
*.dispatchers='(PROTOCOL=TCP) (SERVICE=racdbXDB)'
*.enable_ddl_logging=TRUE
*.log_archive_format='%t_%s_%r.dbf'
*.open_cursors=300
*.memory_target=2G
*.processes=500
*.remote_login_passwordfile='exclusive'
*.utl_file_dir='/home/oracle/logmnr'

--创建缺省目录，并查看是否有oracle.oinstall属组
[oracle@orcl01 tmp]$ mkdir -p /home/oracle/data
[oracle@orcl01 tmp]$ mkdir -p /home/oracle/onlinelog
[oracle@orcl01 tmp]$ mkdir -p /home/oracle/archivelog

--编辑oracle的环境变量
[oracle@orcl01 ~]$ more ~/.bash_profile
export PATH
export TMP=/tmp
export LANG=en_US.UTF-8
export TMPDIR=$TMP
export ORACLE_SID=racdb
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export ORACLE_UNQNAME=racdb
export TNS_ADMIN=$ORACLE_HOME/network/admin
export ORACLE_TERM=xterm
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export EDITOR=vi
export NLS_DATE_FORMAT='yyyy/mm/dd hh24:mi:ss'
umask 022

--用参数文件启动
shutdown immediate 
startup nomount pfile='/tmp/pfile_racdb.ora'

--rman恢复控制文件(此处假设rac已完全损坏，无法通过rmand的 RMAN> list backupset; 找到控制文件具体在哪个备份集中 )
[oracle@racnode02 ~]$ rman target /

Recovery Manager: Release 11.2.0.4.0 - Production on Thu Dec 26 11:08:43 2019
Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.
connected to target database: RACDB (not mounted)

restore controlfile from '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.343.1027933941';
restore controlfile from '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.348.1027933925';
restore controlfile from '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.450.1027933925';
restore controlfile from '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.503.1027933981';
restore controlfile from '/home/oracle/backupset_racdb/annnf0_CRSDB_LV1_0.650.1027933981';
restore controlfile from '/home/oracle/backupset_racdb/ncnnn1_CRSDB_LV1_0.318.1027933971';
restore controlfile from '/home/oracle/backupset_racdb/nnndn1_CRSDB_LV1_0.338.1027933949';
restore controlfile from '/home/oracle/backupset_racdb/nnndn1_CRSDB_LV1_0.342.1027933949';
restore controlfile from '/home/oracle/backupset_racdb/nnndn1_CRSDB_LV1_0.457.1027933949';
restore controlfile from '/home/oracle/backupset_racdb/nnndn1_CRSDB_LV1_0.458.1027933949';
restore controlfile from '/home/oracle/backupset_racdb/nnsnn1_CRSDB_LV1_0.341.1027933971';

Starting restore at 2019/12/26 11:11:28
using target database control file instead of recovery catalog
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=585 device type=DISK

channel ORA_DISK_1: restoring control file
channel ORA_DISK_1: restore complete, elapsed time: 00:00:01
output file name=/u01/app/oracle/product/11.2.0/db_1/dbs/ora_control1
output file name=/u01/app/oracle/product/11.2.0/db_1/dbs/ora_control2
Finished restore at 2019/12/26 11:11:29


--参数文件恢复完成后，启动数据库到mount状态
alter database mount;


SQL> select OPEN_MODE from V$database;

OPEN_MODE
--------------------
MOUNTED

--恢复数据文件
1、将备份集信息重新导入到当前控制文件中 --需要把全量和增量放在同一个文件夹下。一次性导入，后期再有增加，也可以再放在这个文件夹下，再导入，不可新建其它的文件夹
RMAN> catalog start with "/home/oracle/backupset_racdb";   <--可以加入归档日志，进行完全恢复，但是实验尝试不成功。

2、检查备份
crosscheck backup;

3、恢复数据库
--检查并关闭闪回
SQL> alter database flashback off;

Database altered.

SQL> select flashback_on from v$database;

FLASHBACK_ON
------------------
NO

--介质恢复
--目标单实例进行文件的转换
#数据文件  --需要替换 +DATA/racdb/datafile 为本地路径
select 'SET NEWNAME FOR DATAFILE ' || file# || ' TO '''|| name||'.dbf'''||';' from v$datafile order by file#; 

#临时文件  --需要替换 +DATA/racdb/datafile 为本地路径
select 'SET NEWNAME FOR DATAFILE ' || file# || ' TO '''|| name||'.dbf'''||';' from v$tempfile order by file#; 

##数据文件和临时文件，需要打包到run块里面
run {
SET NEWNAME FOR DATAFILE 1 TO '/home/oracle/data/system.262.1011625547.dbf';
SET NEWNAME FOR DATAFILE 2 TO '/home/oracle/data/sysaux.263.1011625553.dbf';
SET NEWNAME FOR DATAFILE 3 TO '/home/oracle/data/undotbs1.264.1011625555.dbf';
SET NEWNAME FOR DATAFILE 4 TO '/home/oracle/data/undotbs2.266.1011625563.dbf';
SET NEWNAME FOR DATAFILE 5 TO '/home/oracle/data/users.267.1011625563.dbf';
SET NEWNAME FOR DATAFILE 6 TO '/home/oracle/data/test_data.942.1024050437.dbf';
SET NEWNAME FOR DATAFILE 7 TO '/home/oracle/data/aaa.286.1024831425.dbf';
SET NEWNAME FOR DATAFILE 8 TO '/home/oracle/data/bbb.291.1024831983.dbf';
SET NEWNAME FOR DATAFILE 9 TO '/home/oracle/data/ccc.303.1024832443.dbf';
SET NEWNAME FOR DATAFILE 10 TO '/home/oracle/data/cz_tps01.365.1027933875.dbf';
SET NEWNAME FOR DATAFILE 1 TO '/home/oracle/data/temp.265.1011625555.dbf';
}
restore database;

#redo log
sql>alter database backup controlfile to trace;
sql>select value from v$diag_info where name='Default Trace File';
sed -n '/CREATE CONTROLFILE.*NORESETLOGS/,/;/p' /u01/app/oracle/diag/rdbms/racdb/racdb/trace/racdb_ora_25335.trc
从跟踪文件中，找到logfile
--由于源库的redo的影响，需要重命名
sqlplus / as sysdba 
alter database rename file '+DATA/racdb/onlinelog/group_1.259.1011625547' to '/home/oracle/data/RACDB/onlinelog/redo1_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_1.258.1011625547' to '/home/oracle/data/RACDB/onlinelog/redo1_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_2.260.1011625547' to '/home/oracle/data/RACDB/onlinelog/redo2_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_2.261.1011625547' to '/home/oracle/data/RACDB/onlinelog/redo2_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_5.810.1022411397' to '/home/oracle/data/RACDB/onlinelog/redo5_1.log';
alter database rename file '+DATA/racdb/onlinelog/redo5.rdo'              to '/home/oracle/data/RACDB/onlinelog/redo5_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_3.268.1011627295' to '/home/oracle/data/RACDB/onlinelog/redo3_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_3.269.1011627295' to '/home/oracle/data/RACDB/onlinelog/redo3_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_4.270.1011627295' to '/home/oracle/data/RACDB/onlinelog/redo4_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_4.271.1011627295' to '/home/oracle/data/RACDB/onlinelog/redo4_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_6.935.rdo'        to '/home/oracle/data/RACDB/onlinelog/redo6_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_6.934.1024246183' to '/home/oracle/data/RACDB/onlinelog/redo6_2.log';

--增量恢复
rman > recover database;  

--不完全恢复
控制文件中，SCN号靠后，启动时需要应用归档日志，但是在rman备份时，归档是最新的，并且控制文件，还记录了redolog的SCN根本无法找到归档，所以并不会丢失数据。
RMAN-06054: media recovery requesting unknown archived log for thread 1 with sequence 241 and starting SCN of 21836419
RMAN> recover database until scn 21836419;
alter database open resetlogs;

--查看redo、archivelog 序号
select name,thread#,sequence#,first_time,next_time,first_change#,next_change# from v$archived_log where sequence#=241 and thread#=1;
select sequence#,status,group# from v$log;



##########################################################################################################################################



run {
allocate channel c1 device type disk;
allocate channel c2 device type disk;
set newname for datafile 1 to 'o1_mf_system_01.dbf';
set newname for datafile 2 to 'o1_mf_sysaux_01.dbf';
set newname for datafile 3 to 'o1_mf_undotbs1_01.dbf';
set newname for datafile 4 to 'o1_mf_users_01.dbf';
set newname for datafile 5 to 'o1_mf_users_02.dbf';
set newname for datafile 6 to 'o1_mf_test_01.dbf';
set newname for datafile 7 to 'o1_mf_aaa_01.dbf';
set newname for datafile 8 to 'o1_mf_bbb_01.dbf';
set newname for datafile 9 to 'o1_mf_ccc_01.dbf';
restore database;   
switch datafile all;
release channel c1;
release channel c2;
}



alter database clear logfile '/xx/oradata/redo01.dbf'；


alter database drop logfile '/xx/oradata/redo01.dbf'；


alter database create logfile '/xx/oradata/redo01.dbf'


alter database rename file '+DATA/racdb/onlinelog/redo5.rdo'  To '/home/oracle/data/RACDB/onlinelog/redo5.log';



alter database rename file '+DATA/racdb/onlinelog/group_1.259.1011625547' to '/home/oracle/data/RACDB/onlinelog/redo1_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_1.258.1011625547' to '/home/oracle/data/RACDB/onlinelog/redo1_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_2.260.1011625547' to '/home/oracle/data/RACDB/onlinelog/redo2_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_2.261.1011625547' to '/home/oracle/data/RACDB/onlinelog/redo2_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_5.810.1022411397' to '/home/oracle/data/RACDB/onlinelog/redo5_1.log';
alter database rename file '+DATA/racdb/onlinelog/redo5.rdo'              to '/home/oracle/data/RACDB/onlinelog/redo5_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_3.268.1011627295' to '/home/oracle/data/RACDB/onlinelog/redo3_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_3.269.1011627295' to '/home/oracle/data/RACDB/onlinelog/redo3_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_4.270.1011627295' to '/home/oracle/data/RACDB/onlinelog/redo4_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_4.271.1011627295' to '/home/oracle/data/RACDB/onlinelog/redo4_2.log';
alter database rename file '+DATA/racdb/onlinelog/group_6.935.rdo'        to '/home/oracle/data/RACDB/onlinelog/redo6_1.log';
alter database rename file '+DATA/racdb/onlinelog/group_6.934.1024246183' to '/home/oracle/data/RACDB/onlinelog/redo6_2.log';

         

restore spfile to pfile '/u01/app/oracle/11.2.0/db_1/dbs/inibigdata.ora' from '/home/oracle/backupset_racdb/sp_BIGDATA_02ukangs_1.ora';
restore spfile from '/home/oracle/backupset_racdb/sp_BIGDATA_02ukangs_1.ora';
restore spfile to pfile '/tmp/pfile.ora' from '/home/oracle/backupset_racdb/sp_BIGDATA_02ukangs_1.ora';

2).拷贝控制文件：
RMAN> backup as copy current controlfile  format '/u01/oracle/bak/control01.ctl';
3).拷贝参数文件：
RMAN> backup as copy spfile format '/u01/oracle/bak/spfileorcl.ora';

--控制文件跟踪
SQL> alter database backup controlfile to trace;

Database altered.

SQL> select value from v$diag_info  where name='Default Trace File';

VALUE
--------------------------------------------------------------------------------
/u01/app/oracle/diag/rdbms/racdb/racdb/trace/racdb_ora_23305.trc