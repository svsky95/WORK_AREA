##���ݿ���ղ���ʱ����
1���������ݿ��쳣���������µĵ�ǰʱ���˿��ղ����ɡ�
2�����ڿ��ٻָ������������ͷſռ����Ȼ����ʱ���ɿ��ա�

--������
1���鿴pmon�����Ƿ����
1����Ҫˢ�¿������ɲ���
--��һ���ڵ�ִ�У������ڵ����Ч
retention => 28800   --���ձ�����  20*24*60   ����20��
INTERVAL => 60       --���     ÿ60��������һ��

SELECT 'exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention => 28800 ,INTERVAL => 60,dbid => ��' || DBID || '
�� );��' cmd  FROM dba_hist_wr_control;

exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention => 28800,INTERVAL => 60,dbid => ��3621313270�� );��

