#####��������#####
--����˵��
--���������
##PS:����oracle online����������˵��
�����ݵı���ִ��dml����ʱ��insert��delete��update�����������õ�dml������ʱ��ʵ����online����������ʱ�򣬻��еȴ���
֮��Ϊ��������oneline��ʱ�������ɣ�����Ϊ��dml�����Ѿ��ύ�ˣ����ʱ�򣬴�������������ɡ�
��ô��dml��䣬һֱ��������ʱ��online�Ĵ����������ͻ�һֱ�ĵȴ������ԣ�����dml��εĲ�����online���������������еȴ��ġ� 
#ȫ������
create index idx_name on table_name(cloumn_name1,cloumn_name2) tablespace tablespace_name nologging parallel 4 online;
alter idex_name logging;

#��������
create index dzdz.idx_dkxsfsbh_WHSJ on dzdz.DZDZ_FPXX_PTFP(DK_XSFSBH,FPZT_WHSJ) local parallel 8 nologging online;

-�Ƿ��߷����ü�������
PARTITION RANGE ITERATOR --��������ɨ�裬δ�߷����ü�
PARTITION RANGE SINGLE   --����Ψһɨ�裬�߷����ü�

##��������
1�������ĸ߶ȱȽϵ�
2����������洢���е�ֵ����Ӧ�˵�ROWID 
3����������������

##����������ԭ��
1���е����ݷֲ�����--���ռ��е�ֱ��ͼ
2���п�ֵ��������һ����Ϊ�յ��У��������������Ϳ���������   create index cz.tab_a on (col_null,1);
3��������������ѡ���Ժõķ���ǰ�����ϡ�
-ָ����Ϊ��
select * from aa where object_id is not null;
-�����в���Ϊ��
alter table t modify object_id not null;
3���󶨱�����̽
���µ�һ�εı�����ѡ��ռ��Ĵ󲿷����ݣ�������ȫ��ɨ�裬����Ӧ�α�ɽ��
4�������е�����
��upper(aaa)=bbb,����aaa�Ͳ�������
5������ʧЧ
6�������Ϸ�����ʽת��
��֤�ֶ�����������������һ��
PS:object_id ��number ��SQL����ǣ�object_id=1000
1000��number
7��������Ӧ�����в��ڸ���������һλ
8��������Ӧ������ѡ��Ȳ�����
9��ͳ����Ϣ��׼ȷ
10��ʹ��<>��!=���ܹ����˴������ݵ������
11��like 'somevalue%' ��������like '%somevalue%'��like '%somevalue'����������
12��������trunc��substr��to_date��to_char��instr�޷�ʹ��������
where trunc(hirdate) = '01-may-01';��д�������ķ�����where hirdate >to_date('01-may-01')
13���ֶ�������ν��������һ�£�SELECT * FROM cz.test0001 t WHERE t.object_id=1000������object_id��varchar2,��ʱ������ȫ��ɨ�衣
����t.object_id='1000'����������

-������ȱ��
1����ɾ�Ŀ����󣬱��е�����Խ�࣬���¾�Խ������ΪҪά��������������
2�����������ݶ�������������ұߣ���һ���ѯ�����ݽ϶������£��ͻ���������龺��
3���������������� ����ȡ�����м�ROWID�����������һֱ��ȡ���ݣ��ǽ�������ʲôʱ����ܽ��� ����ʹ��online�������������Ҳ�������DML


-��������ǰ׺������
������������ʱ��Ӧ�ÿ���ǰ���м���ֵ��ѯ���ȵ�����
1���Ѳ�ѯΪ��ֵ�����ģ�����ǰ�棬��Χ��ѯ�ķ��ں���
2����ѡ���Բ�ķ���ǰ��

-��������
���������ΪС����ߴ����ѡ���ԽϺõ�������ɸ��������������ݡ�
�������������߷�����

ÿ�ű������SQL�У�ֻ����һ����������ô���������ʱ�򣬾ͻ�ѡ���в�ѯ���������������˵��󲿷ֵ����ݡ�
��������������������������������ô�������������Ǵ������������ݡ�
�мǲ�Ҫ�ѷ������������ڸ��������У����ײ���INDEX SKIP SCAN������cost�ϸߡ�

