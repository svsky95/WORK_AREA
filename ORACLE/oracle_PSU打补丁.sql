##oracle PSU �򲹶�

ʲô��CPU/PSU

Oracle CPU��ȫ����Critical Patch Update, Oracle�������Ʒÿ�����ȷ���һ�ΰ�ȫ��������ͨ����Ϊ���޸���Ʒ�еİ�ȫ������

Oracle PSU��ȫ����Patch Set Update��Oracle�������Ʒÿ�����ȷ���һ�εĲ�������������bug���޸���Oracleѡȡ���û����������࣬�ұ���֤�����нϵͷ��յĲ������뵽ÿ�����ȵ�PSU�С���ÿ��PSU�в�������Bug���޸����һ����������µ�CPU��PSUͨ����CPUһ�𷢲���

CPU���ۻ��ģ�Cumulative���������µ�CPU�����Ѿ�����������CPU����������ֻҪ��װ���µ�CPU�������ɡ�
PSUͨ��Ҳ�������ģ��󲿷�PSU����ֱ�Ӱ�װ������ЩPSU�����Ҫ��װ����һ ���汾��PSU֮����ܼ�����װ��Ҫ��ϸ������PSU��Readme�ĵ���

�������CPU/PSU

ע�⣺Ҫ����CPU/PSU������Ҫ��Oracle Support�˺Ų��У�
��Oracle CPU��ҳ �����Կ���ÿ�����ȷ�����CPU�����б�����ͼ��ʾ�������������Ҫѡ����Ӧ��CPU�������ɣ�����ѡ��July2011��Ĳ�����

ÿ������ֻ����ض������ݿ�汾����Ҫ�ҵ���Ӧ�����ݿ�汾������ͼ��ʾ������������ݿ�汾Ϊ11.2.0.1������Ҳ�����˵���ò�����֧�ָð汾���ݿ⡣

�ұߵ��Database���ӣ����Ǹò�����һ����ϸ˵���ĵ����ҵ�3.1.3 Oracle Database���������Ӧ�����ݿ�汾������ͼ��ʾ��

����Ӧ�����ݿ�汾����Կ�������ƽ̨��CPU��PSU�汾�ţ�ǰ���Ѿ�˵����PSU����CPU�����Խ��龡����װPSU��ע�⣺�����UNIXƽ̨Ҳ����Linux

�������İ汾�ţ����Զ�����Oracle Support����ҳ�棬����ͼ��ʾ��ѡ����Ӧ��ƽ̨�󣬵��Readme���Բ鿴Readme�ĵ������Download����
�Ķ�Readme�ĵ�
ÿ��CPU/PSU����һ��Readme�ĵ������ڸ�CPU/PSU��������Ϣ����Readme�ĵ��һ��Ҫ��ϸ�Ķ���
����������Ҫ�ر�ע�⣺
1��OPatch�İ汾�������ͨ��opatch version����鿴Oracle Home��ǰ��OPatch�汾���������Readme�涨����Ͱ汾��һ��Ҫ������OPatch���ܴ򲹶���
2����Patch���裺���������е�CPU/PSU����ͬС�죬���岽�轫�������������չʾ��
��װCPU/PSU����
1�����ȼ�飺�鿴���ݿ�򲹶�ǰ��Ϣ�������ֳ�
�ڴ򲹶�ǰ��ð����ݿ��һЩ������Ϣ�����������Ա���ʱ֮�衣

