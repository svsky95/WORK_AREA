##oracle PSU 打补丁

什么是CPU/PSU

Oracle CPU的全称是Critical Patch Update, Oracle对于其产品每个季度发行一次安全补丁包，通常是为了修复产品中的安全隐患。

Oracle PSU的全称是Patch Set Update，Oracle对于其产品每个季度发行一次的补丁包，包含了bug的修复。Oracle选取被用户下载数量多，且被验证过具有较低风险的补丁放入到每个季度的PSU中。在每个PSU中不但包含Bug的修复而且还包含了最新的CPU。PSU通常随CPU一起发布。

CPU是累积的（Cumulative），即最新的CPU补丁已经包含以往的CPU补丁，所以只要安装最新的CPU补丁即可。
PSU通常也是增量的，大部分PSU可以直接安装，但有些PSU则必须要求安装了上一 个版本的PSU之后才能继续安装，要仔细看各个PSU的Readme文档。

如何下载CPU/PSU

注意：要下载CPU/PSU，必须要有Oracle Support账号才行！
到Oracle CPU主页 ，可以看到每个季度发布的CPU补丁列表（如下图所示），根据你的需要选择相应的CPU补丁即可，这里选择July2011年的补丁。

每个补丁只针对特定的数据库版本，你要找到对应的数据库版本（如下图所示），这里的数据库版本为11.2.0.1，如果找不到，说明该补丁不支持该版本数据库。

右边点击Database链接，就是该补丁的一个详细说明文档，找到3.1.3 Oracle Database，并点击相应的数据库版本（如下图所示）

在相应的数据库版本里，可以看到各个平台下CPU和PSU版本号，前面已经说过，PSU包含CPU，所以建议尽量安装PSU，注意：这里的UNIX平台也包括Linux

点击上面的版本号，会自动跳到Oracle Support下载页面，如下图所示。选择相应的平台后，点击Readme可以查看Readme文档，点击Download下载
阅读Readme文档
每个CPU/PSU都有一个Readme文档，关于该CPU/PSU的所有信息都在Readme文档里，一定要仔细阅读。
有两个部分要特别注意：
1）OPatch的版本，你可以通过opatch version命令查看Oracle Home当前的OPatch版本，如果低于Readme规定的最低版本，一定要先升级OPatch才能打补丁。
2）打Patch步骤：基本上所有的CPU/PSU都大同小异，具体步骤将在下面的例子中展示。
安装CPU/PSU补丁
1）事先检查：查看数据库打补丁前信息，保留现场
在打补丁前最好把数据库的一些基本信息保留下来，以备不时之需。

##patch说明
Combo Patch~
对于Oracle Database产品的PSU来说，目前出现了3种补丁
1. RDBMS 的PSU — DB PSU （使用opatch apply安装，可以对rdbms，client安装patch）
2. GI的PSU — GI PSU （这种PSU是GI+DB PSU的组合里面有两个目录一个是gi的patch，一个是db patch，使用opatch auto自动安装，会将GI和及下注册的RDBMS一起安装patch；也可以使用db patch目录中的文件对client进行升级）
3. OJVM的PSU — 包含gi，rdbms，client中所有针对java组件的patch
将以上3种不同的PSU打包在一起就形成了Combo Patch，这种PSU目录结构很简单，一共三个目录：
1. GI PSU（如上面所说，这个目录下又有两个子目录，一个值GI的patch，一个就是DB patch）
2. 最新版OJVM PSU
3. 第一版OJVM PSU — JDBC patch
所以，其实你仅仅需要下载Combo Patch就可以了，因为里面已经包含了所有PSU~

注意带有:	QUARTERLY EXADATA DATABASE是用不上的
 
#######################打补丁前的准备工作#######################
1、有OGG要关闭OGG的MGR及所有进程
##操作如下：
--查看opatch版本   --如果版本低，需要mos下载新的OPatch软件包
cd $ORACLE_HOME/OPatch
./opatch version

OPatch Version: 11.2.0.3.4
OPatch succeeded.

版本不足请升级包：
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

-添加opatch变量
vim ~/.bash_profile
PATH=$PATH:$HOME/bin:/u01/app/oracle/product/11.2.0/db_1/OPatch
export PATH=$PATH:/usr/ccs/bin
source ~/.bash_profile 
 
--查看实例名
sys@ORCL>select instance_name,status from v$instance;
INSTANCE_NAME    STATUS
---------------- ------------
orcl             OPEN

--查看数据库版本
sys@ORCL>select * from v$version;
BANNER
--------------------------------------------------------------------------------
Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production
PL/SQL Release 11.2.0.1.0 - Production
CORE    11.2.0.1.0      Production
TNS for Linux: Version 11.2.0.1.0 - Production
NLSRTL Version 11.2.0.1.0 - Production

