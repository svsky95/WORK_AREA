##前置配置
参考11g的前置安装，完成相关参数的调整
yum install -y bc* \
binutils* \
compat-libcap1* \
compat-libstdc++* \
elfutils-libelf* \
elfutils-libelf-devel* \
fontconfig-devel* \
glibc* \
glibc-devel* \
ksh* \
libaio* \
libaio-devel* \
libX11* \
libXau* \
libXi* \
libXtst* \
libXrender* \
libXrender-devel* \
libgcc* \
libstdc++* \
libstdc++-devel* \
libxcb* \
make* \
smartmontools* \
gcc* \
sysstat* 

groupadd -g 1203 oinstall
groupadd -g 1200 asmadmin
groupadd -g 1201 asmdba
groupadd -g 1202 asmoper
groupadd -g 1208 backupdba
groupadd -g 1204 dgdba
groupadd -g 1205 kmdba
groupadd -g 1206 racdba
groupadd -g 1207 dba

/usr/sbin/useradd -u 54321 -g oinstall -G dba,asmdba,backupdba,dgdba,kmdba,racdba oracle
passwd oracle

mkdir -p /u01/app/oracle
mkdir -p /u01/app/oraInventory
chown -R oracle:oinstall /u01/app/oracle
chown -R oracle:oinstall /u01/app/oraInventory
chmod -R 775 /u01/app

vim .bash_profile                                                                                                                 
umask 022                                                                                                        
export ORACLE_SID=test19c                                                                                         
export ORACLE_BASE=/u01/app/oracle                                                                               
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/dbhome_1                                                           
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib                                                            
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"                                                                   
export TMP=/tmp                                                                                                  
export TMPDIR=$TMP                                                                                               
export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH                                                           
export EDITOR=vi                                                                                                 
export TNS_ADMIN=$ORACLE_HOME/network/admin                                                                      
export ORACLE_PATH=.:$ORACLE_BASE/dba_scripts/sql:$ORACLE_HOME/rdbms/admin                                       
export SQLPATH=$ORACLE_HOME/sqlplus/admin                                                                        
#export NLS_LANG="SIMPLIFIED CHINESE_CHINA.ZHS16GBK" --AL32UTF8 SELECT userenv('LANGUAGE') db_NLS_LANG FROM DUAL;
export NLS_LANG="AMERICAN_CHINA.ZHS16GBK" 

source ~/.bash_profile  

su - oracle 
mkdir -p /u01/app/oracle/product/19.0.0/dbhome_1
cd /u01/app/oracle/product/19.0.0/dbhome_1
mv /home/oracle/LINUX.X64_193000_db_home.zip .
chown -R oracle.oinstall LINUX.X64_193000_db_home.zip

unzip -q LINUX.X64_193000_db_home.zip
                       
cd /u01/app/oracle/product/19.0.0/dbhome_1
./runInstaller            

                                                                     

Oracle Multitenant Administrator's Guide for an introduction to CDBs and PDBs                      
Oracle Multitenant Administrator's Guide for information about managing CDBs and PDBs 

##Common Users in a CDB
在CDB和PDB之间有共有的用户可以访问：SYS and SYSTEM也是最大的权限，如果提示密码不正确，可以修改密码。    
A common user can log in to any container (including CDB$ROOT) in which it has the
CREATE SESSION privilege. 
sqlplus / as sysdba@root
SQL> alter user sys identified by cz123456;

##查看PDB及CDB的相关信息
SELECT * FROM gv$containers;

##PDB结构
独立的system、sysaux、undo、tmp、users每个pdb独立
共用online_redolog、共用archive_log

所有 PDB 共享 CDB 的控制文件、
日志文件和 UNDO 表空间，各个 PDB 之间互访需要通过 DB Link 进行

连接PDB：connect sys/foresee_abc@10.10.8.49:1521/pdb_t1 as sysdba

##查看当前容器：
select Sys_Context('Userenv', 'Con_Name') "current container" from dual;
SHOW con_name

##连接PDB
--直连PDB需要在tnsnames.ora中进行配置
sqlplus cz/cz@10.10.8.49:1521/PDB_T1
sqlplus sys/foresee_abc@pdb_t1 as sysdba 
sqlplus c##cz_com/cz_com@pdb_t1
alter session set container=PDB_T1; 

##连接CDB(root)
默认安装完成19C后，虽然有统一的密码，但是想通过plsqldev登录root，提示密码不正确，所以需要先改sys的密码
sqlplus / as sysdba@root
SQL> alter user sys identified by foresee_abc;

