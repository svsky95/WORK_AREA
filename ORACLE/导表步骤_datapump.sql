--data pump import��export�����﷨���ο�oracle11.2�������112ҳ
--�鿴�ͻ��˵��ַ���
�ڽ������ݵĵ��뼰����ʱ���ǳ���Ҫ�ľ��ǿͻ��˵��ַ���
--�鿴�ͻ��˵��ַ���
echo $NLS_LANG
--�����ַ���
set NLS_LANG=SIMPLIFIED CHINESE_CHINA.ZHS16GBK
export NLS_LANG="SIMPLIFIED CHINESE_CHINA.ZHS16GB";

#####�ر�/����������#####
SELECT 'alter trigger ' ||t.owner||'.'||t.trigger_name||' disable;'  FROM Dba_Triggers t WHERE t.table_owner='DB_TY';

SELECT 'alter trigger ' ||t.owner||'.'||t.trigger_name||' enable;'  FROM Dba_Triggers t WHERE t.table_owner='DB_TY';

##��������ʵ��
1����ȷ����Ҫ���������������������ֶ������ȡ�
2��������ʱ��ռ䣬��ִ��create index��ʱ�򣬻��ǻ�ռ����ʱ��ռ䣬�������ǳ����������ʱ�򣬿��ܻᵼ����ʱ��ռ䲻�㡣
3��undo ��ִ�е������ݼ�����������£�DDL��DML����漰�����񣬶����õ�undo��ռ䣬���������ora-015555�Ĵ��󣬽�����������10T������£�����undo tablespace=160G��undo_retention����ʱ��Ϊ1��Сʱ��
4�����������ĵ�������������ݺ������ֿ���������ͨ�����ķ�ʽ���Ӳ�����Ŀ��ⴴ�������������ö���Ự������֮��ԭΪ���ж�1������Ҫע����ʱ�����Ĵ�С�� 
--����Ŀ¼·��
SELECT * FROM dba_directories t WHERE t.directory_name='DUMP_DIR';--Ĭ��·��
Ҳ�������д���·��
mkdir -p /data/dump_dir
chown oracle:oinstall /data/dump_dir
CREATE DIRECTORY dump_dir AS '/data/dump_dir';
--ɾ��Ŀ¼
DROP DIRECTORY dump_dir;
--��Ŀ¼��Ȩ�޸��������û�
GRANT READ, WRITE ON DIRECTORY dump_dir TO hr; 

--�鿴datadump��ҵ
SELECT * FROM dba_datapump_jobs;
--�鿴datapump��ǰִ�еĻỰ
SELECT * FROM dba_datapump_sessions;
--�鿴�û���������ռ�
select 'select dbms_metadata.get_ddl(' || '''TABLESPACE''' || ','|| '''' || a.tablespace_name || '''' ||
       ')||'';'' as sql_text from dual;'
  from DBA_TABLESPACES a
 where a.TABLESPACE_NAME  in (
 SELECT DISTINCT t.tablespace_name FROM dba_segments t WHERE t.owner='DZDZ'
 UNION 
 SELECT DISTINCT t.tablespace_name FROM Dba_Tab_Partitions t WHERE t.table_owner='DZDZ');
 
--�����ݲ���_datapump 
expdp SCHEMAS=CZ DIRECTORY=dpump_dir LOGFILE=schemas.log DUMPFILE=expdat.dmp
impdp SCHEMAS=CZ DIRECTORY=dpump_dir LOGFILE=schemas.log DUMPFILE=expdat.dmp

��impdp������ݿ⵼��ʱ�������Ѿ����ڣ������ֵĴ���ʽ��

1)  skip�� �����Ѵ��ڵı� --Ĭ�ϲ���
2)  replace����drop��Ȼ�󴴽�������������
3)  append����ԭ�����ݵĻ�������������
4)  truncate����truncate��Ȼ���ٲ�������


--�����������ļ���С
ESTIMATE_ONLY=y

--��ʾÿһ����ִ��ʱ��
metrics=y                  

--RAC �������� ���ڵ�ĵ���/����������cluster=no
impdp www/www directory=dump_dir SCHEMAS=HX_ZS DUMPFILE=HX_ZS%u.dmp logfile=imp_HX_ZS.log cluster=no parallel=32 TABLE_EXISTS_ACTION=replace