##patch˵��
Combo Patch~
����Oracle Database��Ʒ��PSU��˵��Ŀǰ������3�ֲ���
1. RDBMS ��PSU �� DB PSU ��ʹ��opatch apply��װ�����Զ�rdbms��client��װpatch��
2. GI��PSU �� GI PSU ������PSU��GI+DB PSU���������������Ŀ¼һ����gi��patch��һ����db patch��ʹ��opatch auto�Զ���װ���ὫGI�ͼ���ע���RDBMSһ��װpatch��Ҳ����ʹ��db patchĿ¼�е��ļ���client����������
3. OJVM��PSU �� ����gi��rdbms��client���������java�����patch
������3�ֲ�ͬ��PSU�����һ����γ���Combo Patch������PSUĿ¼�ṹ�ܼ򵥣�һ������Ŀ¼��
1. GI PSU����������˵�����Ŀ¼������������Ŀ¼��һ��ֵGI��patch��һ������DB patch��
2. ���°�OJVM PSU
3. ��һ��OJVM PSU �� JDBC patch
���ԣ���ʵ�������Ҫ����Combo Patch�Ϳ����ˣ���Ϊ�����Ѿ�����������PSU~

ע�����:	QUARTERLY EXADATA DATABASE���ò��ϵ�
 
#######################�򲹶�ǰ��׼������#######################
1����OGGҪ�ر�OGG��MGR�����н���
##�������£�
--�鿴opatch�汾   --����汾�ͣ���Ҫmos�����µ�OPatch�����
cd $ORACLE_HOME/OPatch
./opatch version

OPatch Version: 11.2.0.3.4
OPatch succeeded.

�汾��������������
su - oracle
cd /home/oracle
p6880880_112000_Linux-x86-64.zip
unzip p6880880_112000_Linux-x86-64.zip
[oracle@ctaisdb ~]$ cd $ORACLE_HOME
mv OPatch OPatch_bak
cp -r /home/oracle/OPatch .

[oracle@ctaisdb db_1]$ cd OPatch
[oracle@ctaisdb OPatch]$ ./opatch version 
OPatch Version: 11.2.0.3.21

OPatch succeeded.

-���opatch����
vim ~/.bash_profile
PATH=$PATH:$HOME/bin:/u01/app/oracle/product/11.2.0/db_1/OPatch
export PATH=$PATH:/usr/ccs/bin
source ~/.bash_profile 
 
--�鿴ʵ����
sys@ORCL>select instance_name,status from v$instance;
INSTANCE_NAME    STATUS
---------------- ------------
orcl             OPEN

--�鿴���ݿ�汾
sys@ORCL>select * from v$version;
BANNER
--------------------------------------------------------------------------------
Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production
PL/SQL Release 11.2.0.1.0 - Production
CORE    11.2.0.1.0      Production
TNS for Linux: Version 11.2.0.1.0 - Production
NLSRTL Version 11.2.0.1.0 - Production

--�鿴���ݿ��С
sys@ORCL>select sum(bytes)/1024/1024/1024||'G' from dba_segments;
SUM(BYTES)/1024/1024||'G'
-----------------------------------------
68058.375G

--�鿴�����Ϣ
sys@ORCL>select COMP_ID,COMP_NAME,VERSION,STATUS from DBA_REGISTRY;
COMP_ID              COMP_NAME                                          VERSION                        STATUS
-------------------- -------------------------------------------------- ------------------------------ ----------------------
OWB                  OWB                                                11.2.0.1.0                     VALID
APEX                 Oracle Application Express                         3.2.1.00.10                    VALID
EM                   Oracle Enterprise Manager                          11.2.0.1.0                     VALID
AMD                  OLAP Catalog                                       11.2.0.1.0                     VALID
SDO                  Spatial                                            11.2.0.1.0                     VALID
ORDIM                Oracle Multimedia                                  11.2.0.1.0                     VALID
XDB                  Oracle XML Database                                11.2.0.1.0                     VALID
CONTEXT              Oracle Text                                        11.2.0.1.0                     VALID
EXF                  Oracle Expression Filter                           11.2.0.1.0                     VALID
RUL                  Oracle Rules Manager                               11.2.0.1.0                     VALID
OWM                  Oracle Workspace Manager                           11.2.0.1.0                     VALID
CATALOG              Oracle Database Catalog Views                      11.2.0.1.0                     VALID
CATPROC              Oracle Database Packages and Types                 11.2.0.1.0                     VALID
JAVAVM               JServer JAVA Virtual Machine                       11.2.0.1.0                     VALID
XML                  Oracle XDK                                         11.2.0.1.0                     VALID
CATJAVA              Oracle Database Java Packages                      11.2.0.1.0                     VALID
APS                  OLAP Analytic Workspace                            11.2.0.1.0                     VALID
XOQ                  Oracle OLAP API                                    11.2.0.1.0                     VALID
18 rows selected.