登录的时候的TNS就写CDB的服务名：
SQL> show parameter name 
service_names                        string                 test19c

登录后，会有cdb_开头的表，都为总管理的表。

##启用PDB并通过plsqldev连接
SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB_T1                         READ WRITE NO
         4 PDB_T2                         READ WRITE NO
         5 MY_PDB                         READ WRITE NO

SQL> alter session set container=PDB_T1; 

Session altered.

Elapsed: 00:00:00.12
SQL> alter pluggable database PDB_T1 open;

SQL> create user cz identified by cz;

User created.

Elapsed: 00:00:00.12
SQL> grant dba to cz;

Grant succeeded.

PDB_T1_8.49 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.10.8.49 )(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = PDB_T1)
    )
  )
  
##编辑sqlnet,由于版本升级到了12C，就导致客户端版本及JDBC版本较低
[oracle@ora19c admin]$ vim sqlnet.ora

NAMES.DIRECTORY_PATH= (TNSNAMES, ONAMES, HOSTNAME)

SQLNET.ALLOWED_LOGON_VERSION_CLIENT = 11

SQLNET.ALLOWED_LOGON_VERSION_SERVER = 11

  
##查看用户对应的PDB
select USERNAME, COMMON,CON_ID from cdb_users;

##创建comm_user用来连接所有的PDB
创建的所有comnon user必须以c##开头：
-登录root
sqlplus / as sysdba@root

SQL> create user c##cz_com identified by cz_com container=all;

User created.

SQL> grant dba to c##cz_com container=all;

Grant succeeded.

##创建PDB
CREATE PLUGGABLE DATABASE salesact01 ADMIN USER salesadm IDENTIFIED BY cz_123456;

##从现有PDB克隆新的PDB
SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 ORADBPDB1                      READ WRITE NO
         4 ORADBPDB2                      READ WRITE NO

SQL> alter pluggable database ORADBPDB1 close immediate;(rac环境需要在两个节点上执行)
SQL> alter pluggable database ORADBPDB1 open read only;(一个节点上执行)
SQL> create pluggable database ORADBPDB3 from ORADBPDB2;

SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 ORADBPDB1                      MOUNTED
         4 ORADBPDB2                      READ WRITE NO
         5 ORADBPDB3                      MOUNTED

alter pluggable database ORADBPDB3 open;(rac环境两个节点都要open)       

##删除PDB
SQL>  alter pluggable database ORADBPDB3 close immediate/abort;
SQL> drop pluggable database ORADBPDB3 including datafiles/KEEP DATAFILES;

#PDB的打开状态：
alter pluggable database CEPHK open;         --读写模式打开PDB
alter pluggable database CEPHK open read only;    --只读模式打开PDB
alter pluggable database CEPHK open RESTRICTED;   --禁止所有用户的访问
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         4 CEPHK                          READ WRITE YES
		 

#PDB的关闭状态：
alter pluggable database CEPHK close abort;       
alter pluggable database CEPHK close immediate;  


1、从源CDB中拔下PDB
ALTER PLUGGABLE DATABASE salesact UNPLUG INTO '/home/oracle/saleact.xml';

##实例关闭正常顺序
1、关闭所有的PDB
sqlplus / as sysdba@root
SQL> alter pluggable database all close immediate;

SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 ORADBPDB1                      MOUNTED
         4 ORADBPDB2                      MOUNTED

SQL> shutdown immedaite;

2、打开数据库
SQL> startup

SQL> alter pluggable database all open;

##参数修改
在12c rac之后的版本中,启动是不再有initoradb.ora的参数文件支持，也不再有spfile的指向ASM的条目，默认都是从ASM中启动spfile;
--以下命令，可以任意执行ASM中的参数文件
--当失败时，先从备份的pfile文件生成，再去指定，文件名可随意指定，两个节点分别执行
SQL> create spfile='+ORA_DATA/oradb/PARAMETERFILE/spfileoradb.ora' from pfile='/u01/app/oracle/product/12.2.0/db_1/dbs/initoradb2.ora'
[oracle@12cnod01 dbs]$ srvctl config database -db oradb
[oracle@12cnod01 dbs]$ srvctl modify database -db oradb -spfile +ORA_DATA/oradb/PARAMETERFILE/spfileoradb.ora


##调整PDB资源：
sqlplus / as sysdba@root

