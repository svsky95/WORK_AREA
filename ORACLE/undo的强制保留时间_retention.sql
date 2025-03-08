--undo_retention 参数设置
默认参数是记录，数据提交后的UNDO记录还要保留多长时间。
但是，oralce并不强制保留这么长的时间，如果undo的空间不够，即使还没有达到时间的限制，这些记录依然还是会被覆盖掉。
SQL> show parameter undo

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
undo_management                      string      AUTO
undo_retention                       integer     900        单位：秒
undo_tablespace                      string      UNDOTBS1

--retention guarantee 强制保留
SQL> select tablespace_name,retention from dba_tablespaces where tablespace_name like 'UNDO%';

TABLESPACE_NAME                RETENTION
------------------------------ -----------
UNDOTBS1                       NOGUARANTEE

SQL> alter tablespace UNDOTBS1 retention GUARANTEE;

Tablespace altered

