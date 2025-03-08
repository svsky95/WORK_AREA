--指定表空间的块大小
越大的块，对于OLAP数据库，减少了逻辑读，一次读取的块中的数据更多。
但是对于OLTP，越大的块，不同的人访问不同的数据落在同一个块的概率大大增加，这就容易产生热快竞争。
create tablespace TBS_LJB_4k
blocksize 2K/4K/8K/16K 
datafile  'D:\ORACLE\ORADATA\TEST11G\TBS_LJB_4K_01.DBF' size 100M
autoextend on
extent management local
segment space management auto;