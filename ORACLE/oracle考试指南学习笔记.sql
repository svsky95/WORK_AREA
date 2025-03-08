--oralce考试指南学习笔记
show parameter like 'undo_tablespace';
select t."VALUE" from v$parameter t where t."NAME"='undo_management';
select * from dba_tablespaces t where t.CONTENTS='UNDO';
select * from dba_data_files t where t.TABLESPACE_NAME='UNDOTBS1';
--查看undo的大小
select * from dba_rollback_segs;
select * from v$rollstat;
--undo段生成的数据量
select * from v$undostat;   undoblks*8K
--undo保留时间
show parameter like 'undo_retention';   --900S

