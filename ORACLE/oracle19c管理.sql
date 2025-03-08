##ǰ������
�ο�11g��ǰ�ð�װ�������ز����ĵ���
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
��CDB��PDB֮���й��е��û����Է��ʣ�SYS and SYSTEMҲ������Ȩ�ޣ������ʾ���벻��ȷ�������޸����롣    
A common user can log in to any container (including CDB$ROOT) in which it has the
CREATE SESSION privilege. 
sqlplus / as sysdba@root
SQL> alter user sys identified by cz123456;

##�鿴PDB��CDB�������Ϣ
SELECT * FROM gv$containers;

##PDB�ṹ
������system��sysaux��undo��tmp��usersÿ��pdb����
����online_redolog������archive_log

���� PDB ���� CDB �Ŀ����ļ���
��־�ļ��� UNDO ��ռ䣬���� PDB ֮�以����Ҫͨ�� DB Link ����

����PDB��connect sys/foresee_abc@10.10.8.49:1521/pdb_t1 as sysdba

##�鿴��ǰ������
select Sys_Context('Userenv', 'Con_Name') "current container" from dual;
SHOW con_name

##����PDB
--ֱ��PDB��Ҫ��tnsnames.ora�н�������
sqlplus cz/cz@10.10.8.49:1521/PDB_T1
sqlplus sys/foresee_abc@pdb_t1 as sysdba 
sqlplus c##cz_com/cz_com@pdb_t1
alter session set container=PDB_T1; 

##����CDB(root)
Ĭ�ϰ�װ���19C����Ȼ��ͳһ�����룬������ͨ��plsqldev��¼root����ʾ���벻��ȷ��������Ҫ�ȸ�sys������
sqlplus / as sysdba@root
SQL> alter user sys identified by foresee_abc;

��¼��ʱ���TNS��дCDB�ķ�������
SQL> show parameter name 
service_names                        string                 test19c

��¼�󣬻���cdb_��ͷ�ı���Ϊ�ܹ���ı�

##����PDB��ͨ��plsqldev����
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
  
##�༭sqlnet,���ڰ汾��������12C���͵��¿ͻ��˰汾��JDBC�汾�ϵ�
[oracle@ora19c admin]$ vim sqlnet.ora

NAMES.DIRECTORY_PATH= (TNSNAMES, ONAMES, HOSTNAME)

SQLNET.ALLOWED_LOGON_VERSION_CLIENT = 11

SQLNET.ALLOWED_LOGON_VERSION_SERVER = 11

  
##�鿴�û���Ӧ��PDB
select USERNAME, COMMON,CON_ID from cdb_users;

##����comm_user�����������е�PDB
����������comnon user������c##��ͷ��
-��¼root
sqlplus / as sysdba@root

SQL> create user c##cz_com identified by cz_com container=all;

User created.

SQL> grant dba to c##cz_com container=all;

Grant succeeded.

##����PDB
CREATE PLUGGABLE DATABASE salesact01 ADMIN USER salesadm IDENTIFIED BY cz_123456;

##������PDB��¡�µ�PDB
SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 ORADBPDB1                      READ WRITE NO
         4 ORADBPDB2                      READ WRITE NO

SQL> alter pluggable database ORADBPDB1 close immediate;(rac������Ҫ�������ڵ���ִ��)
SQL> alter pluggable database ORADBPDB1 open read only;(һ���ڵ���ִ��)
SQL> create pluggable database ORADBPDB3 from ORADBPDB2;

SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 ORADBPDB1                      MOUNTED
         4 ORADBPDB2                      READ WRITE NO
         5 ORADBPDB3                      MOUNTED

alter pluggable database ORADBPDB3 open;(rac���������ڵ㶼Ҫopen)       

##ɾ��PDB
SQL>  alter pluggable database ORADBPDB3 close immediate/abort;
SQL> drop pluggable database ORADBPDB3 including datafiles/KEEP DATAFILES;

#PDB�Ĵ�״̬��
alter pluggable database CEPHK open;         --��дģʽ��PDB
alter pluggable database CEPHK open read only;    --ֻ��ģʽ��PDB
alter pluggable database CEPHK open RESTRICTED;   --��ֹ�����û��ķ���
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         4 CEPHK                          READ WRITE YES
		 

#PDB�Ĺر�״̬��
alter pluggable database CEPHK close abort;       
alter pluggable database CEPHK close immediate;  


1����ԴCDB�а���PDB
ALTER PLUGGABLE DATABASE salesact UNPLUG INTO '/home/oracle/saleact.xml';

##ʵ���ر�����˳��
1���ر����е�PDB
sqlplus / as sysdba@root
SQL> alter pluggable database all close immediate;

SQL> show pdbs;

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 ORADBPDB1                      MOUNTED
         4 ORADBPDB2                      MOUNTED

SQL> shutdown immedaite;