--�鿴�������
sys@ORCL>select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;
ACTION_TIME                                                                 ACTION                         COMMENTS
--------------------------------------------------------------------------- ------------------------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
13-APR-18 02.49.17.927405 PM                                                APPLY                          Patchset 11.2.0.2.0
17-SEP-19 11.20.23.422910 AM                                                APPLY                          PSU 11.2.0.4.190716

--�鿴��Ч����
sys@ORCL>select count(*) from dba_objects where status<>'VALID';
  COUNT(*)
----------
       123
sys@ORCL> select object_name,object_type,owner,status from dba_objects where status<>'VALID';
sys@ORCL>spool off



##����
1�����ݹ۲죬��Ҫ����$ORACLE_HOME(/u01/app/oracle/product/11.2.0/db_1)�µ��ļ���$GRID_HOME�µ��ļ���

--�����ļ��Ĵ��λ�ã�
1����װ���������У�oracle��grid�û���ȥ���ʣ���������ļ��У�����Ҫ����Ȩ�ޣ�һ�����/home/oracle�ǿ��Եģ�
����Ȩ�ޣ�chown -R oracle.oinstall patch

################��ʵ��#################
##�汾�򲹶���ʼ
----�رռ���
----�ر����ݿ�
----����OGG����ر����н��̼�MGR��
1������ͻ
su - oracle
cd /home/oracle/29497421
opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir ./

2������OCM�ļ�����oracle�汾��1901��ʼ����ҪOCM�ļ�
[oracle@racnode01 ~]$ $ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /home/oracle/ocm.rsp
1���س�
2��Y

3����װ����
cd /home/oracle/29497421
opatch apply -silent -ocmrf /home/oracle/ocm.rsp

4��SQL������Ϣ
-database
cd $ORACLE_HOME/rdbms/admin
SQL> sqlplus / as sysdba
SQL> STARTUP
SQL> @catbundle.sql psu apply
SQL> QUIT

-if the OJVM PSU was applied
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> @utlrp.sql

-this patch now includes the OJVM Mitigation patch (Patch:19721304)
SQL > @dbmsjdev.sql
SQL > exec dbms_java_dev.disable

5��������
-��鲹��
sys@ORCL>select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;

-�鿴oracleĿ¼�Ĳ�����Ϣ
su - oracle 
opatch lsinventory

##��������
1���ر����ݿ�
2��su - oracle
opatch rollback -id 29497421
���룺y

3�����ݿ�ִ�л���
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> STARTUP
SQL> @catbundle_PSU_<database SID>_ROLLBACK.sql //�����ļ������ڣ������У�@catbundle.sql psu ROLLBACK 
SQL> QUIT

4������ʧЧ����
SQL>@utlrp.sql

5���鿴������Ϣ
sys@ORCL>select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;
13-APR-18 02.49.17.927405 PM                                                APPLY                          Patchset 11.2.0.2.0
17-SEP-19 11.20.23.422910 AM                                                APPLY                          PSU 11.2.0.4.190716
17-SEP-19 02.41.47.530056 PM                                                ROLLBACK                       PSU 11.2.0.4.190716
17-SEP-19 02.41.47.890897 PM                                                APPLY                          Patchset 11.2.0.2.0

[oracle@ctaisdb admin]$ opatch lsinventory

##�ļ����ݻ���
1����root�û������ļ��ĸ���
[root@ctaisdb ~]# cd /u01/app/oracle/product/11.2.0
[root@ctaisdb 11.2.0]# cp -rp /u01/app/oracle_bak/product/11.2.0/db_1 .


2��opath���ˣ��ᱨ��û�취
[oracle@ctaisdb ~]$ opatch rollback -id 29497421
Argument(s) Error... Patch not present in the Oracle Home, Rollback cannot proceed
OPatch failed with error code 135

