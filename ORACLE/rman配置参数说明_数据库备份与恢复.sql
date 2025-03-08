#�����ļ�SCN˵��
1��ϵͳ����scn
��һ�����㶯����ɺ�Oracle�Ͱ�ϵͳ�����SCN�洢�������ļ��С�
select checkpoint_change# from v$database;
2�������ļ�����scn
��һ�����㶯����ɺ�Oracle�Ͱ�ÿ�������ļ���scn��������ڿ����ļ��С�
select name,checkpoint_change# from v$datafile;
3������scn
Oracle����������scn�洢��ÿ�������ļ����ļ�ͷ�У����ֵ��Ϊ����scn����Ϊ�����������ݿ�ʵ������ʱ��
����Ƿ���Ҫִ�����ݿ�ָ���
select name,checkpoint_change# from v$datafile_header;
4����ֹscn
ÿ�������ļ�����ֹscn���洢�ڿ����ļ���,�������رգ���ֹSCNΪ��
select name,last_change# from v$datafile;

#####RMAN����˵��#####
--�鿴����
RMAN> show all;
#CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 5 DAYS;
���ݱ������ԣ���������ı����ļ������������ļ����ݼ��鵵��־����ر��� 
�����ڵ�ʱ����6��11��16:42��������������������ݱ������Բ����б��ݣ���ñ�����6��16��16:42֮��ᱻ��ʶΪ������
 
#CONFIGURE RETENTION POLICY TO REDUNDANCY 3;
����3�ε�0�����ݣ���������Ĵ�0�����ݵ�ʱ�򣬵�һ�α��ݽ��������ʶΪ������
ORACLE11GĬ�ϵı��ݱ����������ø÷������õģ���REDUNDANCYΪ1��
����ʹ������CONFIGURE RETENTION POLICY CLEAR�ָ�����ΪĬ��ֵ��
������������CONFIGURE RETENTION POLICY TO NONE���в������ã���ʱREPORT OBSOLETE��DELETE OBSOLETE�������κα����ļ���Ϊ������

#���������Ż�
CONFIGURE BACKUP OPTIMIZATION ON; # default
CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default

#���������ļ����Զ����ݲ�ͬʱ��ʼspfile����
CONFIGURE CONTROLFILE AUTOBACKUP ON;

#�����ļ��������ʽ(Ĭ�Ϸ��ڿ��ٻظ�����+ORA_DATA/db_name/AUTOBACKUP�£�show parameter db_recovery_file_dest)
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO 'ctrl_%F';
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '+DATA/RACDB/BACKUPSET/ctrl_%F';

#���ݵĲ��ж�
CONFIGURE DEVICE TYPE DISK PARALLELISM 2 BACKUP TYPE TO BACKUPSET;

#���ݶ�������ļ�����
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default

#���ݶ���鵵��־����
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default

#�ų�����Ҫ���ݵı�ռ�
CONFIGURE exclude for tablespace tps_name;

#RAC��������ʱ����Ҫ�ѿ����ļ����շ��ڹ���洢��
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DATA/RACDB/BACKUPSET/snapcf_crsdb2.f'

#��������٣�Ϊ��ʵ�ֿ��ٱ��ݣ�
[oracle@zx ~]$ sqlplus / as sysdba
SQL> alter database enable block change tracking using file '+FRA_DATA' ;    --ָ����ſ���ĸ����ļ��Ĺ���洢·��
�鿴
SQL> col filename for a50
SQL> select * from v$block_change_tracking;
STATUS     FILENAME                                         BYTES
---------- -------------------------------------------------- ----------
ENABLED    +RCY1/zx/changetracking/ctf.298.861133721        11599872

##���ݼ��鿴
SELECT * FROM v$rman_backup_job_details;
SELECT * FROM v$rman_configuration;   --��Ĭ�����ò鿴
SELECT * FROM v$rman_backup_subjob_details t WHERE t.status='COMPLETED' order by t."SESSION_KEY"  ;
SELECT * FROM v$backup;
SELECT * FROM v$backup_set;
SELECT * FROM v$backup_set_summary;

1���޸�rman����·��
configure channel device type disk format '/oracle/rman_back/%d_db_%u';
2����ʾʧЧ�ı���
report obsolete
3��ɾ��ʧЧ�ı���
delete obsolete
4���鿴�������
RMAN> list backupset summary;
5���鿴�Ƿ����ļ���Ҫ����
RMAN> report need backup;
6���鿴�����ļ�����
RMAN> list backup of controlfile;
7���鿴�����ļ�
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

