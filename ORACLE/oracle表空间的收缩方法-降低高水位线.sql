--oracle ��ռ����������
-�ο����ӣ�https://www.modb.pro/db/11354
1���鿴��ռ��пռ�ռ�����ı�
SELECT t.segment_name,SUM(t.BYTES)/1024/1024 SIZE_M FROM dba_segments t WHERE t.tablespace_name='ETLUSR_DATA' GROUP BY t.segment_name ORDER BY 2 DESC;
2������Ǵ��ֶΣ��鿴���ֶζ�Ӧ�ı�
SELECT * FROM dba_lobs t WHERE t.SEGMENT_NAME = 'SYS_LOB0000087935C00011$$';

--��ռ�Ĵ������ڱ�ռ䴴����ʱ��������Զ���չ�ķ�ʽ�������������޷������ġ�
--�鿴��ռ�Ľ������
select dbms_metadata.get_ddl('TABLESPACE','TS_HX_ZM_DAT') from dual;
CREATE TABLESPACE "NF_FDM" NOLOGGING
DATAFILE 
'/u01/oracle/oradata/NFZCDB/NF_FDM/NF_FDM_01.DBF' SIZE 500M AUTOEXTEND ON NEXT 10M MAXSIZE 30000M,
'/u01/oracle/oradata/NFZCDB/NF_FDM/NF_FDM_02.DBF' SIZE 500M AUTOEXTEND ON NEXT 10M MAXSIZE 30000M,
'/u01/oracle/oradata/NFZCDB/NF_FDM/NF_FDM_03.DBF' SIZE 500M AUTOEXTEND ON NEXT 10M MAXSIZE 30000M,
'/u01/oracle/oradata/NFZCDB/NF_FDM/NF_FDM_04.DBF' SIZE 500M AUTOEXTEND ON NEXT 10M MAXSIZE 30000M��

--ɾ�������ļ�
alter tablespace IDX_TS drop datafile '/u01/oracle/oradata/NFZCDB/IDX_TS02.dbf';

--�鿴��ռ���������ļ���������file_id
select file_id, tablespace_name, file_name, online_status,autoextensible,user_bytes/1024/1024 size_M
  from dba_data_files
 where tablespace_name = 'TS_HX_ZM_DAT';
-->
file ID     �˱�ռ���������������ļ� 73��186                             �����ļ�ʵ����ϵͳ�е��ļ���һ�µ�
73	TS_HX_ZM_DAT	/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_01.dbf	ONLINE	YES	249    --����չ
186	TS_HX_ZM_DAT	/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_02.dbf	ONLINE	NO	99     --�̶���������չ

--�鿴���Ѿ�ʹ�õ������ļ�
select distinct file_id from dba_extents t WHERE t.tablespace_name='TS_HX_ZM_DAT';
-->
186
73
���Կ������жΣ����Ѿ�ʹ����������������ļ�

--�鿴Ŀǰ��ռ������������ʹ������
SELECT sum(t.BYTES)/1024/1024 size_M FROM dba_segments t WHERE t.tablespace_name='TS_HX_ZM_DAT';
-->
248    --�˱�ռ����������248M

--���������ڱ�CZ_TEST��ɾ��һ�������ݣ�CZ_TEST��TS_HX_ZM_DAT��ռ��У���Ϊdelete�ǲ��ή�͸�ˮ�ߵģ�����֮����Ҫ���͸�ˮλ�ߡ�
--ɾ��������
delete /*+parallel 8*/  from cz_test WHERE rownum<50000 ;

--�������ƶ�
alter table cz.cz_test enable row movement;
--��ʼ�������飬�˲������
alter table cz.cz_test shrink space compact;
--��ʼ�ͷſռ䣬����HWM ���˹�����Ҫ�ڱ��ϼ�X��������ɱ��ϵ�����DML�����������ҵ���ر�æ��ϵͳ�Ͽ�����ɱȽϴ��Ӱ�죩
alter table owner.table_name shrink space;
--�ر����ƶ�
alter table owner.table_name disable row movement;

----����ִ��
SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' enable row movement;'  FROM dba_tables t WHERE t.TABLESPACE_NAME='ETLUSR_DATA';
SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' shrink space;'  FROM dba_tables t WHERE t.TABLESPACE_NAME='ETLUSR_DATA';
SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' disable row movement;'  FROM dba_tables t WHERE t.TABLESPACE_NAME='ETLUSR_DATA';

--�쳣���
�п��ܳ��֣�shrink�󣬸�ˮλ����Ȼû�н��͵����������ʹ��move�����ǻ�����������
�Ա����MOVE������ALTER TABLE TABLE_NAME MOVE;�������ϴ�������������Ҫ�ؽ�������
SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' move;'  FROM dba_tables t WHERE t.TABLESPACE_NAME='ETLUSR_DATA';

--֮���ٴβ鿴��ռ��ܴ�С
SELECT sum(t.BYTES)/1024/1024 size_M FROM dba_segments t WHERE t.tablespace_name='TS_HX_ZM_DAT';
-->
173   --���ڱ�ռ�������Ϊ173M

--�鿴��ռ�������������ļ��е�ռ�����
select t.FILE_ID,sum(t.BYTES)/1024/1024 from dba_extents t WHERE t.tablespace_name='TS_HX_ZM_DAT' group by FILE_ID order by 1;
-->
file_id   size_M
73	      160
186	      86