--为CDB创建pending area
exec dbms_resource_manager.create_pending_area();

--创建名为low_app的资源计划
begin
  dbms_resource_manager.create_cdb_plan(plan => 'low_app',comment => 'tools for priority');
end;
/

--给PDB：ORADBPDB1，份额为1（100/PDB的数量*1），资源使用限制50%，
begin
  dbms_resource_manager.create_cdb_plan_directive(plan => 'low_app',pluggable_database => 'ORADBPDB1',shares => 1,utilization_limit => 50,parallel_server_limit => 50);
end;
/

--验证和提交pending area
exec dbms_resource_manager.validate_pending_area();

exec dbms_resource_manager.submit_pending_area();

--执行当前pending area
alter system set resource_manager_plan='low_app';

--查看资源计划
SELECT * FROM dba_cdb_rsrc_plan_directives t;

##理解参数更改作用域
由于CDB是数据库实例，而PDB共享该实例，因此有一些CDB参数应用于CDB和所有PDB，不能针对任何给定的PDB加以修改。
通过：v$parameter的ISPDB_MODIFIABLE列，来识别PDB级别及CDB级别，即是克隆或者拔下某个PDB，本地的设置仍保留在该PDB中。
SELECT t."INST_ID",t."NAME",t."DISPLAY_VALUE",t."ISSES_MODIFIABLE",t."ISSYS_MODIFIABLE",t."ISPDB_MODIFIABLE" FROM gv$parameter t where t."NAME" like '%&para_name%' order by t."NAME",t."INST_ID";
--查看已经在PDB中修改了的参数
SELECT t.inst_id,t.name,a.name,a.value$ FROM pdb_spfile$ a,gv$pdbs t WHERE a.pdb_uid=t.dbid order by a.name,t."NAME",t."INST_ID";

--参数视图(动态参数与静态参数)
SELECT t."INST_ID",t."NAME",t."DISPLAY_VALUE",t."ISSES_MODIFIABLE",t."ISSYS_MODIFIABLE",t."ISPDB_MODIFIABLE" FROM gv$parameter t where t."NAME" like '%&para_name%' order by t."NAME",t."INST_ID";
-DISPLAY_VALUE     格式化后大小
-ISSES_MODIFIABLE  会话级别是否可以改变
-ISSYS_MODIFIABLE  系统级别： IMMEDIATE（立即生效，不重启实例）  DEFERRED（延期生效） FALSE（重启实例生效）
-ISPDB_MODIFIABLE  在PDB级别是否可以修改，若是FALSE,说明只能从CDB中继承。

在rac环境中，修改参数时，ISSYS_MODIFIABLE=IMMEDIATE，但是报：ORA-32018: parameter cannot be modified in memory on another instance
可以在两个节点上分别执行：
alter system set sga_target=3G scope=both sid='oradb1';
alter system set sga_target=3G scope=both sid='oradb2';

--SGA和PGA
要修改PDB中的SGA和PGA的修改的上线受限于根容器的大小。

##PDB的数据文件存储
在ASM中，每个PDB都独立的存放在以guid命名的文件夹中。
SELECT t.inst_id,t.guid,t.name,OPEN_MODE,t."RESTRICTED",t."OPEN_TIME",t."CREATION_TIME" FROM gv$pdbs t;
[grid@12cnod01 ~]$ asmcmd
ASMCMD> ls
MGMT/
OCR_DATA/
ORA_DATA/
ASMCMD> cd ORA_DATA
ASMCMD> ls
oradb/
ASMCMD> cd oradb
ASMCMD> ls
4700A987085B3DFAE05387E5E50A8C7B/
9640FEB3D2B47084E05332080A0AF808/
9641253BCEAA24AEE05333080A0A9B1E/
96412BE207060ECCE05332080A0AFB0F/
9682367650D2641CE05332080A0A8CFA/
ARCHIVELOG/
AUTOBACKUP/
CONTROLFILE/
DATAFILE/
ONLINELOG/
PARAMETERFILE/
PASSWORD/
TEMPFILE/
ASMCMD> 

##权限管理
唯一区别于非CDB环境，在grant、revoke后，添加container=pdb1/all/current(当前容器)来指定权限的范围。

##rman备份与恢复
-需要提前配置好TNS
-登录CDB进行rman的备份
[oracle@12cnod01 ~]$ rman target /
-登录PDB进行rman的备份
[oracle@12cnod01 ~]$ rman target sys/cz123456@ORADBPDB1
-显示备目录
RMAN> report schema; 

