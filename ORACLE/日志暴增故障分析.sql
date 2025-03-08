--��־�������Ϸ���
�ű����£�
--1��redo����������Ȼ�����ڴ�������"��ı�"����awr��ͼ���ҳ�"��ı�"����segments��
select * from (
SELECT to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI') snap_time,
       dhsso.object_name,
       SUM(db_block_changes_delta)
  FROM dba_hist_seg_stat     dhss,
       dba_hist_seg_stat_obj dhsso,
       dba_hist_snapshot     dhs
 WHERE dhs.snap_id = dhss. snap_id
   AND dhs.instance_number = dhss. instance_number
   AND dhss.obj# = dhsso. obj#
   AND dhss.dataobj# = dhsso.dataobj#
   AND begin_interval_time> sysdate - 60/1440      --����һ��֮�ڣ�  sysdate -10  ����10��֮��            
 GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'),
          dhsso.object_name
 order by 3 desc)
 where rownum<=5;

--------------------------------------------------------------------------------------------

--2����awr��ͼ���ҳ�����1������ǰ�Ķ����漰����SQL��
SELECT to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'),
       dbms_lob.substr(sql_text, 4000, 1),
       dhss.instance_number,
       dhss.sql_id,
       executions_delta,
       rows_processed_delta
  FROM dba_hist_sqlstat dhss, dba_hist_snapshot dhs, dba_hist_sqltext dhst
 WHERE UPPER(dhst.sql_text) LIKE '%����д��������д%'
   AND dhss.snap_id = dhs.snap_id
   AND dhss.instance_Number = dhs.instance_number
   AND dhss.sql_id = dhst.sql_id;

--------------------------------------------------------------------------------------------

--3����ASH�����ͼ���ҳ�ִ����ЩSQL��session��module��machine��
select * from dba_hist_active_sess_history WHERE sql_id = '';
select * from v$active_session_history where sql_Id = '';

--------------------------------------------------------------------------------------------

--4. dba_source �����Ƿ��д洢���̰������SQL

--���²�������������redo,�����������ķ����������ǡ�
drop table   test_redo  purge;
create table test_redo as select * from dba_objects;
insert into  test_redo select * from test_redo;
insert into  test_redo select * from test_redo;
insert into  test_redo select * from test_redo;
insert into  test_redo select * from test_redo;
insert into  test_redo select * from test_redo;
exec dbms_workload_repository.create_snapshot();

--------------------------------------------------------------------------------------------

�������
--ִ���˴��������test_redo���INSERT���������ǿ�ʼ�����·������и��٣����ܷ��ָ��µ������ű�����Щ��䡣
select * from (
SELECT to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI') snap_time,dhsso.object_name,SUM(db_block_changes_delta)
  FROM dba_hist_seg_stat dhss,dba_hist_seg_stat_obj dhsso,dba_hist_snapshot  dhs
 WHERE dhs.snap_id = dhss. snap_id
   AND dhs.instance_number = dhss. instance_number AND dhss.obj# = dhsso. obj# AND dhss.dataobj# = dhsso.dataobj#
   AND begin_interval_time> sysdate - 60/1440
 GROUP BY to_char(begin_interval_time, 'YYYY_MM_DD HH24:MI'), dhsso.object_name order by 3 desc) 
  where rownum<=3;

SELECT to_char(begin_interval_time,'YYYY_MM_DD HH24:MI'),dbms_lob.substr(sql_text,4000,1),dhss.sql_id,executions_delta,rows_processed_delta
  FROM dba_hist_sqlstat dhss, dba_hist_snapshot dhs, dba_hist_sqltext dhst
 WHERE UPPER(dhst.sql_text) LIKE '%TEST_REDO%' AND dhss.snap_id = dhs.snap_id 
  AND dhss.instance_Number = dhs.instance_number AND dhss.sql_id = dhst.sql_id;