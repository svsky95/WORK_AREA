#######Logminer���ú�ʹ��#######
--Logminer������Ҫ�������ݿ�ſ���ʹ�ã����԰ѹ鵵��־�ļ����������Կ�·���£�Ȼ�󵼳�������ٵ��ص��������ϡ�
��ʹ��LogMiner֮ǰ��Ҫȷ��Oracle�Ƿ���н���LogMiner��������һ����˵Windows����ϵͳOracle10g���϶�Ĭ�ϰ������������ȷ�ϣ�����DBA��ݵ�¼ϵͳ���鿴ϵͳ���Ƿ��������LogMiner����Ҫ��dbms_logmnr��dbms_logmnr_d�������û����Ҫ��װLogMiner���ߣ���������Ҫ�����������������ű���
1��$ORACLE_HOME/rdbms/admin/dbmslm.sql
2��$ORACLE_HOME/rdbms/admin/dbmslmd.sql.
�������ű��������DBA�û�������С����е�һ���ű���������DBMS_LOGMNR�����ð�����������־�ļ����ڶ����ű���������DBMS_LOGMNR_D�����ð��������������ֵ��ļ���

������Ϻ󽫰������¹��̺���ͼ��

Dbms_logmnr_d.build      ����һ�������ֵ��ļ�
Dbms_logmnr.add_logfile  �������������־�ļ��Թ�����
Dbms_logmnr.start_logmnr ʹ��һ����ѡ���ֵ��ļ���ǰ��ȷ��Ҫ������־�ļ�������LogMiner
Dbms_logmnr.end_logmnr   ֹͣLogMiner����

V$logmnr_dictionary      ��ʾ������������ID���Ƶ��ֵ��ļ�����Ϣ
V$logmnr_logs            ��LogMiner����ʱ��ʾ��������־�б�
V$logmnr_contents        LogMiner�����󣬿���ʹ�ø���ͼ��SQL��ʾ��������SQL�������ѯ������־������

##���������ֵ��ļ�
LogMiner����ʵ�������������µ�PL/SQL�ڽ�����(DBMS_LOGMNR �� DBMS_ LOGMNR_D�����ĸ�V$��̬������ͼ����ͼ�������ù���DBMS_LOGMNR.START_LOGMNR����LogMinerʱ��������ɡ���ʹ��LogMiner���߷���redo log�ļ�֮ǰ������ʹ��DBMS_LOGMNR_D ���������ֵ䵼��Ϊһ���ı��ļ������ֵ��ļ��ǿ�ѡ�ģ��������û������LogMiner���ͳ���������й��������ֵ��еĲ��֣�������������ȣ�����ֵ������16���Ƶ���ʽ���������޷�ֱ�����ġ�
INSERT INTO dm_dj_swry (rydm, rymc) VALUES (00005, '����'); 
LogMiner���ͳ����Ľ����������������ӣ�
insert into Object#308(col#1, col#2) values (hextoraw('c30rte567e436'), hextoraw('4a6f686e20446f65')); 

���������ֵ��Ŀ�ľ�����LogMiner�����漰���ڲ������ֵ��еĲ���ʱΪ����ʵ�ʵ����֣�������ϵͳ�ڲ���16���ơ������ֵ��ļ���һ���ı��ļ���ʹ�ð�DBMS_LOGMNR_D���������������Ҫ���������ݿ��еı��б仯��Ӱ�쵽��������ֵ�Ҳ�����仯����ʱ����Ҫ���´������ֵ��ļ�������һ��������ڷ�������һ�����ݿ��ļ���������־ʱ��Ҳ����Ҫ��������һ�鱻�������ݿ�������ֵ��ļ���
���������ֵ��ļ�֮ǰ��Ҫ����LogMiner�ļ��У�

#����Ŀ¼��
[root@racnode01 ~]# su - oracle
oracle@racnode01 ~]$ mkdir logmnr

