--���ݿ����
--EM����
emctl start/stop/status dbconsole

--�����ֵ�
����ص����ݣ��洢��system��ռ���
--��̬������ͼ
�ǲ���صģ�ֻ�����ݿ�open״̬�£��ſ��Բ�ѯ

--�����ļ�λ��
$ORACLE_HOME/dbs/init.ora  
$ORACLE_HOME/dbs/initorcl.ora   --�ļ���ָ����spfile��λ�� SPFILE='+DATA/orcl/spfileorcl.ora'

--���ݿ����
SELECT t.NAME,t.VALUE,t.DISPLAY_VALUE,t.DESCRIPTION FROM v$parameter t;
show v$parameter
show parameter parallel/shared_pool
--�޸����ݿ����
scope=spfile --���Ľ��ڲ����ļ���Ӧ�ã���������Ч
scope=memory --���Ľ����ڴ���Ӧ�ã������������ڴ�����Ч����������ʧ
scope=both --�ڴ���ļ�����Ч�������󲻶�ʧ
exp:alter session set NLS_DATE_FORMAT='mon dd yyyy';

##���ݿ������׶�����
һ��startup nomount 
ʵ������״̬ --ָ�������ļ������ݼ��ָ�  --��Ҫ�����ļ�
����spfile<SID> or init<SID>.ora ����SGA��������̨����  ��alert<SID>.log�������ļ� asmcmd>cd +DATA/ORCL/spfileorcl.ora
����alter databse mount  
���ݿ�װ��                                --��Ҫ�����ļ�
���ݿ���֮ǰ�������ļ����� 
1����λ�򿪲����ļ��еĿ����ļ� --��·����ʱ��Ҫ�����ļ�������
2��ͨ�������ļ�����ȡ�����ļ�   --���������ļ����ǿ���״̬
3������������־�ļ�             --ÿ����־��������������Ա�����ڲ�ͬ�Ĵ������У�����������һ������
�������������ݿ�ָ�  
����alter databse open 
ʵ������ 
���ݿ�� 
������������־�ļ�   --�����ļ�������������־�ļ�

--���ݿ���/ͣ����
startup
startup nomount
alter database mount
alter database open;
startup force;
--����δ�ύ�ĸ��ġ����ݿ⻺���������ٻ���д�������ļ����ͷ���Դ
shutdown immediate/abort/normal/transactional


=======���ݿ�����=========
#######���ݿ�ʵ��#######
---�ڴ�++
----SGA+
-----buffer cache ���ٻ����� �û��洢�����û���ѯ�����ĵ�����,�ڴ��е����ݣ����ĺ�����ݽ���dirty buffer
-----share pool   ����� ���ڴ�Ž�������ִ�мƻ� ����ء������ֵ仺�桢sql��ѯ��PL/SQL�������
-----large pool   ���ͳ� ���ڹ���������Ľ���ʹ��
-----redo log     ��־������ �û����DML��������־
-----java pool 
-----stream pool 
----PGA+
-----����
-----�ϲ�
---��̨����++
----PMON �û��Ự�������ݿ⡢���ӻỰ�������쳣�����ع�

----SMON ���Ҽ���֤���еĿ����ļ�������������־�ļ��������ݿ�

----DBWn ���ݿ�д���� ���Է����� ��buffer cache �е�����д�������ļ�,�ӳ�д��������ʱд
1��û�п��õĻ������ɾ��飨1����� δд����� 2�����ڱ��Ựռ�õĿ� ��
2�����̫��
3��ÿ3�� �Ի�������һ������
4��check point 
5���ر����ݿ�

----LGWR ��־д����ֻ����һ�� ˳��д�����������ļ�����д��Ƶ��д
����������
1��commit
2������֮һ��
3��DBWn ���д�������ļ�
----CKPT ������� ָʾDBWn�������д�������ļ�

----ARCn �鵵��־���� �û�������������־�ļ�����������д��鵵��־�ļ���

----MMON ���Ҽ��ӡ����ҵ��ڽ���  AWR ADDM ÿСʱ1��

----LREG ����ע�����ݿ�


##share pool
--�⻺�� �洢SQL����ִ�мƻ�
--�����ֵ仺�� �洢ִ�й�SQL�ı�
--SQL��ѯ��pl/sql����������� ������ѯ����

#######���ݿ�#######
---�����ļ�
���ݿ�ļ��䣬����ά�����ݿ��һ���ԣ�����������־�ļ��������ļ����鵵��־�ļ���λ�ü����ݿ��������Ϣ�� --���÷��ڲ�ͬ������Ķ�·����
show parameter controlfile
---�����ļ� 
---����������־�ļ� redo log ���������顢ÿ������������Ա�� --���÷��ڲ�ͬ������Ķ�·����
---�鵵��־�ļ� archive log 
---�����ļ� ����¼���ݿ���ز�����SGA�и�������ķ����С��
show parameter spfile 
---�����ļ�
---�����ļ���������־ 
show parameter background_dump_dest    alert_orcl.log

######��doһ��
redo
undo
checkpoint 

��ִ��commitʱ������commit compelete ��������Ȼ���ڴ��У����������ϳ�����dbwrд���ݵ������ļ�������������Ȼ�������ļ��С�
��ô����������ʱ���ڴ�ͻᶪʧ��Ϊ�˱�֤���ݵĳ־��ԣ�����redo log��
redo log�м�¼�ˣ��ڼ��������ļ����ڼ����飬�ڼ��У��ڼ��б��޸ĳ���ʲôֵ�������������ǰ�˷���commit compeleteʱ������ζ��redo
log buffer�Ѿ�д�뵽redo log file�С�
undo �м�¼�ˣ��ڼ��������ļ����ڼ����飬�ڼ��У��ڼ���ԭ������ֵ��ʲô�� 

##ora-01555 snapshot too old ���չ���
�����һ����ѯ��������ѯ��ʼ����Ҫ����undo���еľɰ����ݣ���������undo���е������Ѿ������ǣ��ͻᵼ��һ���Զ�ʧ�ܡ�
Ҳ����undo�εĿռ䲻�������undo_retentionʱ��϶̡�
�Ų�ԭ�򣬲鿴ռ��undo�ε�SQL��
--���������
1����������undo��ռ�
2��undo_retention Ĭ��900S��
�������ʱ����Ĳ�ѯΪ1800�룬��ô���������Ӧ������Ϊ1800�����oracle�ͻ��跨�����е�undo�������ݱ���1800�룬�Ӷ�������ֿ��չ��õĴ���
3��Ϊ�˱�֤��ԭ��������Ч��������Ϊundo���㣬��������
SQL> show parameter undo

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
undo_management                      string      AUTO
undo_retention                       integer     900
undo_tablespace                      string      UNDOTBS1

SQL> SELECT t.TABLESPACE_NAME,t.CONTENTS,t.RETENTION FROM dba_tablespaces t WHERE t.TABLESPACE_NAME like 'UNDOTBS1';
TABLESPACE_NAME                CONTENTS  RETENTION
------------------------------ --------- -----------
UNDOTBS1                       UNDO      GUARANTEE --��Ч

alter tablespace UNDOTBS1 RETENTION GUARANTEE;

#####����redo log�ĸ���
redo log����״̬��active��inactive��current
������redo log��״̬��active active ��current������־��ʱ����ʱҪ������־����л������Ǹ��ǵ�ǰ����inactive״̬�����Ǹ���־���Ѿ�д�뵽
archive log�������ʱ��active����û��inactive����ô���ء�
   ��ǿ�ƴ���dbwr��һ����buffer�е�������ݣ�д�뵽�����ļ��У���ʱactive����־�飬�Ϳ��Ը����ˡ�
   Ҳ���������Ƿ����鵵��������Ӱ��ʵ����һ���Իָ���
redo log�а������ύ������Ҳ����δ�ύ������

####��####
oracle������DML������������ͬ�е����ݣ�������һ����û�����������໥֮�䲻Ӱ�졣������ͬ�е����ݣ�����ֵȴ���
oracle������DDL��䣬��������������online����
####����archive log   
##�ǹ鵵ģʽ
���ݣ��䱸��һ���Ա��ݣ��������ȱ�
��ԭ������ʵ�������������ļ�������õģ�ֻ��restore�ķ�ʽ,��Ϊû�й鵵��־������Ҳ��û��recover��
##�鵵ģʽ
���ݣ��ȱ�����һ���Ա��ݣ�
��ԭ�����������ļ��𻵣����Ի�ԭ�����һ��commit��״̬��
��ȫ�ָ������ݿⱸ��+�鵵��־+online redo log 
##���ݼ��ָ�
restore ��ԭ�����ļ������ǿ���dbf�ļ���ԭ·����
recover �طű���ʱ���֮��Ĺ鵵��־archive log����ǰactive��current��redo log 

##scan_ip��־
su - grid
lsnrctl status listener_scan1

======�û���Ȩ�޹���=======
##�û�����
create/alter user [user_name] identified by [password]
default tablespace [tablespace_name] temporary tablespace [tmp_tablespace]
profile [profile_name]
password expire --�û������޸�����
account unlock
quota  unlimited on users; --�������

--ɾ���û� <��ͬ�û�ӵ�еĶ���>
drop user [user_name] <cascade> ;

--�鿴Ϊ��Щ�û�������sysdba��sysoperȨ��
SELECT * FROM V$pwfile_Users;

--Ȩ�޹���ϵͳȨ�޺Ͷ���Ȩ�ޣ�
--�û������Ʊ�ռ��д��Ȩ��
grant unlimited tablespace to HX_FP  ;
--ϵͳȨ�� dba_sys_privs
create session --�����������ݿ�
alter database --����������ݿ��ļ�
alter system   --�����޸�ϵͳ
grant privilege to [user_name];
--����Ȩ�� dba_tab_privs
insert/update/delete/select/alter/execute
create tablespace/alter tablespace/drop tablespace --�����޸�ɾ����ռ�
grant any object privilege --���������κ�Ȩ��
create any table --�����κα�
insert/update/delete/select any table --��ɾ�Ĳ��κα�
GRANT SELECT  ON sjyy.cxtj_jsydfpcx_sy   TO J2_CX;
SELECT 'grant select on ' ||t.owner||'.'||t.table_name || ' to wb_cx;' FROM dba_tables t WHERE t.OWNER='HX_QX';
--ϵͳȨ�� ϵͳȨ�޴��ݲ��᳷��
grant privilege to [user_name] <with admin option>;
revoke privilege from [user_name];
revoke dba from db_smbs_sjyy;
--����Ȩ�� ����Ȩ�޵ĳ������ἶ��
grant privilege on hr.scott to [user_name] <with grant option>;
revoke privilege on schema.table from [user_name];

