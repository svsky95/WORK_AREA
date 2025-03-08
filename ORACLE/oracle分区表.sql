--�Զ�����������  ##�����Զ������ɺ󣬵����µķ����������ݲ���ʱ�������Ż��Զ����
--���ȱ�����rang����
1���̶�����
partition by range (KPYF)                    
(                                            
  partition SYS_000 values less than (201410)    
--�Զ���1
alter table cz.dzdz_fpxx_zzsfp set interval(1);  

2��������д��
partition by range (sales_dt)                                         
(                                                                     
partition p1107 values less than (to_date('2012-08-01','yyyy-mm-dd')) 
--�·ݼ�1
alter table sales set interval(NUMTOYMINTERVAL(1,'month'));

--���������1
����day��hour��minute��secondʹ�õ���numtodsinterval������������numtoymintervalһ��
alter table sales set interval(numtodsinterval(1,'day'));

--��ѯָ���Ĵ洢��ռ�
ALTER TABLE cz.dzdz_fpxx_zzsfp SET store IN(tablespace_name1,tablespace_name2);  

--������� ����
SELECT DISTINCT  'alter table '||xx.table_owner||'.'||xx.table_name || ' set interval(1);' comm_sql FROM (SELECT DISTINCT t.table_owner,t.table_name,t.tablespace_name fROM dba_tab_partitions t WHERE t.table_owner NOT IN ('CZ','SYS') AND t.partition_name LIKE '%SYS%' AND t.table_name NOT LIKE 'BIN%' ORDER BY 2
) xx ; 
--������� ��ռ���ѯ
SELECT DISTINCT  'alter table '||xx.table_owner||'.'||xx.table_name || ' set store IN ('||to_char(WM_CONCAT(XX.TABLESPACE_NAME))||');' comm_sql FROM (SELECT DISTINCT t.table_owner,t.table_name,t.tablespace_name fROM dba_tab_partitions t WHERE t.table_owner NOT IN ('CZ','SYS') AND t.partition_name LIKE '%SYS%' AND t.table_name NOT LIKE 'BIN%' ORDER BY 2
) xx  GROUP BY xx.table_owner,xx.table_name ; 

--������ʱ�Դ�������չ
create table xx(c1,c2)
partition by range(c2)
interval(numtoyminterval (1,'month')) store in(tablespace1,tablespace2,....,tablespacen)
(partition xx......,
 partition xx......
)                                            

//��������
--��Χ��������-range
create table range_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
      partition by range (deal_date)
      (
      partition p1 values less than (TO_DATE('2015-02-01', 'YYYY-MM-DD')) TABLESPACE LS6_SID_DATA_1,
      partition p2 values less than (TO_DATE('2015-03-01', 'YYYY-MM-DD')) TABLESPACE LS6_SID_DATA_2,
      partition p3 values less than (TO_DATE('2015-04-01', 'YYYY-MM-DD')),
      partition p4 values less than (TO_DATE('2015-05-01', 'YYYY-MM-DD')),
      partition p5 values less than (TO_DATE('2015-06-01', 'YYYY-MM-DD')),
      partition p6 values less than (TO_DATE('2015-07-01', 'YYYY-MM-DD')),
      partition p7 values less than (TO_DATE('2015-08-01', 'YYYY-MM-DD')),
      partition p8 values less than (TO_DATE('2015-09-01', 'YYYY-MM-DD')),
      partition p9 values less than (TO_DATE('2015-10-01', 'YYYY-MM-DD')),
      partition p10 values less than (TO_DATE('2015-11-01', 'YYYY-MM-DD')),
      partition p11 values less than (TO_DATE('2015-12-01', 'YYYY-MM-DD')),
      partition p12 values less than (TO_DATE('2016-01-01', 'YYYY-MM-DD')),
      partition p_max values less than (maxvalue)
       );
       
--list����
create table list_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
 partition by list (area_code)
 (
 partition p_591 values  (591),
 partition p_592 values  (592),
 partition p_593 values  (593),
 partition p_594 values  (594),
 partition p_595 values  (595),
 partition p_596 values  (596),
  partition p_597 values  (597),
  partition p_598 values  (598),
  partition p_599 values  (599),
  partition p_other values  (DEFAULT)
  )
  ;
  
--HASH����
create table hash_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
 partition by hash (deal_date)
 PARTITIONS 12                --��������
 ;      
       
 
--��Ϸ���
create table range_list_part_tab (id number,deal_date date,area_code number,��contents varchar2(4000))
  partition by range (deal_date)
    subpartition by list (area_code)
    subpartition TEMPLATE
    (subpartition p_591 values  (591),
     subpartition p_592 values  (592),
     subpartition p_593 values  (593),
     subpartition p_594 values  (594),
     subpartition p_595 values  (595),
      subpartition p_596 values  (596),
      subpartition p_597 values  (597),
      subpartition p_598 values  (598),
      subpartition p_599 values  (599),
      subpartition p_other values (DEFAULT))
   (
    partition p1 values less than (TO_DATE('2015-02-01', 'YYYY-MM-DD')),
    partition p2 values less than (TO_DATE('2015-03-01', 'YYYY-MM-DD')),
    partition p3 values less than (TO_DATE('2015-04-01', 'YYYY-MM-DD')),
    partition p4 values less than (TO_DATE('2015-05-01', 'YYYY-MM-DD')),
    partition p5 values less than (TO_DATE('2015-06-01', 'YYYY-MM-DD')),
    partition p6 values less than (TO_DATE('2015-07-01', 'YYYY-MM-DD')),
    partition p7 values less than (TO_DATE('2015-08-01', 'YYYY-MM-DD')),
    partition p8 values less than (TO_DATE('2015-09-01', 'YYYY-MM-DD')),
    partition p9 values less than (TO_DATE('2015-10-01', 'YYYY-MM-DD')),
    partition p10 values less than (TO_DATE('2015-11-01', 'YYYY-MM-DD')),
    partition p11 values less than (TO_DATE('2015-12-01', 'YYYY-MM-DD')),
    partition p12 values less than (TO_DATE('2016-01-01', 'YYYY-MM-DD')),
    partition p_max values less than (maxvalue)
   )
   ;
   
--����ά��
������ѯ
select count(*) from part_tab_trunc partition(p1);

����truncate
alter table part_tab_trunc truncate partition p1 ;

����drop
alter table part_tab_drop drop partition p1 ;

�������split
alter table part_tab_split SPLIT PARTITION P_MAX  at (30000) into (PARTITION p3  ,PARTITION P_MAX);
alter table part_tab_split SPLIT PARTITION P_MAX  at (40000) into (PARTITION p4  ,PARTITION P_MAX);

�������
--ע�⣺����Ҫ��Ĭ�Ϸ���ȥ������add������������Ĭ�Ϸ���,������ܶ�����!
--drop������ʱ����Ҫ�ȿ���max����������û�����ݣ�û�����ݲſ���ɾ��
select count(*) from part_tab_add partition(p_max);
alter table part_tab_add  drop partition p_max;  --ɾ�����һ������
alter table part_tab_add  add PARTITION p6 values less than (60000);
alter table part_tab_add  add PARTITION p_max  values less than (maxvalue);

�������� --����including indexes  ��ѡ��Ϊ�˱�֤ȫ��������ҪʧЧ
alter table part_tab_exch exchange partition p1 with table normal_tab including indexes update global indexes;

�����ϲ�
alter table EMP_RANGE merge partitions TEST_RANGE_SAL_01,TEST_RANGE_SAL_02 into partition TEST_RANGE_SAL_00;
      
�����ƶ�
alter table EMP_BB move partition EMPLOYEE_DEPTNO_10 tablespace LS6_BILL_DATA;


--�ƶ���Ϸ����ı�
���ƶ���Ϸ����ı�ʱ������ֱ���ƶ���������Ҫ���ƶ��ӷ�����Ȼ�����޸�����������

alter table EMP_BB move subpartition EMPLOYEE_10_JOB_MAGAGER tablespace LS6_BILL_DATA;

alter table EMP_BB move subpartition EMPLOYEE_10_JOB_DEFAULT tablespace LS6_BILL_DATA;


select * from user_tab_subpartitions t WHERE t.subpartition_name in ('EMPLOYEE_10_JOB_MAGAGER','EMPLOYEE_10_JOB_DEFAULT');

alter table EMP_BB move partition EMPLOYEE_DEPTNO_10 tablespace LS6_BILL_DATA;

alter table EMP_RANGE truncate partition  TEST_RANGE_SAL_02;

SELECT * FROM user_tab_partitions t WHERE t.partition_name='TEST_RANGE_SAL_01';

SELECT * FROM emp_range;

alter table EMP_BB truncate subpartition  TEST_RANGE_SAL_02;
alter table EMP_BB truncate subpartition EMPLOYEE_30_JOB_DEFAULT;

SELECT * FROM EMP_BB subpartition (EMPLOYEE_30_JOB_DEFAULT);

--��������ʧЧ�Ĳ���
����               ȫ������              ��������
truncate           ʧЧ                   ��Ӱ��
drop               ʧЧ                   ��Ӱ��
split              ʧЧ                   �������ؽ�   alter index idx_aaa rebulid;
add                ��Ӱ��                 ��Ӱ��
exchange           ʧЧ                   ��Ӱ��

����ʧЧ�ķ�����
alter table part_tab_trunc truncate partition p1 update global indexes;

--���ڷ�����������˵��
����������з��������ģ���ô��������ʹ�õ�������������������з�����������£���ô��ѯ�ͺܿ졣
������Ȼʹ�÷���������û���õ�����������ô���൱��ɨ���˱���������ȫ�����������Բ�ѯЧ�ʿ϶�����ͨ��Ҫ��������������ǰѱ���������Ϊȫ��������

--������Ǩ�Ʒ�����
--����������DBLINK�ķ����鿴Ŀ���ķ��������ǿ��Բ鿴������
һ����ͼ������
1����Ŀ��˴�����Ӧ�ķ�������ͼ --Դ��ִ�� 
SELECT 'create view  dzdz.par_HDZFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
  
2����dblink������Ŀ��ⴴ����Ӧ�ı� --Դ�����ɽű���Ŀ���ִ��
SELECT 'create table dzdz.par_HDZFP_'||t.PARTITION_NAME||' as select * from dzdz.par_HDZFP_'||t.PARTITION_NAME||'@sjyy_dzdz;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
 
3����Ŀ���ִ�з�������
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_HDZFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
 
4������ÿ������������
DECLARE
    V_SQL   VARCHAR2(1000);
    V_COUNT NUMBER := 0;
BEGIN
    FOR I IN (SELECT * FROM dba_TAB_PARTITIONS WHERE table_owner='HX_SB' AND TABLE_NAME = 'SB_ZZS_YBNSR_FB3_YSFWKCXM') LOOP
        V_SQL := 'SELECT COUNT(*) FROM ' ||I.table_owner||'.'||I.TABLE_NAME || ' PARTITION(' ||
                 I.PARTITION_NAME || ')';
        EXECUTE IMMEDIATE V_SQL INTO V_COUNT;
        DBMS_OUTPUT.PUT_LINE(I.PARTITION_NAME||':   '||V_COUNT);
    END LOOP;
END;

5�����д�����������
create index SJYY.IDX_ZZS_YBNSR_FB3_YSFWKCXMSJ on SJYY.SB_ZZS_YBNSR_FB3_YSFWKCXM (SJTB_SJ)
  nologging  LOCAL PARALLEL 20;

6��ȡ������
select 'alter table '||owner||'.'||table_name||' noparallel;' from dba_tables where degree not in(0,1) union all
 select 'alter index '||owner||'.'||index_name||' noparallel;'  from  dba_indexes  where degree not in('0','1','DEFAULT');
 
7����Դ��ɾ����ͼ
SELECT 'DROP VIEW '||tt.OWNER||'.'||tt.VIEW_NAME||';' FROM ( 
SELECT * FROM dba_views t WHERE t.OWNER='DZDZ' AND t.VIEW_NAME LIKE 'PAR_%')tt;

--ɾ��Ŀ������ʱ��
SELECT 'DROP table '||tt.OWNER||'.'||tt.table_NAME||';' FROM ( 
SELECT * FROM dba_tables t WHERE t.OWNER='DZDZ' AND t.TABLE_NAME LIKE 'PAR_%')tt;
8��ͳ����Ϣ�ռ�


##ora-14402 ����range�����ĸ��£����¿����
��Դ����⣬��Ҫ����row movement
alter table tab_name enable row movement; 

--����rename
 SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' rename to '||t.TABLE_NAME||'_20180626bak;' FROM dba_tables t WHERE t.OWNER='DZDZ'





--������DZDZ
�滻���� DZDZ_HWXX_DZFP  -->   DZDZ_HWXX_DZFP
�滻������ par_HWXX_DZFP_  -->  par_HWXX_DZFP_
1����Ŀ��˴�����Ӧ�ķ�������ͼ --Դ��ִ�� 
SELECT 'create view  dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM all_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;
  
2����dblink������Ŀ��ⴴ����Ӧ�ı� --Դ�����ɽű���Ŀ���ִ��
SELECT 'create table dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||' as select * from fangxin.par_HWXX_ZZSFP_'||t.PARTITION_NAME||'@sjyy_dzdz_fangxin;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;
 
3����Ŀ���ִ�з�������
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;