--���������ַ�д��
nohup expdp ruanshuqin/\"RSQ@\!foresee2017\" directory=dmp DUMPFILE=HX_FP%u.dmp logfile=HX_PZ.log SCHEMAS=HX_PZ parallel=5 compression=all >HX_PZ.out 2>&1 &                             "

--��̨�������
nohup impdp cz/cz_123456 directory=dpump_dir  DUMPFILE=HX_FP%u.dmp logfile=HX_FP.log table_exists_action=replace SCHEMAS=HX_FP parallel=5 >HX_FP.out 2>&1 &
nohup ./back_level0.sh >backup_level-`date +%Y%m%d-%H%M`.out 2>&1 &

--����������
select 'select /*+parallel 8 full*/count(1) from '||t.OWNER||'.'||t.TABLE_NAME||';'from  dba_tables t WHERE t.OWNER='CZ';

expdp cz/cz directory=dpump_dir  DUMPFILE=sjyy_t%u.dmp logfile=sjyy_t.log SCHEMAS=SJYY FILESIZE=10G  EXCLUDE=INDEX,STATISTICS parallel=8;
nohup expdp cz/cz directory=dpump_dir  DUMPFILE=sjyy_t%u.dmp logfile=sjyy_t.log SCHEMAS=SJYY FILESIZE=10G  EXCLUDE=INDEX,STATISTICS parallel=8 >HX_FP.out 2>&1 &
-------------------���ı�ռ�-----------------------------
--ԭ�������������к��в�ͬ��ռ�����ݣ������ﵼ��ʱ���¶���ͳһ�ı�ռ�
--�鿴ԭ�����ݶ�Ӧ�ı�ռ估���ݴ�С
 SELECT t.owner, t.tablespace_name, sum(t.BYTES / 1024 / 1024) SIZE_M
     FROM dba_segments t
    WHERE t.segment_type in ('TABLE', 'TABLE PARTITION')
      and t.owner in ('SJYY')
      and t.segment_name not like 'BIN%'
      group by t.owner,t.tablespace_name 
      order by 3 desc;
--���������ű� ----������� &1   --ѹ������������̫��ᵼ��д���ļ�ʧ��
SELECT 'nohup expdp ruanshuqin/\"RSQ@\!foresee2017\" directory=DMP DUMPFILE=' ||
       TT.OWNER || '%u.dmp logfile=' || TT.OWNER || '.log' || ' SCHEMAS=' ||
       TT.OWNER || ' parallel=2 compression=all >' || TT.OWNER ||
       '.out 2>&1 & '
  FROM (SELECT T.OWNER, SUM(T.BYTES) / 1024 / 1024 / 1024
          FROM DBA_SEGMENTS T
         WHERE T.TABLESPACE_NAME NOT IN ('SYSTEM', 'SYSAUX')
           AND T.OWNER NOT IN ('SYS', 'HX_SB')
           AND T.OWNER LIKE 'HX%'
         GROUP BY T.OWNER
         ORDER BY 2 DESC) TT;
--��������ű� ----������� &1         
SELECT 'nohup impdp cz/\"cz\" directory=dpump_dir DUMPFILE=' || TT.OWNER ||
         '%u.dmp logfile=imp_' || TT.OWNER || '.log' || ' SCHEMAS=' ||
         TT.OWNER || ' parallel=2 table_exists_action=replace > imp_' ||
         TT.OWNER || '.out 2>&1 & '
    FROM (SELECT T.OWNER, SUM(T.BYTES) / 1024 / 1024 / 1024
            FROM DBA_SEGMENTS T
           WHERE T.TABLESPACE_NAME NOT IN ('SYSTEM', 'SYSAUX')
             AND T.OWNER NOT IN ('SYS', 'HX_SB')
             AND T.OWNER LIKE 'HX%'
           GROUP BY T.OWNER
           ORDER BY 2 DESC) TT;

--db_link��������ű� --������� &1
SELECT 'nohup impdp cz/cz directory=dpump_dir  logfile=' || TT.OWNER ||
       '.log' || ' SCHEMAS=' || TT.OWNER ||
       ' network_link=SJYY_12_94 table_exists_action=replace >' || TT.OWNER ||
       '.out 2>&1 & '
  FROM (SELECT T.OWNER, SUM(T.BYTES) / 1024 / 1024 / 1024
          FROM DBA_SEGMENTS T
         WHERE T.TABLESPACE_NAME NOT IN ('SYSTEM', 'SYSAUX')
           AND T.OWNER NOT IN ('SYS', 'HX_SB')
           AND T.OWNER LIKE 'HX%'
         GROUP BY T.OWNER
         ORDER BY 2 DESC) TT;
      