--ϵͳĬ���Դ��û�
SELECT * FROM DBA_USERS_WITH_DEFPWD;

--������ɫ
create role [role_name] <with admin option/with grant option>;

--��ɫ��Ȩ dba_role_privs 
grant privilege to [role_name];
grant privilege on hr.scott to [role_name] <with grant option>; 

--��ɫ��Ȩ�û�
grant [role_name] to [user_name];


--Ԥ�����ɫȨ��
connect   --����create session 
resource  --�������ݿ����͹���
dba
public   --�˽�ɫ��ÿ���û��ж���ڣ�����һ���������public,�����е��û������Է��������<grant select on hr.emp to public>
select_catalog_role
schema_admin

##��ѯȨ�޻���
SELECT * FROM dba_role_privs t WHERE t.granted_role='YS_ROLE';
SELECT t.grantee,t.owner,t.table_name,t.privilege,t.grantable FROM dba_tab_privs t WHERE t.grantee='YS_ROLE'
union all
SELECT b.grantee,to_char(null),to_char(null),b.privilege,b.admin_option FROM dba_sys_privs b WHERE b.grantee='YS_ROLE';
--������ѯ��ɫ��Ȩ��
SELECT * FROM dba_role_privs t WHERE t.grantee = upper('&role_name') or t.granted_role=upper('&role_name');
SELECT t.grantee, t.owner, t.table_name, t.privilege, t.grantable
  FROM dba_tab_privs t
 WHERE t.grantee =upper('&role_name')
union all
SELECT b.grantee, to_char(null), to_char(null), b.privilege, b.admin_option
  FROM dba_sys_privs b
 WHERE b.grantee =upper('&role_name');
 
##DDL�﷨
�����ֶ��﷨��alter table tablename add (column datatype [default value][null/not null],��.);

˵����alter table ���� add (�ֶ��� �ֶ����� Ĭ��ֵ �Ƿ�Ϊ��);

   ����alter table sf_users add (HeadPIC blob);

   ����alter table sf_users add (userName varchar2(30) default '��' not null);

�޸��ֶε��﷨��alter table tablename modify (column datatype [default value][null/not null],��.); 

˵����alter table ���� modify (�ֶ��� �ֶ����� Ĭ��ֵ �Ƿ�Ϊ��);

   ����alter table sf_InvoiceApply modify (BILLCODE number(4));

ɾ���ֶε��﷨��alter table tablename drop (column);

˵����alter table ���� drop column �ֶ���;

   ����alter table sf_users drop column HeadPIC;

�ֶε���������

˵����alter table ���� rename  column  ���� to ������   �����У�column�ǹؼ��֣�

 ����alter table sf_InvoiceApply rename column PIC to NEWPIC;

�����������

˵����alter table ���� rename to  �±���

   ����alter table sf_InvoiceApply rename to  sf_New_InvoiceApply;
   
--sqlplusָ���û�
alter session set current_schema=hr;
   
##��ѯ���е�����GV$��ͼ
select * from v$fixed_table;

##��ѯGV$��ͼ�Ĵ������
select * from v$fixed_view_definition;

##���������ļ�
--��ѯ��ǰ��ÿ���û�����������ļ�
SELECT t.username,t.profile FROM dba_users t ;

--�鿴�����ļ�����
SELECT * FROM dba_profiles t WHERE t.profile='DEFAULT'

--�����ļ������ű�    
@$ORACLE_HOME/rdbms/admin/utlpwdmg.sql

--redo log �л�
ALTER SYSTEM SWITCH LOGFILE        �Ե�ʵ�����ݿ��RAC�еĵ�ǰʵ��ִ����־�л���

ALTER SYSTEM ARCHIVE LOG CURRENT   ������ݿ��е�����ʵ��ִ����־�л�

--rman�����ļ���
RMAN> backup as copy current controlfile  format '/u01/oracle/bak/control01.ctl';
--rman�����ļ���
RMAN> backup as copy spfile format '/u01/oracle/bak/spfileorcl.ora';

--�����ļ�����
SQL> alter database backup controlfile to trace;

Database altered.

SQL> select value from v$diag_info  where name='Default Trace File';

VALUE
--------------------------------------------------------------------------------
/u01/app/oracle/diag/rdbms/racdb/racdb/trace/racdb_ora_23305.trc

--ִ�м���
-��ǰʵ��
SQL>alter system checkpoint local;
-racȫ��
SQL>alter system checkpoint global;


##ɱ���Ự
1����ʵ��
alter system kill session '25,889' [immediate];
2��RAC��ڵ�ɱ�Ự 
alter system kill session 'SID,serial#,@1'  --ɱ��1�ڵ�Ľ��� 
alter system kill session 'SID,serial#,@2'  --ɱ��2�ڵ�Ľ��� 

##��̬����ͳ��
--ϵͳ��Χ
SELECT * FROM v$sysstat;
SELECT * FROM v$system_event;
--�ض��Ự
SELECT * FROM v$session;
SELECT * FROM v$session_event;
--�ض��ڷ���
SELECT * FROM v$service_stats;
SELECT * FROM v$service_event;

--�����Ż����ų�
SELECT * FROM v$database;
SELECT * FROM v$instance;
SELECT * FROM v$parameter;
SELECT * FROM v$spparameter;
SELECT * FROM v$process;
SELECT * FROM v$bgprocess;
SELECT * FROM v$px_process_sysstat;
SELECT * FROM v$system_event;

--����
SELECT * FROM v$datafile;
SELECT * FROM v$filestat;
SELECT * FROM v$log;
SELECT * FROM v$log_history;
SELECT * FROM v$dbfile;
SELECT * FROM v$tempfile;
SELECT * FROM v$tempseg_usage;
SELECT * FROM v$segment_statistics; 

--�ڴ�
SELECT * FROM v$buffer_pool_statistics;
SELECT * FROM v$librarycache;
SELECT * FROM v$sgainfo;
SELECT * FROM v$pgastat;

--����
SELECT * FROM v$lock;
SELECT * FROM v$undostat;
SELECT * FROM v$waitstat;
SELECT * FROM v$latch;

--������ͼ(��̬�����뾲̬����)
SELECT t."INST_ID",t."NAME",t."DISPLAY_VALUE",t."ISSES_MODIFIABLE",t."ISSYS_MODIFIABLE" FROM gv$parameter t where t."NAME" like '%&para_name%' order by t."NAME",t."INST_ID";
-DISPLAY_VALUE     ��ʽ�����С
-ISSES_MODIFIABLE  �Ự�����Ƿ���Ըı�
-ISSYS_MODIFIABLE  ϵͳ���� IMMEDIATE��������Ч��������ʵ����  DEFERRED��������Ч�� FALSE������ʵ����Ч��

��rac�����У��޸Ĳ���ʱ��ISSYS_MODIFIABLE=IMMEDIATE�����Ǳ���ORA-32018: parameter cannot be modified in memory on another instance
�����������ڵ��Ϸֱ�ִ�У�
alter system set sga_target=3G scope=both sid='oradb1';
alter system set sga_target=3G scope=both sid='oradb2';

--oracleĬ���Խ����û�
SELECT * FROM DBA_USERS_WITH_DEFPWD;

--��Ч��PL/SQL������ң�
SELECT * FROM dba_objects t WHERE t.status='INVAILD'

--���������
create index idx_name on table_name(cloumn_name1,cloumn_name2) tablespace tablespace_name nologging online <local> parallel 4;
alter idex_name logging;

oralce��������ʵ�������ݿ���ɡ�
--ʵ����RAM��CPU�е��ڴ�ṹ�����̣��û�������ͣʵ����
--���ݿ⣺�����ϵ������ļ�
--�����ļ��� ���ݿ�ļ��䣬����ά�����ݿ��һ���ԣ�����ʵ�������ݿ����Ҫ�����ļ������е�ָ��ָ�������ļ�������������־�ļ���

--����UNDO��ռ�
create undo tablespace undo_tbs2 datafile '+DATA/orcl/datafile/undo_tbs2'  size 10M;
create  tablespace undo_tbs2 datafile '+DATA/orcl/datafile/undo_tbs2'  size 10M;


alter database datafile 3 autoextend off; --ȡdba_data_files.file_id 

--������ռ��С
alter database datafile 7 resize 100M;

--ɾ����ռ估�����ļ�
drop tablespace TEST_01 including contents and datafiles
--����ռ���������ļ�
ALTER TABLESPACE TEST_01 ADD DATAFILE '+DATA/orcl/datafile/test_02' SIZE 100M;

--�����µ�UNDO��ռ�
alter system set undo_tablespace=undo_tbs2 scope=memory;

ALTER DATABASE DATAFILE '+DATA/orcl/datafile/undo_tbs2'  ONLINE /OFFLINE FOR DROP;

--���ر��ѯ   <һ��Ҫ����ɾ��ʱ�Ĺ�������>

alter session set nls_date_format='dd-mm-yy hh24:mi:ss';

select sysdate from  dual;--2017/1/25 0:04:42 

--��ѯ10����ǰ������
select * from t1 as of timestamp(systimestamp-10/14440) where t1.object_id=1002;

--��v$undostat ��ָ��ʱ������� SELECT * FROM v$undostat;
select * from t1 as of timestamp to_timestamp ('24-01-17 23:55:12','dd-mm-yy hh24:mi:ss') where t1.object_id=1000;

--�鿴���ݿ�ʵ��
SELECT * FROM v$instance;  parallel--NO ��ʵ�� YES RAC

--���ݿ���Ϣ�鿴
SELECT * FROM v$database;


--�����ò鿴
SELECT * FROM dba_streams_administrator;

--ʶ�����ݿ������ṹ
SELECT * FROM v$datafile;
SELECT * FROM dba_data_files;
--��ʱ��ռ�
SELECT * FROM v$tempfile;
--��־�ļ�
SELECT * FROM v$logfile;
--�����ļ�
SELECT * FROM v$controlfile;

--SGA �������ڴ����
SQL> show sga

Total System Global Area 6.4137E+10 bytes
Fixed Size                  2269072 bytes
Variable Size            6039797872 bytes
Database Buffers         5.7848E+10 bytes
Redo Buffers              246980608 bytes

SELECT t.COMPONENT,
       t.CURRENT_SIZE / 1024 / 1024 CURRENT_SIZE_M,
       t.MAX_SIZE / 1024 / 1024  MAX_SIZE_M,
       t.MIN_SIZE / 1024 / 1024  MIN_SIZE_M
  FROM v$sga_dynamic_components t WHERE t.CURRENT_SIZE<>0;

