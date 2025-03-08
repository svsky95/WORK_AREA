--oracle 表空间的收缩方法
-参考链接：https://www.modb.pro/db/11354
1、查看表空间中空间占用最大的表
SELECT t.segment_name,SUM(t.BYTES)/1024/1024 SIZE_M FROM dba_segments t WHERE t.tablespace_name='ETLUSR_DATA' GROUP BY t.segment_name ORDER BY 2 DESC;
2、如果是大字段，查看大字段对应的表
SELECT * FROM dba_lobs t WHERE t.SEGMENT_NAME = 'SYS_LOB0000087935C00011$$';

--表空间的创建，在表空间创建的时候必须以自动扩展的方式创建，否则是无法收缩的。
--查看表空间的建表语句
select dbms_metadata.get_ddl('TABLESPACE','TS_HX_ZM_DAT') from dual;
CREATE TABLESPACE "NF_FDM" NOLOGGING
DATAFILE 
'/u01/oracle/oradata/NFZCDB/NF_FDM/NF_FDM_01.DBF' SIZE 500M AUTOEXTEND ON NEXT 10M MAXSIZE 30000M,
'/u01/oracle/oradata/NFZCDB/NF_FDM/NF_FDM_02.DBF' SIZE 500M AUTOEXTEND ON NEXT 10M MAXSIZE 30000M,
'/u01/oracle/oradata/NFZCDB/NF_FDM/NF_FDM_03.DBF' SIZE 500M AUTOEXTEND ON NEXT 10M MAXSIZE 30000M,
'/u01/oracle/oradata/NFZCDB/NF_FDM/NF_FDM_04.DBF' SIZE 500M AUTOEXTEND ON NEXT 10M MAXSIZE 30000M；

--删除数据文件
alter tablespace IDX_TS drop datafile '/u01/oracle/oradata/NFZCDB/IDX_TS02.dbf';

--查看表空间包含数据文件（区）的file_id
select file_id, tablespace_name, file_name, online_status,autoextensible,user_bytes/1024/1024 size_M
  from dba_data_files
 where tablespace_name = 'TS_HX_ZM_DAT';
-->
file ID     此表空间包含了两个数据文件 73、186                             数据文件实际与系统中的文件是一致的
73	TS_HX_ZM_DAT	/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_01.dbf	ONLINE	YES	249    --可扩展
186	TS_HX_ZM_DAT	/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_02.dbf	ONLINE	NO	99     --固定，不可扩展

--查看表已经使用的数据文件
select distinct file_id from dba_extents t WHERE t.tablespace_name='TS_HX_ZM_DAT';
-->
186
73
可以看出，有段（表）已经使用了这个两个数据文件

--查看目前表空间中所包含表的使用总量
SELECT sum(t.BYTES)/1024/1024 size_M FROM dba_segments t WHERE t.tablespace_name='TS_HX_ZM_DAT';
-->
248    --此表空间的数据量是248M

--现在我们在表CZ_TEST中删除一部分数据，CZ_TEST在TS_HX_ZM_DAT表空间中，因为delete是不会降低高水线的，所以之后还需要降低高水位线。
--删除表数据
delete /*+parallel 8*/  from cz_test WHERE rownum<50000 ;

--开启行移动
alter table cz.cz_test enable row movement;
--开始数据重组，此步骤较慢
alter table cz.cz_test shrink space compact;
--开始释放空间，降低HWM （此过程需要在表上加X锁，会造成表上的所有DML语句阻塞。在业务特别繁忙的系统上可能造成比较大的影响）
alter table owner.table_name shrink space;
--关闭行移动
alter table owner.table_name disable row movement;

----批量执行
SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' enable row movement;'  FROM dba_tables t WHERE t.TABLESPACE_NAME='ETLUSR_DATA';
SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' shrink space;'  FROM dba_tables t WHERE t.TABLESPACE_NAME='ETLUSR_DATA';
SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' disable row movement;'  FROM dba_tables t WHERE t.TABLESPACE_NAME='ETLUSR_DATA';

--异常情况
有可能出现，shrink后，高水位线依然没有降低的情况，可以使用move，但是会锁表，谨慎。
对表进行MOVE操作：ALTER TABLE TABLE_NAME MOVE;。若表上存在索引，则需要重建索引。
SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' move;'  FROM dba_tables t WHERE t.TABLESPACE_NAME='ETLUSR_DATA';

--之后再次查看表空间总大小
SELECT sum(t.BYTES)/1024/1024 size_M FROM dba_segments t WHERE t.tablespace_name='TS_HX_ZM_DAT';
-->
173   --现在表空间数据量为173M

