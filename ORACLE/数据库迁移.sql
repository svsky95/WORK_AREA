--数据库迁移步骤
1、授予所有用户的dba权限。
2、可以先导入所有的数据后，再统一跑统计信息，这样当数据倒完后，统计信息和应用验证可以同步。
3、借助dba_object，来验证表的数据量、索引的数量、同义词、dblink数量，vaild和invaild数量，触发器、sequence的数量。
4、割接期间的job设置为0及crontab都要暂停。

--关闭/开启触发器
SELECT 'alter trigger ' ||t.owner||'.'||t.trigger_name||' disable;'  FROM Dba_Triggers t WHERE t.table_owner='DB_TY';

SELECT 'alter trigger ' ||t.owner||'.'||t.trigger_name||' enable;'  FROM Dba_Triggers t WHERE t.table_owner='DB_TY';

--查看失效的对象数量
SELECT * FROM dba_invalid_objects;
--统计对象的数量
SELECT t.OWNER,t.OBJECT_TYPE,count(*)  FROM dba_objects t group by t.OWNER,t.OBJECT_TYPE having t.OWNER not in (SELECT * FROM DBA_USERS_WITH_DEFPWD) order by t.OWNER ,count(*) desc; 

--查询当前实际使用表，对于创建了表但是其中没有数据的，不在其中。
   select t.owner,t.segment_name,t.segment_type,sum(t.BYTES/1024/1024) SIZE_M
  from dba_segments t
 WHERE t.segment_type in ('TABLE','TABLE PARTITION')
   and t.tablespace_name not in ('SYSAUX', 'SYSTEM','EXAMPLE')
   and t.owner not like 'NF%'
   and t.owner not in (SELECT * FROM DBA_USERS_WITH_DEFPWD)
   group by t.owner,t.segment_name,t.segment_type order by 1 ;

--按用户统计数据量
SELECT T.OWNER, SUM(T.BYTES) / 1024 / 1024 / 1024 SUM_SIZE_G
      FROM DBA_SEGMENTS T
     WHERE T.OWNER NOT IN
           (SELECT * FROM DBA_USERS_WITH_DEFPWD)
     GROUP BY T.OWNER /*HAVING SUM(T.BYTES) / 1024 / 1024 / 1024<0.6*/
     ORDER BY 2 DESC;
     
--指定用户下的表统计数据量
     SELECT t.owner, t.segment_name, t.segment_type,sum(t.BYTES) / 1024 / 1024 / 1024
       FROM dba_segments t
      WHERE t.owner = 'HX_SB'
      group by t.owner, t.segment_name,t.segment_type
      order by 4 desc ;
   
--查看表空间下的数据文件及表空间的数据量
SELECT t.TABLESPACE_NAME,t.FILE_NAME,t.USER_BYTES/1024/1024/1024 SIZE_G FROM Dba_Data_Files t WHERE  t.TABLESPACE_NAME NOT IN ('sys','system','UNDOTBS1' ) ORDER BY 1 DESC  ;

SELECT t.TABLESPACE_NAME,COUNT(1) datafile_num, sum(USER_BYTES/1024/1024/1024) SIZE_G FROM Dba_Data_Files t WHERE  t.TABLESPACE_NAME NOT IN ('sys','system','UNDOTBS1' ) GROUP BY t.TABLESPACE_NAME ORDER BY 2 DESC ;


--创建表空间
select 'select dbms_metadata.get_ddl(' || '''TABLESPACE''' || ','|| '''' || a.tablespace_name || '''' ||
       ')||'';'' as sql_text from dual;'
  from DBA_TABLESPACES a
 where a.TABLESPACE_NAME not in ('SYSAUX', 'SYSTEM', 'EXAMPLE','TEMP','UNDOTBS1','USERS');

--查看用户下的表空间
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
       
--在目标库启用OMF后，就不用关心原库的表空间中数据文件的存放路径了。                    
SELECT 'create tablespace '||t.TABLESPACE_NAME||';' FROM dba_tablespaces t WHERE t.TABLESPACE_NAME not in ('SYSTEM','SYSAUX','UNDOTBS1','TEMP','USERS','UNDOTBS2');                         

--稽核 --可以取表空间名到excel对比
select * from DBA_TABLESPACES a
 where a.TABLESPACE_NAME not in ('SYSAUX', 'SYSTEM', 'EXAMPLE','TEMP','UNDOTBS1','USERS') order by a.TABLESPACE_NAME;