--查看数据库大小
sys@ORCL>select sum(bytes)/1024/1024/1024||'G' from dba_segments;
SUM(BYTES)/1024/1024||'G'
-----------------------------------------
68058.375G

--查看组件信息
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

--查看补丁情况
sys@ORCL>select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;
ACTION_TIME                                                                 ACTION                         COMMENTS
--------------------------------------------------------------------------- ------------------------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
13-APR-18 02.49.17.927405 PM                                                APPLY                          Patchset 11.2.0.2.0
17-SEP-19 11.20.23.422910 AM                                                APPLY                          PSU 11.2.0.4.190716

--查看无效对象
sys@ORCL>select count(*) from dba_objects where status<>'VALID';
  COUNT(*)
----------
       123
sys@ORCL> select object_name,object_type,owner,status from dba_objects where status<>'VALID';
sys@ORCL>spool off



##备份
1、根据观察，需要备份$ORACLE_HOME(/u01/app/oracle/product/11.2.0/db_1)下的文件及$GRID_HOME下的文件。

--补丁文件的存放位置：
1、安装补丁过程中，oracle及grid用户会去访问，这个补丁文件夹，所以要都有权限，一般放在/home/oracle是可以的，
赋予权限：chown -R oracle.oinstall patch

################单实例#################
##版本打补丁开始
----关闭监听
----关闭数据库
----如有OGG，请关闭所有进程及MGR。
1、检查冲突
su - oracle
cd /home/oracle/29497421
opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir ./

2、生成OCM文件，从oracle版本的1901开始，需要OCM文件
[oracle@racnode01 ~]$ $ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /home/oracle/ocm.rsp
1、回车
2、Y

3、安装补丁
cd /home/oracle/29497421
opatch apply -silent -ocmrf /home/oracle/ocm.rsp

4、SQL更新信息
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

5、检查更新
-检查补丁
sys@ORCL>select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;

-查看oracle目录的补丁信息
su - oracle 
opatch lsinventory

##补丁回退
1、关闭数据库
2、su - oracle
opatch rollback -id 29497421
输入：y

3、数据库执行回退
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> STARTUP
SQL> @catbundle_PSU_<database SID>_ROLLBACK.sql //若此文件不存在，则运行：@catbundle.sql psu ROLLBACK 
SQL> QUIT

4、编译失效对象
SQL>@utlrp.sql

5、查看回退信息
sys@ORCL>select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;
13-APR-18 02.49.17.927405 PM                                                APPLY                          Patchset 11.2.0.2.0
17-SEP-19 11.20.23.422910 AM                                                APPLY                          PSU 11.2.0.4.190716
17-SEP-19 02.41.47.530056 PM                                                ROLLBACK                       PSU 11.2.0.4.190716
17-SEP-19 02.41.47.890897 PM                                                APPLY                          Patchset 11.2.0.2.0

[oracle@ctaisdb admin]$ opatch lsinventory

##文件备份回退
1、用root用户进行文件的复制
[root@ctaisdb ~]# cd /u01/app/oracle/product/11.2.0
[root@ctaisdb 11.2.0]# cp -rp /u01/app/oracle_bak/product/11.2.0/db_1 .


2、opath回退，会报错，没办法
[oracle@ctaisdb ~]$ opatch rollback -id 29497421
Argument(s) Error... Patch not present in the Oracle Home, Rollback cannot proceed
OPatch failed with error code 135

3、数据库回退
SQL> @catbundle_PSU_<database SID>_ROLLBACK.sql //若此文件不存在，则运行：@catbundle.sql psu ROLLBACK 
SQL> @utlrp.sql

4、如果这是到了这一步，那只能保证，数据库可以用，但是后续会发生什么问题，没办法确定。
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
--有OGG要关闭OGG的MGR及所有进程
--检查数据库状态
1、分别升级节点1和节点2，ORACLE_HOME及GRID_HOME的opatch文件，保证最新版本。
2、分别在oracle和grid用户的profile中配置opatch的环境变量 
(PATH=$PATH:$HOME/bin:$ORACLE_HOME/OPatch)
3、由于是root去执行的补丁，所以就直接给root的环境中配置oracle的opatch的环境变量
vim ~/.bash_profile
PATH=$crs_bin:$PATH:/u01/app/oracle/product/11.2.0/db_1/OPatch
4、创建patch、OCM文件的存放文件夹，oracle及grid用户会去访问，这个补丁文件夹，所以要都有权限。
mkdir /patch
chown -R oracle.oinstall /patch
补丁包及OCM都放进去进去后，再给权限：
-用oracle去解压压缩包及OPATCH软件。

