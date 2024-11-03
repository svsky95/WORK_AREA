@@DZDZ.DZDZ_FPXX_DZFP	211916994
--DZDZ.DZDZ_FPXX_ESCFP	509774
--DZDZ.DZDZ_FPXX_JDCFP	4020710
#DZDZ.DZDZ_FPXX_JSFP	49647014
@@DZDZ.DZDZ_FPXX_PTFP	234971165
--DZDZ.DZDZ_FPXX_TXFFP	5168359
#DZDZ.DZDZ_FPXX_YDK	63243440
#DZDZ.DZDZ_FPXX_ZZSFP	111782811
@@DZDZ.DZDZ_HWXX_DZFP	518538101
#DZDZ.DZDZ_HWXX_JSFP	55861166
@@DZDZ.DZDZ_HWXX_PTFP	417849675
--DZDZ.DZDZ_HWXX_TXFFP	5167865
@@DZDZ.DZDZ_HWXX_ZZSFP	482812839

insert into DZDZ.DZDZ_FPXX_ESCFP  select * from DZDZ.DZDZ_FPXX_ESCFP@sjyy_dzdz;
insert into DZDZ.DZDZ_FPXX_JDCFP  select * from DZDZ.DZDZ_FPXX_JDCFP@sjyy_dzdz;
insert into DZDZ.DZDZ_FPXX_TXFFP  select * from DZDZ.DZDZ_FPXX_TXFFP@sjyy_dzdz;
insert into DZDZ.DZDZ_HWXX_TXFFP  select * from DZDZ.DZDZ_HWXX_TXFFP@sjyy_dzdz;

create table DZDZ.DZDZ_FPXX_JSFP_1 as select * from DZDZ.DZDZ_FPXX_JSFP@sjyy_dzdz;
create table DZDZ.DZDZ_FPXX_YDK_1 as select * from  DZDZ.DZDZ_FPXX_YDK@sjyy_dzdz;
create table DZDZ.DZDZ_HWXX_JSFP_1 as select * from DZDZ.DZDZ_HWXX_JSFP@sjyy_dzdz;
create table DZDZ.DZDZ_FPXX_ZZSFP_1 as select * from DZDZ.DZDZ_FPXX_ZZSFP@sjyy_dzdz;


insert into DZDZ.DZDZ_FPXX_JSFP select * from DZDZ.DZDZ_FPXX_JSFP_1;
insert into DZDZ.DZDZ_FPXX_YDK  select * from DZDZ.DZDZ_FPXX_YDK_1;
insert into DZDZ.DZDZ_HWXX_JSFP select * from DZDZ.DZDZ_HWXX_JSFP_1;
insert into DZDZ.DZDZ_FPXX_ZZSFP select * from DZDZ.DZDZ_FPXX_ZZSFP_1;


select /*+parallel 4*/ count(*) from DZDZ.DZDZ_FPXX_JSFP;
select /*+parallel 4*/ count(*) from DZDZ.DZDZ_FPXX_YDK ;
select /*+parallel 4*/ count(*) from DZDZ.DZDZ_HWXX_JSFP;


drop table DZDZ.DZDZ_FPXX_JSFP_1;
drop table DZDZ.DZDZ_FPXX_YDK_1 ;
drop table DZDZ.DZDZ_HWXX_JSFP_1;



替换表名 DZDZ_FPXX_DZFP  -->   DZDZ_FPXX_DZFP    
替换分区名 par_FPXX_DZFP_  -->  par_FPXX_DZFP_
1、在目标端创建对应的分区的视图 --源库执行 
SELECT 'create view  dzdz.par_FPXX_DZFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM all_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_FPXX_DZFP' ORDER BY t.partition_name;
  
2、用dblink方法在目标库创建对应的表 --源库生成脚本，目标库执行
SELECT 'create table dzdz.par_FPXX_DZFP_'||t.PARTITION_NAME||' as select * from DZDZ.par_FPXX_DZFP_'||t.PARTITION_NAME||'@sjyy_dzdz;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_FPXX_DZFP' ORDER BY t.partition_name;
 
