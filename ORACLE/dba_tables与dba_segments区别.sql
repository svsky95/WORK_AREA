--关于dba_segment 和 dba_tables的区别
当用户创建表后，如果表中没有数据，那么只会在dba_tables中有记录，而因为没有占用空间，所以在dba_segment中就没有。
当插入数据库，两个表就会同时存在。
--实验实例
create table aaaaa as SELECT * FROM dba_objects WHERE 1=2;
insert into aaaaa SELECT * FROM dba_objects;
SELECT * FROM dba_segments t WHERE t.segment_name='AAAAA';
SELECT * FROM dba_tables t WHERE t.TABLE_NAME='AAAAA';
SELECT * FROM aaaaa;