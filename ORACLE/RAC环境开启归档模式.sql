--RAC���������鵵
#�鿴�鵵
SQL> archive log list;
Database log mode              No Archive Mode
Automatic archival             Disabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     49
Current log sequence           50

--���޸Ĺ鵵λ��
#�鿴�鵵λ��
SQL> show parameter log_archive_dest��1-31��������ָ��31���鵵·����

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
log_archive_dest                     string      +DATA/ARCHIVELOG
log_archive_dest_1                   string

#�޸Ĺ鵵��ASM�浵·��,RAC������ʵ��д��ͬһ��ASMĿ¼�¡�
alter diskgroup DATA add directory '+DATA/ARCHIVELOG';     (DADA ����������)
alter system set log_archive_dest='+DATA/ARCHIVELOG' scope=spfile sid='*';
#�޸Ĺ鵵��ʽ
SQL> show parameter log_archive_format

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
log_archive_format                   string      %t_%s_%r.dbf

alter system set log_archive_format='%t_%s_%r.dbf' scope=spfile sid='*';


#��һ��ʵ��1��ִ��
alter system set cluster_database=false scope=spfile sid='crsdb1';

#�ر����ݿ�
[oracle@racnod1 dbs]$ srvctl stop database -d crsdb
[oracle@racnod1 dbs]$ srvctl status database -d crsdb
Instance crsdb1 is not running on node racnod1
Instance crsdb2 is not running on node racnod2

#ʹ�õ�ǰʵ���������ݿ�
SQL> startup mount;

#�����鵵
SQL> alter database archivelog;

#��һ��ʵ��1��ִ��
alter system set cluster_database=true scope=spfile sid='crsdb1';

#�رյ�ǰʵ��
SQL> shutdown immediate

#�������ݿ�
[oracle@racnod1 dbs]$ srvctl start database -d crsdb
[oracle@racnod1 dbs]$ srvctl status database -d crsdb
Instance crsdb1 is running on node racnod1
Instance crsdb2 is running on node racnod2

-QA
��������ݿ⣬���޸�Oracle�Ĺ鵵ģʽ����������´���
SQL> alter database archivelog;
alter database archivelog
*
ERROR at line 1:
ORA-00265: instance recovery required, cannot set ARCHIVELOG mode
���������£�ԭ�����ϴ�ϵͳ�ķ������رյ��¡���Ҫ���´����ݿ⣬ʹ�����ļ��������ļ�����־�ļ�ͬ�������޸Ĺ鵵ģʽ��
 
 
�����������
���Ѿ�����mount�׶ε����ݿ�򿪣�����open�׶Σ���Ȼ���ٹرգ�������mount�׶Ρ�
 
SQL> alter database open;
 
Database altered.
 
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup mount;
ORACLE instance started.
 
Total System Global Area  623546368 bytes
Fixed Size                  1338308 bytes
Variable Size             436208700 bytes
Database Buffers          180355072 bytes
Redo Buffers                5644288 bytes
Database mounted.
 
SQL> alter database archivelog;
 
Database altered.
 
SQL> alter database open;
 
Database altered.
