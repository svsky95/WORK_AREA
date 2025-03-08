--���ݿ�Ǩ�Ʋ���
1�����������û���dbaȨ�ޡ�
2�������ȵ������е����ݺ���ͳһ��ͳ����Ϣ�����������ݵ����ͳ����Ϣ��Ӧ����֤����ͬ����
3������dba_object������֤�����������������������ͬ��ʡ�dblink������vaild��invaild��������������sequence��������
4������ڼ��job����Ϊ0��crontab��Ҫ��ͣ��

--�ر�/����������
SELECT 'alter trigger ' ||t.owner||'.'||t.trigger_name||' disable;'  FROM Dba_Triggers t WHERE t.table_owner='DB_TY';

SELECT 'alter trigger ' ||t.owner||'.'||t.trigger_name||' enable;'  FROM Dba_Triggers t WHERE t.table_owner='DB_TY';

--�鿴ʧЧ�Ķ�������
SELECT * FROM dba_invalid_objects;
--ͳ�ƶ��������
SELECT t.OWNER,t.OBJECT_TYPE,count(*)  FROM dba_objects t group by t.OWNER,t.OBJECT_TYPE having t.OWNER not in (SELECT * FROM DBA_USERS_WITH_DEFPWD) order by t.OWNER ,count(*) desc; 

--��ѯ��ǰʵ��ʹ�ñ����ڴ����˱�������û�����ݵģ��������С�
   select t.owner,t.segment_name,t.segment_type,sum(t.BYTES/1024/1024) SIZE_M
  from dba_segments t
 WHERE t.segment_type in ('TABLE','TABLE PARTITION')
   and t.tablespace_name not in ('SYSAUX', 'SYSTEM','EXAMPLE')
   and t.owner not like 'NF%'
   and t.owner not in (SELECT * FROM DBA_USERS_WITH_DEFPWD)
   group by t.owner,t.segment_name,t.segment_type order by 1 ;

--���û�ͳ��������
SELECT T.OWNER, SUM(T.BYTES) / 1024 / 1024 / 1024 SUM_SIZE_G
      FROM DBA_SEGMENTS T
     WHERE T.OWNER NOT IN
           (SELECT * FROM DBA_USERS_WITH_DEFPWD)
     GROUP BY T.OWNER /*HAVING SUM(T.BYTES) / 1024 / 1024 / 1024<0.6*/
     ORDER BY 2 DESC;
     
--ָ���û��µı�ͳ��������
     SELECT t.owner, t.segment_name, t.segment_type,sum(t.BYTES) / 1024 / 1024 / 1024
       FROM dba_segments t
      WHERE t.owner = 'HX_SB'
      group by t.owner, t.segment_name,t.segment_type
      order by 4 desc ;
   
--�鿴��ռ��µ������ļ�����ռ��������
SELECT t.TABLESPACE_NAME,t.FILE_NAME,t.USER_BYTES/1024/1024/1024 SIZE_G FROM Dba_Data_Files t WHERE  t.TABLESPACE_NAME NOT IN ('sys','system','UNDOTBS1' ) ORDER BY 1 DESC  ;

SELECT t.TABLESPACE_NAME,COUNT(1) datafile_num, sum(USER_BYTES/1024/1024/1024) SIZE_G FROM Dba_Data_Files t WHERE  t.TABLESPACE_NAME NOT IN ('sys','system','UNDOTBS1' ) GROUP BY t.TABLESPACE_NAME ORDER BY 2 DESC ;


--������ռ�
select 'select dbms_metadata.get_ddl(' || '''TABLESPACE''' || ','|| '''' || a.tablespace_name || '''' ||
       ')||'';'' as sql_text from dual;'
  from DBA_TABLESPACES a
 where a.TABLESPACE_NAME not in ('SYSAUX', 'SYSTEM', 'EXAMPLE','TEMP','UNDOTBS1','USERS');

--�鿴�û��µı�ռ�
SELECT 'create tablespace '||TABLESPACE_NAME||';' FROM (SELECT distinct t.tablespace_name FROM dba_segments t WHERE t.owner ='J1_SGS');                         

SELECT 'select dbms_metadata.get_ddl(' || '''TABLESPACE''' || ',' || '''' ||
       A.TABLESPACE_NAME || '''' || ')||'';'' as sql_text from dual;'
  FROM DBA_TABLESPACES A
 WHERE A.TABLESPACE_NAME IN
       (SELECT DISTINCT T.TABLESPACE_NAME
          FROM DBA_TABLES T
         WHERE T.OWNER IN ('DZDZ',
                           'HX_DJ',
                           'HX_RD',
                           'HX_FP',
                           'HX_SB',
                           'HX_DM_QG',
                           'HX_DM_ZDY',
                           'HX_QX')
        UNION
        SELECT DISTINCT A.TABLESPACE_NAME
          FROM DBA_TAB_PARTITIONS A
         WHERE A.TABLE_OWNER IN ('DZDZ',
                                 'HX_DJ',
                                 'HX_RD',
                                 'HX_FP',
                                 'HX_SB',
                                 'HX_DM_QG',
                                 'HX_DM_ZDY',
                                 'HX_QX')
        UNION
        SELECT DISTINCT B.TABLESPACE_NAME
          FROM DBA_TAB_SUBPARTITIONS B
         WHERE B.TABLE_OWNER IN ('DZDZ',
                                 'HX_DJ',
                                 'HX_RD',
                                 'HX_FP',
                                 'HX_SB',
                                 'HX_DM_QG',
                                 'HX_DM_ZDY',
                                 'HX_QX')
        UNION
        SELECT DISTINCT T.TABLESPACE_NAME
          FROM DBA_INDEXES T
         WHERE T.OWNER IN ('DZDZ',
                           'HX_DJ',
                           'HX_RD',
                           'HX_FP',
                           'HX_SB',
                           'HX_DM_QG',
                           'HX_DM_ZDY',
                           'HX_QX'));
       
--��Ŀ�������OMF�󣬾Ͳ��ù���ԭ��ı�ռ��������ļ��Ĵ��·���ˡ�                    
SELECT 'create tablespace '||t.TABLESPACE_NAME||';' FROM dba_tablespaces t WHERE t.TABLESPACE_NAME not in ('SYSTEM','SYSAUX','UNDOTBS1','TEMP','USERS','UNDOTBS2');                         

--���� --����ȡ��ռ�����excel�Ա�
select * from DBA_TABLESPACES a
 where a.TABLESPACE_NAME not in ('SYSAUX', 'SYSTEM', 'EXAMPLE','TEMP','UNDOTBS1','USERS') order by a.TABLESPACE_NAME;


