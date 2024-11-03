select table_name,
partition_name,
last_analyzed,
partition_position,
num_rows
from user_tab_statistics t
where table_name ='RANGE_PART_TAB';
�ű�7-15��������ͳ����Ϣ

--------------------------------------------------------------------------------------------

3�� �������������
select partitioning_type,
subpartitioning_type,
partition_count
from user_part_tables
where table_name ='RANGE_PART_TAB';
�ű�7-16����ѯ��������Ϣ
��ѯ���������н�����
select sum(bytes) / 1024 / 1024
from user_segments
where segment_name ='RANGE_PART_TAB';
�ű�7-18����ѯ������ߴ�

--------------------------------------------------------------------------------------------


��ѯ������������Ĵ�С�������
select partition_name,
segment_type,
bytes
from user_segments
where segment_name ='RANGE_PART_TAB';
�ű�7-19����ѯ������������Ĵ�С�������

--------------------------------------------------------------------------------------------


��ѯ������ͳ����Ϣ�ռ����
select table_name,
partition_name,
last_analyzed,
partition_position,
num_rows
from user_tab_statistics t
where table_name ='RANGE_PART_TAB'
�ű�7-20����ѯ������ͳ����Ϣ�ռ����

--------------------------------------------------------------------------------------------


��ѯ�������������
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
�ű�7-21����ѯ�������������

--------------------------------------------------------------------------------------------


��ѯ����������Щ��������
select index_name,
column_name,
column_position
from user_ind_columns
where table_name = 'RANGE_PART_TAB';
�ű�7-22����ѯ����������Щ��������

--------------------------------------------------------------------------------------------


��ѯ�������������С
select segment_name,segment_type,sum(bytes)/1024/1024
from user_segments
where segment_name in
(select index_name
from user_indexes
where table_name ='RANGE_PART_TAB')
group by segment_name,segment_type ;
�ű�7-23����ѯ�������������С

--------------------------------------------------------------------------------------------


��ѯ�����������εķ������
select segment_name
partition_name,
segment_type,
bytes
from user_segments
where segment_name in
(select index_name
from user_indexes
where table_name ='RANGE_PART_TAB');
�ű�7-24����ѯ�����������εķ������

--------------------------------------------------------------------------------------------


��ѯ�������������ͳ����Ϣ
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

