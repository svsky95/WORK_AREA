--关于表从一个表空间移动到另一个表空间
表的表空间移动，并不影响表所属用户的使用。但是移动完成后索引会失效，所以需要重建索引。
--普通标
alter table schema.[table_name] move tablespace [new tablespace];
--移动LOB字段
alter table [table_name] move lob ([lobsegment_name]) store as (tablespace [new tablespace]);
--索引重建
alter index [index_name] rebuild tablespace [new tablespace];

---普通表的移动是可以直接移动的，但是如果表中有LOB字段那么就会在dba_segment中产生两个大对象。
1、LOBSEGMENT  
2、LOBINDEX

1、我们建一个表的时候，Oracle对在对应的表空间在给我们一个segent中来存放数据，并且会因为数据量的增大再做扩展。但是当我们所建立的表中含有lob型的数据时，oracle会为每个lob字段生成一个独立的segment用来存放数据，同时也建立了独立的index segment .oracle对它们是单独管理的。

2;普通表只会新增一个或两个段对象.类型为TABLE和INDEX，数据就存放在表段中.索引就放在索引段中。但是LOB列则额外新增了两个段对象,类型为LOBSEGMENT和LOBINDEX，LOBINDEX用于指向LOB段,找出其中的某一部分，所以存储在表中的LOB存储的是一个地址,或者说是一个指针,实际上表中的lob列中存的是一个地址段.然后在lobindex找到所有的地址段.然后在lobSegment中把所有地址段的值都读取了来。所以lobSegment就保存了LOG列的真正的数据，所以会非常大，并且独立于原始表存在。

 
--示例：
create table lx.lx_ETL_JOB_LOG
(
  id           VARCHAR2(32) not null,
  sys_name     VARCHAR2(180),
  job_name     VARCHAR2(100),
  jobsessionid INTEGER,
  scriptfile   VARCHAR2(70),
  txdate       VARCHAR2(10),
  starttime    VARCHAR2(19),
  endtime      VARCHAR2(19),
  returncode   INTEGER,
  seconds      INTEGER,
  txtlog       CLOB
)
tablespace USERS
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

alter table lx.lx_ETL_JOB_LOG
  add primary key (ID)
  using index 
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

--查看大字段对象与表的对应关系
SELECT A.OWNER,
       A.TABLE_NAME,
       A.COLUMN_NAME,
       B.SEGMENT_NAME,
       B.SEGMENT_TYPE,
       B.TABLESPACE_NAME,
       B.BYTES / 1024 / 1024,
       B.BLOCKS,
       B.EXTENTS
  FROM dba_LOBS A, dba_SEGMENTS B
 WHERE A.SEGMENT_NAME = B.SEGMENT_NAME
 ORDER BY B.BYTES DESC;
 
select * from dba_segments t WHERE t.owner='LX';
LX	SYS_IL0000196576C00011$$		LOBINDEX	ASSM	USERS	160	2079818	196608	24	3	65536	1048576	1	2147483645	2147483645						160	DEFAULT	DEFAULT	DEFAULT
LX	SYS_LOB0000196576C00011$$		LOBSEGMENT	ASSM	USERS	160	2079810	226492416	27648	98	65536	1048576	1	2147483645	2147483645						160	DEFAULT	DEFAULT	DEFAULT

--普通表的移动方法
1、移动表
alter table lx.LX_ETL_JOB_LOG move  tablespace TS_ZDSY_DAT;
2、重建索引
select 'alter index '||owner||'.'||index_name||' rebuild  online nologging  parallel 8;' from dba_indexes where status='UNUSABLE'; 
--大对象字段移动方法
1、表所属的用户一定要有目标表空间的权限。
alter user lx quota unlimited on TS_ZDSY_DAT;
2、移动表到目标表空间
alter table lx.LX_ETL_JOB_LOG move  tablespace TS_ZDSY_DAT;
3、移动LOB字段到目标表空间
alter table lx.LX_ETL_JOB_LOG move lob (TXTLOG) store as (tablespace TS_ZDSY_DAT);
4、核实正确性
5、查看表中是否还有其它的索引会失效。
select 'alter index '||owner||'.'||index_name||' rebuild  online nologging  parallel 8;' from dba_indexes where status='UNUSABLE'; 



