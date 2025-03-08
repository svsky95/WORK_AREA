--���ڱ��һ����ռ��ƶ�����һ����ռ�
��ı�ռ��ƶ�������Ӱ��������û���ʹ�á������ƶ���ɺ�������ʧЧ��������Ҫ�ؽ�������
--��ͨ��
alter table schema.[table_name] move tablespace [new tablespace];
--�ƶ�LOB�ֶ�
alter table [table_name] move lob ([lobsegment_name]) store as (tablespace [new tablespace]);
--�����ؽ�
alter index [index_name] rebuild tablespace [new tablespace];

---��ͨ����ƶ��ǿ���ֱ���ƶ��ģ��������������LOB�ֶ���ô�ͻ���dba_segment�в������������
1��LOBSEGMENT  
2��LOBINDEX

1�����ǽ�һ�����ʱ��Oracle���ڶ�Ӧ�ı�ռ��ڸ�����һ��segent����������ݣ����һ���Ϊ������������������չ�����ǵ������������ı��к���lob�͵�����ʱ��oracle��Ϊÿ��lob�ֶ�����һ��������segment����������ݣ�ͬʱҲ�����˶�����index segment .oracle�������ǵ�������ġ�

2;��ͨ��ֻ������һ���������ζ���.����ΪTABLE��INDEX�����ݾʹ���ڱ����.�����ͷ����������С�����LOB������������������ζ���,����ΪLOBSEGMENT��LOBINDEX��LOBINDEX����ָ��LOB��,�ҳ����е�ĳһ���֣����Դ洢�ڱ��е�LOB�洢����һ����ַ,����˵��һ��ָ��,ʵ���ϱ��е�lob���д����һ����ַ��.Ȼ����lobindex�ҵ����еĵ�ַ��.Ȼ����lobSegment�а����е�ַ�ε�ֵ����ȡ����������lobSegment�ͱ�����LOG�е����������ݣ����Ի�ǳ��󣬲��Ҷ�����ԭʼ����ڡ�

 
--ʾ����
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

--�鿴���ֶζ������Ķ�Ӧ��ϵ
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

--��ͨ����ƶ�����
1���ƶ���
alter table lx.LX_ETL_JOB_LOG move  tablespace TS_ZDSY_DAT;
2���ؽ�����
select 'alter index '||owner||'.'||index_name||' rebuild  online nologging  parallel 8;' from dba_indexes where status='UNUSABLE'; 
--������ֶ��ƶ�����
1�����������û�һ��Ҫ��Ŀ���ռ��Ȩ�ޡ�
alter user lx quota unlimited on TS_ZDSY_DAT;
2���ƶ���Ŀ���ռ�
alter table lx.LX_ETL_JOB_LOG move  tablespace TS_ZDSY_DAT;
3���ƶ�LOB�ֶε�Ŀ���ռ�
alter table lx.LX_ETL_JOB_LOG move lob (TXTLOG) store as (tablespace TS_ZDSY_DAT);
4����ʵ��ȷ��
5���鿴�����Ƿ���������������ʧЧ��
select 'alter index '||owner||'.'||index_name||' rebuild  online nologging  parallel 8;' from dba_indexes where status='UNUSABLE'; 