--登录CDB进行指定PDB的备份
[oracle@12cnod01 ~]$ rman target /
-指定PDB的整库备份
RMAN> backup database ORADBPDB1;
-备份PDB的users表空间
RMAN> backup tablespace ORADBPDB1:users;
--同时指定多个PDB的备份
RMAN> backup pluggable database ORADBPDB1,ORADBPDB2;

--PDB的恢复
-基于数据库的恢复
-关闭所有节点的PDB
SQL> alter pluggable database ORADBPDB1 close immediate;
[oracle@12cnod01 ~]$ rman target /
RMAN> restore database ORADBPDB1;
RMAN> recover database ORADBPDB1;
alter pluggable database ORADBPDB1 open;

-基于表空间的恢复
SQL> alter session set container=ORADBPDB1;
SQL> alter tablespace user offline;
RMAN> restore tablespace ORADBPDB1:users;
RMAN> recover tablespace  ORADBPDB1:users;
SQL> alter tablespace users online;

-检查PDB是否有坏块
RMAN> validate pluggable database ORADBPDB1,ORADBPDB2;

##导表
1、为了方便管理，可以创建一个comm user，来统一导入和导出所有的PDB数据，也可以为每个PDB单独创建用户，具体导入导出参数，参见11g。
2、创建用户及目录。
mkdir -p /data/dump_dir
chown oracle:oinstall /data/dump_dir
--创建公共用户
SQL> create user c##cz_com identified by cz_123456 container=all;

SQL> grant dba to c##cz_com container=all;

--需要在每个PDB中创建。
CREATE DIRECTORY dump_dir AS '/data/dump_dir';

--需要配置所有PDB的TNS
expdp c##cz/cz_123456@ORADBPDB1 directory=dump_dir dumpfile=user03.dmp logfile=admin.log SCHEMAS=cz cluster=no 

--TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y 导入不生成redo
impdp c##cz/cz_123456@ORADBPDB2 directory=dump_dir dumpfile=user03.dmp logfile=admin_nolog.log table_exists_action=replace TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y

##undo管理
undo管理在12.2后，分为两个：
1、所有的PDB包括CDB都公用CDB下的一个undo表空间
2、PDB及CDB各自使用独立的undo表空间
--查看模式
select property_name,property_value from database_properties where property_name='LOCAL_UNDO_ENABLED';
LOCAL_UNDO_ENABLED   TRUE     --采用独立的表空间模式   FLASE   --共享表空间模式
--查看undo表空间
select con_id,tablespace_name,file_name from cdb_data_files where tablespace_name like 'UNDOTBS%';
         1 UNDOTBS1                       +ORA_DATA/ORADB/DATAFILE/undotbs1.259.1023187619
         1 UNDOTBS2                       +ORA_DATA/ORADB/DATAFILE/undotbs2.274.1023187895
         3 UNDOTBS1                       +ORA_DATA/ORADB/9641253BCEAA24AEE05333080A0A9B1E/DATAFILE/undotbs1.283.1023188337
         4 UNDOTBS1                       +ORA_DATA/ORADB/96412BE207060ECCE05332080A0AFB0F/DATAFILE/undotbs1.289.1023188445
		 
#创建公共用户
公共用户用可以登录所有PDB，并赋予一定的权限
1、连接到CDB
SQL> show con_name;

CON_NAME
------------------------------
CDB$ROOT
2、创建公共用户必须以C##开头，登录所有PDB
create user c##pdbadmin identified by pdbadmin_123 container=all;

3、赋权
grant create session to c##pdbadmin container=all;

4、尝试登录
SQL> conn c##pdbadmin/pdbadmin_123@CEPHK
Connected.
SQL> show con_name

CON_NAME
------------------------------
CEPHK

##rman的备份和恢复
1、查看所有schema的信息
[oracle@racnode1 ~]$ rman target /
RMAN> report schema;
1.1 整个数据库的备份
backup database 
1.2 PDB的备份
backup pluggable database CEPCN;
1.3 PDB表空间的备份(可填写多个：备份CEPHK及CEPDB的USERS表空间)
backup tablespace CEPHK:USERS,CEPDB:USERS;

2、使用RMAN复制PDB
duplicate database to CEP_NEW pluggable database TOOL_DB;

#限制PDB的总容量
-包括所有的数据文件和临时文件的总大小限制
alter pluggable database CEPHK storage(maxsize 100g);