impdp lx/lx directory=dpump_dir  DUMPFILE=sjyy_t%u.dmp logfile=sjyy_t_imp.log remap_TABLESPACE=USERS:SJYY_TS,TS_DAT_QYSDS:SJYY_TS,TS_NFZC_DAT:SJYY_TS parallel=8 table_exists_action=replace; 

-----------------------����schema����ռ�---------------------
impdp lx/lx directory=dpump_dir  DUMPFILE=NF_YHS_t%u.dmp logfile=NF_YHS_t_imp.log remap_schema=NF_YHS:CZ remap_tablespace=USERS:TS_NFZC_DAT parallel=8 table_exists_action=replace; 


-----------------------�ӵ�����dump�ļ���ֻ����ָ���ı�-------
impdp lx/lx directory=dpump_dir  DUMPFILE=NF_YHS_t%u.dmp logfile=NF_YHS_t_imp.log remap_schema=NF_YHS:CZ remap_tablespace=USERS:TS_NFZC_DAT tables=NF_YHS.DJ_NSRXX_KZ  table_exists_action=replace; 

----------------------������--------------------------------
expdp lx/lx directory=dpump_dir  DUMPFILE=SJYY_DW_TJ_SB_NSRSBQK%u.dmp logfile=SJYY_DW_TJ_SB_NSRSBQK.log TABLES=SJYY.DW_TJ_SB_NSRSBQK,sjyy.DM_GY_SWJG EXCLUDE=INDEX,STATISTICS,OBJECT_GRANT; 
impdp cz/cz directory=DMPDIR  DUMPFILE=dw_tj_yh_zzszczx.dmp logfile=dw_tj_yh_zzszczx.log tables=sjyy.dw_tj_yh_zzszczx table_exists_action=replace; 

-----------------------db_linkֱ�ӹ���------------------------
impdp lx/lx directory=dpump_dir  logfile=NF_YHS_t_imp1.log SCHEMAS=NF_YHS remap_schema=NF_YHS:CZ remap_tablespace=USERS:TS_NFZC_DAT network_link=sjyy_12_94 job_name=Cases_Export table_exists_action=replace EXCLUDE=INDEX,STATISTICS,FLASHBACK_SCN=928672344; 

-----------------------�������洢���̵���--------------------
nohup impdp cz/\"cz\" directory=dpump_dir DUMPFILE=NF_YHS%u.dmp logfile=NF_YHS.log SCHEMAS=NF_YHS INCLUDE=FUNCTION,PROCEDURE parallel=5 > imp_YHS_pro.out 2>&1 &                  "

-----------------------SYS�û�ֱ�ӵ���-------------------
impdp \" / as sysdba \" directory=dpump_dir DUMPFILE=NF_YHS%u.dmp logfile=NF_YHS.log SCHEMAS=NF_YHS INCLUDE=FUNCTION,PROCEDURE parallel=5 > imp_YHS_pro.out 2>&1 &                     "
--�����ű�
SELECT 'impdp cz/cz directory=dpump_dir LOGFILE='||aa.OWNER||'.log SCHEMAS='||aa.OWNER||' network_link=BIGDATA_NFZCDB94 table_exists_action=skip;'FROM  
      (SELECT T.OWNER, SUM(T.BYTES) / 1024 / 1024 / 1024 SUM_SIZE_G
      FROM DBA_SEGMENTS T
     WHERE T.OWNER NOT IN
           ('SCOTT', 'ORDSYS', 'OUTLN', 'DBSNMP', 'OE', 'SYS','MDSYS','CZ','SH','LX','SYSMAN','SYSTEM','PM','XDB','OLAPSYS','WMSYS','CTXSYS','EXFSYS','TEST')
     GROUP BY T.OWNER HAVING SUM(T.BYTES) / 1024 / 1024 / 1024<0.6
     ORDER BY 2 DESC) aa ;
     
-----------------------���������-----------------------------
impdp lx/lx directory=dpump_dir  logfile=dfds.log  tables=HX_SB.SB_SBB:P_1610198 remap_schema=HX_SB:CZ remap_tablespace=TS_HX_SB_DATA:SJYY_TS network_link=sjyy_12_94 job_name=Cases_Export table_exists_action=append EXCLUDE=INDEX,STATISTICS; 

-----------------------ѹ������-------------------------------
nohup expdp cz/cz directory=DPUMP_DIR  DUMPFILE=SJYY0920%u.dmp logfile=SJYY0920.log SCHEMAS=SJYY parallel=10 compression=all >SJYY.out 2>&1 &

-----------------------��ṹ����-----------------------------
 SELECT 'nohup expdp ruanshuqin/\"RSQ@\!foresee2017\" directory=DMP DUMPFILE=' ||
       TT.OWNER || '_META.dmp logfile=' || TT.OWNER || '_META.log' || ' SCHEMAS=' ||
       TT.OWNER || ' content=metadata_only >' || TT.OWNER ||
       '.out 2>&1 & '
  FROM (SELECT T.OWNER, SUM(T.BYTES) / 1024 / 1024 / 1024
          FROM DBA_SEGMENTS T
         WHERE T.TABLESPACE_NAME NOT IN ('SYSTEM', 'SYSAUX')
           AND T.OWNER NOT IN ('SYS')
           AND T.OWNER LIKE 'HX%'
         GROUP BY T.OWNER
         ORDER BY 2 DESC) TT;
-----------------------�����ļ�д��---------------------------
--ȡ����
--�û�ѡȡ
 SELECT wm_concat(t.username) FROM dba_users t WHERE t.username like 'DB%';
