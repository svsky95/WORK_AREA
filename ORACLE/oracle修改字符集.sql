--oracle 设置字符集
1、查看字符集
--直观查询
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

--字符集修改步骤
SQL>shutdown immediate;

SQL>STARTUP MOUNT;
 
 
SQL>ALTER SYSTEM ENABLE RESTRICTED SESSION;
 
 
SQL>ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
 
 
SQL>ALTER SYSTEM SET AQ_TM_PROCESSES=0;
 
 
SQL>ALTER DATABASE OPEN;
 
 
SQL>ALTER DATABASE CHARACTER SET INTERNAL_USE ZHS16GBK; //跳过超子集检测

SQL>ALTER DATABASE NATIONAL CHARACTER SET INTERNAL_USE AL16UTF16;
 
SQL>ALTER DATABASE national CHARACTER SET INTERNAL ZHS16GBK;   --执行后出错ORA-00933: SQL 命令未正确结束，不过执行上一行命令已经生效

--AMERICAN_AMERICA.AL32UTF8 
//ALTER DATABASE character set INTERNAL_USE AL32UTF8;

SQL>SHUTDOWN IMMEDIATE;
 
SQL>STARTUP;

最后重启oracle11g监听和服务，重新登录PL/SQL developer 。





系统版本:

Oracle Linux Server release 5.7

数据库版本：

Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production
PL/SQL Release 11.2.0.3.0 - Production
CORE 11.2.0.3.0 Production
TNS for Linux: Version 11.2.0.3.0 - Production
NLSRTL Version 11.2.0.3.0 - Production

查看字符集：

SQL>select userenv('language') from dual;

USERENV('LANGUAGE')
--------------------------------------------------------------------------------
AMERICAN_AMERICA.AL32UTF8

关闭RAC其中一个节点：

[root@rac1 ~]#cd /u01/app/11.2.0/grid/bin/crsctl

[root@rac1 ~]#./crsctl stop cluster

在另一个节点查看oracle启动参数：

SQL>show parameter spfile;

NAME TYPE VALUE
------------------------------------ --------------------------------- ------------------------------
spfile string +DG1/yoon/spfileyoon.ora

若VALUE为空，表示用pfile参数启动，即修改为spfile参数启动：

SQL>CREATE SPFILE FROM PFILE;

SQL>shutdown immediate;

SQL>startup;

执行：

SQL>alter system set cluster_database=false scope=spfile sid='*';

关闭数据库：

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

修改字符集：

SQL> ALTER DATABASE character set INTERNAL_USE ZHS16GBK;

SQL>ALTER DATABASE NATIONAL CHARACTER SET INTERNAL_USE AL16UTF16;
Database altered.

恢复数据库为RAC：

SQL> alter system set cluster_database=true scope=spfile sid='*';

SQL> shutdown immediate;

SQL>startup;

启动另一节点cluster服务并验证：

[root@rac1 ~]#./crsctl start cluster

查看字符集：

SQL>select userenv('language') from dual;

USERENV('LANGUAGE')
--------------------------------------------------------------------------------
AMERICAN_AMERICA.ZHS16GBK


#####关于字符集的重要说明#####
--字符集AL32UTF8字符集并不是ZHS16GBK的超集，并且这两个字符集之间也不能相互修改，会导致部分中文乱码。

数据库由ZHS16GBK字符集修改为AL32UTF8字符集，发现中文的数据中小部分出现乱码，客户认为AL32UTF8明明可以支持更多的文字，不应该出现这样的情况才对。
从现象看，基本可以确认故障是字符集转换导致的，Oracle也强烈不建议做这种字符集转换的操作，幸好该客户的操作只是在一个测试环境中操作的。不过，之前也一直有个误区，我们都知道AL32UTF8是可以支持多国语言的字符集，对于中文字节存储占用空间比ZHS16GBK多，然后第一反应就认为AL32UTF8应该是ZHS16GBK的超集。而如果是绝对的超集，就不应该出现任何乱码的情况，可实际用户反馈的现象的确是有小部分出现乱码的情况。
而客户端是Windows，chcp结果是936，也就是ZHS16GBK，这也进一步说明了ZHS16GBK和AL32UTF8字符集的不同。

同时实验还验证，如果数据库字符集本身是AL32UTF8，想修改成为ZHS16GBK字符集，也是一样的情况，需要加internal_use参数才可以转换，也就是说这种转换一样可能出现乱码，不过这个情况反倒好理解，也符合我们之前的认知，就不再赘述了。