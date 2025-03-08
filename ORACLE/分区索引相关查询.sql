select table_name,
partition_name,
last_analyzed,
partition_position,
num_rows
from user_tab_statistics t
where table_name ='RANGE_PART_TAB';
脚本7-15　分区与统计信息

--------------------------------------------------------------------------------------------

3） 分区相关数据字
select partitioning_type,
subpartitioning_type,
partition_count
from user_part_tables
where table_name ='RANGE_PART_TAB';
脚本7-16　查询分区表信息
查询分区表哪列建分区
select sum(bytes) / 1024 / 1024
from user_segments
where segment_name ='RANGE_PART_TAB';
脚本7-18　查询分区表尺寸

--------------------------------------------------------------------------------------------


查询分区表各分区的大小与分区名
select partition_name,
segment_type,
bytes
from user_segments
where segment_name ='RANGE_PART_TAB';
脚本7-19　查询分区表各分区的大小与分区名

--------------------------------------------------------------------------------------------


查询分区表统计信息收集情况
select table_name,
partition_name,
last_analyzed,
partition_position,
num_rows
from user_tab_statistics t
where table_name ='RANGE_PART_TAB'
脚本7-20　查询分区表统计信息收集情况

--------------------------------------------------------------------------------------------


查询分区表索引情况
select table_name,
index_name,
last_analyzed,
blevel,
num_rows,
leaf_blocks,
distinct_keys,
status
from user_indexes
where table_name ='RANGE_PART_TAB';
脚本7-21　查询分区表索引情况

--------------------------------------------------------------------------------------------


查询分区表在哪些列有索引
select index_name,
column_name,
column_position
from user_ind_columns
where table_name = 'RANGE_PART_TAB';
脚本7-22　查询分区表在哪些列有索引

--------------------------------------------------------------------------------------------


查询分区表各索引大小
select segment_name,segment_type,sum(bytes)/1024/1024
from user_segments
where segment_name in
(select index_name
from user_indexes
where table_name ='RANGE_PART_TAB')
group by segment_name,segment_type ;
脚本7-23　查询分区表各索引大小

--------------------------------------------------------------------------------------------


查询分区表索引段的分配情况
select segment_name
partition_name,
segment_type,
bytes
from user_segments
where segment_name in
(select index_name
from user_indexes
where table_name ='RANGE_PART_TAB');
脚本7-24　查询分区表索引段的分配情况

--------------------------------------------------------------------------------------------


查询分区表索引相关统计信息
select t2.table_name,
t1.index_name,
t1.partition_name,
t1.last_analyzed,
t1.blevel,
t1.num_rows,
t1.leaf_blocks,
t1.status
from user_ind_partitions t1, user_indexes t2
where t1.index_name = t2.index_name
and t2.table_name='RANGE_PART_TAB';

