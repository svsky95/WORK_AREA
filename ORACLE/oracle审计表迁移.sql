--创建审计表空间
create tablespace aud_tps;

--查询sys.AUD$表的，默认表空间及索引
SELECT * FROM dba_tables t WHERE t.TABLE_NAME='AUD$';
SELECT * FROM dba_indexes t WHERE t.table_name='AUD$';

--修改默认表空间
sqlplus / as sysdba  --必须在终端执行，否则会报权限不足

alter table sys.aud$ move tablespace aud_tps;
alter table sys.aud$ move lob(sqlbind) store as( tablespace aud_tps);
alter table sys.aud$ move lob(SQLTEXT) store as( tablespace aud_tps);
alter index sys.I_AUD1 rebuild tablespace aud_tps;