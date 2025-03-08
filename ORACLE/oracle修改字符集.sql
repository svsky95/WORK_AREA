--oracle �����ַ���
1���鿴�ַ���
--ֱ�۲�ѯ
SQL> select userenv('language') from dual;

USERENV('LANGUAGE')
----------------------------------------------------
AMERICAN_AMERICA.ZHS16GBK

select * from nls_database_parameters;
PARAMETER                      VALUE
------------------------------ --------------------------------------------------------------------------------
NLS_LANGUAGE                   AMERICAN
NLS_TERRITORY                  AMERICA
NLS_CURRENCY                   $
NLS_ISO_CURRENCY               AMERICA
NLS_NUMERIC_CHARACTERS         .,
NLS_CHARACTERSET               ZHS16GBK
NLS_CALENDAR                   GREGORIAN
NLS_DATE_FORMAT                DD-MON-RR
NLS_DATE_LANGUAGE              AMERICAN
NLS_SORT                       BINARY
NLS_TIME_FORMAT                HH.MI.SSXFF AM
NLS_TIMESTAMP_FORMAT           DD-MON-RR HH.MI.SSXFF AM
NLS_TIME_TZ_FORMAT             HH.MI.SSXFF AM TZR
NLS_TIMESTAMP_TZ_FORMAT        DD-MON-RR HH.MI.SSXFF AM TZR
NLS_DUAL_CURRENCY              $
NLS_COMP                       BINARY
NLS_LENGTH_SEMANTICS           BYTE
NLS_NCHAR_CONV_EXCP            FALSE
NLS_NCHAR_CHARACTERSET         AL16UTF16
NLS_RDBMS_VERSION              11.2.0.4.0

--�ַ����޸Ĳ���
SQL>shutdown immediate;

SQL>STARTUP MOUNT;
 
 
SQL>ALTER SYSTEM ENABLE RESTRICTED SESSION;
 
 
SQL>ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
 
 
SQL>ALTER SYSTEM SET AQ_TM_PROCESSES=0;
 
 
SQL>ALTER DATABASE OPEN;
 
 
SQL>ALTER DATABASE CHARACTER SET INTERNAL_USE ZHS16GBK; //�������Ӽ����

SQL>ALTER DATABASE NATIONAL CHARACTER SET INTERNAL_USE AL16UTF16;
 
SQL>ALTER DATABASE national CHARACTER SET INTERNAL ZHS16GBK;   --ִ�к����ORA-00933: SQL ����δ��ȷ����������ִ����һ�������Ѿ���Ч

--AMERICAN_AMERICA.AL32UTF8 
//ALTER DATABASE character set INTERNAL_USE AL32UTF8;

SQL>SHUTDOWN IMMEDIATE;
 
SQL>STARTUP;

�������oracle11g�����ͷ������µ�¼PL/SQL developer ��





ϵͳ�汾:

Oracle Linux Server release 5.7

���ݿ�汾��

Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
PL/SQL Release 11.2.0.3.0 - Production
CORE 11.2.0.3.0 Production
TNS for Linux: Version 11.2.0.3.0 - Production
NLSRTL Version 11.2.0.3.0 - Production

�鿴�ַ�����

SQL>select userenv('language') from dual;

USERENV('LANGUAGE')
--------------------------------------------------------------------------------
AMERICAN_AMERICA.AL32UTF8

�ر�RAC����һ���ڵ㣺

[root@rac1 ~]#cd /u01/app/11.2.0/grid/bin/crsctl

[root@rac1 ~]#./crsctl stop cluster

����һ���ڵ�鿴oracle����������

SQL>show parameter spfile;

NAME TYPE VALUE
------------------------------------ --------------------------------- ------------------------------
spfile string +DG1/yoon/spfileyoon.ora

��VALUEΪ�գ���ʾ��pfile�������������޸�Ϊspfile����������

SQL>CREATE SPFILE FROM PFILE;

SQL>shutdown immediate;

SQL>startup;

ִ�У�

SQL>alter system set cluster_database=false scope=spfile sid='*';

�ر����ݿ⣺

SQL>shutdown immediate;

SQL>startup mount;

SQL> ALTER SYSTEM ENABLE RESTRICTED SESSION;
System altered.
SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
System altered.
SQL> ALTER SYSTEM SET AQ_TM_PROCESSES=0;
System altered.
SQL> alter database open;
Database altered.

�޸��ַ�����

SQL> ALTER DATABASE character set INTERNAL_USE ZHS16GBK;

SQL>ALTER DATABASE NATIONAL CHARACTER SET INTERNAL_USE AL16UTF16;
Database altered.

�ָ����ݿ�ΪRAC��

SQL> alter system set cluster_database=true scope=spfile sid='*';

SQL> shutdown immediate;

SQL>startup;

������һ�ڵ�cluster������֤��

[root@rac1 ~]#./crsctl start cluster

�鿴�ַ�����

SQL>select userenv('language') from dual;

USERENV('LANGUAGE')
--------------------------------------------------------------------------------
AMERICAN_AMERICA.ZHS16GBK


#####�����ַ�������Ҫ˵��#####
--�ַ���AL32UTF8�ַ���������ZHS16GBK�ĳ����������������ַ���֮��Ҳ�����໥�޸ģ��ᵼ�²����������롣

���ݿ���ZHS16GBK�ַ����޸�ΪAL32UTF8�ַ������������ĵ�������С���ֳ������룬�ͻ���ΪAL32UTF8��������֧�ָ�������֣���Ӧ�ó�������������Ŷԡ�
�����󿴣���������ȷ�Ϲ������ַ���ת�����µģ�OracleҲǿ�Ҳ������������ַ���ת���Ĳ������Һøÿͻ��Ĳ���ֻ����һ�����Ի����в����ġ�������֮ǰҲһֱ�и����������Ƕ�֪��AL32UTF8�ǿ���֧�ֶ�����Ե��ַ��������������ֽڴ洢ռ�ÿռ��ZHS16GBK�࣬Ȼ���һ��Ӧ����ΪAL32UTF8Ӧ����ZHS16GBK�ĳ�����������Ǿ��Եĳ������Ͳ�Ӧ�ó����κ�������������ʵ���û������������ȷ����С���ֳ�������������
���ͻ�����Windows��chcp�����936��Ҳ����ZHS16GBK����Ҳ��һ��˵����ZHS16GBK��AL32UTF8�ַ����Ĳ�ͬ��

ͬʱʵ�黹��֤��������ݿ��ַ���������AL32UTF8�����޸ĳ�ΪZHS16GBK�ַ�����Ҳ��һ�����������Ҫ��internal_use�����ſ���ת����Ҳ����˵����ת��һ�����ܳ������룬������������������⣬Ҳ��������֮ǰ����֪���Ͳ���׸���ˡ