--λͼ����
λͼ����ʵ�ʴ洢���Ǳ���ֵ���ʺ����������ظ��Խϸߵ������
���ظ��Խϸߵ�����£�COSTҪ�ȸ��ϵ�B-tree������Ч��Ҫ�ߡ�
�������׳�������������λͼ�������ʺ���û�б仯���ظ��ȼ��ߣ����磬��Ů�����б�ŵȡ�
--���µĲ�ѯ����
select *
from t
where gender='M'
and location in (1,10,30)
and age_group='child';

create bitmap index gender_idx on t(gender);
create bitmap index location_idx on t(location);
create bitmap index age_group_idx on t(age_group);

--��������

--��������
���������ݶ�������������ұߣ���һ���ѯ�����ݽ϶������£��ͻ���������龺���������������Լ��ٿ�����á�
create index idx_reverse_objname on t(reverse(object_name));
set autotrace on
select object_name,object_id from t where reverse(object_name) like reverse('%LJB');

##��������##
���أ����ɼ���������invisible indexes����oracle 11g ��һ�������ԣ��������������������صķ�ʽ�������ߴ����Ժ���Ϊ���ء�������ɣ�oracle Ҳϲ����Ǳˮ�������������Ż����ǲ��ɼ��ģ�������ʽ����ʵ�������߻Ự������optimizer_use_invisible_indexes ��ʼ������Ϊtrue�������������ô����ڣ����Ե�������ɾ����������Ϊ�����õ�һ�ִ��淽ʽ��

alter index emp.emp_idx invisible/visible; --invisible���ɼ� 
������ָ��ʹ��hit +index() Ҳ��������Ч
����ͨ���˷�����������insert��������ʱ�ģ�ά�������������ԣ��ǲ��ܵġ�  
��������ʵ���ڵ�������������dba_indexes��dba_segment��dba_objects ���ǿ��Կ����ġ�
SELECT t.owner,t.index_name,t.visibility FROM dba_indexes t WHERE t.index_name='IDX_DZDZ_HWXX_PTFP_TSLSH';