--��Ȼ��ˮλ�߽����ˣ����ϵ�����û��ʧЧ�����Ǳ��ϵ������εĸ�ˮλû�н��ͣ���˻�Ҫ���������ĸ�ˮλ�ߣ����͵�Ψһ�취�����ؽ�����
ALTER INDEX idx_object_id_cz REBUILD ONLINE NOLOGGING PARALLEL 8;
��ʱ��������ռ�õĿռ�����ˣ�����������ʱ��COSTҲ��Խ���

--�������չ�������ļ��Ѿ�������ռ���ˣ���ôҲ���޷���������

--��Ŀǰ���Ǳ�ռ�TS_HX_ZM_DAT�������ļ���ֻ��һ���ڴ�����ʱ��ʹ�����Զ���չ��
�Զ���չ�������ļ��Ĵ�СΪ��249    �̶���С������չΪ 99 ������ֻ��������չ�Ĵ�С249��
�����Զ���չ�ı�ռ��ʼ��СΪ100M���������ֻ��������100M��

ALTER DATABASE DATAFILE '/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_01.dbf' RESIZE 100M;

������󣬿��Կ����������ļ�����������ʼ��100M��

--����CLOB�ֶε�����
�ڱ��п��ܴ���CLOB�ֶΣ�������ɾ�����ݲ��Ա��������֮�󣬿��ܲ���������CLOB�ֶΣ����Զ���CLOB�ֶν���������
ALTER TABLE lx.lx_etl_job_log  MODIFY LOB (TXTLOG) (SHRINK SPACE);

#####�ܲ������������ļ��Ĺؼ�####
ps���ܲ������������ļ���������dba_segment��ռ�õĿռ��⣬��ȡ����dba_extents��block_id�����ֵ������Ѿ������ļ���С�����ޣ�������������shrink��moveҲû�а취��С�����ı�����λ�ã���ôֻ�а���
�ƶ���������ռ��ϣ����ܹ�������������ļ���С��

SELECT max(t.BLOCK_ID)*8/1024 FROM dba_extents t WHERE t.segment_name='DJ_NSRXX_01' and t.tablespace_name='TEST_01';
SQL> SELECT max(t.BLOCK_ID)*8/1024 sSIZE_M FROM dba_extents t WHERE t.segment_name='DJ_NSRXX_01' and t.tablespace_name='TEST_01';

   SSIZE_M
----------
      1217
      
Ŀǰ��������������ļ���ռ������������ļ���1217λ�ã���ʵblock_Id������������ļ������ֵ����������ļ���32G����ô���һ��block_id=32766��
��ô��Ҫ��С��������ļ�������Ҫ�ѱ�����������ļ������ߡ�
�������������������£������ֺܸ��ӣ��ܶ��ֲ����ڲ�ͬ�������ļ��еĶ��ˣ���ʹ��move��һ������һ������ܾ�������ĺ��棬��Ҫ�����ͷţ�Ҫô
��һ�ƶ�����һ���ռ䣬���⻹��Ҫע�⣬Ҫ��ɾ������������ô��dba_segments��,�����л���վ��Ĵ��ڣ�����Ҫ��ɾ����������purge�����Ǵ˲�������
flashback,�������������϶������ˣ������ļ��Ϳ��������ˡ�

alter table DB_TY.T_NF_BSQD_DM move tablespace SJYY_TPS;  //���ڱ�ռ���ƶ�������


-----------------------------��ϸ˵��CLOB----------------------------------
LOB�ֶδ����ָ����ռ� ����CLOB�ֶμ�ѹ��CLOB�ռ�
 
��LOB�ֶε�SEGMENT �����ָ����ռ䡢����CLOB�ֶμ�ѹ��CLOB�ռ�
1������LOB�ֶδ�ű�ռ䣺
create tablespace lob_test datafile '/oracle/data/lob_test.dbf' size 500m autoextend on next 10m maxsize unlimited
 
2���ƶ�LOB�ֶε�������ű�ռ䣺
ALTER TABLE CENTER_ADMIN.NWS_NEWS 
MOVE LOB(ABSTRACT) 
STORE AS (TABLESPACE lob_test);
ABSTRACT---ΪһCLOB���͵��ֶ�
lob_test---Ϊ�´����ı�ռ䡣
 
3�����ָ��ʱ���CLOB�ֶε����ݣ�
update  CENTER_ADMIN.NWS_NEWS 
set ABSTRACT=EMPTY_CLOB()     
where substr(to_char(pubdate,'yyyy-mm-dd'),1,4)='2011'
 
4������shrink CLOB�ֶΣ�
 ALTER TABLE CENTER_ADMIN.NWS_NEWS  MODIFY LOB (lob_column) (SHRINK SPACE);
--ע���˷������ڱ�ռ伶�ͷų����ֿռ����������ʹ�ã����ⲿ�ֿռ��ڲ���ϵͳ�����Ǳ�ռ��
 
5���ڲ���ϵͳ���ͷſռ䣺
  alter database datafile '/oracle/data/lob_test.dbf' resize 400m
---ע�������������£�������һ����ռ���ֻ���һ��CLOB�ֶΣ�����Ҫ�Ӳ���ϵͳ�������ͷſռ䣬����Ҫshink table��EXP/IMP�Ȳ�����





