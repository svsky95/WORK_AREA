--����dba_segment �� dba_tables������
���û���������������û�����ݣ���ôֻ����dba_tables���м�¼������Ϊû��ռ�ÿռ䣬������dba_segment�о�û�С�
���������ݿ⣬������ͻ�ͬʱ���ڡ�
--ʵ��ʵ��
create table aaaaa as SELECT * FROM dba_objects WHERE 1=2;
insert into aaaaa SELECT * FROM dba_objects;
SELECT * FROM dba_segments t WHERE t.segment_name='AAAAA';
SELECT * FROM dba_tables t WHERE t.TABLE_NAME='AAAAA';
SELECT * FROM aaaaa;