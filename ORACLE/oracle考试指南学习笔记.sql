--oralce����ָ��ѧϰ�ʼ�
show parameter like 'undo_tablespace';
select t."VALUE" from v$parameter t where t."NAME"='undo_management';
select * from dba_tablespaces t where t.CONTENTS='UNDO';
select * from dba_data_files t where t.TABLESPACE_NAME='UNDOTBS1';
--�鿴undo�Ĵ�С
select * from dba_rollback_segs;
select * from v$rollstat;
--undo�����ɵ�������
select * from v$undostat;   undoblks*8K
--undo����ʱ��
show parameter like 'undo_retention';   --900S