--�����û�
SELECT 'create user ' || t.username || ' identified by values ''' ||
       b.password || ''' default tablespace ' || t.default_tablespace ||
       ' quota unlimited on ' || t.default_tablespace || ';'
  FROM dba_users t, sys.user$ b
 WHERE t.username = b.name
   and t.username not in (SELECT * FROM DBA_USERS_WITH_DEFPWD)
/*   and t.account_status = 'OPEN'*/
 order by t.default_tablespace;
 
  SELECT 'create user  '||t.username||' identified by '||t.username ||';' FROM dba_users t WHERE t.username  in ( SELECT distinct t.owner FROM dba_segments t
 minus
  SELECT distinct t.owner FROM dba_segments@db94_bigdata t);
  
 
--��ռ�Ȩ��������
-Ϊ�˷�ֹ�û��µ�dblink������Ȩ�޵����⣬���´���ʧ�ܣ���������DBA��ɫ��֮���ڸ���Դ�����revoke�ĵ�����
-grant dba
SELECT 'grant dba to '||t.username||';' FROM dba_users t WHERE t.username not in (SELECT * FROM DBA_USERS_WITH_DEFPWD) and t.username not in ('SYS','SYSTEM','SYSMAN');
-revoke dba
SELECT 'revoke dba from '||t.username||';' FROM dba_users t WHERE t.username not in (SELECT * FROM DBA_USERS_WITH_DEFPWD) and t.username not in ('SYS','SYSTEM','SYSMAN');

--����
 select count(*)  FROM dba_users t, sys.user$ b
 WHERE t.username = b.name
   and t.default_tablespace not in ('SYSAUX', 'SYSTEM', 'EXAMPLE')
   and t.account_status = 'OPEN'
 order by t.default_tablespace;
 
 
--�û���ɫ

select 'select dbms_metadata.get_granted_ddl(' || '''ROLE_GRANT''' || ','|| '''' || a.username || '''' ||
       ')||'';'' as sql_text from dual;'
  from dba_users a where a.username  in (SELECT grantee from dba_role_privs t where t.GRANTEE not in ('SYSTEM','SYS'));

                       
--�û�ϵͳȨ��

select 'select dbms_metadata.get_granted_ddl(' || '''SYSTEM_GRANT''' || ',' || '''' ||
       a.username || '''' || ')||'';'' as sql_text from dual;'
  from dba_users a
 where a.username in (SELECT grantee from dba_sys_privs)
   and a.username not in ('SYS', 'SYSTEM', 'SYSMAN');




--��Ҫ�Ƚ�����ܸ������Ȩ�ޣ��������ʾ�����ڡ�   
--�û�����

select 'select dbms_metadata.get_granted_ddl(' || '''OBJECT_GRANT''' || ',' || '''' ||
       a.username || '''' || ')||'';'' as sql_text from dual;'
  from dba_users a
 where a.username in (SELECT grantee from dba_sys_privs)
   and a.username not in ('SYS', 'SYSTEM', 'SYSMAN');

   
--������

select 'select dbms_metadata.get_ddl(' || '''TABLE''' || ',' || '''' ||
       a.table_name || '''' || ',' || '''' || a.owner || '''' ||
       ')||'';'' as sql_text from dual;'
  from dba_tables a
 where (a.TABLESPACE_NAME not in
       ('SYSAUX', 'SYSTEM', 'EXAMPLE', 'TMP', 'UNDOTBS1') or
       a.TABLESPACE_NAME is null)
   and a.OWNER = 'SJYY' and a.table_name='SALES';


--����������ȫ�ֺͱ��أ�
select 'select dbms_metadata.get_ddl(' || '''INDEX''' || ',' || '''' ||
       a.index_name || '''' || ',' || '''' || a.owner || '''' ||
       ')||'';'' as sql_text from dual;'
  from dba_indexes a, dba_tables b
 where a.table_name = b.TABLE_NAME
   and (b.TABLESPACE_NAME not in
       ('SYSAUX', 'SYSTEM', 'EXAMPLE', 'TMP', 'UNDOTBS1') or
       a.TABLESPACE_NAME is null)
   and a.OWNER = 'SJYY';
   
SELECT DISTINCT sy.TABLE_OWNER,sy.TABLE_NAME,sy.INDEX_NAME,dbms_lob.substr(dbms_metadata.get_ddl('INDEX', sy.INDEX_NAME,sy.INDEX_OWNER),4000) as sqlstr FROM dba_IND_COLUMNS SY
 WHERE SY.TABLE_OWNER = 'DZDZ'
   AND SY.TABLE_NAME IN ('DZDZ_FPXX_ZZSFP');
   
   
--�����ռ�ͳ����Ϣ
 select case b.PARTITIONED
          when 'YES' then
           'execute dbms_stats.gather_table_stats(ownname =>''' || a.owner ||
           ''',tabname =>''' || a.table_name || ''',partname =>''' ||
           partition_name ||
           ''',granularity=>''PARTITION'',estimate_percent =>10,degree =>8,cascade=>true);'
          when 'NO' then
           'execute dbms_stats.gather_table_stats(ownname =>''' || a.owner ||
           ''',tabname =>''' || a.table_name ||
           ''',estimate_percent =>10,degree=>8,cascade =>true);'
        end as stats_sql
   from dba_tab_statistics a, dba_tables b
  where a.owner = b.owner
    and a.table_name = b.table_name
    and a.OWNER='HX_SB'
  order by a.owner, a.table_name, a.partition_name;
  
--��ȡͬ���
select 'select dbms_metadata.get_ddl(' || '''SYNONYM''' || ',' || '''' ||
       a.TABLE_NAME || '''' || ',' || '''' || a.owner || '''' ||
       ')||'';'' as sql_text from dual;'
  from dba_synonyms a
 where a.owner not in
       ('SYS', 'SYSTEM', 'SYSMAN') 
   and a.OWNER = 'SJYY';
   
   select 'CREATE OR REPLACE SYNONYM '||a.owner||'.'||a.synonym_name||' for '||a.table_owner||'.'||a.table_name||';'
  from dba_synonyms a
 where a.owner not in
       ('SYS', 'SYSTEM', 'SYSMAN') 
   and a.OWNER = 'NF_NFZC';        
   
--�����漰��SJYY�û��Ĵ洢���̣�������Ҫ������SJYY�û��£�����ͬ��ʵ��漰�ı�

--�鿴ͬ���
SELECT * FROM dba_synonyms t WHERE t.owner='SJYY';

--ͳ���û�����ռ�����
SELECT t.owner, t.tablespace_name, sum(t.BYTES) / 1024 / 1024 / 1024
  FROM dba_segments t
 WHERE t.owner in (SELECT distinct t.TABLE_OWNER
                     FROM dba_synonyms t
                    WHERE t.owner = 'SJYY')
 group by t.owner, t.tablespace_name
 order by 1;
 
--�鿴��
SELECT * FROM dba_tables t WHERE t.OWNER in (SELECT distinct t.TABLE_OWNER FROM dba_synonyms t WHERE t.owner='SJYY');

--�����ű�
expdp cz/cz directory=dpump_dir  DUMPFILE=HX_NF%u.dmp logfile=HX_NF.log SCHEMAS=HX_QX,NF_FDM,HX_DM_ZDY,HX_FP,HX_DM_QG,HX_SB,HX_CS_QG,HX_CS_ZDY INCLUDE=INDEX parallel=8; 

--����ű�
impdp lx/lx directory=dpump_dir  DUMPFILE=HX_NF%u.dmp logfile=HX_NF.log SCHEMAS=HX_QX,NF_FDM,HX_DM_ZDY,HX_FP,HX_DM_QG,HX_SB,HX_CS_QG,HX_CS_ZDY parallel=8 table_exists_action=replace; 


--ͳ��ʧЧ����
SELECT * FROM dba_invalid_objects;

--���±���ʧЧ����
/home/oracle/app/oracle/product/11.2.0/dbhome_1/rdbms/admin
@utlrp.sql