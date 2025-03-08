##基数反馈##  cardinality feedback used for this statement
--cardianality feedback
 当语句第一次执行的时候，优化器生成初始的执行计划。
     优化器在以下情况下会监控语句执行时的统计信息：
     1.表上没有统计信息（动态采样虽然打开但是统计信息也不准确）。
     2.多个合并或分开的谓词条件。
     3.谓词包含复杂的操作符导致优化器没法评估选择性。
     在语句执行的后期，优化器对每个操作比较初始的基数评估和返回的行数，如果评估出的基数和实际的行数相去甚远，优化器将存储正确的基数给后续的执行使用。
     当查询第二次执行的时候，优化器会使用之前存储的基数去生成更准确的执行计划。
     
11.2中的新特性，该特性，只针对统计信息陈旧、无直方图或虽然有直方图但仍基数计算不准确的情况，
cardianality基数的计算直接影响到join cost等的计算出成本，造成CBO选择不当。
典型的就是在测试语句的性能的时候，第一次快，第二次就很慢。

acs(adaptive_cursor_sharing) 自适应游标特性，配合bind peeking才算真正意义上解决了这个问题。不过也不够完美，因为acs特性本身也的确会增加额外的硬解析，且会导致child cursor增多，从而软解析扫描chain的时间变长，同时对shared pool空间需求也增加，且早期bug较多，即使Oracle默认也是开启这个特性的，很多客户生产环境也是将其关闭的。


##生产建议，关闭自适应游标和基数反馈
alter system set "_optimizer_use_feedback" = false scope = both;
alter system set "_optimizer_adaptive_cursor_sharing" = false scope = both;


##生产谨慎操作##
QL> alter system flush shared_pool;

System altered

SQL> alter system flush buffer_cache;

System altered
                 
                 
                 
                 
                 
                 




