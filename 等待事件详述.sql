--收获不止SQL优化
##出现问题时需要询问：
1、这个问题是一直以来都是这个样子，还是今天忽然出现。
2、今天或者昨晚做过什么大的操作，比如打补丁、升级等。
##等待事件案例
--表示有表空间不足的等待
statement suspended, wait error to be cleared 

--PX DEP Credit 并行导致    
由于表及索引设置了并行导致，可根据业务分时段的执行，适当去掉并行。

--gc buffer busy  热块导致
通过业务使程序访问同一个块，跑在不同的节点上，避免热块产生。

--RAC环境中大量read by other session
表示块太大或延迟较大，从而导致争用。可通过查看Segments by Physical Reads 来判断哪些表的竞争	 

--RAC环境中read by other session 


--日志等待有关
transaction较大，但是per transaction 较少，怀疑程序中存在循环，并且没有批量的提交，

--数据库的动态采样
由于没有在数据库的动态收集统计信息之内，建立和表，导致收集不到这张表的统计信息，可以在建立完表及索引后，手动收集，也可以让数据库动态采样。

--高速缓冲区的等待事件
##db file scattered read 
导致原因：
存在全表扫描或者快速索引扫描有关
但有时，需要查询的数据占全表的30%以上时，全表扫描可能比走索引的效率更高。

##db file sequential read 
导致原因：
单块读的操作，或者选择的索引效率不高
从读取开始，增加SGA中buffer cache的大小，避免每次都从硬盘中去读数
优化sql语句，减少不必要的块读取
table access full
index full scan
index range scan
index fast full scan


##latch:cache buffers chains
导致原因：
-低效的SQL
多个进程同时扫描大范围的索引和表，适当的减少扫描范围及优化查询。
-hot block
较难解决，减少块的大小，可以减少块中容纳的行数，从而来解决热块，但是同样的也增大了资源的开销，就是要扫描更多的块。

##latch:cache buffers lru chains
导致原因：
-低效的SQL --同时伴有 db file scattered read<数据文件分散读取>、latch:cache buffers chains的发生
多个进程的低效的不同的SQL语句过多的请求空闲的缓冲区
适当创建索引，并取消全表扫描

##read by other session --同时伴有db file scattered read、db file sequential read
select/select 引起的buffer lock
多个会话同时查询相同的块，从数据文件读入buffer cache，但是当第二次执行时buffer cache已经有获取的数据，由于获得了buffer lock，所以等待消失。
解决方法：
1、优化SQL，以便以最小的I/O获得所需的结果。
2、若SGA或buffer cache过小，可以适当调大。

##free buffer wait
当没有空闲的缓冲区时，就会向DBWR发出写入请求，直到把脏数据块写入到数据文件为止，这个过程中会发生free buffer wait。

导致原因#
低效的SQL  会请求过多的空闲缓冲区
过小的高速缓冲区  较少的空闲缓冲区请求
DBWR的性能下降

--库高速缓冲区上的等待事件
##latch:share pool 

导致原因：
hard parsing 硬解析过多 --使用绑定变量解决

##latch:ibrary cache 
导致原因:
hard parsing 硬解析过多 --使用绑定变量解决

##TX锁是对事务的保护，事务结束（执行commit 或 rollback）会释放
-enq:TX-row lock contention 
欲修改特定的行
修改唯一键或主键
修改位图索引的列值
导致原因:
多个会话同时修改行，update
insert 是不会引起enq:TX-row lock contention 

-enq:TX-allocate ITL entry
修改块ITL上想要修改的登记条目

-enq:TX-index contention
索引叶节点上发生的分割

--段上的等待事件
##enq:HW-contention 
为了防止多个进程同时修改HWM（高水位线）提供的锁。
导致原因：
大量的insert
大量的update，导致回滚段的高水位线急速升高，空间扩张

--I/O 上的等待事件
##db file scattered read 
oracle在执行全表扫描或者全索引扫描时，一次性读取多个块的数据，每次执行多块读，都会存在等待。
SQL> show parameter db_file

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_file_multiblock_read_count        integer     93

解决方法：
--应用程序
1、尽量避免全表扫描机索引全扫描。判断全表扫描是否有利还是index range scan有利。
--oracle内存层
1、buffer cache过小，会导致重复的物理I/O，同时也会伴随free buffer waits等待事件出现的几率增高。
2、使用分区表

##db file sequential read 
每次发生单块读时，就会有次等待事件的发生。
导致原因：
低效的索引扫描，行迁移，行连接
使用选择性较差的索引是发生等待的主要原因

解决方法：
--应用程序
改善索引
--oracle内存层
1、buffer cache过小，会导致重复的物理I/O，同时也会伴随free buffer waits等待事件出现的几率增高。

##direct path read 
发生并行查询时，产生此等待事件

##direct path write
产生directload工作（create table as select *,insert /*+append*/ ）

##direct path read temp direct path write temp 
在临时区域的排序动作的读写，会产生此等待事件。
基本上与PGA有关，调大pga_aggregate_target就可解决。
调整标准：
OLTP：pga_aggregate_target=(total_mem*80%)*20%
OLAP/DSS：pga_aggregate_target=(total_mem*80%)*50%

