online_Redo log �������ɾ��
--����״̬
CURRENT   ��ǰ������ʹ�õ�
INACTIVE  �鵵����ɣ����Խ���ɾ����
ACTIVE    ʵ���ָ���Ҫ��

1 �鿴redo ��Ϣ


--�Զ��鵵ʱ��

SQL> show parameter ARCHIVE_LAG_TARGET

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------ --Ĭ����0 
archive_lag_target                   integer     0


ARCHIVE_LAG_TARGET = 1800


3 �޸�Online redo

RAC��ʵ��1��ʵ��2��ʹ�ø��Ե�redolog�ļ���
�ڵ�ʵ���У�redolog���ڲ����鵵�����Ե�һ��redologд���󣬾��л�����һ�������ø��ǵķ�ʽ��ѯдredolog��

--�鿴relog_file��״̬
--��ͼ���Կ�����
ʵ��1 �õ���־��ֻ����1��2��5
ʵ��2 �õ���־��ֻ����3��4��6
SQL> SELECT a."THREAD#",c."INSTANCE_NAME",a."GROUP#",a."STATUS",b."MEMBER" FROM v$log a,v$logfile b,gv$instance c where a."GROUP#"=b."GROUP#" and a."THREAD#"=c."THREAD#" order by 1,3;

   THREAD# INSTANCE_NAME        GROUP# STATUS           MEMBER
---------- ---------------- ---------- ---------------- ----------------------------------------------------------------------------------------------------
         1 snsmbs1                   1 ACTIVE           +DATA/snsmbs/onlinelog/group_1.294.1006970993
         1 snsmbs1                   2 ACTIVE           +DATA/snsmbs/onlinelog/group_2.293.1006970993
         1 snsmbs1                   5 CURRENT          +DATA/snsmbs/onlinelog/group_5.2020.1008242247
         2 snsmbs2                   3 ACTIVE           +DATA/snsmbs/onlinelog/group_3.289.1006971051
         2 snsmbs2                   4 ACTIVE           +DATA/snsmbs/onlinelog/group_4.362.1006971051
         2 snsmbs2                   6 CURRENT          +DATA/snsmbs/onlinelog/group_6.2041.1008242287
       
--ȷ��״̬��INACTIVE�Ĳſ����޸� ���Կ�����2�ǿ��Բ����ģ�����һ�����ٱ���һ����Ա
alter database drop logfile member '+ORA_DATA/crsdb/onlinelog/group_2.261.1004629265';
--����ļ�������·��
SQL> show parameter db_create(1-5��ʾ����ָ��5�鲻ͬ��λ��)

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_create_file_dest                  string      +ORA_DATA
db_create_online_log_dest_1          string      +ORA_DATA   <--ָ����һ�����е���������Ա1��λ��
db_create_online_log_dest_2          string      +OCR_DATA   <--ָ����һ�����е���������Ա2��λ��
db_create_online_log_dest_3          string
db_create_online_log_dest_4          string
db_create_online_log_dest_5          string

alter system set db_create_online_log_dest_1='+ORA_DATA' sid='*' scope=both;
alter system set db_create_online_log_dest_2='+OCR_DATA' sid='*' scope=both;
--���ĸ�ʵ����ӵ���־�飬�ĸ��ڵ����ʹ�ã���һ��ʵ��������ʹ�á�
alter database add logfile group 6 size 500M;
--Ҳ����ָ��ʵ�����
alter database add logfile thread 1 group 8 size 500M; 

SQL> select thread#,group#,archived,status, bytes/1024/1024 size_M from gv$log order by 1,2;
              
--������ӳ�Ա(�������³�Ա�����еĳ�Ա��С��ͬ)
ALTER DATABASE ADD LOGFILE MEMBER '+DATA/racdb/onlinelog/redo5.rdo' TO GROUP 5 ;

--��Ա���������
When using the ALTER DATABASE statement, you can alternatively identify the target group by specifying all of the other members of the group in the TO clause, as shown in the following example:
ALTER DATABASE ADD LOGFILE MEMBER '/oracle/dbs/log2c.rdo'
    TO ('+DATA/racdb/onlinelog/group_5.810.1022411397', '+DATA/racdb/onlinelog/redo5.rdo'); 
    
alter system switch logfile;
ǿ���Բ���������־�л����

ǿ�Ʋ����������

alter system checkpoint;

����FAST_START_MTTR_TARGET=900 ǿ��900�뼴15���Ӳ���һ�����㡣����ʵ�� �ָ�ʱ�䲻�ᳬ��900�롣

--ɾ��һ����ĳ�Ա
--��������������ڵ����ǲ��ظ��ģ�����ֻҪֱ��ָ�����ɾ���Ϳ��ԡ�
ALTER DATABASE DROP LOGFILE GROUP 2;

alter database add logfile group 5 '/opt/oracle/oradata/dbtest/redo05_1.log' SIZE 10M
alter database add logfile member '/opt/oracle/oradata/dbtest/redo04_3.log' to group 4
alter database drop logfile group 5
alter database drop logfile  ('/opt/oracle/oradata/dbtest/redo05_1.log','/opt/oracle/oradata/dbtest/redo05_2.log')         


###################################################################################
         

-- �����ļ�û��ɾ�����ֹ��İ������ļ�ɾ�����ڴ�����

--������־
SQL> alter database add logfile  group 1 ('/u01/app/oracle/oradata/xezf/redo01.log') size 100M;

Database altered.

--��·�����
ALTER DATABASE ADD LOGFILE
  GROUP 4 ('/u01/logs/orcl/redo04a.log','/u01/logs/orcl/redo04b.log')
  SIZE 100M BLOCKSIZE 512 REUSE;
 
--�����е��������־��Ա
Notice that filenames must be specified, but sizes need not be. The size of the new members is determined from the size of the existing members of the group.
ALTER DATABASE ADD LOGFILE MEMBER '/oracle/dbs/log2b.rdo' TO GROUP 2;

--ɾ����־��
SQL>  alter database drop logfile group 1; 
--ɾ��standby ��־��
alter database drop STANDBY logfile group 9; 

--ɾ����־���Ա
ALTER DATABASE DROP LOGFILE MEMBER '/oracle/dbs/log3c.rdo';

--ǿ���л�
ALTER SYSTEM SWITCH LOGFILE;
SQL>  select group#,thread#,archived,status, bytes/1024/1024 from v$log;  

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 YES UNUSED                       100

         2          1 NO  CURRENT                       50

         3          1 YES INACTIVE                      50

 

group1 �㶨�ˡ�

 

SQL> alter database drop logfile group 3;

Database altered.

 

ɾ����Ӧ�������ļ��������

SQL> alter database add logfile  group 3 ('/u01/app/oracle/oradata/xezf/redo03.log') size 100M;

 

Database altered.

SQL> select group#,thread#,archived,status, bytes/1024/1024 from v$log;

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 YES UNUSED                       100

         2          1 NO  CURRENT                       50

         3          1 YES UNUSED                       100

 

group3 �㶨��

 

�л�һ��logfile����ɾ��group2

 

SQL> alter system switch logfile;

System altered.

SQL>  select group#,thread#,archived,status, bytes/1024/1024 from v$log;

 

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 NO  CURRENT                      100

         2          1 YES ACTIVE                        50

       -- group ���ڹ鵵�����ǵȻ��ڿ�һ��

         3          1 YES UNUSED                       100

 

������֮��

SQL> select group#,thread#,archived,status, bytes/1024/1024 from v$log;

 

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 NO  CURRENT                      100

         2          1 YES INACTIVE                      50

         3          1 YES UNUSED                       100

 

SQL>  alter database drop logfile group 2;

Database altered.

ɾ�������ļ����ڴ���

SQL> alter database add logfile  group 2 ('/u01/app/oracle/oradata/xezf/redo02.log') size 100M;

Database altered.

SQL> select group#,thread#,archived,status, bytes/1024/1024 from v$log;

 

    GROUP#    THREAD# ARC STATUS           BYTES/1024/1024

---------- ---------- --- ---------------- ---------------

         1          1 NO  CURRENT                      100

         2          1 YES UNUSED                       100

         3          1 YES UNUSED                       100
         
���standby redo

SQL> ALTER DATABASE ADD STANDBY LOGFILE GROUP 4 ('/u01/app/oracle/oradata/xezf/std_redo04.log') size 100M;

Database altered.

SQL> ALTER DATABASE ADD STANDBY LOGFILE GROUP 5 ('/u01/app/oracle/oradata/xezf/std_redo05.log') size 100M;

Database altered.

SQL> ALTER DATABASE ADD STANDBY LOGFILE GROUP 6 ('/u01/app/oracle/oradata/xezf/std_redo06.log') size 100M;

Database altered.

SQL> ALTER DATABASE ADD STANDBY LOGFILE GROUP 7 ('/u01/app/oracle/oradata/xezf/std_redo07.log') size 100M;

Database altered.

2 �޸�standby redo

SQL> alter database drop logfile group 4;

Database altered.

SQL> alter database drop logfile group 5;

Database altered.

SQL> alter database drop logfile group 6;

Database altered.

SQL> alter database drop logfile group 7;

Database altered.

SQL> select group#,type, member from v$logfile;

    GROUP# TYPE    MEMBER

---------- ------- -------------------------------------------------------------

         3 ONLINE  /u01/app/oracle/oradata/xezf/redo03.log

         2 ONLINE  /u01/app/oracle/oradata/xezf/redo02.log

         1 ONLINE  /u01/app/oracle/oradata/xezf/redo01.log
 

SQL> select group#,type, member from v$logfile;

 

    GROUP# TYPE    MEMBER

---------- ------- -------------------------------------------------------------

         3 ONLINE  /u01/app/oracle/oradata/xezf/redo03.log

         2 ONLINE  /u01/app/oracle/oradata/xezf/redo02.log

         1 ONLINE  /u01/app/oracle/oradata/xezf/redo01.log

         4 STANDBY /u01/app/oracle/oradata/xezf/std_redo04.log

         5 STANDBY /u01/app/oracle/oradata/xezf/std_redo05.log

         6 STANDBY /u01/app/oracle/oradata/xezf/std_redo06.log

         7 STANDBY /u01/app/oracle/oradata/xezf/std_redo07.log

 

7 rows selected.

--���online_redolog
Clearing a Redo Log File
A redo log file might become corrupted while the database is open, and ultimately stop database activity because archiving cannot continue. In this situation the ALTER DATABASE CLEAR LOGFILE statement can be used to reinitialize the file without shutting down the database.

The following statement clears the log files in redo log group number 3:

ALTER DATABASE CLEAR LOGFILE GROUP 3;
This statement overcomes two situations where dropping redo logs is not possible:

If there are only two log groups
The corrupt redo log file belongs to the current group
If the corrupt redo log file has not been archived, use the UNARCHIVED keyword in the statement.

ALTER DATABASE CLEAR UNARCHIVED LOGFILE GROUP 3;
This statement clears the corrupted redo logs and avoids archiving them. The cleared redo logs are available for use even though they were not archived.

If you clear a log file that is needed for recovery of a backup, then you can no longer recover from that backup. The database writes a message in the alert log describing the backups from which you cannot recover.

Note:
If you clear an unarchived redo log file, you should make another backup of the database.
To clear an unarchived redo log that is needed to bring an offline tablespace online, use the UNRECOVERABLE DATAFILE clause in the ALTER DATABASE CLEAR LOGFILE statement.

If you clear a redo log needed to bring an offline tablespace online, you will not be able to bring the tablespace online again. You will have to drop the tablespace or perform an incomplete recovery. Note that tablespaces taken offline normal do not require recovery.