CREATE DIRECTORY utlfile AS '/home/oracle/logmnr';
alter system set utl_file_dir='/home/oracle/logmnr' scope=spfile sid='*';
�������ݿ⣬ʹ������Ч
srvctl stop database -d racdb

#������С������־��
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
SELECT SUPPLEMENTAL_LOG_DATA_MIN FROM V$DATABASE;

####logminer�ǻ��ڻỰ�ģ����������Ự���ɼ�������ʹ��plsqldev��SQL���ڡ�
#���������ֵ��ļ�
EXECUTE dbms_logmnr_d.build(dictionary_filename => 'dictionary.ora', dictionary_location =>'/home/oracle/logmnr');

#��ӷ������ļ������Է���redo log��archive log
--onlinelog
BEGIN
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/onlinelog/group_2.261.1011625547',options=>dbms_logmnr.NEW);
END;
/

--�鿴������ļ�
SELECT * FROM v$logmnr_logs;

#��������
--��������������
begin
dbms_logmnr.start_logmnr(dictfilename=>'/home/oracle/logmnr/dictionary.ora');
end;
/


--����������
-����ʱ���
begin
  dbms_logmnr.start_logmnr(DictFileName => '/home/oracle/logmnr/dictionary.ora',
                           StartTime    => to_date('2013-6-8 00:00:00',
                                                   'YYYY-MM-DD HH24:MI:SS'),
                           EndTime      => to_date('2013-6-8 23:59:59',
                                                   'YYYY-MM-DD HH24:MI:SS '));
end;
/

-����SCN
SQL> select current_scn from v$database;

          CURRENT_SCN
---------------------
             15723709


begin
  dbms_logmnr.start_logmnr(DictFileName => '/home/oracle/logmnr/dictionary.ora',
                           StartScn=>15887121,
                           EndScn=>15887221 );
end;
/



#�鿴���
SELECT t."SEG_OWNER",t."SEG_NAME",t."SQL_REDO" FROM v$logmnr_contents t WHERE  t."SEG_OWNER"='LX' and t."SEG_NAME"='TEST02'; 

#��ɾ�����µ����ݶ�ʧ��Ҳ���Դ�redo log���һ�
SELECT t."USERNAME",t."OS_USERNAME",t."MACHINE_NAME",t."SEG_OWNER",t."SEG_NAME",t."OPERATION",t."SQL_REDO",t."SQL_UNDO" FROM v$logmnr_contents t WHERE  t."SEG_OWNER"='CZ' and t."SEG_NAME"='TEST01' and t."OPERATION"='DELETE'; 

###�鵵��־������
--����������䣬���޵�һ����¼Ϊdbms_logmnr.NEW��
select 'dbms_logmnr.add_logfile(logfilename=>'''||name||''',options=>dbms_logmnr.ADDFILE);' from 
(SELECT name FROM v$archived_log t where to_char(t."COMPLETION_TIME",'YYYY/MM/DD HH24:MI:SS') between '2019/11/22 15:00:12' and  '2019/11/22 15:08:38' and t.thread#=1 and t."STANDBY_DEST"='NO');

begin
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_35.811.1025017211',options=>dbms_logmnr.NEW);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_36.803.1025017213',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_37.802.1025017213',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_38.795.1025017285',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_39.790.1025017289',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_40.789.1025017291',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_41.785.1025017297',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_42.778.1025017391',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_43.775.1025017395',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_44.768.1025017397',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_45.765.1025017401',options=>dbms_logmnr.ADDFILE);
end;
/

begin
dbms_logmnr.start_logmnr(dictfilename=>'/home/oracle/logmnr/dictionary.ora');
end;
/

SELECT t."USERNAME",t."OS_USERNAME",t."MACHINE_NAME",t."SEG_OWNER",t."SEG_NAME",t."OPERATION",t."SQL_REDO",t."SQL_UNDO" FROM v$logmnr_contents t WHERE  t."SEG_OWNER"='CZ' and t."SEG_NAME"='TEST01' and t."OPERATION"='DELETE'; 