3�����ݿ����
SQL> @catbundle_PSU_<database SID>_ROLLBACK.sql //�����ļ������ڣ������У�@catbundle.sql psu ROLLBACK 
SQL> @utlrp.sql

4��������ǵ�����һ������ֻ�ܱ�֤�����ݿ�����ã����Ǻ����ᷢ��ʲô���⣬û�취ȷ����
SQL> select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;

ACTION_TIME                                                                 ACTION                         COMMENTS
--------------------------------------------------------------------------- ------------------------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
13-APR-18 02.49.17.927405 PM                                                APPLY                          Patchset 11.2.0.2.0
17-SEP-19 11.20.23.422910 AM                                                APPLY                          PSU 11.2.0.4.190716
17-SEP-19 02.41.47.530056 PM                                                ROLLBACK                       PSU 11.2.0.4.190716
17-SEP-19 02.41.47.890897 PM                                                APPLY                          Patchset 11.2.0.2.0
17-SEP-19 02.52.43.149578 PM                                                APPLY                          PSU 11.2.0.4.190716
17-SEP-19 03.07.36.611796 PM                                                ROLLBACK                       Patchset 11.2.0.2.0



################RAC#################
--��OGGҪ�ر�OGG��MGR�����н���
--������ݿ�״̬
1���ֱ������ڵ�1�ͽڵ�2��ORACLE_HOME��GRID_HOME��opatch�ļ�����֤���°汾��
2���ֱ���oracle��grid�û���profile������opatch�Ļ������� 
(PATH=$PATH:$HOME/bin:$ORACLE_HOME/OPatch)
3��������rootȥִ�еĲ��������Ծ�ֱ�Ӹ�root�Ļ���������oracle��opatch�Ļ�������
vim ~/.bash_profile
PATH=$crs_bin:$PATH:/u01/app/oracle/product/11.2.0/db_1/OPatch
4������patch��OCM�ļ��Ĵ���ļ��У�oracle��grid�û���ȥ���ʣ���������ļ��У�����Ҫ����Ȩ�ޡ�
mkdir /patch
chown -R oracle.oinstall /patch
��������OCM���Ž�ȥ��ȥ���ٸ�Ȩ�ޣ�
-��oracleȥ��ѹѹ������OPATCH�����

[root@racnode01 ~]# crsctl stat res -t
#######Ϊ���գ��ڽڵ�1�ϴ򲹶����رսڵ�2��CRS����
���ڴ����ORACLE_HOME��GRID_HOME�Ĳ����������ڴ򲹶��Ĺ����У�����������Զ���ͣRAC��CRS��

--����ǰ���
���ORACLE_HOMEȷ��oracleĿ¼����ȷ�ԣ�
su - oracle
[oracle@racnode01 29698727]$ 
opatch lsinventory -detail -oh $ORACLE_HOME
opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir ./

su - grid
[oracle@racnode01 29698727]$ 
opatch lsinventory -detail -oh $ORACLE_HOME
opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir ./

##����oracle��grid���������ֹͣ��Ⱥ�����ݿ⣬����Ҫ���ݣ�����Ҫ������
���ݽڵ�1���ڵ�2��oracle_home��grid_home
su - root
cd /u01/app/oracle/product/11.2.0
cp -rp db_1 db_1_bak (��Ȩ�޵Ŀ���)

su - grid
cd /u01/app/11.2.0
cp -rp grid grid_bak


2��Patching Oracle RAC Database Homes and GI Together
@1����oracle�û�����OCM�ļ�,oracle��grid��Ҫ����
su - oracle
[oracle@racnode01 ~]# $ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /patch/ocm.rsp
Email address/User Name:  �س�
Do you wish to remain uninformed of security issues ([Y]es, [N]o) [N]:  Y

@2����root�û�����ÿ���ڵ���ִ�в��������As root user, execute the following command on each node of the cluster��:
�ڵ�1���ڵ�2ִ�У�
su - root
[root@racnode01 29699309]# pwd
/home/oracle/29699309
[root@racnode01 29699309]# opatch auto 29698727 -ocmrf /patch/ocm.rsp
--Ҳ�������oracle_home��grid_home�ֱ�򲹶�
opatch auto 29698727 -oh '/u01/app/11.2.0/grid' -ocmrf /patch/ocm.rsp
--�������ĳһ�������ļ�����oracle����grid�Ĳ�������rootִ��

3��������
su - oracle
[oracle@racnode01 ~]$ opatch lsinventory
-���Կ������θ��µİ����ļ���
Interim patches (2) :
Patch  29141201     : applied on Wed Sep 18 11:48:12 CST 2019
Patch  29497421     : applied on Tue Sep 17 15:47:03 CST 2019

su - grid
[grid@racnode01 ~]$ opatch lsinventory
Patch  29509309     : applied on Wed Sep 18 11:55:06 CST 2019
Patch  29497421     : applied on Wed Sep 18 11:53:28 CST 2019
Patch  29141201     : applied on Wed Sep 18 11:51:43 CST 2019

4�����ݿ����
���µĸ��ģ�ֻ��һ���ڵ�ִ��
--Ĭ�ϼ�Ⱥ�ڴ򲹶���ɺ��Զ�����
cd $ORACLE_HOME/rdbms/admin
SQL> @catbundle.sql psu apply
SQL> @utlrp.sql
SQL>select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;


##��������
1���ڽڵ�1���ڵ�2��ִ�У�root�û�
cd /home/oracle/29699309
opatch auto 29698727 -rollback -ocmrf /root/ocm.rsp
-���ڽڵ�1��ִ������˺󣬻���ʾ��
-----
Starting RAC /u01/app/oracle/product/11.2.0/db_1 ...
 Failed to start resources from  database home /u01/app/oracle/product/11.2.0/db_1
ERROR: Refer log file for more details.
opatch auto failed.
-----
������Ϊ�����ڵ�1�Ŀ��ʱ�򣬷�����2��һ�£��ɺ��Դ���ȥ���ڵ�2�Ļ���
-���ڵ�2������ɺ�ʵ��1��Instance Shutdown��ʵ��2��Open����ʱ�ڽڵ�2��ִ�����ݿ���ˡ�

2��ֻ��һ���ڵ���ִ��
cd $ORACLE_HOME/rdbms/admin
SQL> @catbundle_PSU_<database SID PREFIX>_ROLLBACK.sql
SQL> @utlrp.sql

3��������

##�ļ����ˣ���Ҫ�رսڵ�1���ڵ�2��CRS���񣬰ѱ��ݵ��ļ������ǻ�ȥ��
1�����������ļ�
2��������״̬


#######################QA �������#############################
1��2019-09-20 15:59:34: Starting Clusterware Patch Setup
Using configuration parameter file: /u01/11.2.0/grid/crs/install/crsconfig_params
unable to get oracle owner for 

��ȡoracle_home�����⣬��Ҫ���ò�����
[root@sc-wsbs-db1 29699309]# export LANG=C

2������ռ�ã�����patchʧ��
[root@oggdb ~]#/sbin/fuser /home/oracle/app/oracle/product/11.2.0/dbhome_1/lib/libclntsh.so.11.1
/home/oracle/app/oracle/product/11.2.0/dbhome_1/lib/libclntsh.so.11.1: 31007m 45643m 63912m 72481m 78955m 81247m 93505m 93682m
[root@oggdb ~]# kill -9 31007 63912 72481 78955 81247 93505 93682

3��id command not avaliable!��opatch auto can not proceed without id command!
root�Ļ������������⣬��Ҫ��ӣ�
[root@rac2 ~]# which id
/usr/bin/id

PATH=$crs_bin:$PATH:$HOME/bin:$ORACLE_HOME/OPatch:/usr/bin


















##############PS���ο���Ϣ###############
5����װ������Oracle������֣�
���ȣ�ͨ��opatch lsinventory �鿴֮ǰ����Ĳ�����Ϣ��
Ȼ���ѹ�������ļ���
���ƴ����������:

[oracle@data psu_jul_2011]$ unzip p12419378_112010_Linux-x86-64.zip
[oracle@data psu_jul_2011]$ cd 12419378

����ڲ�������Ŀ¼��ִ��opatch apply���ȴ�5~10���Ӽ��ɣ�ע�⣺һ��Ҫ����ȫ�ر����ݿ�ͼ�������
���ƴ����������:

[oracle@data 12419378]$ pwd
/home/oracle/psu_jul_2011/12419378
[oracle@data 12419378]$ opatch apply

��������warningsһ�㶼ûʲô���⣬ֻҪ����error�ͺá�
--ȷ�������Ƿ�װ�ɹ�
opatch lsinventory
--�����RAC����Ҫ�����ڵ㶼�򲹶���Ȼ������Ľű�����Զ��һ�����ݿ���ֻ��һ�Ρ�

6����װ���������ݿⲿ�֣�
�ⲽ�Ƚϼ򵥣������ܽű�����ʱ��Ƚϳ���10�������ң��ӻ������ܶ�����
���ƴ����������:

--��ʵ��
cd $ORACLE_HOME/sqlpatch/29251270
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> startup upgrade
SQL> @postinstall.sql
SQL> shutdown
SQL> startup

--RAC
cd $ORACLE_HOME/sqlpatch/29251270
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> STARTUP
SQL> alter system set cluster_database=false scope=spfile;
SQL> SHUTDOWN
SQL> STARTUP UPGRADE
SQL> @postinstall.sql
SQL> alter system set cluster_database=true scope=spfile;
SQL> SHUTDOWN
SQL> STARTUP 


7�����±�����Ч�Ķ���
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> @utlrp.sql

8���º���
���ƴ����������:

set line 150
set pagesize 99
col action_time for a30
col action for a30
col comments for a90
col object_name for a30
col object_type for a30
col comp_name for a50
col comp_id for a20
spool post_check.log
select instance_name,status from v$instance;
select COMP_ID,COMP_NAME,VERSION,STATUS from DBA_REGISTRY;
select ACTION_TIME, ACTION, COMMENTS from DBA_REGISTRY_HISTORY;
select owner,object_name,object_type,status from dba_objects where status<>'VALID';
select count(*) from dba_objects where status<>'VALID';
spool off

##opath auto
========PS:�����ĵ���д����opatch apply�ķ�����һ�㶼oracle�û�ȥ���ģ������oracle_home�µĲ���================
ʹ��opath auto��ʹ�õ�oralce�µ�Opatch ��grid�û��µ�Opatch��Ҫ��Opatch�İ汾���ͣ���ͬʱ�滻�����û��µ�Opatch�����°汾��
-oracle opatch�滻
[root@racnode02 package]# cd /u01/app/oracle/product/11.2.0/db_1/
[root@racnode02 db_1]# mv OPatch OPatch_20190624
[root@racnode02 db_1]# cp -r /package/OPatch .
[root@racnode02 db_1]# chown -R oracle.oinstall OPatch

-grid opatch�滻
[root@racnode02 grid]# cd /u01/app/11.2.0/grid
[root@racnode02 grid]# mv OPatch OPatch_20190624
[root@racnode02 grid]# cp -r /package/OPatch .
root@racnode02 grid]# chown -R grid.oinstall OPatch

-����ocm.rsp�ļ�
su - oracle
[oracle@racnode01 ~]$ $ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /home/oracle/ocm.rsp
1���س�
2��Y
--�ر����ݿ�
srvctl stop database -d racdb

1��Validation of Oracle Inventory
$ORACLE_HOME/OPatch/opatch lsinventory -detail -oh $ORACLE_HOME

2��Stop EM Agent Processes Prior to Patching and Prior to Rolling Back the Patch
[oracle@racnode01 ~]$ $ORACLE_HOME/bin/emctl stop dbconsole

