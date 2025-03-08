###flashback table owner.table_name to before drop; ++++++++

--由于DROP导致表的删除，但是若添加了purge则无法闪回
SELECT t.original_name,'flashback table '||t.owner||'.'||t.original_name||' to before drop;',t.droptime FROM dba_recyclebin t WHERE t.owner='SJYY' AND  t.original_name='SB_ZZS_YBNSR_FB3_YSFWKCXM';
--
flashback table owner.table_name to before drop;
flashback table sjyy."BIN$W0ex0vC6IfDgUwwICgq/fA==$0" to before drop;
--闪回删除并重命名
flashback table owner.table_name to before drop rename to table_name_bak;

--索引与主键重命名
ALTER INDEX sjyy."BIN$W0ex0vC6IfDgUwwICgq/fA==$0" RENAME TO idx_aaa;

--主键索引重命名
--查询表的主键及约束
SELECT A.CONSTRAINT_NAME, A.COLUMN_NAME, B.CONSTRAINT_TYPE
  FROM DBA_CONS_COLUMNS A, DBA_CONSTRAINTS B
 WHERE A.CONSTRAINT_NAME = B.CONSTRAINT_NAME
      /*   AND B.CONSTRAINT_TYPE = 'P'*/
   AND A.OWNER = 'CZ'
   AND A.TABLE_NAME = 'SB_SBB';

--重命名主键
ALTER TABLE cz.SB_SBB RENAME CONSTRAINT "BIN$W0ex0vDwIfDgUwwICgq/fA==$1" TO PK_PC59;

--约束与主键重命名
ALTER TABLE sjyy.SB_ZZS_YBNSR_FB3_YSFWKCXM RENAME CONSTRAINT "BIN$W0ex0vC0IfDgUwwICgq/fA==$0" TO PK_PC59;
--批量收集统计信息

###表的delete误删除
select * from emp as of timestamp to_timestamp('2015-03-13 15:00:00','yyyy-mm-dd hh24:mi:ss'); 
--确定后，插入表
insert into emp select * from emp as of timestamp to_timestamp('2015-03-13 15:00:00','yyyy-mm-dd hh24:mi:ss'); 
