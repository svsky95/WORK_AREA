--临时表
1、全局临时表 
--基于会话的 on commit preserve rows 
1、在session连接退出后，自动被删除，无需收动操作。
2、针对于不同的会话，数据独立，不同的session看到的数据是不同的。
create global temporary table T_TMP_session on commit preserve rows as select  * from dba_objects where 1=2;

--基于事物的 on commit delete rows
1、commit后自动清除数据。
使用范围：
1、程序的一次调用过程中需要多次清空记录并再插入记录。
create global temporary table t_tmp_transaction on commit delete rows as select * from dba_objects where 1=2;

--临时表空间不足
看看，临时表空间中，有没有笛卡尔积的SQL