--PGA �ڴ����
SELECT name,CASE WHEN t."UNIT"= 'bytes' THEN
                round(t."VALUE"/1024/1024/1024,2)
                when t."UNIT" is null then t."VALUE"
             END as size_G   from v$pgastat t;

--��̨����
SELECT * FROM v$bgprocess t WHERE t.PADDR<>'00';

--�鿴�������еĽ��̼�����
SELECT * FROM v$session t order by t.PROGRAM;
SELECT t.PROGRAM,t.ADDR FROM v$process t  order by t.PROGRAM;

--���ұ�ռ������������ļ�
SELECT * FROM dba_extents t WHERE t.owner='CZ' and t.segment_name='T66';--file_id
SELECT * FROM dba_data_files t WHERE t.FILE_ID=4;

SELECT * FROM v$spparameter;
SELECT * FROM v$parameter t WHERE t.NAME like '%spfile%';

--�鿴ϵͳ�Ķ�̬��ͼ�ֵ��
SELECT * FROM v$fixed_table;
SELECT * FROM v$fixed_view_definition;

--�ֵ��ͳ����Ϣ�ռ�
exec dbms_stats.gather_fixed_objects_stats;
exec dbms_stats.gather_dictionary_stats;
execute dbms_stats.gather_schema_stats('SYS');


--oracle ����Ĳ��
su - oracle
oerr ora 15046
--�鿴��ռ��Ӧ���������ļ���λ�� 
SELECT t.NAME tablespace_name,d.NAME,d.BYTES/1024/1024/1024 size_G FROM v$tablespace t ,v$datafile d WHERE t.TS#=d.TS# order by t.NAME;
--�鿴����������־�ļ��ĳ�Ա��λ��
SELECT m.GROUP#,m.MEMBER,g.ARCHIVED,g.STATUS,m.TYPE,m.IS_RECOVERY_DEST_FILE,g.BYTES/1024/1024 size_M FROM v$log g,v$logfile m WHERE g.GROUP#=m.GROUP# order by m.GROUP#,m.MEMBER

--���������TNS
ͼ�ν��棺 netca��netmgr
--���ļ���
alter system set local_listener=ORCL12<TNSNAME.ORA�еı���> scope=both;
alter system register;
--listener.ora
LISTENER2 =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = edt3r10p1.us.oracle.com)(PORT = 1522))
      (ADDRESS = (PROTOCOL = TCP)(HOST = edt3r10p1.us.oracle.com)(PORT = 1521))
    )
  )
  
--tnsnames.ora
ORCL12 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = edt3r10p1.us.oracle.com)(PORT = 1522))
    (ADDRESS = (PROTOCOL = TCP)(HOST = edt3r10p1.us.oracle.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl.example.com)
    )
  )
  
##rowid˵��
rowid �����е����֤�ţ�����һ�е�Ψһ��ݣ�����18λ������6/3/6/3�ķָʽ��
SELECT  t.rowid,t.* FROM hx_dj.dj_nsrxx t;
AACGwi     ACj     AAAAeE   AAA
object#   file#    block#   row#
��ռ�    �����ļ� 

  
--ʹ��omf(oracle�ļ�ϵͳ����) 
�Զ�������СΪ100M ���Զ���չ ���32G�ı�ռ�
show parameter db_create
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_create_file_dest                  string      --��������ļ���λ��
db_create_online_log_dest_1          string      --���redo log ����������־
db_create_online_log_dest_2          string
db_create_online_log_dest_3          string
db_create_online_log_dest_4          string
db_create_online_log_dest_5          string

--ָ����������ļ���·��
alter system set db_create_file_dest='/oracle/ora_data/jsdb' scope=both;
--ָ�����redolog��·�� 
alter system set db_create_online_log_dest_1='+ORACL_DATA';
alter system set db_create_online_log_dest_2='+FRA_DATA';
--�鿴��Ա
SELECT v."THREAD#",le."GROUP#",v."STATUS",v."ARCHIVED","MEMBER",v."BYTES"/1024/1024 SIZE_M FROM v$logfile le,v$log v WHERE le."GROUP#"=v."GROUP#" ORDER BY 1,2;
--���redolog
ALTER DATABASE  
    ADD LOGFILE THREAD 1 GROUP 5 SIZE 50M;  --���ڵ�1�����5����СΪ50M��redolog
--ɾ��redolog
    ALTER DATABASE DROP LOGFILE  GROUP 5; 
--��ӳ�Ա
ALTER DATABASE   
   ADD LOGFILE MEMBER '+ORACL_DATA'
   TO GROUP 6;
--ɾ����Ա
ALTER DATABASE   
   DROP LOGFILE MEMBER '+ORACL_DATA/crsdb/onlinelog/group_6.285.968922535'

--OMF��֤
create tablespace OMF;
alter tablespace OMF add datafile;

##����DBLINK public
create public database link orcl12connect to cz identified by cz using 'ORCL12';   //ORCL12Ҫ��tnsname.ora�������á�

--rac�У����Ҫ��Թ̶����û��������ҽ�������û�ʹ�ã���ô�ͱ����¼����û����ٴ�����
create [pbulic] database link db_test_name connect to cz identified by cz_123456 using '10.10.8.11:1521/bigdata';

create database link YS_JYFX connect to STJYFX identified by "STJYFX" 
using '(DESCRIPTION =
    (ADDRESS_LIST =
      (address = (protocol = tcp)(host = 133.64.46.67)(port = 1521))
      (LOAD_BALANCE = NO)
    )
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = stjyfx_srv)
      (failover_mode =
        (type = select)
        (method = basic)
        (retries = 20)
        (delay = 5)
      )
    )
  )';
--����ֻ�ܸ�������ʹ�õ�dblink
create public database link orcl121
connect to cz identified by cz using 'ORCL12';
--ɾ��DBLINK
DROP [PUBLIC] DATABASE LINK zrhs_link
--��ѯDBLINK 
SELECT * FROM dba_db_links;
--�޸�DBLINK����
ALTER  PUBLIC database link BIGDATA_NFZCDB94 connect to CZ identified by "CZ_1QAZ";
--�����Ƶ�½ʧ�ܴ���
alter profile default limit FAILED_LOGIN_ATTEMPTS UNLIMITED;
--ͬ��ʿ����ڲ�ͬ�Ŀ�֮���໥���á�
ͬ��֮�䣬Ҳ������ͬ��ʵ�ͬ���
--����ͬ���
CREATE OR REPLACE SYNONYM "SJYY"."SB_ZZS_YBNSR_FB_JDCXSFPQD" FOR "NF_FDM_H"."SB_ZZS_YBNSR_FB_JDCXSFPQD";
CREATE OR REPLACE SYNONYM sjyy.dzdz_fpxx_zzsfp FOR dzdz.dzdz_fpxx_zzsfp@sjyydb_dzdz;
--�鿴ͬ���
SELECT * FROM dba_synonyms;
--��������ͬ���
SELECT 'CREATE OR REPLACE SYNONYM ' ||aa.owner||'.'||aa.synonym_name||' FOR ' ||aa.table_owner||'.'||aa.table_name||'@SJYY_12_94;'
FROM  (SELECT * FROM dba_synonyms t WHERE t.owner='SJYY')aa;

SELECT 'CREATE SYNONYM ' ||aa.owner||'.'||aa.table_name||' FOR ' ||aa.owner||'.'||aa.table_name||'@SJYY_12_94;'
FROM  (SELECT * FROM dba_tables t WHERE t.TABLESPACE_NAME NOT IN ('SYSTEM','SYSAUX') AND t.OWNER<>'SJYY')aa;

SELECT 'CREATE or replace SYNONYM SJYY.'||aa.table_name||' FOR ' ||aa.owner||'.'||aa.table_name||'@sjyyys96_bigdata11;'
FROM  (SELECT t.OWNER,t.TABLE_NAME FROM dba_tables t WHERE t.OWNER='DZDZ')aa;

SELECT 'CREATE or replace SYNONYM sx_mdm_db.'||aa.table_name||' FOR ' ||aa.owner||'.'||aa.table_name||';'
FROM  (SELECT t.OWNER,t.TABLE_NAME FROM dba_tables t WHERE t.OWNER='SX_ADM_MDM' AND t.TABLE_NAME LIKE 'M%')aa;

--ɾ��ͬ���
DROP [PUBLIC] SYNONYM [schema.]sysnonym_name
--����ɾ��ͬ���
SELECT 'drop SYNONYM ' ||aa.owner||'.'||aa.synonym_name||'; ' FROM  dba_synonyms aa WHERE aa.owner LIKE 'HX%' OR aa.OWNER LIKE  'GS%';

--������ȡע��
SELECT 'COMMENT ON COLUMN '||t.owner||'.'||t.table_name||'.'||t.column_name|| ' IS '''||t.comments||''';' FROM dba_col_comments t WHERE t.owner='TSSH' AND t.comments IS NOT NULL;

--��������
SELECT 'CREATE TABLE '||t.owner||'.'||t.table_name|| ' as select * from '||t.owner||'.'||t.table_name||'@SJYYDB_CKTS;' FROM all_tables@sjyydb_ckts t WHERE t.owner='TSSH';


--��ռ����
PCTFREE--��������10%�Ŀռ䣬��û�п��õĿռ�ʱ�ͻ��������ƶ����ռ����Ŀ顣
���ƶ�--UPDATE������
������--����insert���µ�ǰ�Ŀ�ռ䲻�㣬�������20K�����ݣ���Ŀǰֻ��8K���ͱ����ٷ���3����ſ��ԡ�

--�������ƶ��������������͸�ˮλ�ߣ����ǻ�ʹ�������ڡ�
alter table t1 enable row movement;  --�������ƶ�
alter table t1 shrink space compact cascade;--������������ͬ����

--����ɻָ��Ŀռ����
�����ڿռ䲻�㵼�¼��ش���������ʧ��ʱ�����ڿռ䲻�������£�����Ự������������ɼ��������ҿ������ó�ʱʱ�䡣
alter session enable resumable [TIMEOUT <seconds>];
alter session enable resumable timeout 10;

--�ռ�ֱ��ͼͳ����Ϣ
select 'execute dbms_stats.gather_table_stats(ownname =>''' || a.owner ||
          ''',tabname =>''' || a.table_name ||
          ''',estimate_percent =>5,degree=>7,cascade =>true,method_opt=>''for all columns size auto'');'
       as stats_sql
  from  dba_tables a
 where a.owner = upper('&owner')
   and a.table_name = upper('&tabname');
       
--for all columns size auto     �Զ��ռ���ֱ��ͼͳ����Ϣ
--for all columns size skewonly �Զ��ռ���������б�ϴ��ͳ����Ϣ
--for all columns size repeat   �ռ�֮ǰ�ռ�����ֱ��ͼͳ����Ϣ
--for all columns size 1        ɾ���е�ֱ��ͼͳ����Ϣ
--for columns size auto a b     �Ա����a��b�Զ��ռ�ֱ��ͼͳ����Ϣ


--no_invaildate=>flase      ˢ��ִ�мƻ�
--no_invaildate=>true       ��ˢ��ִ�мƻ�

--��ѯֱ��ͼ��Ϣ
select owner, table_name, column_name, histogram from dba_tab_col_statistics where table_name = 'T_SKEW1' ;

Ƶ��ֱ��ͼ��Frequency,Freq����Ƶ��ֱ��ͼֻ������Ŀ���е�distinctֵС�ڻ��ߵ���254������
�߶�ƽ��ֱ��ͼ��Height Balanced,HtBal������distinctֵ����254����ôֻ��ʹ�ø߶�ƽ��ֱ��ͼ

ֱ��ͼ��һ���е������ͳ����Ϣ����Ҫ�����������ϵ����ݷֲ�����������ݷֲ�������бʱ��ֱ��ͼ������С������cardinality������׼ȷ�ȡ�����ֱ��ͼ����Ҫ��ԭ����ǰ����Ż����ڱ���������֤��б��������õ�ѡ��
�����磬���е�ĳ����������ռ�����������80%�����ݷֲ���б������ص������Ϳ����޷��������������ѯ�����I/O����������ֱ��ͼ�����û��ڳɱ����Ż���֪����ʱʹ������������ʡ�

ֱ��ͼʵ�ʴ洢�������ֵ�sys.histgrm$�У�����ͨ�������ֵ�dba_tab_historgrams,dba_part_histograms��dba_subpart_histograms���ֱ�鿴��������ķ����ͷ�������ӷ�����ֱ��ͼ��Ϣ��

--estimate_percent ������
ͨ�����ò����ʣ���ȥ�������ͳ����Ϣ��Ϊ�˸���׼��ͳ����Ϣ��ORACLEʹ�� 
estimate_percent =>dbms_stats.auto_sample_size 

##expdp/impdp   �ο���http://www.linuxidc.com/Linux/2013-07/87891p3.htm http://www.linuxidc.com/Linux/2013-06/86383.htm
Data Pump����������������ɣ�
�ͻ��˹��ߣ�expdp/impdp
Data Pump API (��DBMS_DATAPUMP)
Metadata API����DMBS_METADATA)
��������v$process�а����������� DM00  DW00 
�����͵����������������ɫ
grant EXP_FULL_DATABASE to HR;        --����Ȩ��
grant IMP_FULL_DATABASE to HR;          --����Ȩ��

---�鿴dump���Ŀ¼
SELECT * FROM dba_directories t WHERE t.directory_name='DATA_PUMP_DIR';--Ĭ��·��
Ҳ�������д���·��
mkdir -p /data/oracle_backup
chown oracle:oinstall /data/oracle_backup
CREATE DIRECTORY dpump_dir AS '/data/oracle_backup';
GRANT READ, WRITE ON DIRECTORY dpump_dir TO hr; --hr�û���Ŀ¼�в����µ�Ȩ��
--expdp 5��ģʽ
--����ȫ��/schema(�û�)/��/��ռ�
expdp user_name<���е���Ȩ�޵ĵ�¼�û�> FULL=y/SCHEMAS=hr,sh,oe/TABLES=hr.employees,SH.jobs/TABLESPACES=tbs_4, tbs_5, tbs_6 DUMPFILE=expdat%u.dmp DIRECTORY=dpump_dir LOGFILE=export.log 
CONTENT=data_only  --��������
CLUSTER=N          --����Ⱥ��
PARALLEL=8         --���ж�
compression=all    --ѹ��<�ļ���С������1/7>  �ĸ�ѡ��ֱ���ALL��DATA_ONLY��METADATA_ONLY��NONE
FILESIZE=2G        --�����ļ���С
ENCRYPTION=data_only  --��������  --��ѡ
ENCRYPTION_PASSWORD=password --�������� --��ѡ
QUERY=hr.employees:"WHERE department_id > 10 AND salary > 10000"  --��ӵ���ʱ�Ĺ�������--���ڵ�����ʱ���ô˲���
SAMPLE=70      --��ӵ���ʱ���ݵİٷֱ�--���ڵ�����ʱ���ô˲��� 
table_exists_action  skip ������Ѵ��ڱ���������������һ������append��Ϊ���������ݣ�truncate�ǽضϱ�Ȼ��Ϊ�����������ݣ�replace��ɾ���Ѵ��ڱ����½���׷������
--���ݲ����ֱ�ӹ���
impdp user_cz/user_cz directory=DUMP_USER_CZ  logfile=DUMP_USER_CZ.log TABLES=LS85_PARA.CY_SERV_T REMAP_schema=LS85_PARA:user_cz  network_link=YS113_YS179_CZ query=LS85_PARA.CY_SERV_T:\"where serv_id=10841437\" table_exists_action=replace EXCLUDE=INDEX,STATISTICS parallel 8;                                    " 

--���ݲ����ֱ�ӹ��� �����ļ�
impdp user_cz/user_cz directory=DUMP_USER_CZ  logfile=DUMP_USER_CZ.log parfile=parfile.txt REMAP_schema=LS85_PARA:user_cz  network_link=YS113_YS179_CZ table_exists_action=replace; 

parfile.txt(parfile������������)
tables=
(
LS85_PARA.CY_SERV_T,
scott.test1,
scott.test2
)
query=
(
LS85_PARA.CY_SERV_T:"where serv_id=10841437",
scott.test1:"where UA_SERIAL_ID in ('96','26')",
scott.test2:"where FILESIZE=273899"
)
EXCLUDE=
(
INDEX,
STATISTICS
)





Ԫ���ݹ���
Ԫ���ݽ�������EXCLUDE��INCLUDE������ע�⣺���������⡣
EXCLUDE<������>���ӣ�
expdp FULL=YES DUMPFILE=expfull.dmp EXCLUDE=SCHEMA:"='HR'"
> expdp hr DIRECTORY=dpump_dir1 DUMPFILE=hr_exclude.dmp EXCLUDE=VIEW,METADATA,
PACKAGE, FUNCTION,INDEX,STATISTICS 
--������LOG��ͷ�ı�
exclude=table:"like 'LOG%'"

INCLUDE<������>���ӣ�
SCHEMAS=HR
DUMPFILE=expinclude.dmp
DIRECTORY=dpumexpincludep_dir1
LOGFILE=.log
INCLUDE=TABLE:"IN ('EMPLOYEES', 'DEPARTMENTS')"
INCLUDE=PROCEDURE
INCLUDE=INDEX:"LIKE 'EMP%'"


--impdp��expdp����

Schemaģʽ
����Schema�������﷨����
SCHEMAS=schema_name [,...]

����������ӵ���hr���ݵ�hr schema��

> impdp hr SCHEMAS=hr DIRECTORY=dpump_dir1 LOGFILE=schemas.log
DUMPFILE=expdat.dmp

Tableģʽ


����Table�������﷨���£�
TABLES=[schema_name.]table_name[:partition_name]

���û��ָ��schema_name��Ĭ�ϱ�ʾ���뵱ǰ�û���schema�£��磺
> impdp hr DIRECTORY=dpump_dir1 DUMPFILE=expfull.dmp TABLES=employees,jobs

Ҳ���Ե���ָ���ķ�����
> impdp hr DIRECTORY=dpump_dir1 DUMPFILE=expdat.dmp 
TABLES=sh.sales:sales_Q1_2012,sh.sales:sales_Q2_2012

Tablespaceģʽ
����Tablespace���������﷨���£�
TABLESPACES=tablespace_name [, ...]

������һ�����ӣ�Ҫע����ǣ���ЩҪ�����tablespace�����Ѿ����ڣ�����ᵼ��ʧ�ܡ�
> impdp hr DIRECTORY=dpump_dir1 DUMPFILE=expfull.dmp TABLESPACES=tbs_1,tbs_2,tbs_3,tbs_4

Transpotable Tablespaceģʽ
����Transpotable_tablespace���������﷨�������£�
TRANSPORT_TABLESPACES=tablespace_name [, ...]

REMAP_SCHEMA=source_schema:target_schema��������ܳ��ã��������㵼�뵽��ͬ��schema�У����target_schema�����ڣ�����ʱ���Զ�������������һ�����ӣ�
> expdp system SCHEMAS=hr DIRECTORY=dpump_dir1 DUMPFILE=hr.dmp

> impdp system DIRECTORY=dpump_dir1 DUMPFILE=hr.dmp REMAP_SCHEMA=hr:scott

REMAP_TABLE=[schema.]old_tablename[.partition]:new_tablename�����ڵ���ʱ��������������������һ�����ӣ�
> impdp hr DIRECTORY=dpump_dir1 DUMPFILE=expschema.dmp
TABLES=hr.employees REMAP_TABLE=hr.employees:emps

REMAP_TABLESPACE=source_tablespace:target_tablespace�ڵ���ʱ�޸ı�ռ�����������һ�����ӣ�
> impdp hr REMAP_TABLESPACE=tbs_1:tbs_6 DIRECTORY=dpump_dir1
  DUMPFILE=employees.dmp

SELECT * FROM v$database ;--PLATFORM_NAME
SELECT * FROM v$transportable_platform;  --�ֽ����и�ʽת��
--��Դ���ݿ�����rman��¼Ŀ�����ݿ�
convert datafile '/u01/app/oracle/admin/orcl/dpdump/hrtab.dump' to platform 'AIX-Based Systems (64-bit)' format '/u01/app/oracle/admin/orcl/dpdump/hrtab_aix.dump';

SELECT * FROM dba_rsrc_consumer_groups;
SELECT * FROM dba_users;
SELECT * FROM dba_rsrc_plan_directives;

--��ѯ��������ݱ仯��
����ͳ����ϢʧЧ�ı�׼�������ݱ仯����10%
select * from dba_tab_modifications;
�������ݱ仯ʱ������������ʾ��������Ҫ�ֶ�ˢ�¡�
begin
	dbms_stats.flush_database_monitoring_info();
end;

==========������ҵ===========
--�鿴������ҵ
SELECT * FROM dba_scheduler_jobs;
--�鿴�ƻ��������
SELECT * FROM v$process t WHERE t.PROGRAM like '%J%';
--���ȳ��� <������Ķ�����ҵ>
--show parameter job  --��Ϊ0 �򲻻����е��ȳ���
job_queue_processes                  integer     1000 
dbms_scheduler.create_job;    --��ҵ
dbms_scheduler.create_program; --����
dbms_scheduler.create_schedule; --ʱ���

--job_type                                                  job_action 
PLSQL_BLOCK������PL/SQL ��                        'insert into times values (sysdate)'

STORED_PROCEDURE��������PL/SQL��Java ���ⲿ����   'begin HR.cleanup_events; end; '

EXECUTABLE�����ԴӲ���ϵͳ(OS) ������ִ�е�����    '/home/usr/dba/rman/nightly_incr.sh'


exec dbms_scheduler.create_job(job_name => 'savedate', job_type => 'plsql_block',job_action =>'insert into times values (sysdate);',start_date =>sysdate,repeat_interval => 'freq=minutely;interval=1',enabled => true,auto_drop => false);

exec dbms_scheduler.create_job(job_name => 'savedate_por', job_type => 'STORED_PROCEDURE',job_action =>'CZ.TEST01',start_date =>sysdate,repeat_interval => 'freq=minutely;interval=1',enabled => true,auto_drop => false);

--��ѯ��ҵ
SELECT * FROM dba_scheduler_jobs t WHERE t.job_name=upper('savedate');

--��ѯ��ҵ�Ĺ�����־��¼
SELECT * FROM dba_scheduler_job_log t WHERE t.JOB_NAME=upper('savedate');

--����/������ҵ
exec dbms_scheduler.disable('savedate_p');
exec dbms_scheduler.enable('savedate');

--ɾ����ҵ
exec dbms_scheduler.drop_job('savedate_por');

--�ﻯ��ͼJOB
select job,log_user,to_char(next_date,'DD-MON-YYYY HH24:MI:SS') next_date, interval,what from dba_jobs;
�鿴�������е���ҵ
select * from dba_jobs_running;

�ﻯ��ͼ��ˢ��ʱ���ֱ��ͨ��SQl�ű��޸�
alter materialized view ecif.V_NSRCX_ZJLSDJ                       refresh force on demand     start with to_date('31-10-2017 03:00:00', 'dd-mm-yyyy hh24:mi:ss') next to_date(concat(to_char( sysdate+1,'dd-mm-yyyy'),'03:00:00'),'dd-mm-yyyy hh24:mi:ss'); 

=======���ݿ�ı�����ָ�===========
--����������־������������־�飬ÿ����־������������Ա��
SELECT * FROM v$log;  --current ��ʾ��ǰ��ʹ��
SELECT * FROM v$logfile;
--�л�����������־
alter system switch logfile;
--�����־��
alter database add logfile group 4 '+FRA/orcl/onlinelog/group_4relog01' size 50M;
--�����־���Ա ��ɺ�ִ�м���alter system switch logfile �Ϳ���Ч
alter database add logfile member '+FRA/orcl/onlinelog/group_4relog02' to group 4;

--�鿴��ǰ�Ŀ����ļ�
SELECT * FROM  v$controlfile;
--�鿴��ǰϵͳʹ�õĿ����ļ�����
SELECT * FROM v$parameter t WHERE t.NAME='control_files';

--ȷ�����ݿ�Ĺ鵵ģʽ
SELECT archiver FROM v$instance;
SELECT log_mode FROM v$database;

--���ÿ��ٻָ���
--����������־�ļ�����·���ø����������ļ�����·���ø������鵵��־�ļ���rman�����ļ��ȡ�
SELECT * FROM v$parameter t WHERE t.NAME like 'db_recovery%';
db_recovery_file_dest
db_recovery_file_dest_size

-���ٻָ���ʹ����
SELECT substr(name, 1, 30) name, space_limit/1024/1024/1024 AS quota_G,
space_used/1024/1024/1024 AS used_G,
space_reclaimable/1024/1024/1024 AS reclaimable,
number_of_files AS files
FROM v$recovery_file_dest ;

-���ٻָ���ʹ����ϸ
select * from V$RECOVERY_AREA_USAGE;


-�ͷſ��ٻָ���(ɾ���鵵)
RMAN> crosscheck archivelog all;
RMAN> delete noprompt expired archivelog all;
RMAN> DELETE noprompt ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE';
-ɾ��2Сʱǰ�Ĺ鵵��־
delete noprompt archivelog all completed before 'sysdate -2/24'
-ɾ����Сʱǰ�Ĺ鵵��־���ߵ����ɾ��һ��ʹ��������
delete noprompt archivelog all completed before 'sysdate -0.5/24'
-�鿴�����Ĺ鵵
select sum(blocks*block_size)/1024/1024/1024 from v$archive_log where dest_id=1 and completion_time>to_date('2021-08-01 15:30:00','yyyy-mm-dd hh24:mi:ss');
select sum(blocks*block_size)/1024/1024/1024 from v$archive_log where dest_id=1 and first_time>to_date('2021-08-01 15:30:00','yyyy-mm-dd hh24:mi:ss');
--�鿴redo��archivelog ���
select name,thread#,sequence#,first_time,next_time,first_change#,next_change# from v$archived_log where sequence#=241 and thread#=1;
select sequence#,status,group# from v$log;

--���ú�ʹ��
SELECT * FROM v$recovery_file_dest;
SELECT * FROM v$recovery_area_usage;

--�л�archivelogģʽ
--��ɱ������л�Ϊarchivelogģʽ��һ������Ĳ��衣
--�鿴�鵵��־�ļ�
SELECT * FROM v$archived_log;
--�鵵��־�����ٻָ�����ָ��
SELECT * FROM v$archive_dest;

======rman����=======
--�鿴�鵵ģʽ
archive log list;
--�ǹ鵵ģʽ�µ����ⱸ��
shutdown immedaite;
rman target /
RMAN> startup mount;
RMAN> backup database;

--�鵵ģʽ����
backup datafile 1,2;
--��������ͨ��d1,d2,���������ļ����鵵��־�ļ��ı��� SBT--�Ŵ�
rman>run {allocate channel d1 type disk; allocate channel d2 type disk/SBT; backup as compressed backupset database;backup as compressed backupset archivelog all <delete all input>;}

--�鿴�����ļ�����
SELECT * FROM v$backup_files;
SELECT * FROM v$backup_piece;
SELECT * FROM v$backup_piece_details;
SELECT * FROM v$backup_datafile;
SELECT * FROM v$backup_datafile_details;
SELECT * FROM v$backup_datafile_summary;

--�鿴�����ļ�����
SELECT * FROM v$backup_controlfile_details;
SELECT * FROM v$backup_controlfile_summary;

--�鿴�鵵��־�ļ�����
SELECT * FROM v$backup_archivelog_details;
SELECT * FROM v$backup_archivelog_summary;

--�����ָ�Ŀ¼
sql>create tablespace rman_cata datafile '+DATA/orcl/datafile/rman_cata.dbf' size 150M;
create user rman identified by rman;
grant recovery_catalog_owner,connect,resource to rman; 

rman target / catalog rman@orcl --Զ�̻򱾵����ݿ�
create catalog tablespace rman_cata;
register database;
resync catalog;

--����ȫ�ֻ򱾵ؽű�
create global script backup_src {backup database plus archivelog;}
--��ʾ�ű�����
list script names;
--��ʾ�ű�����
print global script backup_src;
--���нű�
 run {execute script backup_src};
--ɾ���ű�
delete script backup_src;

--��������
--0�� ȫ��
backup incremental level 0 tablespace users;
--1�� �������ݣ����챸�ݣ�
backup incremental level 1 tablespace users;
--1�� �ۻ�����
backup incremental level 1 cumulative tablespace users;

--�����鵵����
�����̶�ʱ��Ĺ鵵���ݼ�
backup as compressed backupset database format '+FRA/orcl/archback/%U' tag save_1_year keep until time 'sysdate+365'; --Ŀ¼������ASM��Ӧ��·���д���
backup as compressed backupset database format '+FRA/orcl/archback/%U' tag save_forever keep  forever;     --���ñ���

--���ö�α���
backup tablespace users section size 30M/10G;  --ָ���ֶεĴ�С

--��֤���ļ������µ�
--���ע���ļ��б��ݼ����鵵��־�ļ�������������Ϊexpired,��ɾ����
run {crosscheck backupset; crosscheck archivelog all;delete expired backupset;delete expired archivelog all;}

----�����ָ�
1������Ҫ�����ļ��ָ�<��ʧ���ļ�����system��undo��һ����>
--��ռ�
rman>sql "alter tablespace users offline immediate";
RMAN> restore tablespace users;
RMAN> recover tablespace users;
RMAN> sql "alter tablespace users online ";
--�����ļ�
alter database datafile 6 offline;
restore datafile 6;
recover datafile 6;
alter database datafile 6 online;

2����Ҫ�����ļ��ָ�<system��undo��>
�ر����ݿ⣺shutdown abort;
�������ݿ⣺startup mount;
restore tablespace/datafile system/1 ;
recover tablespace/datafile system/1 ;
alter database open;

----�������ָ�
�鿴��ǰ��SCN
SELECT t.CURRENT_SCN FROM v$database t; 
--Ϊ�ض���SCN������ԭ��
create resotre point scn_now as of scn 1943513;
--ɾ��ָ���Ļ�ԭ��
drop restore point scn_now;

--�鿴���滹ԭ���ʱ��
show parameter keep_time;
control_file_record_keep_time        integer     7

--��ԭ�����ļ�
startup nomount;
restore controlfile from autobackup;
alter database mount;
recover database;
alter database open resetlogs;

--����������־��
SELECT * FROM v$log;
current --����д������飬�ָ�ʵ��ʱ��Ҫ�����
active  --�ָ�ʵ����Ҫ����飬�������ڹ鵵
inactive --�ָ�����Ҫ����顣
unused  --��־��δʹ��
clearing --alter database clear logfile;
clearing_current --����г���


--����DROP���±��ɾ���������������purge���޷�����
SELECT t.original_name,'flashback table '||t.owner||'.'||t.original_name||' to before drop;',t.droptime FROM dba_recyclebin t WHERE t.owner='SJYY' AND  t.original_name='SB_ZZS_YBNSR_FB3_YSFWKCXM';

����������
ALTER INDEX sjyy."BIN$W0ex0vC6IfDgUwwICgq/fA==$0" RENAME TO idx_aaa;
������Լ��������
ALTER TABLE sjyy.SB_ZZS_YBNSR_FB3_YSFWKCXM RENAME CONSTRAINT "BIN$W0ex0vC0IfDgUwwICgq/fA==$0" TO PK_PC59;

--�������
alter table student add constraint pk_student primary key(studentid) tablespace SJYY_TS;
--������ȡ����
 select OWNER,TABLE_NAME, to_char('alter table FYL_A add constraints ' || constraint_name ||
        '   primary key (' || wm_concat(COLUMN_NAME)||');')  from 
 (select b.OWNER,b.TABLE_NAME,b.constraint_name,a.COLUMN_NAME  from all_cons_columns a, all_constraints b
  where b.CONSTRAINT_TYPE = 'P'
    and a.CONSTRAINT_NAME = b.CONSTRAINT_NAME  order by a.POSITION)
    group by OWNER,TABLE_NAME,constraint_name; 

alter table SJYY.DW_TJ_DJ_NSRXX
  add constraint PRI_DW_TJ_DJ_NSRXX primary key (ETL_DT, DJXH)
  using index 
  tablespace SJYY_TS
--�����������ݿ� 
--��Ҫ��mount״̬�¿��� 
1��--���� ARCHIVELOG
SELECT t.LOG_MODE FROM v$database t;
2��--ȷ���������ػָ�����λ�úʹ�С
alter system set  db_recovery_file_dest='+FRA';
alter system set  db_recovery_file_dest_size=4G;
3��--���ñ���ʱ�� --��λ������
alter system set db_flashback_retention_target=240;
4��--����������־��¼
alter database flashback on;
5��--�����ݿ�
alter database open;
6��--ȷ�������Ѿ�������ɼ�����������
select flashback_on from v$database;
SELECT spid FROM v$process WHERE pname='RVWR';

--������ز�ѯ��ͼ
SELECT * FROM v$flashback_database_log;
SELECT * FROM v$flashback_database_stat;

--��ѯ��ǰ���ػ������Ĵ�С
SELECT * FROM v$sgastat t WHERE t.NAME='flashback generation buff';

--RMAN�����Ż�
--�鿴���ݽ���
SELECT a.SID,b.SPID,a.CLIENT_INFO FROM v$session a,v$process b WHERE a.PADDR=a.SADDR and a.CLIENT_INFO='%rman%'; 

--ORACLE ����汾��ѯ 
select * from dba_registry;

--�澯��־
show parameter background_dump_dest
/u01/app/oracle/diag/rdbms/orcl/orcl/alert
--�����ļ�
show parameter diag
/u01/app/oracle/diag/rdbms/orcl/orcl/trace

--������ʷ��Ϣ
SELECT * FROM dba_alert_history;

--ͻ���澯��Ϣ
SELECT * FROM dba_outstanding_alerts;

--ASM�����͹ر�˳��
�ȹر����ݿ�ʵ�����ٹر�ASMʵ��
������ASMʵ�������������ݿ�ʵ��
ASMCMD>shutdown abort 
ASMCMD>startup
--�鿴״̬ 
[oracle@edt3r10p1 ~]$ srvctl status asm

======��Ӵ���ASM������========
--�����������Ӵ���<�������������>
[root@localhost ~]# echo "- - -" > /sys/class/scsi_host/host0/scan

--�Դ���������
fdisk /dev/sdc
--������ת��ΪPV
pvcreate /dev/sdc
pvcreate /dev/sdc1
pvcreate /dev/sdc2
pvcreate /dev/sdc3

--����VG
vgcreate VolGroup02 /dev/sdc1 /dev/sdc2
�鿴 vgscan 
�鿴��ϸ vgdisplay

--����LV
lvcreate -L 968MB  -n LogVol03 VolGroup02

--��ʽ��
mke2fs -j /dev/VolGroup02/LogVol03

--��oracle asm��Ӵ���
oracleasm createdisk ASMDISK14 /dev/sdc4

1���ҵ�δʹ�õĴ��̡�
��SELECT * FROM v$asm_disk;
--�鿴������
��SELECT * FROM v$asm_diskgroup;�ҵ���Ҫ��ӵĴ�����
2����ӣ�alter diskgroup FRA add disk 'ORCL:ASMDISK09';

--�Ӵ�������ɾ������
alter diskgroup FRA drop disk ASMDISK09;

--���������鼰������  external, normal��high redunancy
create diskgroup DGA normal redundancy failgroup controlerA disk 'ORCL:ASMDISK09','ORCL:ASMDISK10' failgroup controlerB disk 'ORCL:ASMDISK11','ORCL:ASMDISK12';
--ɾ��������
drop diskgroup DGA including contents;

--�������Ӧ�������ļ�
SELECT b.GROUP_NUMBER,b.NAME,f.type, f.redundancy, f.striped, f.modification_date,
a.system_created, a.name FROM v$asm_alias a, v$asm_file f,v$asm_diskgroup b WHERE
a.file_number = f.file_number and a.group_number = f.group_number and a.GROUP_NUMBER=b.GROUP_NUMBER
and f.type='DATAFILE';

--��ȡ�󶨱�����ֵ
select instance_number,
       sql_id,
       name,
       datatype_string,
       last_captured,
       value_string
  from dba_hist_sqlbind
 where sql_id = '06qn4w6am2d2v'
 order by LAST_CAPTURED desc, POSITION ;

--�����鵵
shutdown immediate; �C�ر����ݿ� 
startup mount; �C �����ݿ� 
alter database archivelog;�������鵵��־ 
alter database open;�C�������ݿ� 
archive log list; �C �鿴�鵵��־�Ƿ���

--�رչ鵵
shutdown immediate;                      
startup mount;                           
alter database noarchivelog;             
alter database open;                     
archive log list;

--��ʵ���鵵�޸�
ԭ�鵵·�����ÿ��ٻָ����������޸�ԭ�У���Ҫ�������ݿ⣬�����޸�log_archive_dest_n�ǿ���ֱ����Ч�ģ��ͱ���˶�·����
SQL> alter system set log_archive_dest='/opt/oracle/arch_dir' scope=spfile sid='*';
������Ч��
startup force 

--�鵵��־ÿ������ͳ��
SELECT t."THREAD#",to_char(t."COMPLETION_TIME",'yyyymmdd'),sum(t."BLOCKS"*t."BLOCK_SIZE"/1024/1024/1024) size_G FROM v$archived_log t group by t."THREAD#",to_char(t."COMPLETION_TIME",'yyyymmdd') order by 2 desc;

/* ���ÿСʱ�Ĺ鵵���� */
SELECT  trunc(first_time) "Date",
        to_char(first_time, 'Dy') "Day",
        count(1) "Total",
        SUM(decode(to_char(first_time, 'hh24'),'00',1,0)) "hh00",
        SUM(decode(to_char(first_time, 'hh24'),'01',1,0)) "hh01",
        SUM(decode(to_char(first_time, 'hh24'),'02',1,0)) "hh02",
        SUM(decode(to_char(first_time, 'hh24'),'03',1,0)) "hh03",
        SUM(decode(to_char(first_time, 'hh24'),'04',1,0)) "hh04",
        SUM(decode(to_char(first_time, 'hh24'),'05',1,0)) "hh05",
        SUM(decode(to_char(first_time, 'hh24'),'06',1,0)) "hh06",
        SUM(decode(to_char(first_time, 'hh24'),'07',1,0)) "hh07",
        SUM(decode(to_char(first_time, 'hh24'),'08',1,0)) "hh08",
        SUM(decode(to_char(first_time, 'hh24'),'09',1,0)) "hh09",
        SUM(decode(to_char(first_time, 'hh24'),'10',1,0)) "hh10",
        SUM(decode(to_char(first_time, 'hh24'),'11',1,0)) "hh11",
        SUM(decode(to_char(first_time, 'hh24'),'12',1,0)) "hh12",
        SUM(decode(to_char(first_time, 'hh24'),'13',1,0)) "hh13",
        SUM(decode(to_char(first_time, 'hh24'),'14',1,0)) "hh14",
        SUM(decode(to_char(first_time, 'hh24'),'15',1,0)) "hh15",
        SUM(decode(to_char(first_time, 'hh24'),'16',1,0)) "hh16",
        SUM(decode(to_char(first_time, 'hh24'),'17',1,0)) "hh17",
        SUM(decode(to_char(first_time, 'hh24'),'18',1,0)) "hh18",
        SUM(decode(to_char(first_time, 'hh24'),'19',1,0)) "hh19",
        SUM(decode(to_char(first_time, 'hh24'),'20',1,0)) "hh20",
        SUM(decode(to_char(first_time, 'hh24'),'21',1,0)) "hh21",
        SUM(decode(to_char(first_time, 'hh24'),'22',1,0)) "hh22",
        SUM(decode(to_char(first_time, 'hh24'),'23',1,0)) "hh23"
FROM    V$log_history
group by trunc(first_time), to_char(first_time, 'Dy')
Order by 1 desc; 

/* �鿴����ÿСʱ�鵵������ */  
select logtime,  
       count(*),  
       round(sum(blocks * block_size)/1024/1024/1024,2) gbsize  
  from (select trunc(first_time, 'hh') as logtime, a.BLOCKS, a.BLOCK_SIZE  
          from v$archived_log a  
         where a.DEST_ID = 1  
           and a.FIRST_TIME > trunc(sysdate))  
 group by logtime  
 order by logtime desc; 

 /* �鿴���һ��ÿ��鵵������ */
 select logtime,  
       count(*),  
       round(sum(blocks * block_size)/1024/1024/1024,2) size_gb  
  from (select trunc(first_time, 'dd') as logtime, a.BLOCKS, a.BLOCK_SIZE  
          from v$archived_log a  
         where a.DEST_ID = 1  
           and a.FIRST_TIME > trunc(sysdate - 7))  
 group by logtime  
 order by logtime desc;
 
 
--������ʱ��ռ�����   
Select se.username,
       se.sid,
       se."SERIAL#",
       su.extents,
       su.blocks * to_number(rtrim(p.value))/1024 as Size_M,
       tablespace,
       segtype,
       sql_text,
       su."SQL_ID",
       sss."LAST_ACTIVE_TIME"
  from v$sort_usage su, v$parameter p, v$session se, v$sql sss
 where p.name = 'db_block_size'
   and su.session_addr = se.saddr
   and sss.hash_value = su.sqlhash
   and sss.address = su.sqladdr
 order by sss."LAST_ACTIVE_TIME" desc;

--ռ����ʱ��մ����ʷ�Ự��sql��ѯ��
select to_char(a.sample_time, 'yyyy-mm-dd hh24'),
       a.session_id,
       u.username,
       a.sql_id
  from gv$active_session_history a, dba_users u
 where u.user_id = a.user_id
   and to_char(a.sample_time, 'yyyy-mm-dd hh24:mi:ss') >
       '2021-05-25 20:30:00'
   and to_char(a.sample_time, 'yyyy-mm-dd hh24:mi:ss') <
       '2021-05-25 20:40:59'
   and a.temp_space_allocated > 10000000
   and sql_id is not null
 group by to_char(a.sample_time, 'yyyy-mm-dd hh24'),
          a.session_id,
          u.username,
          a.sql_id
 order by a.sql_id, a.session_id desc;
��
 select to_char(a.sample_time, 'yyyy-mm-dd hh24'),
       a.session_id,
       u.username,
       a.sql_id
  from dba_hist_active_sess_history a, dba_users u
 where u.user_id = a.user_id
   and to_char(a.sample_time, 'yyyy-mm-dd hh24:mi:ss') >
       '2020-07-09 11:00:00'
   and to_char(a.sample_time, 'yyyy-mm-dd hh24:mi:ss') <
       '2020-07-09 11:10:00'
   and a.temp_space_allocated > 1000000000
   and sql_id is not null
 group by to_char(a.sample_time, 'yyyy-mm-dd hh24'),
          a.session_id,
          u.username,
          a.sql_id
 order by a.sql_id, a.session_id desc;
--�鿴sqlռ����ʱ��ռ����ֵ��
select max(a.temp_space_allocated / 1024 / 1024 / 1024) g
  from gv$active_session_history a
 where a.sql_id = '6uk7dr0n12f9n';


--��ʱ��ռ��ʹ�����
select d.tablespace_name,
space "sum_space(m)",
blocks sum_blocks,
used_space "used_space(m)",
round(nvl(used_space, 0) / space * 100, 2) "used_rate(%)",
nvl(free_space, 0) "free_space(m)"
from (select tablespace_name,
round(sum(bytes) / (1024 * 1024), 2) space,
sum(blocks) blocks
from dba_temp_files
group by tablespace_name) d,
(select tablespace_name,
round(sum(bytes_used) / (1024 * 1024), 2) used_space,
round(sum(bytes_free) / (1024 * 1024), 2) free_space
from v$temp_space_header
group by tablespace_name) f
where d.tablespace_name = f.tablespace_name(+);

--��չ��ʱ��ռ�
select d.file_name,d.tablespace_name,d.autoextensible from dba_temp_files d; 


ALTER TABLESPACE TEMP
 ADD TEMPFILE'/u01/oracle/oradata/NFZCDB/temp02.dbf'                                                                    
 SIZE 30G
 AUTOEXTEND ON
 NEXT 128M;

--�鿴�����ڴ�ʹ�����
SELECT count(*),round(sum(t."SHARABLE_MEM")/1024/1024,2) FROM v$db_object_cache t;

--�û���Ӧ��ռ�ʹ�����
SELECT c.owner                                  "�û�", 
       a.tablespace_name                        "��ռ���", 
       total/1024/1024                          "��ռ��СM", 
       free/1024/1024                           "��ռ�ʣ���СM", 
       ( total - free )/1024/1024               "��ռ�ʹ�ô�СM", 
       Round(( total - free ) / total, 4) * 100 "��ռ��ܼ�ʹ����   %", 
       c.schemas_use/1024/1024                  "�û�ʹ�ñ�ռ��СM", 
       round((schemas_use)/total,4)*100         "�û�ʹ�ñ�ռ���  %"      
FROM   (SELECT tablespace_name, 
               Sum(bytes) free 
        FROM   DBA_FREE_SPACE 
        GROUP  BY tablespace_name) a, 
       (SELECT tablespace_name, 
               Sum(bytes) total 
        FROM   DBA_DATA_FILES 
        GROUP  BY tablespace_name) b, 
       (Select owner ,Tablespace_Name, 
                Sum(bytes) schemas_use  
        From Dba_Segments  
        Group By owner,Tablespace_Name) c 
WHERE  a.tablespace_name = b.tablespace_name 
and a.tablespace_name =c.Tablespace_Name 
order by "�û�","��ռ���" ;                      

##�ҳ����������ĻỰ
select *
  from (select a.inst_id, a.sid, a.serial#,
               a.sql_id,
               a.event,
               a.status,
               connect_by_isleaf as isleaf,
               sys_connect_by_path(a.SID||'@'||a.inst_id, ' <- ') tree,
               level as tree_level
          from gv$session a
         start with a.blocking_session is not null
        connect by (a.sid||'@'||a.inst_id) = prior (a.blocking_session||'@'||a.blocking_instance))
 where isleaf = 1
 order by tree_level asc;
 
##��������
ȡ�� ����Ϊ��SB_CWBB_CJTJJ_ZCFZB  ������Ϊ��idx_CJTJJ_ZCFZB_ZLBSCJUUID
SELECT distinct  'create index '||t.tab_owner||'.idx_' || trim (substr(t.tab_name,instr(t.tab_name,'_',-1,2)+1)) ||'_ZLBSCJUUID on '||t.tab_owner||'.'||trim(t.tab_name)||'(ZLBSCJUUID) online nologging;'FROM cz.create_index_t t;

##ORA-12720: operation requires database is in EXCLUSIVE mode
--��rac���Ĺ鵵ģʽ
��һ̨������ִ�У�
alter system set cluster_database=false scope=spfile sid='*';
����̨������ִ�У�
shutdown immediate
��һ̨������ִ�У�
startup mount������Ҫ��2̨����ͬʱshutdown��ϼ��ɣ�
alter database noarchivelog;
alter database open;
alter system set cluster_database=true scope=spfile sid='*';
shutdown immediate;
����̨������ִ�У�
Startup
��ʱ�޸���ϼ��ɹرչ鵵�������鵵�������ơ�

##ASM�ȴ��¼�
select sid, state, event, seconds_in_wait, blocking_session
from   v$session
where  blocking_session is not null
or sid in (select blocking_session 
         from   v$session 
           where  blocking_session is not null)
 order by sid;
##��ʷ�ȴ��¼���ѯ
  with tt as
  (SELECT t.instance_number, t.user_id, t."SQL_ID", t."EVENT", count(1) CNT
     FROM DBA_HIST_ACTIVE_SESS_HISTORY t
    WHERE t."WAIT_CLASS" <> 'Idle'
      and t.sql_id is not null
      and t."SAMPLE_TIME" between
          to_date('2020-01-01 09:00:00', 'yyyy-mm-dd hh24:mi:ss') and
          to_date('2020-01-03 11:00:00', 'yyyy-mm-dd hh24:mi:ss')
    group by t.instance_number, t.user_id, t."SQL_ID", t."EVENT"
    order by count(1) desc)
 SELECT tt.instance_number, a.username, tt."SQL_ID", tt."EVENT", tt.CNT
   FROM tt, dba_users a
  where a.user_id = tt.user_id and rownum<11;
  

##����ӱ���
--��������Ӱ�����е�ddl��dml�Լ�expdp�Ĳ���
lock table cz.m_obj_cz in exclusive mode nowait;    //�����plsqldev��ִ�еģ���Ҫ���ύ��ִ����ɾͿ���
--�ͷ���
ͨ��lock_objectɱ�����̡�

##TOP 10 ִ�д������� 
select * 
from (select executions,username,PARSING_USER_ID,sql_id,sql_text    
   from v$sql,dba_users where user_id=PARSING_USER_ID order by executions desc) 
where rownum <=5;

##TOP 10 �������������IO���򣬼��������SQL����ЧSQL���� 
select * 
from (select DISK_READS,username,PARSING_USER_ID,sql_id,ELAPSED_TIME/1000000,sql_text    
   from v$sql,dba_users where user_id=PARSING_USER_ID order by DISK_READS desc) 
where rownum <=5;

ע�⣺��Ҫʹ��DISK_READS/ EXECUTIONS��������Ϊ�κ�һ����䲻��ִ�м��ζ�����߼�����cpu�����ܲ���������������LRU������������LRU������ִ���Ƶ���������һ��ִ��ʱ������������Զ�ľͻᱻ������buffer cache��������Ϊbuffer cache��ŵ������ݿ飬ȥ���ݿ�������һ��������cpu���߼����ġ�Shared poolִ�д��sql�Ľ��������sqlִ�е�ʱ��ֻ��ȥshare pool����hash value�������ƥ��ľ��������������������߼�������buffer cache�У������Ӳ��������shared pool��

##TOP 10 �߼������������ڴ�����
select * 
from (select BUFFER_GETS,username,PARSING_USER_ID,sql_id,ELAPSED_TIME/1000000,sql_text    
   from v$sql,dba_users where user_id=PARSING_USER_ID order by BUFFER_GETS desc) 
where rownum <=5;

ע�⣺��Ҫʹ��BUFFER_GETS/ EXECUTIONS��������Ϊ�κ�һ����䲻��ִ�м��ζ�����߼�����cpu�����ܲ���������������LRU������������LRU������ִ���Ƶ���������һ��ִ��ʱ������������Զ�ľͻᱻ������buffer cache��������Ϊbuffer cache��ŵ������ݿ飬ȥ���ݿ�������һ��������cpu���߼����ġ�Shared poolִ�д��sql�Ľ��������sqlִ�е�ʱ��ֻ��ȥshare pool����hash value�������ƥ��ľ��������������������߼�������buffer cache�У������Ӳ��������shared pool��

##TOP 10 CPU����(��λ��=cpu_time/1000000) 
select * 
from (select CPU_TIME/1000000,username,PARSING_USER_ID,sql_id,ELAPSED_TIME/1000000,sql_text    
   from v$sql,dba_users where user_id=PARSING_USER_ID order by CPU_TIME/1000000 desc) 
where rownum <=5;

ע�⣺��Ҫʹ��CPU_TIME/ EXECUTIONS��������Ϊ�κ�һ����䲻��ִ�м��ζ�����߼�����cpu�����ܲ���������������LRU������������LRU������ִ���Ƶ���������һ��ִ��ʱ������������Զ�ľͻᱻ������buffer cache��������Ϊbuffer cache��ŵ������ݿ飬ȥ���ݿ�������һ��������cpu���߼����ġ�Shared poolִ�д��sql�Ľ��������sqlִ�е�ʱ��ֻ��ȥshare pool����hash value�������ƥ��ľ��������������������߼�������buffer cache�У������Ӳ��������shared pool��

##��ѯ��PGA�����ʹ����ʱ��ռ����Ƶ����10��SQL��� 
select * from  
( 
select OPERATION_TYPE,ESTIMATED_OPTIMAL_SIZE,ESTIMATED_ONEPASS_SIZE, 
sum(OPTIMAL_EXECUTIONS) optimal_cnt,sum(ONEPASS_EXECUTIONS) as onepass_cnt, 
sum(MULTIPASSES_EXECUTIONS) as mpass_cnt,s.sql_text 
from V$SQL_WORKAREA swa, v$sql s  
where swa.sql_id=s.sql_id  
group by OPERATION_TYPE,ESTIMATED_OPTIMAL_SIZE,ESTIMATED_ONEPASS_SIZE,sql_text 
having sum(ONEPASS_EXECUTIONS+MULTIPASSES_EXECUTIONS)>0  
order by sum(ONEPASS_EXECUTIONS) desc 
)  
where rownum<10 

##�鿴��ʱ��ռ�ʹ����
����һ

SELECT temp_used.tablespace_name,round(total),used, 
           round(total - used) as "Free", 
           round(nvl(total-used, 0) * 100/total,1) "Free percent" 
      FROM (SELECT tablespace_name, SUM(bytes_used)/1024/1024 used 
              FROM GV$TEMP_SPACE_HEADER 
             GROUP BY tablespace_name) temp_used, 
           (SELECT tablespace_name, SUM(decode(autoextensible,'YES',MAXBYTES,bytes))/1024/1024 total 
              FROM dba_temp_files 
             GROUP BY tablespace_name) temp_total 
     WHERE temp_used.tablespace_name = temp_total.tablespace_name

������

SELECT a.tablespace_name, round(a.BYTES/1024/1024) total_M, round(a.bytes/1024/1024 - nvl(b.bytes/1024/1024, 0)) free_M, 
round(b.bytes/1024/1024) used,round(b.using/1024/1024) using 
  FROM (SELECT   tablespace_name, SUM (decode(autoextensible,'YES',MAXBYTES,bytes)) bytes FROM dba_temp_files GROUP BY tablespace_name) a, 
       (SELECT   tablespace_name, SUM (bytes_cached) bytes,sum(bytes_used) using FROM v$temp_extent_pool GROUP BY tablespace_name) b 
WHERE a.tablespace_name = b.tablespace_name(+)


����undo��Ҫ��� 

SELECT (UR * (UPS * DBS)) AS "Bytes"  
FROM (select max(tuned_undoretention) AS UR from v$undostat),  
(SELECT undoblks/((end_time-begin_time)*86400) AS UPS  
FROM v$undostat  
WHERE undoblks = (SELECT MAX(undoblks) FROM v$undostat)),  
(SELECT block_size AS DBS  
FROM dba_tablespaces  
WHERE tablespace_name = (SELECT UPPER(value) FROM v$parameter WHERE name = 'undo_tablespace'));

##����undo�ĵ�ǰ��Ự����Щ 
����һ
SELECT a.inst_id, a.sid, c.username, c.osuser, c.program, b.name, 
a.value, d.used_urec, d.used_ublk 
FROM gv$sesstat a, v$statname b, gv$session c, gv$transaction d 
WHERE a.statistic# = b.statistic# 
AND a.inst_id = c.inst_id 
AND a.sid = c.sid 
AND c.inst_id = d.inst_id 
AND c.saddr = d.ses_addr 
AND b.name = 'undo change vector size' 
AND a.value>0 
ORDER BY a.value DESC 


������
select s.sid,s.serial#,s.sql_id,v.usn,r.status, v.rssize/1024/1024 mb
from dba_rollback_segs r, v$rollstat v,v$transaction t,v$session s
Where r.segment_id = v.usn and v.usn=t.xidusn and t.addr=s.taddr
order by 6 desc;

##��ѯRman���ݼ���ϸ��Ϣ��δ���ڵģ����ڲ���ɾ���Ĳ鲻����
SELECT B.RECID BackupSet_ID, 
       A.SET_STAMP, 
        DECODE (B.INCREMENTAL_LEVEL, 
                '', DECODE (BACKUP_TYPE, 'L', 'Archivelog', 'Full'), 
                1, 'Incr-1��', 
                0, 'Incr-0��', 
                B.INCREMENTAL_LEVEL) 
           "Type LV", 
        B.CONTROLFILE_INCLUDED "����CTL", 
        DECODE (A.STATUS, 
                'A', 'AVAILABLE', 
                'D', 'DELETED', 
                'X', 'EXPIRED', 
                'ERROR') 
           "STATUS", 
        A.DEVICE_TYPE "Device Type", 
        A.START_TIME "Start Time", 
        A.COMPLETION_TIME "Completion Time", 
        A.ELAPSED_SECONDS "Elapsed Seconds", 
        A.BYTES/1024/1024/1024 "Size(G)", 
        A.COMPRESSED, 
        A.TAG "Tag", 
        A.HANDLE "Path" 
   FROM GV$BACKUP_PIECE A, GV$BACKUP_SET B 
  WHERE A.SET_STAMP = B.SET_STAMP AND A.DELETED = 'NO' 
ORDER BY A.COMPLETION_TIME DESC;

##��ѯRman���ݽ��� 
SELECT SID, SERIAL#, opname,ROUND(SOFAR/TOTALWORK*100)||'%' "%_COMPLETE", 
TRUNC(elapsed_seconds/60) || ':' || MOD(elapsed_seconds,60) elapsed, 
TRUNC(time_remaining/60) || ':' || MOD(time_remaining,60) remaining, 
CONTEXT,target,SOFAR, TOTALWORK 
FROM V$SESSION_LONGOPS 
WHERE OPNAME LIKE 'RMAN%' 
AND OPNAME NOT LIKE '%aggregate%' 
AND TOTALWORK != 0 
AND SOFAR <> TOTALWORK; 

##��XXX�û������ĳЩYYY��Ȩ��user,XXX\YYYҪ��д 
set serveroutput on 
--XXXҪ��д 
declare tablename varchar2(200);     
    begin 
    for x IN (SELECT * FROM dba_tables where owner='XXX' and table_name like '%YYY%') loop   
    tablename:=x.table_name; 
    dbms_output.put_line('GRANT SELECT ON XXX.'||tablename||' to user'); 
    EXECUTE IMMEDIATE 'GRANT SELECT ON XXX.'||tablename||' TO user';  
    end loop; 
end;

##����PGA�����ö��� 
select PGA_TARGET_FOR_ESTIMATE from (select  * from V$PGA_TARGET_ADVICE
 where ESTD_OVERALLOC_COUNT=0 order by 1) where rownum=1; 
 
##����SGA�����ö���
select SGA_SIZE from (select * from V$SGA_TARGET_ADVICE 
where ESTD_DB_TIME_FACTOR=1 order by 1) where rownum=1;

##ͳ�����б��������С(�������ֶΡ�LOB�ֶ�) 
SELECT 
   owner,table_name, TRUNC(sum(bytes)/1024/1024) Meg 
FROM 
(SELECT segment_name table_name, owner, bytes 
 FROM dba_segments 
 WHERE segment_type = 'TABLE' 
 UNION ALL 
SELECT s.segment_name table_name, pt.owner, s.bytes 
 FROM dba_segments s, dba_part_tables pt 
 WHERE s.segment_name = pt.table_name 
 AND   s.owner = pt.owner 
 AND   s.segment_type = 'TABLE PARTITION' 
 UNION ALL 
 SELECT i.table_name, i.owner, s.bytes 
 FROM dba_indexes i, dba_segments s 
 WHERE s.segment_name = i.index_name 
 AND   s.owner = i.owner 
 AND   s.segment_type = 'INDEX' 
 UNION ALL 
 SELECT pi.table_name, pi.owner, s.bytes 
 FROM dba_part_indexes pi, dba_segments s 
 WHERE s.segment_name = pi.index_name 
 AND   s.owner = pi.owner 
 AND   s.segment_type = 'INDEX PARTITION' 
 UNION ALL 
 SELECT l.table_name, l.owner, s.bytes 
 FROM dba_lobs l, dba_segments s 
 WHERE s.segment_name = l.segment_name 
 AND   s.owner = l.owner 
 AND   s.segment_type = 'LOBSEGMENT' 
 UNION ALL 
 SELECT l.table_name, l.owner, s.bytes 
 FROM dba_lobs l, dba_segments s 
 WHERE s.segment_name = l.index_name 
 AND   s.owner = l.owner 
 AND   s.segment_type = 'LOBINDEX' 
 union all 
 SELECT l.table_name, l.owner, s.bytes 
 FROM dba_lobs l, dba_segments s 
 WHERE s.segment_name = l.segment_name 
 AND   s.owner = l.owner 
 AND   s.segment_type = 'LOB PARTITION' 
) 
GROUP BY  owner,table_name 
HAVING SUM(bytes)/1024/1024 > 10   
ORDER BY SUM(bytes) desc ;

##RAC��ڵ�ɱ�Ự 
alter system kill session 'SID,serial#,@1'  --ɱ��1�ڵ�Ľ��� 
alter system kill session 'SID,serial#,@2'  --ɱ��2�ڵ�Ľ��� 

##DATAGUARD�����ӳٶ���ʱ��Ĳ�ѯ���� 
�� ��sqlplus>select value from v$dataguard_stats where name='apply lag' 
�� 
����sqlplus>select ceil((sysdate-next_time)*24*60) "M" from v$archived_log where applied='YES' AND SEQUENCE#=(SELECT MAX(SEQUENCE#)  FROM V$ARCHIVED_LOG WHERE applied='YES'); 

##DG��ADG������
��������ֽ�standby���ָ��Ǵ����ӳٵģ����������ɹ鵵��ȥ���ֶ˻ָ�����������ǾͿ��ܶ�ʧһ���鵵������������ָ�ģʽ��ֻ��״ֻ̬�ܶ�ѡһ��
��������ʵʱ��ѯ
�������˼���ֻ�������������ָ�
�����������adg

DGʱ��������ͬ����ʽ�����Redo Log������ʽ�������ݿ�ͬ�����ݿ졢������Դ�ͣ�������һ�������⡣
Oracle 11G��ǰ��Data Guard���������ݿ⣬������ֻ���ķ�ʽ�����ݣ�����ʱ��־������ͬ�����̾�ֹͣ�ˡ��������־������ͬ������ִ�й����У������ݿ�Ͳ��ܴ򿪡�Ҳ������־����д����״̬�ǻ����ų�ġ���Active Data Guard������Ҫ���������⡣
