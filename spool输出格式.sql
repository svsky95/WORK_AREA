--spool输出格式
--现在sqlplus 上执行
set pagesize 50000
set linesize 32767
set long 999999999
col SQL_TEXT for a150
---再执行以下的输出
SPOOL /home/oracle/table_sql/table_dll.sql
set pagesize 50000
set linesize 32767
set long 999999999
set colsep ';'  
SET NEWPAGE NONE
SET HEADING OFF
SET SPACE 0
SET PAGESIZE 0
SET TRIMOUT ON
SET TRIMSPOOL ON
SET LINESIZE 2500
set pagesize 2000
select dbms_metadata.get_ddl('TABLE','DW_ZS_NSRNSQK','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','CONF_DEFAULT','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','SJ_DBRW','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','SJ_XXTX','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','SJ_GWWDDZ','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','A_TEST','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','DW_TJ_DJ_NSRXX','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','ZT_DS','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','DW_TJ_WS_YHBA','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','DW_FP_DK_FPKJXX','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','DW_TJ_SB_QYSDSYSBTJ','SJYY')||';' as sql_text from dual;
select dbms_metadata.get_ddl('TABLE','DW_TJ_SB_XFSSBTJ','SJYY')||';' as sql_text from dual;
SPOOL OFF