KEY��ÿ�����ݵ�Ψһ��ʶ��
TY��B-���ݼ�   P-������ 
LV��F-���������ݿⱸ�ݼ�   A-�鵵��־   lv0-ȫ������   lv1-��������
S������״̬ A-����   U-������  X-���ݼ��Ѿ�����

--��ʾ������ϸ
RMAN> list backupset 6; 

SELECT * FROM  v$backup_set;
SELECT * FROM  v$backup_piece;
7�����ûָ����ж�
restore database parallel 4;
8����ѯ�ָ��Ľ���
SELECT * FROM v$recovery_progress;
select sid,SERIAL# ,CONTEXT,SOFAR,TOTALWORK,round(SOFAR/TOTALWORK*100,2) "_%"
from v$session_longops where OPNAME like 'RMAN%' and SOFAR<>TOTALWORK and  TOTALWORK<>0;

--��ʾ���ٻָ�����ʹ�����
SELECT substr(name, 1, 30) name, space_limit/1024/1024/1024 AS quota_G,
space_used/1024/1024/1024 AS used_G,
space_reclaimable/1024/1024/1024 AS reclaimable,
number_of_files AS files 
FROM v$recovery_file_dest ;



#####���ݿ�ָ�����#####
--�����ļ��ָ�
startup nomount;
RMAN> restore pfile to '/home/oracle/spfile.resore' from autobackup;
#ָ���ָ���·��
restore spfile to '/tmp/spfile.resore' from autobackup;
#���������ļ���
RMAN> backup as copy spfile format '/u01/oracle/bak/spfileorcl.ora';




#####RAC����#####
#��Ĭ�ϵ�����£������Ƿ��ڿ��ٻָ����еġ�
-backupset Ŀ¼�´�ţ�ÿ�챸��
-autobackup ����Զ����ݵĿ����ļ��������ļ�

#RAC��rman�������RAC��Ψһ�Ĳ�ͬ�ǿ������ñ��ݵĸ��ؾ��⡣
1�����÷���
srvctl add service -d CRSDB -s rdb_main -r crsdb1 crsdb2
-d Unique name for the database 
-s service _name --��������ָ��
-r instance_name
2����֤�����ڵ�����Ѿ�����
srvctl status service -d crsdb
3�������ڵ�����TNS

rdb_main =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST =racnod1)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = rdb_main)
    )
  )
4��rman ���þ���
RMAN> configure device type disk parallelism 2; --���þ���

-- ���յĿ����ļ����ڹ���洢��
configure snapshot controlfile name to '+ORA_DATA\snapcf_rdb';


--rman�ָ�����(��������RAC)
list failure;
advise failure;
repair failure preview;   --�ṩ�޸���׼ȷԤ��
repair failure;


--Ϊ�˱�֤���ݵ���Ч�ԣ���Ҫ������֤���ݵ���Ч�ԡ�
#��֤�����������ִ�лָ������Կ�����ȥ������Ե��鷳��ͬʱ�ֿ��Լ�鱸�ݵ���Ч�ԣ���Ӧ������ִ�еĲ�����

restore validate controlfile;
restore validate spfile;
restore validate database;
restore validate archivelog all;


#####�����ļ��ָ�#####
�����������ļ���ʧ���ᷢ��ʲô���û����ܵ�¼�����������ĺã����������ļ���ʧ��ֻ����sysdba��ʽû�취��¼����¼�ᱨ����ͨ����Զ�̵�¼����Ӱ��

���뵽�����ļ�����Ŀ¼
cd $ORACLE_HOME/dbs

�ļ�ɾ����ģ�ⶪʧ
rm orapwora10g;     �������ļ���������orapw$ORACLE_SID��

ɾ��֮���������������½���һ���ļ�,entries����˼(DBA���û������5����
orapwd file=orapwora10g password=oracle entries=5; 

#####�����ļ��Ļָ�#####
--�����ļ��ָ�
startup nomount;
RMAN>  restore controlfile from AUTOBACKUP;
RMAN> alter database mount;
RMAN> recover database ;
RMAN> alter database open resetlogs;
#���������ļ���
RMAN> backup as copy current controlfile  format '/u01/oracle/bak/control01.ctl';
RMAN> restore controlfile from '/u01/app/oracle/product/11.2.0/db_1/dbs/c-1009242311-20200518-00';


--����Ŀǰ�������ļ��ļ���������ļ��еļ��㲻ͬ��������Ҫ�ƽ����㡣
Ӧ���Իָ������ļ��������Ĺ鵵��־��redo log;
RMAN> recover database;

���ڻָ��˿����ļ������ҿ����ļ���֮ǰʱ���ģ��������ļ��ǵ�ǰ���µ�ʱ��㣬����������resetlog����noresetlog���ᱨ������Ҫ�ƽ�controlfile����Ҫrecover database;
SQL> alter database open resetlogs;
������v$log��SEQUENCE#��archived_log��SEQUENCE#��




#####ָ����ռ䱸�ݼ��ָ�#####
##��ռ䱸��
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


##��ռ�ָ�
�鿴��ռ�״̬:
select FILE_NAME,STATUS,ONLINE_STATUS from dba_data_files;
sql 'alter tablespace cz_test offline';
���������ݿ⴦��mount����open״̬ʱ������ռ���Ϊoffline
run {
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
restore tablespace cz_test;
recover tablespace cz_test;
sql 'alter tablespace cz_test online';
release channel ch1;
release channel ch2;
}

#####����ָ�#####
һ��rman�ָ���������
rman> recover datafile 7 block 3 datafile 2 block 19;

rman> blockrecover datafile 6 block 3893;
 
--�鿴����
SELECT * FROM gv$database_block_corruption;
--�޸������б�
RMAN> recover corruption list;

������������

1�����������
exec DBMS_REPAIR.ADMIN_TABLES('REPAIR_TABLE',1,1,'USERS');     //���԰�����������������ı�ռ���

2������������
exec DBMS_REPAIR.ADMIN_TABLES('ORPHAN_TABLE',2,1,'USERS');  

3����黵��
SQL> SET SERVEROUTPUT ON
declare
cc number;
begin
dbms_repair.check_object(schema_name => 'HWJ',object_name => 'TEST',corrupt_count => cc);
dbms_output.put_line(a => to_char(cc));
end;
/

1    --���Ϊ1��˵����1������

4��check��֮�������Ǹ��ڴ�����REPAIR_TABLE�в鿴������Ϣ��
SQL> SELECT object_name, relative_file_id, block_id,marked_corrupt,corrupt_description, repair_description,CHECK_TIMESTAMP from repair_table;
          
5���������� �������Ļ���ᵼ�¿��ϵ����ݶ�ʧ��
exec dbms_repair.skip_corrupt_blocks(schema_name => 'HWJ',object_name => 'TEST',flags => 1);

6����������
SQL> declare
  cc number;
  begin
  dbms_repair.dump_orphan_keys(schema_name => 'HWJ',object_name => 'IDX_TEST',object_type => 2,
  repair_table_name => 'REPAIR_TABLE',orphan_table_name => 'ORPHAN_TABLE',key_count => CC);
  end;
 /

Ҳ�����ؽ���������
 SELECT * FROM ORPHAN_TABLE;
          

  




#####�����ļ��ָ�######
alter tablespace DZDA_DAT online
*
ERROR at line 1:
ORA-01157: cannot identify/lock data file 6 - see DBWR trace file
ORA-01110: data file 6: '/u01/oracle/oradata/NFZCDB/dzda_dat.dbf'

RMAN> restore datafile 6;
RMAN> recover datafile 6;

SQL> alter tablespace DZDA_DAT online;
SQL> alter database open;

#####���ݿ�ָ�#####
##һ���Իָ�
#�ر����ݿ�
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

#�鿴״̬��
select sid,SERIAL# ,CONTEXT,SOFAR,TOTALWORK,round(SOFAR/TOTALWORK*100,2) "_%"
from v$session_longops where OPNAME like 'RMAN%' and SOFAR<>TOTALWORK and  TOTALWORK<>0;

##��һ���Իָ�
--����ʱ��㣺
startup mount;
restore database until time "to_date('2015-04-20 08:13:50','yyyy-mm-dd hh24:mi:ss')";
recover database until time "to_date('2015-04-20 08:13:50','yyyy-mm-dd hh24:mi:ss')";
alter database open resetlogs;                  

##����scn�ţ�
--�������⣺
RMAN-06025: no backup of archived log for thread 1 with sequence 6 and starting SCN of 2435400 found to restore
--������
startup mount;
restore database until scn 2435400;��Ҳ����ֱ��restore database��
recover database until scn 2435400;
alter database open resetlogs;                  

##���ڹ鵵��־���кŵĻָ�:
startup mount;
restore database until sequence 123 thread 1��
recover database until sequence 123 thread 1��
alter database open resetlogs; 
//���ڹ鵵�ļ�
sys@SYBO2SZ> recover database until cancel;     --> ���� cancel �ָ����ݿ�  
ORA-00279: change 494124 generated at 08/22/2012 17:02:30 needed for thread 1  
ORA-00289: suggestion : /u02/database/SYBO2SZ/archive/arch_792003491_1_4.arc  
ORA-00280: change 494124 for thread 1 is in sequence #4  
  
Specify log: {<RET>=suggested | filename | AUTO | CANCEL}  
/u02/database/SYBO2SZ/archive/arch_792003491_1_4.arc     -->�ָ���β��Ϊ4�Ĺ鵵��־  
ORA-00279: change 494189 generated at 08/22/2012 17:04:46 needed for thread 1  
ORA-00289: suggestion : /u02/database/SYBO2SZ/archive/arch_792003491_1_5.arc  
ORA-00280: change 494189 for thread 1 is in sequence #5  
ORA-00278: log file '/u02/database/SYBO2SZ/archive/arch_792003491_1_4.arc' no longer needed for this recovery  
  
Specify log: {<RET>=suggested | filename | AUTO | CANCEL}  
cancel                                                 -->��5����־�ļ���ʧ������cancel  
Media recovery cancelled.  
sys@SYBO2SZ> alter database open resetlogs;            --> resetlogs ��ʽ�����ݿ� 


#####�Զ�����autobackup#####
1�����������ÿ��ٻظ���
2�����ݽű�
#ȫ������
crosscheck archivelog all;
delete noprompt expired archivelog all;
sql 'alter system archive log current';
backup as compressed backupset full tag 'orcldb-full' database     //ѹ�����ݼ�
plus archivelog
delete all input;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;

#����0��
crosscheck archivelog all;
delete noprompt expired archivelog all;
sql 'alter system archive log current';
backup incremental level=0  tag 'orcldb-level0' database
plus archivelog
delete all input;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;

#����1��
crosscheck archivelog all;
delete noprompt expired archivelog all;
sql 'alter system archive log current';
backup incremental level=1  tag 'orcldb-level1' database
plus archivelog
delete all input;
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;

#������ɺ󣬻ῴ�������ļ��������ļ�����Ϣ
RMAN> list backupset;
Piece Name: +ORA_DATA/ORCLDB/AUTOBACKUP/2020_08_26/s_1049474734.268.1049474737
Control File Included: Ckp SCN: 1436711      Ckp time: 2020/08/26 16:45:34

#####QA#####
##�����쳣
SQL> alter database open resetlogs;

alter database open resetlogs

*

ERROR at line 1:

ORA-01194: file 1 needs more recovery to be consistent

ORA-01110: data file 1: '+ZHAOJINGYU/jy/datafile/system.256.839673875'

˵�������������ģ�������ļ�1��ʧ�����մӱ���restore����һ���ɵ��ļ�������������ԭ����֮û�к����Ĺ鵵ȥ��recover�������޷�׷ƽ��
��ʱ�Ϳɳ���ʹ��_allow_resetlogs_corruption���ز���ǿ�ƿ��⣺
--���������pfile����
alter system set "_allow_resetlogs_corruption" = true scope=spfile;
alter system set "_corrupted_rollback_segments" = true scope=spfile;
alter system set "_offline_rollback_segments" = true scope=spfile;

SQL> shutdown immediate

SQL> startup mount

SQL> alter database open resetlogs;

��ʱ��ȥ��ѯ�����ļ�ͷ��SCN�Ѿ�һ�£�

SQL> select checkpoint_change# from v$datafile_header;


############################################################################


1.����RMAN���ݵ���ز������ܣ�
�����в��� ����
TARGET ΪĿ�����ݿⶨ���һ�������ַ����������ӵ�һ��Ŀ�����ݿ�ʱ����������SYSDBA���ӡ����û�ӵ�������͹ر����ݿ��Ȩ������������OSDBA�飬���뽨��һ�������ļ�����SYSDBA���ӡ�
CATALOG ���ӵ��ָ�Ŀ¼��
NOCATALOG �����ûָ�Ŀ¼����CATALOG��������
CMDFILE ��������������ļ����Ƶ��ַ�����������RMANʱ���������������ļ����߽���ʽ����
LOG & MSGLOG �����˰���RMAN�����Ϣ���ļ����ַ�����LOG����ֻ���ر��������������С�������RMAN������SPOOLING����Ӧ����־�ļ�ʱ���������Ϣ��������Ļ����ʾ
TRACE ������log������������һ����ʾRMAN������Ϣ���ļ���ʹ��TRACE����Ļ��Ҳ��ʾ��
APPEND �����÷��������Ϣ��־�ļ���������Ϣ׷�ӵ����ļ��С�������LOG����ʹ��
���ݿ�OPENʱ�鵵ģʽ��RMAN���Ա��ݡ�
���ݿ�OPENʱ�ǹ鵵ģʽ��RMANֻ�ܱ���READ ONLY��OFFLINE�б�ռ�������ļ���
�鵵ģʽ��RMANȫ�ⱸ��ʱ��
�����ݿ�OPEN��MOUNT�׶ζ����Ա��ݡ����ݿ�ʵ��δ����������������NOMOUNT״̬�����ܱ��ݡ�
�ǹ鵵ģʽ��RMANȫ�ⱸ��ʱ��
ֻ����MOUNT״̬�±��ݡ�
.ע��һ����RMAN�����־�ķ����У�
rman log='/home/oracle/app/oradataback/db_rman1.log' append <<EOF
connect target /;

rman log /home/oracle/rman-arch`date +%Y%m%d-%H:%M`.log <<EOF
connect target /;
ע��������ڹ鵵��־��ɾ������delete all input��
backup archivelog all delete all input������ɾ�����ݹ鵵ʱdelete all input�� delete input����
���ֻ������һ���鵵Ŀ¼����������û������
���������һ�����Ϲ鵵Ŀ¼--log_archive_dest_n������������������
DELETE ALL INPUT �Ὣ�����鵵Ŀ¼�µĹ鵵��־��ɾ��
DELETE INPUT��ֻɾ������һ��--���籸��ʱ��ʹ��log_archive_dest_1�еĹ鵵��־����ɾ��log_archive_dest_1�еĹ鵵��־��

ע���������ݹ鵵��־ʱ�����Կ����ڽű�ǰд��cross check archivelog all;���
�����ʹ��RMAN����ʱ���ڲ���ϵͳ��ɾ���鵵��־δ��RMAN��ִ��cross check archivelog all;ʱ�����ݻᱨ��RMAN-06059: expected archived log not found, loss of archived log compromises recoverability ����ʱ�������ֶ�ִ��cross check archivelog all;������ٽ��б��ݣ�Ҳ����ֱ�Ӱ�cross check archivelog all;����д�����ݽű��
�����ﲢδ�������д�뵽���ݽű��У���Ϊ������������������鵵��־��ȫ���ܵ����ں��ڵ����ݿ�ָ��в�����ȫ�ָ����������ϱ��ݱ����Ա㼰�緢�����⡣
˵��������Ľű��ڰ�װ��LINUX��ORACLE 11G���Ի����������ԣ������Լ�����ʹ�����޸���Ӧ������ʹ������source /home/oracle/.bash_profile������ȷ����LINUX��ʱ������ִ�гɹ��������Ҫ��WIN��ʹ�ã��������޸ġ�
ע���ģ������ļ��Զ����ݵĿ���
Ӧ�ÿ��������ļ��Զ����ݣ������ǣ�
CONFIGURE CONTROLFILE AUTOBACKUP ON;      
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/home/oracle/%F';  
---�����нű�Ĭ�Ͽ��������ļ��Զ����ݡ�
ע���壺д���ݽű���С���ɣ�
�����ڱ���ǰ���ӱ���ǰ--У��鵵��־�ļ�
crosscheck archivelog all;
delete noprompt expired archivelog all;
���ݺ�-У�鱸�ݼ���ɾ�����ڼ���ɾ���ı�����Ϣ
crosscheck backup;
delete noprompt expired backup;
delete noprompt obsolete;
2.���ڲ������������ݸ���ļ򵥽��ܣ�
��������Differential--  Ĭ�ϵķ�ʽ��    ����ͬһ������һ�����ݺ�ı仯
��һ��0�����ݣ���ȫ����
Ȼ��1���ǵ�0�����������ı仯�ı��ݡ�
��ʱ����1�����ݣ����ݵ��Ǵ���һ��1�����ݺ�ı仯��
����2�����ݣ����Ǵӵڶ���1�����ݺ�ı仯��
��ʱ����1�����ݣ��򱸷ݴӵڶ���1�����ݺ�ı仯��---����2�����ݵġ�

�ۻ�����Cumulative--��Ҫָ����   ������һ�����ݺ�ı仯
��һ��0�����ݣ���ȫ����Ȼ��1���ǵ�0�����������ı仯�ı��ݡ�
��ʱ����1�����ݣ����ݵ��Ǵ���һ��0�����ݺ�ı仯��   --------------Ҳ����ͬ����ı��ݲ�����ͬ��
��2�����ݣ����Ǵӵڶ���1�����ݺ�ı仯��
��ʱ����1�����ݣ��򱸷ݴ�0�����ݺ�ı仯
3.ֻ���ݹ鵵�ļ���ָ������Ŀ¼�������ļ���ʽ
ָ����������־�������ļ����ļ�λ�á���ʽ����־��ʽ����������rman-arch20130912-1634.log
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
����鵵��־��Ҫ�������ݣ���RMAN�п���ֱ�����ý����޸ġ���Ҫ�ڱ��ݼ�����%c�������ʽ�ܱ��ݳɹ���ʾ�����£�
 %c Copy number for multiple copies in a duplexed backup   ����Ƭ�Ķ��copy�����
 
RMAN> CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 2;
RMAN> backup archivelog all format '/home/oracle/backup/%t_%d_%u_%c.arc';
4.ɾ���鵵��־�Ľű�����������ɾ��һ��ǰ�Ĺ鵵��־
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
5.ȫ�ⱸ�ݽű��������鵵��־�������ļ���SPFILE�����ļ�
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
###############�����Ǽ�ǿ�棺
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
6.��������Differential���ݽű�--��0��1��2����%%%����Ĭ�ϵ��������ݷ�ʽ����������Differential��Ĭ�ϱ��ݷ�ʽ��
0�������������ݽű�
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
1�������������ݽű�
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

2�������������ݽű�
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

7.cumulative�ۻ���������--��0��1��2����
0���ۻ��������ݽű�
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
1���ۻ��������ݽű�
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

2���ۻ��������ݽű�
����ű���ʹ���˷���������½RMAN���������RMAN��ʹ��connect target sys/sys@192.168.1.212:1521/bys001;ȷ�ϵ�½������д��ű���
��ȻҲ����ʹ�� rman target sys/sys@bys001
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

--ָ��ͨ������
run{
allocate channel ch1 device type disk;
allocate channel ch2 device type disk;
backup as compressed backupset database format '/data/backup/rmanback/db_%d_%T_%U';   --ѹ������
crosscheck backup;
release channel ch1;
release channel ch2;
}

--�鿴ÿ��ı��ݼ���С
select 
to_char(start_time,'yyyy-mm-dd') start_time,
to_char(start_time,'day') day, 
round(sum(OUTPUT_BYTES)/1024/1024/1024,2) SIZE_GB 
from v$backup_set_details
group by to_char(start_time,'yyyy-mm-dd'),to_char(start_time,'day') 
order by start_time desc;

--�鿴ÿ��ı���Ƭ�δ�С
select 
to_char(start_time,'yyyy-mm-dd') start_time,
to_char(start_time,'day') day, 
round(sum(BYTES)/1024/1024/1024,2) SIZE_GB 
from v$backup_piece where handle is not null
group by to_char(start_time,'yyyy-mm-dd'),to_char(start_time,'day') 
order by start_time asc;

8.WINDOWS�µı��ݽű���
�ȴ���һ��BAT�ļ� ���£�����f:\arch_rman.sql�еı��������������־��ʽ�ǣ�f:\backlog\arch20130304-2050.log
rman  target / cmdfile=f:\arch_rman.sql log f:\backlog\arch%date:~0,4%%date:~5,2%%date:~8,2%-%time:~0,2%%time:~3,2%.log
f:\arch_rman.sql�еı������
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
show all �鿴Ŀǰ������
�ָ�5�������ݵ�rman���ݣ�
RETENTION POLICY TO RECOVERY WINDOW OF 5 DAYS;
�������жȣ�
CONFIGURE DEVICE TYPE DISK PARALLELISM 5 BACKUP TYPE TO BACKUPSET;
���ÿ����ļ��Զ����ݣ�
CONFIGURE CONTROLFILE AUTOBACKUP ON;







--�����ű�
0���������������ݵĻ�����ȫ���ݲ��ܵ�0�������á�
ȫ�ⱸ�ݿ�����BLOLK�鼶�Ļָ���0�������ԡ�

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

�ƻ�����
[oracle@localhost dbrman_scripts]$ crontab -e     
0  2  * * 0,1,2,4,5    /oracle/rman_backup_script/back_level_1.sh
0  2  * * 3,6          /oracle/rman_backup_script/back_level_0.sh



