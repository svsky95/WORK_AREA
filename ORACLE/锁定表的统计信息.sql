�������ͳ����Ϣ
exec dbms_stats.lock_table_stats(ownname => 'NF_FDM_H',tabname => 'ZS_YJSF');

--�����ű�
SELECT 'exec dbms_stats.lock_table_stats(''' || T.OWNER || ''',''' ||
       TABLE_NAME || ''');'
  FROM DBA_TAB_STATISTICS T
 WHERE T.OWNER = 'NF_FDM'
   AND T.TABLE_NAME IN ('SB_ZQJM', 'ZS_JKS');

--��ѯ����״̬
select table_name from user_tab_statistics where stattype_locked is not null; 

--�������
dbms_stats.unlock_table_stats