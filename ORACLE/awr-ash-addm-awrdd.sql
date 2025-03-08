--关于oracle整体性能工具
主要工具有AWR、ASH、ADDM、AWRDD这四个工具。
--AWR是关注数据库的整体性能的报告   sqlplus下执行@?/rdbms/admin/awrrpt.sql
--ASH是数据库中的等待事件与哪些SQL具体对应的报告  sqlplus下执行@?/rdbms/admin/ashrpt.sql
--ADDM是Oracle给出的一些建议     sqlplus下执行@?/rdbms/admin/addmrpt.sql
--AWRDD是Oracle针对不同时段的性能的一个比对报告，比如今天早上9点系统很慢，而昨天这个时候很正常，很多人就想知道今天早上9点和昨天早上9点有什么不同，于是就有了这个报告。  sqlplus下执行@?/rdbms/admin/awrddrpt.sql 
--AWRSQRPT是统计统计信息与执行计划。   sqlplus下执行@?/rdbms/admin/awrsqrpt.sql  --需要输入sql_id 
--sql优化建议    @?/rdbms/admin/sqltrpt.sql

--segment advisor 
--开启行移动
alter table HX_SB.SB_CGS_CLDAXX enable row movement;
--开启段收缩
alter table HX_SB.SB_CGS_CLDAXX shrink space;