--�����û�
SELECT wm_concat(''''||t.TABLE_NAME||'''') FROM dba_tables t WHERE t.TABLE_NAME like 'DW%';
--���û�
SELECT wm_concat(''''||t.OWNER||'.'||t.TABLE_NAME||'''') FROM dba_tables t WHERE t.TABLE_NAME like 'DW%';
--ȡ��Ĵ�С
SELECT wm_concat(t.segment_name) FROM dba_segments t WHERE t.owner='SJYY' and t.BYTES/1024/1024/1024 >1  ;
--MYSQL
--ƴ���ַ���
select concat('create view yhs_mdm_db.',TBL_NAME,' as ',view_original_text,';') from  TBLS where TBL_TYPE like '%VIEW%' and DB_ID=1881
select  GROUP_CONCAT(concat(t.SRC_SCHEMA,'.',t.SRC_TAB_NAME)) from  IMP_SQOOP_HIVE_CONF_DEF t where bat_no in (
'100020433',
'100019004'��

expdp sjyy/SJYY@nfzcdb parfile=QX.par
--QX.par 
dumpfile=sjyy%u.dmp
Schemas=SJYY
DIRECTORY=DPUMP_DIR
logfile=sjyy.log
parallel=10
compression=all
--exclude=TABLE:"IN(select table_name from dba_tables where owner='HX_SB' AND NUM_ROWS<5000000)"
exclude=TABLE:"IN('DW_TJ_SB_NSRSBQK','DW_ZS_NSRNSQK_SY','DW_TJ_SB_ZZS_XGM','DW_TJ_SB_ZZS_YBNSR','DW_ZS_NSRNSQK','DW_TJ_SB_HYSFL','DW_ZS_CLGZS','DW_TJ_WS_SWWS
','DW_TJ_FP_YJJCYQK','DW_TJ_SB_ZZS_XGM_002','DW_TJ_SB_DQYSBTJ','DW_TJ_YH_ZZSZCZX','DW_TJ_RD_NSRSFZRDQK','ZS_NSRNSQK','DW_TJ_RD_GSSFZRDXX','DW_TJ_SB_SDS_JMCZ_
YJD','DW_TJ_SB_ZZSYSBTJ','DW_FP_DK_ZZSFP_HLMX_BAK','DW_FP_DK_ZZSFP_HLMX','DW_FP_DK_FPKJXX','DW_SB_SDS_JMCZ_YJD_JMSDSEMXB','TJ_SB_NSRSBQK','TJ_RD_NSRSFZRDQK',
'DW_TJ_FP_DK','TJ_NSRSSGXQK','DW_TJ_DJ_NSRXX','DW_TJ_FP_LY')"
--
TABLES=HX_DJ.DJ_BMDGL,HX_DJ.DJ_DJZTGXDZB,HX_DJ.DJ_JZYGCXMQKDJXXB,HX_DJ.DJ_JZYXMDJ_ZFBGCXMXX,HX_DJ.DJ_NSRXX_KZ,HX_DJ.DJ_SYGLXMDJ_TDXX,HX_DJ.DJ_SZYSSYDJB,DZDZ.DZDZ_FPXX_JSFP,HX_SB.SB_DKDJ_FB_SKMXBG

exclude ������
include ����
--ִ�й���������
sqlfile=imp_sql.txt
--Ԫ���ݹ���
Ԫ���ݽ�������EXCLUDE��INCLUDE������ע�⣺���������⡣
EXCLUDE<������>���ӣ�
content=metadata_only
expdp FULL=YES DUMPFILE=expfull.dmp EXCLUDE=SCHEMA:"='HR'"
> expdp hr DIRECTORY=dpump_dir1 DUMPFILE=hr_exclude.dmp EXCLUDE=VIEW,METADATA,
PACKAGE, FUNCTION,INDEX,STATISTICS 
--������LOG��ͷ�ı�
exclude=table:"like 'LOG%'"

INCLUDE<������>���ӣ�
SCHEMAS=HR
DUMPFILE=expinclude.dmp
DIRECTORY=dpumexpincludep_dir1
LOGFILE=.log
INCLUDE=TABLE:"IN ('EMPLOYEES', 'DEPARTMENTS')"
INCLUDE=PROCEDURE
INCLUDE=INDEX:"LIKE 'EMP%'"
INCLUDE=db_link



--������ɺ������Ա�������
--����ͳ�Ʊ��������
 SELECT 'select /*+parallel 10*/ ''' ||t.OWNER||'.'|| t.TABLE_NAME || ''',count(1) from ' ||
       t.OWNER || '.' || t.TABLE_NAME || ' union all'
  FROM dba_tables t
 WHERE t.OWNER = 'HX_PZ'
 order by t.TABLE_NAME;

--�鿴����Ľ���
select * from dba_datapump_jobs; 
SELECT * FROM DBA_DATAPUMP_SESSIONS;

--�����ε���
SELECT distinct b.TABLE_NAME, nvl(t.BYTES / 1024 / 1024, 0)
  FROM dba_segments t, dba_tables b
 where t.segment_name(+) = b.TABLE_NAME
   and b.OWNER = 'HX_SB' and t.BYTES / 1024 / 1024 >5000
 order by 2 desc;



--�����ű�
vi exp_par.sh
#!/bin/bash
nohup expdp cz/cz_123456 parfile=QX.par &

vi QX.par
dumpfile=RZ_DZFP_FPDKL_MX%u.dmp
#Schemas=skskj01
DIRECTORY=DPUMP_DIR
logfile=exp_RZ_DZFP_FPDKL_MX.log
#parallel=2
#compression=all
TABLES=htjs.RZ_DZFP_FPDKL_MX

--����ű�
vi imp_par.sh
nohup impdp cz/CZ_1QAZ parfile=QX.par &

vi QX.par
dumpfile=RZ_DZFP_FPDKL_MX%u.dmp
#remap_schema=skskj01:skskj
DIRECTORY=DPUMP_DIR
logfile=imp_RZ_DZFP_FPDKL_MX.log
table_exists_action=replace
#schemas=JSFP
#parallel=10
~
--query ʹ��
export ORACLE_SID=XXXXX
expdp \'sys/********* as sysdba\' directory=sfdir dumpfile=test.dmp logfile=test.log tables=scott.test1,scott.test2 query=scott.test1:\"where UA_SERIAL_ID in \'96\',\'26\'\",scott.test2:\"where FILESIZE=273899\"                         
--------------------- 
expdp cz/cz_123456 directory=DUMP_DIR  DUMPFILE=dzdz_fpxx_dzfp%u.dmp logfile=dzdz_fpxx_dzfp.log TABLES=dzdz.dzdz_fpxx_dzfp QUERY=dzdz.dzdz_fpxx_dzfp:\"where TSLSH=\'16100000003201601086470\'\" EXCLUDE=INDEX,STATISTICS; 

--exp.par
QUERY=employees:"WHERE department_id > 10 AND salary > 10000"
QUERY='sales:"WHERE EXISTS (SELECT cust_id FROM customers c WHERE cust_credit_limit > 10000 AND cust_id = c.cust_id)"'

--SAMPLE ��������
SAMPLE=[[schema_name.]table_name:]sample_percent
SAMPLE="HR"."EMPLOYEES":50
expdp hr DIRECTORY=dpump_dir1 DUMPFILE=sample.dmp SAMPLE=70