--自动创建分区表  ##分区自动添加完成后，当有新的分区键的数据插入时，分区才会自动添加
--首先必须是rang分区
1、固定日期
partition by range (KPYF)                    
(                                            
  partition SYS_000 values less than (201410)    
--自动加1
alter table cz.dzdz_fpxx_zzsfp set interval(1);  

2、日期型写法
partition by range (sales_dt)                                         
(                                                                     
partition p1107 values less than (to_date('2012-08-01','yyyy-mm-dd')) 
--月份加1
alter table sales set interval(NUMTOYMINTERVAL(1,'month'));

--按天分区加1
对于day、hour、minute、second使用的是numtodsinterval函数，方法和numtoyminterval一样
alter table sales set interval(numtodsinterval(1,'day'));

--轮询指定的存储表空间
ALTER TABLE cz.dzdz_fpxx_zzsfp SET store IN(tablespace_name1,tablespace_name2);  

--批量添加 日期
SELECT DISTINCT  'alter table '||xx.table_owner||'.'||xx.table_name || ' set interval(1);' comm_sql FROM (SELECT DISTINCT t.table_owner,t.table_name,t.tablespace_name fROM dba_tab_partitions t WHERE t.table_owner NOT IN ('CZ','SYS') AND t.partition_name LIKE '%SYS%' AND t.table_name NOT LIKE 'BIN%' ORDER BY 2
) xx ; 
--批量添加 表空间轮询
SELECT DISTINCT  'alter table '||xx.table_owner||'.'||xx.table_name || ' set store IN ('||to_char(WM_CONCAT(XX.TABLESPACE_NAME))||');' comm_sql FROM (SELECT DISTINCT t.table_owner,t.table_name,t.tablespace_name fROM dba_tab_partitions t WHERE t.table_owner NOT IN ('CZ','SYS') AND t.partition_name LIKE '%SYS%' AND t.table_name NOT LIKE 'BIN%' ORDER BY 2
) xx  GROUP BY xx.table_owner,xx.table_name ; 

--创建表时自带分区扩展
create table xx(c1,c2)
partition by range(c2)
interval(numtoyminterval (1,'month')) store in(tablespace1,tablespace2,....,tablespacen)
(partition xx......,
 partition xx......
)                                            

//分区类型
--范围分区表创建-range
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
       
--list分区
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
  
--HASH分区
create table hash_part_tab (id number,deal_date date,area_code number,contents varchar2(4000))
 partition by hash (deal_date)
 PARTITIONS 12                --分区个数
 ;      
       
 
--组合分区
create table range_list_part_tab (id number,deal_date date,area_code number,　contents varchar2(4000))
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
   
--分区维护
分区查询
select count(*) from part_tab_trunc partition(p1);

分区truncate
alter table part_tab_trunc truncate partition p1 ;

分区drop
alter table part_tab_drop drop partition p1 ;

分区拆分split
alter table part_tab_split SPLIT PARTITION P_MAX  at (30000) into (PARTITION p3  ,PARTITION P_MAX);
alter table part_tab_split SPLIT PARTITION P_MAX  at (40000) into (PARTITION p4  ,PARTITION P_MAX);

分区添加
--注意：必须要把默认分区去掉，再add分区，再增加默认分区,这里可能丢数据!
--drop分区的时候需要先看看max分区里面有没有数据，没有数据才可以删除
select count(*) from part_tab_add partition(p_max);
alter table part_tab_add  drop partition p_max;  --删除最后一个分区
alter table part_tab_add  add PARTITION p6 values less than (60000);
alter table part_tab_add  add PARTITION p_max  values less than (maxvalue);

分区交换 --其中including indexes  可选，为了保证全局索引不要失效
alter table part_tab_exch exchange partition p1 with table normal_tab including indexes update global indexes;

分区合并
alter table EMP_RANGE merge partitions TEST_RANGE_SAL_01,TEST_RANGE_SAL_02 into partition TEST_RANGE_SAL_00;
      
分区移动
alter table EMP_BB move partition EMPLOYEE_DEPTNO_10 tablespace LS6_BILL_DATA;


--移动混合分区的表
在移动混合分区的表时，不能直接移动分区，需要先移动子分区，然后再修改所属分区。

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

--分区索引失效的操作
操作               全局索引              分区索引
truncate           失效                   无影响
drop               失效                   无影响
split              失效                   索引需重建   alter index idx_aaa rebulid;
add                无影响                 无影响
exchange           失效                   无影响

避免失效的方法：
alter table part_tab_trunc truncate partition p1 update global indexes;

--关于分区表索引的说明
如果分区表有分区索引的，那么条件中有使用到分区索引的情况，且有分区键的情况下，那么查询就很快。
若、虽然使用分区表，但是没有用到分区键，那么就相当于扫描了本地索引的全部分区，所以查询效率肯定比普通表还要慢，解决方法就是把本地索引改为全局索引。

--分区表迁移方法：
--分区表不能用DBLINK的方法查看目标库的分区，但是可以查看整个表。
一、视图创建法
1、在目标端创建对应的分区的视图 --源库执行 
SELECT 'create view  dzdz.par_HDZFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
  
2、用dblink方法在目标库创建对应的表 --源库生成脚本，目标库执行
SELECT 'create table dzdz.par_HDZFP_'||t.PARTITION_NAME||' as select * from dzdz.par_HDZFP_'||t.PARTITION_NAME||'@sjyy_dzdz;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
 
3、在目标库执行分区交换
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_HDZFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
 
4、稽核每个分区的数量
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

5、并行创建本地索引
create index SJYY.IDX_ZZS_YBNSR_FB3_YSFWKCXMSJ on SJYY.SB_ZZS_YBNSR_FB3_YSFWKCXM (SJTB_SJ)
  nologging  LOCAL PARALLEL 20;

6、取消并行
select 'alter table '||owner||'.'||table_name||' noparallel;' from dba_tables where degree not in(0,1) union all
 select 'alter index '||owner||'.'||index_name||' noparallel;'  from  dba_indexes  where degree not in('0','1','DEFAULT');
 
7、在源库删除视图
SELECT 'DROP VIEW '||tt.OWNER||'.'||tt.VIEW_NAME||';' FROM ( 
SELECT * FROM dba_views t WHERE t.OWNER='DZDZ' AND t.VIEW_NAME LIKE 'PAR_%')tt;

--删除目标库的临时表
SELECT 'DROP table '||tt.OWNER||'.'||tt.table_NAME||';' FROM ( 
SELECT * FROM dba_tables t WHERE t.OWNER='DZDZ' AND t.TABLE_NAME LIKE 'PAR_%')tt;
8、统计信息收集


##ora-14402 由于range分区的更新，导致跨分区
针对次问题，需要开启row movement
alter table tab_name enable row movement; 

--批量rename
 SELECT 'alter table '||t.OWNER||'.'||t.TABLE_NAME||' rename to '||t.TABLE_NAME||'_20180626bak;' FROM dba_tables t WHERE t.OWNER='DZDZ'





--生产库DZDZ
替换表名 DZDZ_HWXX_DZFP  -->   DZDZ_HWXX_DZFP
替换分区名 par_HWXX_DZFP_  -->  par_HWXX_DZFP_
1、在目标端创建对应的分区的视图 --源库执行 
SELECT 'create view  dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM all_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;
  
2、用dblink方法在目标库创建对应的表 --源库生成脚本，目标库执行
SELECT 'create table dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||' as select * from fangxin.par_HWXX_ZZSFP_'||t.PARTITION_NAME||'@sjyy_dzdz_fangxin;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;
 
3、在目标库执行分区交换
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;