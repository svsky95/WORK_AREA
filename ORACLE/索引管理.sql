#####索引管理#####
--索引说明
--建索引语句
##PS:对于oracle online创建索引的说明
当数据的表，在执行dml语句的时候（insert、delete、update），首先先拿到dml锁，这时其实，在online创建索引的时候，还有等待。
之因为索引创建oneline的时候可以完成，是因为，dml操作已经提交了，这个时候，创建索引才能完成。
那么当dml语句，一直持有锁的时候，online的创建的索引就会一直的等待，所以，不论dml如何的操作，online创建索引，都是有等待的。 
#全局索引
create index idx_name on table_name(cloumn_name1,cloumn_name2) tablespace tablespace_name nologging parallel 4 online;
alter idex_name logging;

#本地索引
create index dzdz.idx_dkxsfsbh_WHSJ on dzdz.DZDZ_FPXX_PTFP(DK_XSFSBH,FPZT_WHSJ) local parallel 8 nologging online;

-是否走分区裁剪的条件
PARTITION RANGE ITERATOR --分区迭代扫描，未走分区裁剪
PARTITION RANGE SINGLE   --分区唯一扫描，走分区裁剪

##三大特性
1、索引的高度比较低
2、索引本身存储着列的值及对应了的ROWID 
3、索引的是有序性

##不走索引的原因
1、列的数据分布不均--需收集列的直方图
2、有空值，但是与一个不为空的列，做复合索引，就可以走索引   create index cz.tab_a on (col_null,1);
3、创建索引，把选择性好的放在前导列上。
-指定不为空
select * from aa where object_id is not null;
-定义列不能为空
alter table t modify object_id not null;
3、绑定变量窥探
导致第一次的变量的选择差，占表的大部分数据，导致走全表扫描，自适应游标可解决
4、索引列的运算
如upper(aaa)=bbb,这样aaa就不走索引
5、索引失效
6、条件上发生隐式转换
保证字段类型与条件的类型一致
PS:object_id 是number 而SQL语句是，object_id=1000
1000是number
7、条件对应索引列不在复合索引第一位
8、条件对应索引列选择度不够高
9、统计信息不准确
10、使用<>、!=不能够过滤大量数据的情况下
11、like 'somevalue%' 走索引。like '%somevalue%'和like '%somevalue'均不走索引
12、索引列trunc、substr、to_date、to_char和instr无法使用索引。
where trunc(hirdate) = '01-may-01';改写走索引的方法：where hirdate >to_date('01-may-01')
13、字段类型与谓词条件不一致，SELECT * FROM cz.test0001 t WHERE t.object_id=1000，其中object_id是varchar2,这时就走了全表扫描。
但是t.object_id='1000'，就走索引

-索引的缺点
1、增删改开销大，表中的索引越多，更新就越慢，因为要维护索引的有序性
2、由于新数据都在索引块的最右边，而一般查询新数据较多的情况下，就会产生索引块竞争
3、建立索引会锁表 需提取索引列及ROWID，如果不锁表，一直提取数据，那建立索引什么时候才能结束 可以使用online建立索引，并且不会阻塞DML


-符合索引前缀的问题
建立符合索引时，应该考虑前导列及等值查询优先的问题
1、把查询为等值条件的，放在前面，范围查询的放在后面
2、把选择性差的放在前面

-索引关联
驱动表，大多为小表或者大表经过选择性较好的条件后，筛除掉大多数的数据。
被驱动表：大表或者分区表

每张表，在这个SQL中，只能用一个索引，那么在驱动表的时候，就会选择有查询条件的索引，过滤掉大部分的数据。
而被驱动表，大多数是与驱动表关联，那么关联条件，就是创建索引的依据。
切记不要把分区键，建立在复合索引中，容易产生INDEX SKIP SCAN，导致cost较高。

--位图索引
位图索引实际存储的是比特值，适合于列数据重复性较高的情况。
在重复性较高的情况下，COST要比复合的B-tree索引的效率要高。
但是容易出现死锁，所以位图索引更适合列没有变化，重复度极高，比如，男女，地市编号等。
--如下的查询条件
select *
from t
where gender='M'
and location in (1,10,30)
and age_group='child';

create bitmap index gender_idx on t(gender);
create bitmap index location_idx on t(location);
create bitmap index age_group_idx on t(age_group);

--函数索引

--反向建索引
由于新数据都在索引块的最右边，而一般查询新数据较多的情况下，就会产生索引块竞争，反向建索引可以减少块的争用。
create index idx_reverse_objname on t(reverse(object_name));
set autotrace on
select object_name,object_id from t where reverse(object_name) like reverse('%LJB');

##隐藏索引##
隐藏（不可见）索引（invisible indexes）是oracle 11g 的一项新特性，该特性允许索引以隐藏的方式创建或者创建以后标记为隐藏。很神奇吧，oracle 也喜欢玩潜水。隐藏索引对优化器是不可见的，除非显式的在实例级或者会话级设置optimizer_use_invisible_indexes 初始化参数为true。隐藏索引的用处在于，可以当作索引删除或者设置为不可用的一种代替方式。