##���������뱾����������##
���ݱ�ռ�sing_dt01----sing_dt02
create tablespace sing_dt01 datafile '/home/oracle/oradata/**z/sing_dt01_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt02 datafile '/home/oracle/oradata/**z/sing_dt02_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt03 datafile '/home/oracle/oradata/**z/sing_dt03_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt04 datafile '/home/oracle/oradata/**z/sing_dt04_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt05 datafile '/home/oracle/oradata/**z/sing_dt05_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt06 datafile '/home/oracle/oradata/**z/sing_dt06_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt07 datafile '/home/oracle/oradata/**z/sing_dt07_01.dbf' size 4096m autoextend on next 100m;

������ռ�sing_idx01----sing_idx07
create tablespace sing_idx01 datafile '/home/oracle/oradata/**z/sing_idx01_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx02 datafile '/home/oracle/oradata/**z/sing_idx02_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx03 datafile '/home/oracle/oradata/**z/sing_idx03_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx04 datafile '/home/oracle/oradata/**z/sing_idx04_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx05 datafile '/home/oracle/oradata/**z/sing_idx05_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx06 datafile '/home/oracle/oradata/**z/sing_idx06_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx07 datafile '/home/oracle/oradata/**z/sing_idx07_01.dbf' size 1024m autoextend on next 100m;

����������
create table FLR_SING_ASAC_AMT
(
  SING_ASAC_AMT_ID    INTEGER not null,
   XXXX             CHAR(11) not null,
   XXXX        CHAR(20) not null,
   XXXX           CHAR(14),
   XXXX             CHAR(2) not null,
   XXXX         INTEGER not null,
   XXXX       VARCHAR2(32),
   XXXX  CHAR(11),
   XXXX           NUMBER(20,4),
   XXXX             CHAR(4),
  XXXX        CHAR(3),
   XXXX        CHAR(8),
   CLR_DATE  CHAR(8) not null,
  XXXX      CHAR(14)
)
partition by range(clr_date)
(
partition p1 values less than ('20120702') tablespace sing_dt01,
partition p2 values less than ('20120703') tablespace sing_dt02,
partition p3 values less than ('20120704') tablespace sing_dt03,
partition p4 values less than ('20120705') tablespace sing_dt04,
partition p5 values less than ('20120706') tablespace sing_dt05,
partition p6 values less than ('20120707') tablespace sing_dt06,
partition p7 values less than ('20120708') tablespace sing_dt07
);

������Ӧ������--local
create unique index PK_FLR_SING_ASAC_AMT on FLR_SING_ASAC_AMT(clr_date,SING_ASAC_AMT_ID) local
(
partition p1 tablespace sing_idx01,
partition p2 tablespace sing_idx02,
partition p3 tablespace sing_idx03,
partition p4 tablespace sing_idx04,
partition p5 tablespace sing_idx05,
partition p6 tablespace sing_idx06,
partition p7 tablespace sing_idx07
);



��20120708��ʱ����Ҫ������P1�Ͷ�Ӧ����������drop�� Ȼ�󣬽��µ�partition����ʹ�ñ�ռ�sing_dt01��
alter table FLR_SING_ASAC_AMT add partition p8 values less than ('20120709') tablespace sing_dt01;

���������ʱ��local�����Ĵ洢λ���Ǳ�ռ�sing_dt01���ܲ�����add partition��ʱ���ָ����Ӧlocal����������tablespace��

##��������##
��������(virtual index)��ָû�д�����Ӧ������ʵ�������������������Ŀ�ģ����ڲ��غ�cpu,��IO�Լ����Ĵ����洢�ռ�ȥʵ�ʴ�����������������ж�һ�������Ƿ��ܹ���sql�Ż������á�

���ڽ�������������Ҫ�������� ��_use_nosegment_indexes��������һ���ǻ���session �н������ã������˻Ự�����������Ч��
alter session set "_use_nosegment_indexes"=TRUE;

create index id_index on tt(object_id) nosegment; 

explain plan for select * from tt where object_id=54;

select * from table(dbms_xplan.display());

����������������������dba_indexes��dba_segment�����Ҳ����ģ�������dba_objects ���ǿ��Կ�����

SELECT * FROM Dba_Indexes t WHERE t.index_name='IDX_OBJECT_IDBB';

SELECT * FROM dba_objects t WHERE t.OBJECT_NAME='IDX_OBJECT_IDBB';

SELECT * FROM dba_segments t WHERE t.segment_name='IDX_OBJECT_IDBB';

##������Ч�Լ��##
Ϊ�˼�������Ƿ�ʹ�ã��Ծ����Ƿ���Ա���������
--��������  ���
ALTER INDEX cz.idx_object_id_cz MONITORING USAGE;
--�ر����� ���
ALTER INDEX cz.idx_object_id_cz noMONITORING USAGE;
--�鿴ʹ�����
--ע�⣬��ص�ʱ�������Ƿ��û��ģ�������ص��������ĸ��û��£������ĸ��û�ȥ�鿴v$object_usage�����ݣ������û��ǲ鿴��������ġ�
SELECT * FROM  v$object_usage t WHERE t.index_name='IDX_DZDZ_HWXX_PTFP_TSLSH';	
INDEX_NAME                     TABLE_NAME                     MON USE START_MONITORING    END_MONITORING
------------------------------ ------------------------------ --- --- ------------------- -------------------
IDX_OBJECT_ID_CZ               CZ_TEST                        NO  YES 11/17/2017 14:46:19 11/17/2017 15:08:17	

����USE  Ϊ YES  ʹ�ù�
                 Ϊ  NO   δʹ�ù�
START_MONITORING    
                  ��ʱ�䣬˵������Ѿ��ر�


##������online����##
�ڴ�ͳ���������Ĺ����У��ᵼ����������֤��û�����ݸ��µ�ǰ���£���֤�������Դ�����ɣ����������ᵼ���������������е�DML��DDL������
��online��ʽ�Ĵ������������ᵼ���������ǵ������ݲ���ʱ��online���������ķ�ʽ����ȴ����ݲ�����ɣ�����commit��roll back���󣬲Żᴴ����ɣ��Ӷ���֤����ҵ��Ľ��С�

CREATE INDEX idx_object_id_cz ON cz_test(object_id) parallel 8 ONLINE nologging;