[root@racnode01 ~]# crsctl stat res -t
#######为保险，在节点1上打补丁，关闭节点2的CRS服务。
由于打的是ORACLE_HOME及GRID_HOME的补丁，所以在打补丁的过程中，补丁程序会自动启停RAC及CRS。

--补丁前检查
检查ORACLE_HOME确保oracle目录的正确性：
su - oracle
[oracle@racnode01 29698727]$ 
opatch lsinventory -detail -oh $ORACLE_HOME
opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir ./

su - grid
[oracle@racnode01 29698727]$ 
opatch lsinventory -detail -oh $ORACLE_HOME
opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir ./

##备份oracle、grid的软件，不停止集群及数据库，必须要备份，很重要！！！
备份节点1、节点2的oracle_home及grid_home
su - root
cd /u01/app/oracle/product/11.2.0
cp -rp db_1 db_1_bak (带权限的拷贝)

su - grid
cd /u01/app/11.2.0
cp -rp grid grid_bak


2、Patching Oracle RAC Database Homes and GI Together
@1、用oracle用户生成OCM文件,oracle和grid都要访问
su - oracle
[oracle@racnode01 ~]# $ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /patch/ocm.rsp
Email address/User Name:  回车
Do you wish to remain uninformed of security issues ([Y]es, [N]o) [N]:  Y

@2、用root用户，在每个节点上执行补丁命令。（As root user, execute the following command on each node of the cluster）:
节点1、节点2执行：
su - root
[root@racnode01 29699309]# pwd
/home/oracle/29699309
[root@racnode01 29699309]# opatch auto 29698727 -ocmrf /patch/ocm.rsp
--也可以针对oracle_home及grid_home分别打补丁
opatch auto 29698727 -oh '/u01/app/11.2.0/grid' -ocmrf /patch/ocm.rsp
--可以针对某一个补丁文件，打oracle或者grid的补丁，用root执行

3、检查更新
su - oracle
[oracle@racnode01 ~]$ opatch lsinventory
-可以看到本次更新的包的文件名
Interim patches (2) :
Patch  29141201     : applied on Wed Sep 18 11:48:12 CST 2019
Patch  29497421     : applied on Tue Sep 17 15:47:03 CST 2019

su - grid
[grid@racnode01 ~]$ opatch lsinventory
Patch  29509309     : applied on Wed Sep 18 11:55:06 CST 2019
Patch  29497421     : applied on Wed Sep 18 11:53:28 CST 2019
Patch  29141201     : applied on Wed Sep 18 11:51:43 CST 2019

4、数据库更新
以下的更改，只在一个节点执行
--默认集群在打补丁完成后，自动启动
cd $ORACLE_HOME/rdbms/admin
SQL> @catbundle.sql psu apply
SQL> @utlrp.sql
SQL>select ACTION_TIME, ACTION, COMMENTS from sys.DBA_REGISTRY_HISTORY;


##补丁回退
1、在节点1、节点2上执行，root用户
cd /home/oracle/29699309
opatch auto 29698727 -rollback -ocmrf /root/ocm.rsp
-当在节点1上执行完回退后，会提示：
-----
Starting RAC /u01/app/oracle/product/11.2.0/db_1 ...
 Failed to start resources from  database home /u01/app/oracle/product/11.2.0/db_1
ERROR: Refer log file for more details.
opatch auto failed.
-----
这是因为启动节点1的库的时候，发现与2不一致，可忽略错误，去做节点2的回退
-当节点2回退完成后，实例1是Instance Shutdown，实例2是Open，这时在节点2上执行数据库回退。

2、只在一个节点上执行
cd $ORACLE_HOME/rdbms/admin
SQL> @catbundle_PSU_<database SID PREFIX>_ROLLBACK.sql
SQL> @utlrp.sql

3、检查回退

##文件回退，需要关闭节点1、节点2的CRS服务，把备份的文件，覆盖回去。
1、回退数据文件
2、检查回退状态


#######################QA 报错解析#############################
1、2019-09-20 15:59:34: Starting Clusterware Patch Setup
Using configuration parameter file: /u01/11.2.0/grid/crs/install/crsconfig_params
unable to get oracle owner for 

获取oracle_home有问题，需要设置参数：
[root@sc-wsbs-db1 29699309]# export LANG=C

2、进程占用，导致patch失败
[root@oggdb ~]#/sbin/fuser /home/oracle/app/oracle/product/11.2.0/dbhome_1/lib/libclntsh.so.11.1
/home/oracle/app/oracle/product/11.2.0/dbhome_1/lib/libclntsh.so.11.1: 31007m 45643m 63912m 72481m 78955m 81247m 93505m 93682m
[root@oggdb ~]# kill -9 31007 63912 72481 78955 81247 93505 93682

3、id command not avaliable!、opatch auto can not proceed without id command!
root的环境变量有问题，需要添加：
[root@rac2 ~]# which id
/usr/bin/id

PATH=$crs_bin:$PATH:$HOME/bin:$ORACLE_HOME/OPatch:/usr/bin


















##############PS：参考信息###############
5）安装补丁（Oracle软件部分）
首先，通过opatch lsinventory 查看之前打过的补丁信息。
然后解压缩补丁文件：
复制代码代码如下:

[oracle@data psu_jul_2011]$ unzip p12419378_112010_Linux-x86-64.zip
[oracle@data psu_jul_2011]$ cd 12419378

最后在补丁的主目录下执行opatch apply，等待5~10分钟即可（注意：一定要先完全关闭数据库和监听器）
复制代码代码如下:

[oracle@data 12419378]$ pwd
/home/oracle/psu_jul_2011/12419378
[oracle@data 12419378]$ opatch apply

如果最后有warnings一般都没什么问题，只要不是error就好。
--确定补丁是否安装成功
opatch lsinventory
--如果是RAC，需要两个节点都打补丁，然后，下面的脚本，永远在一个数据库上只做一次。

6）安装补丁（数据库部分）
这步比较简单，就是跑脚本，但时间比较长，10分钟左右（视机器性能而定）
复制代码代码如下:

--单实例
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


7、重新编译无效的对象
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> @utlrp.sql

8）事后检查
复制代码代码如下:

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
========PS:对于文档中写的用opatch apply的方法，一般都oracle用户去做的，打的是oracle_home下的补丁================
使用opath auto会使用到oralce下的Opatch 和grid用户下的Opatch，要是Opatch的版本过低，请同时替换两个用户下的Opatch到最新版本。
-oracle opatch替换
[root@racnode02 package]# cd /u01/app/oracle/product/11.2.0/db_1/
[root@racnode02 db_1]# mv OPatch OPatch_20190624
[root@racnode02 db_1]# cp -r /package/OPatch .
[root@racnode02 db_1]# chown -R oracle.oinstall OPatch

-grid opatch替换
[root@racnode02 grid]# cd /u01/app/11.2.0/grid
[root@racnode02 grid]# mv OPatch OPatch_20190624
[root@racnode02 grid]# cp -r /package/OPatch .
root@racnode02 grid]# chown -R grid.oinstall OPatch

-生成ocm.rsp文件
su - oracle
[oracle@racnode01 ~]$ $ORACLE_HOME/OPatch/ocm/bin/emocmrsp -no_banner -output /home/oracle/ocm.rsp
1、回车
2、Y
--关闭数据库
srvctl stop database -d racdb

1、Validation of Oracle Inventory
$ORACLE_HOME/OPatch/opatch lsinventory -detail -oh $ORACLE_HOME

2、Stop EM Agent Processes Prior to Patching and Prior to Rolling Back the Patch
[oracle@racnode01 ~]$ $ORACLE_HOME/bin/emctl stop dbconsole

3、Patching Oracle RAC Database Homes and GI Together
su - root 
source /home/oracle/.bash_profile  
$ORACLE_HOME/OPatch/opatch  auto /package/29252208/29255947 -ocmrf /home/oracle/ocm.rsp

4、确定补丁是否安装成功
-查看oracle目录的补丁
su - oracle 
opatch lsinventory
-查看grid目录的补丁
su - grid 
opatch lsinventory

6、Loading Modified SQL Files into the Database
--RAC数据库，在一个节点上执行就可以了。
The following steps load modified SQL files into the database. For an Oracle RAC environment, perform these steps on only one node.

cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> STARTUP
SQL> @catbundle.sql psu apply
SQL> QUIT

-编译失效的对象
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

##补丁回退
su - root
source /home/oracle/.bash_profile
$ORACLE_HOME/OPatch/opatch auto /package/29252208/29255947 -rollback -ocmrf /home/oracle/ocm.rsp

-确认回退
su - oracle 
opatch lsinventory

su - grid
opatch lsinventory

-SQL回退
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> STARTUP
SQL> @catbundle_PSU_RACDB_ROLLBACK.sql      db_unique_name=RACDB
SQL> QUIT

-编译失效对象
cd $ORACLE_HOME/rdbms/admin
sqlplus /nolog
SQL> CONNECT / AS SYSDBA
SQL> @utlrp.sql


##opatch apply
su - oracle
unzip p29141056_112040_<platform>.zip
cd 29141056
opatch apply

--关闭数据库
srvctl stop database -d racdb

-查看oracle目录的补丁
su - oracle 

--若出现连不上数据库的情况，请重启数据库
srvctl stop database -d racdb
srvctl start database -d racdb
srvctl status database -d racdb

--之后再进行数据库的登录和执行SQL脚本

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