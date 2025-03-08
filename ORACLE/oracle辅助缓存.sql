--oracle辅助缓存
--注意，操作系统必须是solaris或oracle enterprise linux
关于SSD的使用可以分为两种：
1、小型数据库，可以把数据库直接部署在SSD上。
2、大型数据库，可以数据文件、表、索引或分区放在SSD上，
show parameter db_flash_cache
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_flash_cache_file                  string
db_flash_cache_size                  big integer 0

alter system set db_flash_cache_size=1024M scope=spfile;
alter system set db_flash_cache_file='/ora_data/test_db.dbf' scope=spfile;

--之后重启数据库。

--配置表到缓存
none     块不会被缓存
default  块以正常的优先级进行缓存
keep     高优先级进行缓存，并且不会被移出缓存，除非没有可用的默认块

alter table sales_test storage(flash_cache none/default/keep);
alter index idx_dale storage(flash_cache none/default/keep);

从oracle 11g 开始，全表扫描通常会绕过buffer cache，直接从硬盘读取，而db_flash_cache是从缓冲区转移过来的，所以全表扫描是不能从db_flash_cache中获得的。