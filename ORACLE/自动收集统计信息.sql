SELECT * FROM sys.mon_mods_all$;

SELECT * FROM dba_objects t WHERE t.OBJECT_ID='100116';

--�Զ��ռ�ͳ����Ϣ�����ѯ
SELECT * FROM dba_autotask_task;

--�Զ��ռ�ͳ����Ϣ�ռ�����
SELECT * FROM dba_autotask_window_clients;

--�鿴ÿ���ռ��������ϸ��Ϣ
SELECT * FROM dba_scheduler_windows;

--�鿴�����ִ��״̬
SELECT * FROM dba_scheduler_job_run_details t WHERE t.JOB_NAME like 'ORA$AT_OS_OPT%' order by t.ACTUAL_START_DATE desc;
SELECT * FROM ( SELECT * FROM dba_autotask_job_history t WHERE t.CLIENT_NAME='auto optimizer stats collection' order by t.WINDOW_START_TIME desc) where rownum<=5;

--�Զ��ռ���ͳ����Ϣ�ı�׼
--sys.mon_mods_all ���л��¼���ϴ�ͳ����Ϣ�ռ���ҵ��ɺ󣬶����б��dml��truncate�����ļ�¼������ֵ,��ͳ����Ϣ�ռ��󣬼�¼���ᱻ��ա�
--�ռ�ͳ����Ϣ�ı�׼����delete+insert+update �������ܺʹ���TAB$,���ߴ˱�truncate
SELECT * FROM sys.mon_mods_all$; /*flags��1-��truncate    0-û��truncate

--��Ҫ�޸�ÿ��ִ�е�ʱ�䣬��ο�������oracle��SQL�Ż�|�Զ�ͳ����Ϣ�ռ���



