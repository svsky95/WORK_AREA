##sql_profile说明：
--查询sql_profile 
select * from dba_sql_profiles  s where s.name='SYS_SQLPROF_015667ca8e5a0000';

--删除sql_profile
exec dbms_sqltune.drop_sql_profile('SYS_SQLPROF_015667ca8e5a0000');

--制作sql_profile
declare
  my_task_name VARCHAR2(30);
  my_sqltext CLOB;
  begin
     my_sqltext := 'select /*+ no_index(test test_idx) */ * from test where n=1';
     my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK(
     sql_text => my_sqltext,
     user_name => 'SCOTT',
     scope => 'COMPREHENSIVE',
     time_limit => 60,
     task_name => 'my_sql_tuning_task_2',
     description => 'Task to tune a query on a specified table');
end;
/

begin
DBMS_SQLTUNE.EXECUTE_TUNING_TASK( task_name => 'my_sql_tuning_task_2');
end;
/

--查看sql_profile的执行计划
set long 10000
set longchunksize 1000
set linesize 100
set heading off
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('my_sql_tuning_task_2') from DUAL;
set heading on