alter index emp.emp_idx invisible/visible; --invisible不可见 
即便是指定使用hit +index() 也不可能生效
但是通过此方法，来减少insert插入数据时的，维护索引的有序性，是不能的。  
由于是真实存在的索引，所以在dba_indexes即dba_segment及dba_objects 中是可以看到的。
SELECT t.owner,t.index_name,t.visibility FROM dba_indexes t WHERE t.index_name='IDX_DZDZ_HWXX_PTFP_TSLSH';


##分区索引与本地索引创建##
数据表空间sing_dt01----sing_dt02
create tablespace sing_dt01 datafile '/home/oracle/oradata/**z/sing_dt01_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt02 datafile '/home/oracle/oradata/**z/sing_dt02_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt03 datafile '/home/oracle/oradata/**z/sing_dt03_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt04 datafile '/home/oracle/oradata/**z/sing_dt04_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt05 datafile '/home/oracle/oradata/**z/sing_dt05_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt06 datafile '/home/oracle/oradata/**z/sing_dt06_01.dbf' size 4096m autoextend on next 100m;
create tablespace sing_dt07 datafile '/home/oracle/oradata/**z/sing_dt07_01.dbf' size 4096m autoextend on next 100m;

索引表空间sing_idx01----sing_idx07
create tablespace sing_idx01 datafile '/home/oracle/oradata/**z/sing_idx01_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx02 datafile '/home/oracle/oradata/**z/sing_idx02_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx03 datafile '/home/oracle/oradata/**z/sing_idx03_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx04 datafile '/home/oracle/oradata/**z/sing_idx04_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx05 datafile '/home/oracle/oradata/**z/sing_idx05_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx06 datafile '/home/oracle/oradata/**z/sing_idx06_01.dbf' size 1024m autoextend on next 100m;
create tablespace sing_idx07 datafile '/home/oracle/oradata/**z/sing_idx07_01.dbf' size 1024m autoextend on next 100m;

创建分区表
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

创建对应的索引--local
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



当20120708的时候需要将分区P1和对应的索引分区drop掉 然后，将新的partition重新使用表空间sing_dt01。
alter table FLR_SING_ASAC_AMT add partition p8 values less than ('20120709') tablespace sing_dt01;

问题是这个时候local索引的存储位置是表空间sing_dt01，能不能再add partition的时候就指定对应local索引分区的tablespace。

##虚拟索引##
虚拟索引(virtual index)是指没有创建对应的物理实体的索引。虚拟索引的目的，是在不必耗cpu,耗IO以及消耗大量存储空间去实际创建索引的情况，来判断一个索引是否能够对sql优化起到作用。

由于建立虚拟索引需要开启参数 “_use_nosegment_indexes”，所以一般是还在session 中进行设置，更换了会话，则参数不生效。
alter session set "_use_nosegment_indexes"=TRUE;

create index id_index on tt(object_id) nosegment; 

explain plan for select * from tt where object_id=54;

select * from table(dbms_xplan.display());

由于是虚拟索引，所以在dba_indexes即dba_segment中是找不到的，但是在dba_objects 中是可以看到的

SELECT * FROM Dba_Indexes t WHERE t.index_name='IDX_OBJECT_IDBB';

SELECT * FROM dba_objects t WHERE t.OBJECT_NAME='IDX_OBJECT_IDBB';

SELECT * FROM dba_segments t WHERE t.segment_name='IDX_OBJECT_IDBB';

##索引有效性监控##
为了监控索引是否被使用，以决定是否可以保留此索引
--开启索引  监控
ALTER INDEX cz.idx_object_id_cz MONITORING USAGE;
--关闭索引 监控
ALTER INDEX cz.idx_object_id_cz noMONITORING USAGE;
--查看使用情况
--注意，监控的时候，索引是分用户的，开启监控的索引在哪个用户下，就用哪个用户去查看v$object_usage的数据，换个用户是查看不到结果的。
SELECT * FROM  v$object_usage t WHERE t.index_name='IDX_DZDZ_HWXX_PTFP_TSLSH';	
INDEX_NAME                     TABLE_NAME                     MON USE START_MONITORING    END_MONITORING
------------------------------ ------------------------------ --- --- ------------------- -------------------
IDX_OBJECT_ID_CZ               CZ_TEST                        NO  YES 11/17/2017 14:46:19 11/17/2017 15:08:17	

其中USE  为 YES  使用过
                 为  NO   未使用过
START_MONITORING    
                  有时间，说明监控已经关闭


##索引的online创建##
在传统创建索引的过程中，会导致锁表，来保证在没有数据更新的前提下，保证索引可以创建完成，但是这样会导致锁表，来阻塞所有的DML及DDL操作。
用online方式的创建索引，不会导致锁表，但是当有数据插入时，online创建索引的方式，会等待数据插入完成，并且commit或roll back，后，才会创建完成，从而保证正常业务的进行。

CREATE INDEX idx_object_id_cz ON cz_test(object_id) parallel 8 ONLINE nologging;