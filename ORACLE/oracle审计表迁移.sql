--������Ʊ�ռ�
create tablespace aud_tps;

--��ѯsys.AUD$��ģ�Ĭ�ϱ�ռ估����
SELECT * FROM dba_tables t WHERE t.TABLE_NAME='AUD$';
SELECT * FROM dba_indexes t WHERE t.table_name='AUD$';

--�޸�Ĭ�ϱ�ռ�
sqlplus / as sysdba  --�������ն�ִ�У�����ᱨȨ�޲���

alter table sys.aud$ move tablespace aud_tps;
alter table sys.aud$ move lob(sqlbind) store as( tablespace aud_tps);
alter table sys.aud$ move lob(SQLTEXT) store as( tablespace aud_tps);
alter index sys.I_AUD1 rebuild tablespace aud_tps;