##direct path read temp(lob) direct path write temp(lob)

##db file parallel write 
经过高速缓冲区的所有数据是通过DBWR写入到磁盘的。DBWR请求写入的脏数据块的I/O后，在此期间是会有此等待。
若此等待经常出现，则可以判断与数据相关的IO下降问题
同时会经历free buffer waits事件或write complete waits事件
解决方法：
调整DBWR的进程数量
调整DB_writer-processes的参数值，推荐CPU_COUNT/8 数量增加采用异步的方式。

##control file parallel write
请求控制文件的更新进程知道更新结束，期间有此等待事件。

导致原因：
1、日志文件切换频繁
日志文件过小，经常发生日志的切换，每当发生日志的切换时，需要对控制文件进行更新，此等待事件就会延长。
2、频繁的检查点
默认的fast_start_mttr_target的值为0，表示关闭自动检查点功能

##log file sync
指定下达后，把redo buffer中的提交数据写入到联机重做日志中，直到LGWR写入成功，期间会有此等待时间的出现。

导致原因：
1、提交次数是否过多
每执行一次提交，就会发生一次log file sync的等待，大量的提交，就可能导致广泛的等待出现。

2、磁盘的I/O
硬盘的写入性能，会导致等待时间的延长，因此建议，把重做日志放在比较快的磁盘上，并且与数据文件或控制文件放在不同的磁盘上是很有必要的。

3、减少重做日志文件写入的数据量
特别是在大而长的事物上减少重做数据量，就会减少后台写入的工作量，争用也可解除。

解决方法：
1、是否对于不重要的数据，使用nologging。
2、将索引修改为unusable状态，生成数据、以nologging方式重建。
3、适量增大redo buffer。
4、把redo log 放在较快的存储上，来提高写入的性能。
由于lGWR是单进程，为了解决写入的问题，在12c后，会有LGNN slave进程帮助redo buffer 到redo log的写入。 

##log file parallel write
LGWR将redo buffer中的内容记录到重做日志文件，执行必要的IO调用后，在工作结束期间，就会有等待时间的出现。
与log file sync解决方法基本相同。

##log buffer space
欲向redo buffer上写入重做记录，为了获得redo buffer中的必要空间，若没有适当的空间，就会发生此等待。

重做数据量 大于 redo buffer时，由于没有空闲的空间，发生log buffer space，建议适当调大redo buffer;
log buffer space 和 log file switch conpletion 等待同时出现，若重做日志文件过小，则log file switch conpletion等待会增加，在日志切换完成后会出现log buffer space。
为了减少log buffer space,增大了redo buffer的大小时，log file sync 等待可能会增加，因为批量写入日志文件的数据量过大，造成等待。

##log file switch completion,log file switch checkpoint incomplete,log file switch archiving needed
当redo log是active active 和current三个日志组时，这时要发生日志组的切换，但是覆盖的前提是inactive状态，就是该日志组已经写入到
archive log。如果这时是active，那没有inactive，怎么办呢。
   会强制触发dbwr把一部分buffer中的脏块数据，写入到数据文件中，这时active的日志组，就可以覆盖了。
   也就是无论是否开始归档，都不会影响实例的一致性恢复。
redo log中包含了提交的事务也包含未提交的事务

服务器从redo buffer写入redo log时，若redo log已满，不能写入，则向LGWR请求进行日志的切换，直到切换完成，则有log file switch completion。
如果需要投入的redo log，还没有完成归档的工作，则会有另外的等待事件出现：
1、如果对欲重新使用的redo log尚未结束检查点，则等待DBWR来结束检查点，这时等待log file switch checkpoint incomplete。
2、如果对欲重新使用的redo log尚未完成归档，则进程等待ARCH来完成归档，这时等待log file switch archiving needed。

处理方法：
增大redo log的日志组，手动脚本进行alter system checkpoint;

##SQL*NET more data from client
若占据着相当比重的等待事件，可能是SQL看起来执行计划没有问题，但是只要查询量一上来，就会导致等待，需要再优化此查询，一般是根据条件，添加复合索引。

--历史等待查询
 with tt as
  (SELECT t.instance_number, t.user_id, t."SQL_ID", t."EVENT", count(1) CNT
     FROM DBA_HIST_ACTIVE_SESS_HISTORY t
    WHERE t."WAIT_CLASS" <> 'Idle'
      and t.sql_id is not null
      and t."SAMPLE_TIME" between
          to_date('2020-01-01 09:00:00', 'yyyy-mm-dd hh24:mi:ss') and
          to_date('2020-01-03 11:00:00', 'yyyy-mm-dd hh24:mi:ss')
    group by t.instance_number, t.user_id, t."SQL_ID", t."EVENT"
    order by count(1) desc)
 SELECT tt.instance_number, a.username, tt."SQL_ID", tt."EVENT", tt.CNT
   FROM tt, dba_users a
  where a.user_id = tt.user_id and rownum<11;