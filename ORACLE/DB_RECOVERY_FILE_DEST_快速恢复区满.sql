--���ٻָ������������ݲ�����������־���£�
���ٻָ�����ţ�
1���鵵��־
2�������ļ�
3�������Ķ�·������
4�������ļ��Ķ�·������


db_recovery_file_dest_size of 6005194752 bytes is 100.00% used, and has 0 remaining bytes available.

��¼����һ���ڵ㣺
SQL> startup nomount
ORACLE instance started.

Total System Global Area 2505338880 bytes
Fixed Size                  2255832 bytes
Variable Size             704644136 bytes
Database Buffers         1778384896 bytes
Redo Buffers               20054016 bytes
SQL> alter database mount;

Database altered.

SQL>  show parameter DB_RECOVERY_FILE_DEST

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest                string      +DATA
db_recovery_file_dest_size           big integer 5727M

alter system set db_recovery_file_dest_size=50G scope=both sid='*';

SQL> alter database open;

Database altered.