2�������ݿ�
SQL> startup

SQL> alter pluggable database all open;

##�����޸�
��12c rac֮��İ汾��,�����ǲ�����initoradb.ora�Ĳ����ļ�֧�֣�Ҳ������spfile��ָ��ASM����Ŀ��Ĭ�϶��Ǵ�ASM������spfile;
--���������������ִ��ASM�еĲ����ļ�
--��ʧ��ʱ���ȴӱ��ݵ�pfile�ļ����ɣ���ȥָ�����ļ���������ָ���������ڵ�ֱ�ִ��
SQL> create spfile='+ORA_DATA/oradb/PARAMETERFILE/spfileoradb.ora' from pfile='/u01/app/oracle/product/12.2.0/db_1/dbs/initoradb2.ora'
[oracle@12cnod01 dbs]$ srvctl config database -db oradb
[oracle@12cnod01 dbs]$ srvctl modify database -db oradb -spfile +ORA_DATA/oradb/PARAMETERFILE/spfileoradb.ora


##����PDB��Դ��
sqlplus / as sysdba@root

--ΪCDB����pending area
exec dbms_resource_manager.create_pending_area();

--������Ϊlow_app����Դ�ƻ�
begin
  dbms_resource_manager.create_cdb_plan(plan => 'low_app',comment => 'tools for priority');
end;
/

--��PDB��ORADBPDB1���ݶ�Ϊ1��100/PDB������*1������Դʹ������50%��
begin
  dbms_resource_manager.create_cdb_plan_directive(plan => 'low_app',pluggable_database => 'ORADBPDB1',shares => 1,utilization_limit => 50,parallel_server_limit => 50);
end;
/

--��֤���ύpending area
exec dbms_resource_manager.validate_pending_area();

exec dbms_resource_manager.submit_pending_area();

--ִ�е�ǰpending area
alter system set resource_manager_plan='low_app';

--�鿴��Դ�ƻ�
SELECT * FROM dba_cdb_rsrc_plan_directives t;

##����������������
����CDB�����ݿ�ʵ������PDB�����ʵ���������һЩCDB����Ӧ����CDB������PDB����������κθ�����PDB�����޸ġ�
ͨ����v$parameter��ISPDB_MODIFIABLE�У���ʶ��PDB����CDB���𣬼��ǿ�¡���߰���ĳ��PDB�����ص������Ա����ڸ�PDB�С�
SELECT t."INST_ID",t."NAME",t."DISPLAY_VALUE",t."ISSES_MODIFIABLE",t."ISSYS_MODIFIABLE",t."ISPDB_MODIFIABLE" FROM gv$parameter t where t."NAME" like '%&para_name%' order by t."NAME",t."INST_ID";
--�鿴�Ѿ���PDB���޸��˵Ĳ���
SELECT t.inst_id,t.name,a.name,a.value$ FROM pdb_spfile$ a,gv$pdbs t WHERE a.pdb_uid=t.dbid order by a.name,t."NAME",t."INST_ID";

--������ͼ(��̬�����뾲̬����)
SELECT t."INST_ID",t."NAME",t."DISPLAY_VALUE",t."ISSES_MODIFIABLE",t."ISSYS_MODIFIABLE",t."ISPDB_MODIFIABLE" FROM gv$parameter t where t."NAME" like '%&para_name%' order by t."NAME",t."INST_ID";
-DISPLAY_VALUE     ��ʽ�����С
-ISSES_MODIFIABLE  �Ự�����Ƿ���Ըı�
-ISSYS_MODIFIABLE  ϵͳ���� IMMEDIATE��������Ч��������ʵ����  DEFERRED��������Ч�� FALSE������ʵ����Ч��
-ISPDB_MODIFIABLE  ��PDB�����Ƿ�����޸ģ�����FALSE,˵��ֻ�ܴ�CDB�м̳С�

��rac�����У��޸Ĳ���ʱ��ISSYS_MODIFIABLE=IMMEDIATE�����Ǳ���ORA-32018: parameter cannot be modified in memory on another instance
�����������ڵ��Ϸֱ�ִ�У�
alter system set sga_target=3G scope=both sid='oradb1';
alter system set sga_target=3G scope=both sid='oradb2';

--SGA��PGA
Ҫ�޸�PDB�е�SGA��PGA���޸ĵ����������ڸ������Ĵ�С��

##PDB�������ļ��洢
��ASM�У�ÿ��PDB�������Ĵ������guid�������ļ����С�
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

##Ȩ�޹���
Ψһ�����ڷ�CDB��������grant��revoke�����container=pdb1/all/current(��ǰ����)��ָ��Ȩ�޵ķ�Χ��

##rman������ָ�
-��Ҫ��ǰ���ú�TNS
-��¼CDB����rman�ı���
[oracle@12cnod01 ~]$ rman target /
-��¼PDB����rman�ı���
[oracle@12cnod01 ~]$ rman target sys/cz123456@ORADBPDB1
-��ʾ��Ŀ¼
RMAN> report schema; 

--��¼CDB����ָ��PDB�ı���
[oracle@12cnod01 ~]$ rman target /
-ָ��PDB�����ⱸ��
RMAN> backup database ORADBPDB1;
-����PDB��users��ռ�
RMAN> backup tablespace ORADBPDB1:users;
--ͬʱָ�����PDB�ı���
RMAN> backup pluggable database ORADBPDB1,ORADBPDB2;

--PDB�Ļָ�
-�������ݿ�Ļָ�
-�ر����нڵ��PDB
SQL> alter pluggable database ORADBPDB1 close immediate;
[oracle@12cnod01 ~]$ rman target /
RMAN> restore database ORADBPDB1;
RMAN> recover database ORADBPDB1;
alter pluggable database ORADBPDB1 open;

-���ڱ�ռ�Ļָ�
SQL> alter session set container=ORADBPDB1;
SQL> alter tablespace user offline;
RMAN> restore tablespace ORADBPDB1:users;
RMAN> recover tablespace  ORADBPDB1:users;
SQL> alter tablespace users online;

-���PDB�Ƿ��л���
RMAN> validate pluggable database ORADBPDB1,ORADBPDB2;

##����
1��Ϊ�˷���������Դ���һ��comm user����ͳһ����͵������е�PDB���ݣ�Ҳ����Ϊÿ��PDB���������û������嵼�뵼���������μ�11g��
2�������û���Ŀ¼��
mkdir -p /data/dump_dir
chown oracle:oinstall /data/dump_dir
--���������û�
SQL> create user c##cz_com identified by cz_123456 container=all;

SQL> grant dba to c##cz_com container=all;

--��Ҫ��ÿ��PDB�д�����
CREATE DIRECTORY dump_dir AS '/data/dump_dir';

--��Ҫ��������PDB��TNS
expdp c##cz/cz_123456@ORADBPDB1 directory=dump_dir dumpfile=user03.dmp logfile=admin.log SCHEMAS=cz cluster=no 

--TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y ���벻����redo
impdp c##cz/cz_123456@ORADBPDB2 directory=dump_dir dumpfile=user03.dmp logfile=admin_nolog.log table_exists_action=replace TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y

##undo����
undo������12.2�󣬷�Ϊ������
1�����е�PDB����CDB������CDB�µ�һ��undo��ռ�
2��PDB��CDB����ʹ�ö�����undo��ռ�
--�鿴ģʽ
select property_name,property_value from database_properties where property_name='LOCAL_UNDO_ENABLED';
LOCAL_UNDO_ENABLED   TRUE     --���ö����ı�ռ�ģʽ   FLASE   --�����ռ�ģʽ
--�鿴undo��ռ�
select con_id,tablespace_name,file_name from cdb_data_files where tablespace_name like 'UNDOTBS%';
         1 UNDOTBS1                       +ORA_DATA/ORADB/DATAFILE/undotbs1.259.1023187619
         1 UNDOTBS2                       +ORA_DATA/ORADB/DATAFILE/undotbs2.274.1023187895
         3 UNDOTBS1                       +ORA_DATA/ORADB/9641253BCEAA24AEE05333080A0A9B1E/DATAFILE/undotbs1.283.1023188337
         4 UNDOTBS1                       +ORA_DATA/ORADB/96412BE207060ECCE05332080A0AFB0F/DATAFILE/undotbs1.289.1023188445
		 
#���������û�
�����û��ÿ��Ե�¼����PDB��������һ����Ȩ��
1�����ӵ�CDB
SQL> show con_name;

CON_NAME
------------------------------
CDB$ROOT
2�����������û�������C##��ͷ����¼����PDB
create user c##pdbadmin identified by pdbadmin_123 container=all;

3����Ȩ
grant create session to c##pdbadmin container=all;

4�����Ե�¼
SQL> conn c##pdbadmin/pdbadmin_123@CEPHK
Connected.
SQL> show con_name

CON_NAME
------------------------------
CEPHK

##rman�ı��ݺͻָ�
1���鿴����schema����Ϣ
[oracle@racnode1 ~]$ rman target /
RMAN> report schema;
1.1 �������ݿ�ı���
backup database 
1.2 PDB�ı���
backup pluggable database CEPCN;
1.3 PDB��ռ�ı���(����д���������CEPHK��CEPDB��USERS��ռ�)
backup tablespace CEPHK:USERS,CEPDB:USERS;

2��ʹ��RMAN����PDB
duplicate database to CEP_NEW pluggable database TOOL_DB;

#����PDB��������
-�������е������ļ�����ʱ�ļ����ܴ�С����
alter pluggable database CEPHK storage(maxsize 100g);