--查看表空间的数据在数据文件中的占用情况
select t.FILE_ID,sum(t.BYTES)/1024/1024 from dba_extents t WHERE t.tablespace_name='TS_HX_ZM_DAT' group by FILE_ID order by 1;
-->
file_id   size_M
73	      160
186	      86

--虽然高水位线降低了，表上的索引没有失效，但是表上的索引段的高水位没有降低，因此还要降低索引的高水位线，降低的唯一办法就是重建索引
ALTER INDEX idx_object_id_cz REBUILD ONLINE NOLOGGING PARALLEL 8;
此时，索引段占用的空间减少了，并且走索引时的COST也相对降低

--如果可扩展的数据文件已经被数据占完了，那么也就无法再收缩了

--而目前我们表空间TS_HX_ZM_DAT的数据文件中只有一个在创建的时候使用了自动扩展。
自动扩展的数据文件的大小为：249    固定大小不可扩展为 99 ，所以只能收缩扩展的大小249。
由于自动扩展的表空间初始大小为100M，所以最多只能收缩到100M。

ALTER DATABASE DATAFILE '/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_01.dbf' RESIZE 100M;

收缩完后，可以看出，数据文件被收缩到初始的100M。

--表中CLOB字段的收缩
在表中可能存在CLOB字段，但是在删除数据并对表进行收缩之后，可能并不会收缩CLOB字段，所以对于CLOB字段进行收缩。
ALTER TABLE lx.lx_etl_job_log  MODIFY LOB (TXTLOG) (SHRINK SPACE);

#####能不能收缩数据文件的关键####
ps：能不能收缩数据文件，除了在dba_segment中占用的空间外，还取决于dba_extents中block_id的最大值，如果已经数据文件大小的上限，即便是你用了shrink、move也没有办法缩小它，改变它的位置，那么只有把它
移动到其它表空间上，才能够降低这个数据文件大小。

SELECT max(t.BLOCK_ID)*8/1024 FROM dba_extents t WHERE t.segment_name='DJ_NSRXX_01' and t.tablespace_name='TEST_01';
SQL> SELECT max(t.BLOCK_ID)*8/1024 sSIZE_M FROM dba_extents t WHERE t.segment_name='DJ_NSRXX_01' and t.tablespace_name='TEST_01';

   SSIZE_M
----------
      1217
      
目前看来，这个数据文件，占用了这个数据文件的1217位置，其实block_Id就是这个数据文件的最大值，如果数据文件是32G，那么最后一个block_id=32766。
那么想要缩小这个数据文件，就需要把表，从这个数据文件中移走。
但是真正在生产环境下，问题又很复杂，很多表分布不在不同的数据文件中的顶端，即使你move了一个表，另一个表可能就在这个的后面，想要彻底释放，要么
逐一移动表到另一个空间，另外还需要注意，要是删除了索引，那么在dba_segments中,还会有回收站表的存在，所以要是删除，尽量用purge，但是此操作不能
flashback,谨慎操作，以上都做到了，数据文件就可以收缩了。

alter table DB_TY.T_NF_BSQD_DM move tablespace SJYY_TPS;  //表在表空间的移动会锁表


-----------------------------详细说明CLOB----------------------------------
LOB字段存放在指定表空间 清理CLOB字段及压缩CLOB空间
 
把LOB字段的SEGMENT 存放在指定表空间、清理CLOB字段及压缩CLOB空间
1、创建LOB字段存放表空间：
create tablespace lob_test datafile '/oracle/data/lob_test.dbf' size 500m autoextend on next 10m maxsize unlimited
 
2、移动LOB字段到单独存放表空间：
ALTER TABLE CENTER_ADMIN.NWS_NEWS 
MOVE LOB(ABSTRACT) 
STORE AS (TABLESPACE lob_test);
ABSTRACT---为一CLOB类型的字段
lob_test---为新创建的表空间。
 
3、清空指定时间段CLOB字段的内容：
update  CENTER_ADMIN.NWS_NEWS 
set ABSTRACT=EMPTY_CLOB()     
where substr(to_char(pubdate,'yyyy-mm-dd'),1,4)='2011'
 
4、单独shrink CLOB字段：
 ALTER TABLE CENTER_ADMIN.NWS_NEWS  MODIFY LOB (lob_column) (SHRINK SPACE);
--注：此方法会在表空间级释放出部分空间给其他对象使用，但这部分空间在操作系统级还是被占用
 
5、在操作系统级释放空间：
  alter database datafile '/oracle/data/lob_test.dbf' resize 400m
---注：绝大多数情况下，不可能一个表空间中只存放一个CLOB字段，若需要从操作系统级真正释放空间，尚需要shink table或EXP/IMP等操作。





