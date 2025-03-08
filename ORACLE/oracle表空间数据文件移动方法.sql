--Oracle��ռ������ļ��ƶ��ķ���
һ����Կ�offline�ķ�ϵͳ��ռ�
�����ƶ�oracle�İ�����ռ�(EXAMPLE��ռ�)�������
D:\ORADATA\ORCL\ �ƶ��� D:\ORACLE\ORADATA\
1.�鿴Ҫ�ı�ı�ռ�������ļ���Ϣ
select file_id,
       tablespace_name,
       file_name,
       online_status,
       autoextensible,
       user_bytes / 1024 / 1024 size_M
  from dba_data_files
 where tablespace_name = 'TS_HX_ZM_DAT';
 
73	TS_HX_ZM_DAT	/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_01.dbf	ONLINE	YES	99
186	TS_HX_ZM_DAT	/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_02.dbf	ONLINE	NO	99

2.��Ŀ���ռ�����Ϊ�ѻ�״̬
--�����ű�
select 'alter tablespace ' || t.tablespace_name|| ' offline;' from (select 
       distinct tablespace_name
  from dba_data_files where tablespace_name not in ('USERS','UNDOTBS1','SYSTEM','SYSAUX')) t ;
  
alter tablespace TS_HX_ZM_DAT offline;

3.�ٴβ鿴Ŀ���ռ��״̬��ȷ�����Ѿ����ѻ�״̬
select file_id,
       tablespace_name,
       file_name,
       online_status,
       autoextensible,
       user_bytes / 1024 / 1024 size_M
  from dba_data_files
 where tablespace_name = 'TS_HX_ZM_DAT';
 
4.��ԭ���������ļ��ƶ�(����)���µ�·��
SQL> ! mv /u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_02.dbf /home/oracle/app/oradata/NFZCDB/datafile/

5.�޸ĸñ�ռ�������ļ�·��
alter tablespace TS_HX_ZM_DAT rename datafile '/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_02.dbf' to '/home/oracle/app/oradata/NFZCDB/datafile/TS_HX_ZM_DAT_02.dbf';
--�����ű�
select 'alter tablespace  '|| t.tablespace_name || ' rename datafile '''||t.file_name||''' to '''||t.file_name||'''  ;'
from (select 
        tablespace_name,file_name
  from dba_data_files where tablespace_name not in ('USERS','UNDOTBS1','SYSTEM','SYSAUX')) t;
6��ȷ���޸ĵ��Ѿ���Ч
select file_id,
       tablespace_name,
       file_name,
       online_status,
       autoextensible,
       user_bytes / 1024 / 1024 size_M
  from dba_data_files
 where tablespace_name = 'TS_HX_ZM_DAT';
 
7.�޸ĸñ�ռ�Ϊ����״̬
alter tablespace TS_HX_ZM_DAT online;

����ϵͳ��ռ��ƶ�

�÷�����Ҫ���ݿ⴦��mount״̬

1.�ر������е����ݿ�


SQL> shutdown immediate
 

2.�������ݿ⵽mount״̬

 
SQL> startup mount
 

3.�ƶ�ϵͳ��ռ�(SYSTEM��ռ�)�������ļ�


SQL> host move D:\ORADATA\ORCL\SYSTEM01.DBF D:\ORACLE\ORADATA\
 

4.�޸ĸñ�ռ�������ļ�·��

 
SQL> alter database rename file 'D:\ORADATA\ORCL\SYSTEM01.DBF' to 'D:\ORACLE\ORA
DATA\SYSTEM01.DBF';
 

5.�������ݿ⣬��ʵ��
 
SQL> alter database open;
 

6.�鿴��ռ��޸Ľ��

SQL> select tablespace_name,file_name,online_status from dba_data_files where ta
blespace_name='SYSTEM';
 
TABLESPACE_NAME FILE_NAME     ONLINE_
--------------- ----------------------------------- -------
SYSTEM  D:\ORACLE\ORADATA\SYSTEM01.DBF SYSTEM

#####�����ƶ���ʽ#####
>>>�� Oracle ���ݿ� 12c R1 �汾�ж������ļ���Ǩ�ƻ�����������
��Ҫ̫�෱���Ĳ��裬���ѱ�ռ���Ϊֻ��ģʽ���������Ƕ������ļ��������߲�����
�� 12c R1 �У�����ʹ�� ALTER DATABASE MOVE DATAFILE ������ SQL ���������ļ�
�����������������ƶ��������������ļ����ڴ���ʱ���ն��û�����ִ�в�ѯ��DML
�Լ� DDL ������������⣬�����ļ������ڴ洢�豸��Ǩ�ƣ���ӷ� ASM Ǩ���� ASM��
��֮��Ȼ
#�����������ļ���
SQL>ALTER DATABASE MOVE DATAFILE '/u00/data/users01.dbf' TO
'/u00/data/users_01.dbf';
#�ӷ� ASM Ǩ�������ļ��� ASM��
SQL>ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO '+DG_DATA';
#�������ļ���һ�� ASM ����Ⱥ��Ǩ������һ�� ASM ����Ⱥ�飺
SQL>ALTER DATABASE MOVE DATAFILE '+DG_DATA/DBNAME/DATAFILE/users_01.dbf ' TO
'+DG_DATA_02';
#�������ļ��Ѵ�������·��������£�����ͬ���������串�ǣ�
SQL>ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO
'/u00/data_new/users_01.dbf' REUSE;
SQL>ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO
'/u00/data_new/users_01.dbf' KEEP;
��ͨ����ѯ v$session_longops ��̬��ͼ���ƶ��ļ�ʱ������Լ����һ���̡����⣬
��Ҳ�������� alert.log��Oracle �������м�¼�������Ϊ��
 