--创建用户
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
  
 
--表空间权限无限制
-为了防止用户下的dblink等由于权限的问题，导致创建失败，建议授予DBA角色，之后，在根据源库进行revoke的调整。
-grant dba
SELECT 'grant dba to '||t.username||';' FROM dba_users t WHERE t.username not in (SELECT * FROM DBA_USERS_WITH_DEFPWD) and t.username not in ('SYS','SYSTEM','SYSMAN');
-revoke dba
SELECT 'revoke dba from '||t.username||';' FROM dba_users t WHERE t.username not in (SELECT * FROM DBA_USERS_WITH_DEFPWD) and t.username not in ('SYS','SYSTEM','SYSMAN');

--稽核
 select count(*)  FROM dba_users t, sys.user$ b
 WHERE t.username = b.name
   and t.default_tablespace not in ('SYSAUX', 'SYSTEM', 'EXAMPLE')
   and t.account_status = 'OPEN'
 order by t.default_tablespace;
 
 
--用户角色

select 'select dbms_metadata.get_granted_ddl(' || '''ROLE_GRANT''' || ','|| '''' || a.username || '''' ||
       ')||'';'' as sql_text from dual;'
  from dba_users a where a.username  in (SELECT grantee from dba_role_privs t where t.GRANTEE not in ('SYSTEM','SYS'));

                       
--用户系统权限

select 'select dbms_metadata.get_granted_ddl(' || '''SYSTEM_GRANT''' || ',' || '''' ||
       a.username || '''' || ')||'';'' as sql_text from dual;'
  from dba_users a
 where a.username in (SELECT grantee from dba_sys_privs)
   and a.username not in ('SYS', 'SYSTEM', 'SYSMAN');




--需要先建表才能赋予对象权限，否则会提示表不存在。   
--用户对象

select 'select dbms_metadata.get_granted_ddl(' || '''OBJECT_GRANT''' || ',' || '''' ||
       a.username || '''' || ')||'';'' as sql_text from dual;'
  from dba_users a
 where a.username in (SELECT grantee from dba_sys_privs)
   and a.username not in ('SYS', 'SYSTEM', 'SYSMAN');

   
--创建表

select 'select dbms_metadata.get_ddl(' || '''TABLE''' || ',' || '''' ||
       a.table_name || '''' || ',' || '''' || a.owner || '''' ||
       ')||'';'' as sql_text from dual;'
  from dba_tables a
 where (a.TABLESPACE_NAME not in
       ('SYSAUX', 'SYSTEM', 'EXAMPLE', 'TMP', 'UNDOTBS1') or
       a.TABLESPACE_NAME is null)
   and a.OWNER = 'SJYY' and a.table_name='SALES';


--创建索引（全局和本地）
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
   
   
--批量收集统计信息
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
  
--获取同义词
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
   
--由于涉及到SJYY用户的存储过程，所以需要导出给SJYY用户下，建立同义词的涉及的表。

--查看同义词
SELECT * FROM dba_synonyms t WHERE t.owner='SJYY';

--统计用户及表空间数据
SELECT t.owner, t.tablespace_name, sum(t.BYTES) / 1024 / 1024 / 1024
  FROM dba_segments t
 WHERE t.owner in (SELECT distinct t.TABLE_OWNER
                     FROM dba_synonyms t
                    WHERE t.owner = 'SJYY')
 group by t.owner, t.tablespace_name
 order by 1;
 
--查看表
SELECT * FROM dba_tables t WHERE t.OWNER in (SELECT distinct t.TABLE_OWNER FROM dba_synonyms t WHERE t.owner='SJYY');

--导出脚本
expdp cz/cz directory=dpump_dir  DUMPFILE=HX_NF%u.dmp logfile=HX_NF.log SCHEMAS=HX_QX,NF_FDM,HX_DM_ZDY,HX_FP,HX_DM_QG,HX_SB,HX_CS_QG,HX_CS_ZDY INCLUDE=INDEX parallel=8; 

--导入脚本
impdp lx/lx directory=dpump_dir  DUMPFILE=HX_NF%u.dmp logfile=HX_NF.log SCHEMAS=HX_QX,NF_FDM,HX_DM_ZDY,HX_FP,HX_DM_QG,HX_SB,HX_CS_QG,HX_CS_ZDY parallel=8 table_exists_action=replace; 


--统计失效对象
SELECT * FROM dba_invalid_objects;

--重新编译失效对象
/home/oracle/app/oracle/product/11.2.0/dbhome_1/rdbms/admin
@utlrp.sql