3��Patching Oracle RAC Database Homes and GI Together
su - root 
source /home/oracle/.bash_profile  
$ORACLE_HOME/OPatch/opatch  auto /package/29252208/29255947 -ocmrf /home/oracle/ocm.rsp

4��ȷ�������Ƿ�װ�ɹ�
-�鿴oracleĿ¼�Ĳ���
su - oracle 
opatch lsinventory
-�鿴gridĿ¼�Ĳ���
su - grid 
opatch lsinventory

6��Loading Modified SQL Files into the Database
--RAC���ݿ⣬��һ���ڵ���ִ�оͿ����ˡ�
The following steps load modified SQL files into the database. For an Oracle RAC environment, perform these steps on only one node.

cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> STARTUP
SQL> @catbundle.sql psu apply
SQL> QUIT

-����ʧЧ�Ķ���
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> @utlrp.sql
Check the following log files in $ORACLE_BASE/cfgtoollogs/catbundle for any errors:

catbundle_PSU_<database SID>_APPLY_<TIMESTAMP>.log
catbundle_PSU_<database SID>_GENERATE_<TIMESTAMP>.log

This patch now includes the OJVM Mitigation patch (Patch:19721304). If an OJVM PSU is installed or planned to be installed, no further actions are necessary. Otherwise, the workaround of using the OJVM Mitigation patch can be activated. As SYSDBA do the following from the admin directory:

SQL > @dbmsjdev.sql
SQL > exec dbms_java_dev.disable

##��������
su - root
source /home/oracle/.bash_profile
$ORACLE_HOME/OPatch/opatch auto /package/29252208/29255947 -rollback -ocmrf /home/oracle/ocm.rsp

-ȷ�ϻ���
su - oracle 
opatch lsinventory

su - grid
opatch lsinventory

-SQL����
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> STARTUP
SQL> @catbundle_PSU_RACDB_ROLLBACK.sql      db_unique_name=RACDB
SQL> QUIT

-����ʧЧ����
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> @utlrp.sql


##opatch apply
su - oracle
unzip p29141056_112040_<platform>.zip
cd 29141056
opatch apply

--�ر����ݿ�
srvctl stop database -d racdb

-�鿴oracleĿ¼�Ĳ���
su - oracle 

--���������������ݿ����������������ݿ�
srvctl stop database -d racdb
srvctl start database -d racdb
srvctl status database -d racdb

--֮���ٽ������ݿ�ĵ�¼��ִ��SQL�ű�

For each database instance running on the Oracle home being patched, connect to the database using SQL*Plus. Connect as SYSDBA, make sure invalid objects are set to zero, if the invalid objects are non-zero, use utlrp.sql. Then run the catbundle.sql script as follows:

cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> STARTUP
SQL> @catbundle.sql psu apply
SQL> QUIT
The catbundle.sql execution is reflected in the dba_registry_history view by a row associated with bundle series PSU.

For information about the catbundle.sql script, see My Oracle Support Document 605795.1 Introduction to Oracle Database catbundle.sql.

If the OJVM PSU was applied for a previous PSU patch, you may see invalid Java classes after execution of the catbundle.sql script in the previous step. If this is the case, run utlrp.sql to re-validate these Java classes.

cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> @utlrp.sql
Check the following log files in $ORACLE_HOME/cfgtoollogs/catbundle or $ORACLE_BASE/cfgtoollogs/catbundle for any errors:

catbundle_PSU_<database SID>_APPLY_<TIMESTAMP>.log
catbundle_PSU_<database SID>_GENERATE_<TIMESTAMP>.log
where TIMESTAMP is of the form YYYYMMMDD_HH_MM_SS. If there are errors, refer to Known Issues.

This patch now includes the OJVM Mitigation patch (Patch:19721304). If an OJVM PSU is installed or planned to be installed, no further actions are necessary. Otherwise, the workaround of using the OJVM Mitigation patch can be activated. As SYSDBA do the following from the admin directory:

SQL > @dbmsjdev.sql
SQL > exec dbms_java_dev.disable