3、在目标库执行分区交换
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_FPXX_DZFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_FPXX_DZFP' ORDER BY t.partition_name;
 

替换表名 DZDZ_FPXX_PTFP  -->   DZDZ_FPXX_PTFP 
替换分区名 par_FPXX_PTFP_  -->  par_FPXX_PTFP_
1、在目标端创建对应的分区的视图 --源库执行 
SELECT 'create view  dzdz.par_FPXX_PTFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM all_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_FPXX_PTFP' ORDER BY t.partition_name;
  
2、用dblink方法在目标库创建对应的表 --源库生成脚本，目标库执行
SELECT 'create table dzdz.par_FPXX_PTFP_'||t.PARTITION_NAME||' as select * from DZDZ.par_FPXX_PTFP_'||t.PARTITION_NAME||'@sjyy_dzdz;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_FPXX_PTFP' ORDER BY t.partition_name;
 
3、在目标库执行分区交换
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_FPXX_PTFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_FPXX_PTFP' ORDER BY t.partition_name;
 
 
替换表名 DZDZ_HWXX_DZFP  -->   DZDZ_HWXX_DZFP 
替换分区名 par_HWXX_DZFP_  -->  par_HWXX_DZFP_
1、在目标端创建对应的分区的视图 --源库执行 
SELECT 'create view  dzdz.par_HWXX_DZFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM all_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
  
2、用dblink方法在目标库创建对应的表 --源库生成脚本，目标库执行
SELECT 'create table dzdz.par_HWXX_DZFP_'||t.PARTITION_NAME||' as select * from DZDZ.par_HWXX_DZFP_'||t.PARTITION_NAME||'@sjyy_dzdz;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
 
3、在目标库执行分区交换
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_HWXX_DZFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_DZFP' ORDER BY t.partition_name;
 

替换表名 DZDZ_HWXX_PTFP  -->   DZDZ_HWXX_PTFP 
替换分区名 par_HWXX_PTFP_  -->  par_HWXX_PTFP_
1、在目标端创建对应的分区的视图 --源库执行 
SELECT 'create view  dzdz.par_HWXX_PTFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM all_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_HWXX_PTFP' ORDER BY t.partition_name;
  
2、用dblink方法在目标库创建对应的表 --源库生成脚本，目标库执行
SELECT 'create table dzdz.par_HWXX_PTFP_'||t.PARTITION_NAME||' as select * from DZDZ.par_HWXX_PTFP_'||t.PARTITION_NAME||'@sjyy_dzdz;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_PTFP' ORDER BY t.partition_name;
 
3、在目标库执行分区交换
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_HWXX_PTFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_PTFP' ORDER BY t.partition_name;
 
 
替换表名 DZDZ_HWXX_ZZSFP  -->   DZDZ_HWXX_ZZSFP 
替换分区名 par_HWXX_ZZSFP_  -->  par_HWXX_ZZSFP_
1、在目标端创建对应的分区的视图 --源库执行 
SELECT 'create view  dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||' as select * from '||t.table_owner||'.'||t.table_name|| ' partition (' || T.PARTITION_NAME || ');'
  FROM all_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and  T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;
  
2、用dblink方法在目标库创建对应的表 --源库生成脚本，目标库执行
SELECT 'create table dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||' as select * from DZDZ.par_HWXX_ZZSFP_'||t.PARTITION_NAME||'@sjyy_dzdz;'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;
 
3、在目标库执行分区交换
SELECT 'alter table '||t.table_owner||'.'||TABLE_NAME|| ' exchange partition '||t.PARTITION_NAME|| ' with table dzdz.par_HWXX_ZZSFP_'||t.PARTITION_NAME||';'
  FROM DBA_TAB_PARTITIONS T
 WHERE t.table_owner='DZDZ' and T.TABLE_NAME = 'DZDZ_HWXX_ZZSFP' ORDER BY t.partition_name;
