--undo_retention ��������
Ĭ�ϲ����Ǽ�¼�������ύ���UNDO��¼��Ҫ�����೤ʱ�䡣
���ǣ�oralce����ǿ�Ʊ�����ô����ʱ�䣬���undo�Ŀռ䲻������ʹ��û�дﵽʱ������ƣ���Щ��¼��Ȼ���ǻᱻ���ǵ���
SQL> show parameter undo

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
undo_management                      string      AUTO
undo_retention                       integer     900        ��λ����
undo_tablespace                      string      UNDOTBS1

--retention guarantee ǿ�Ʊ���
SQL> select tablespace_name,retention from dba_tablespaces where tablespace_name like 'UNDO%';

TABLESPACE_NAME                RETENTION
------------------------------ -----------
UNDOTBS1                       NOGUARANTEE

SQL> alter tablespace UNDOTBS1 retention GUARANTEE;

Tablespace altered

