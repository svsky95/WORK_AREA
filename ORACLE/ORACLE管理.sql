--数据库管理
--EM管理
emctl start/stop/status dbconsole

--数据字典
是落地的数据，存储在system表空间中
--动态性能视图
是不落地的，只有数据库open状态下，才可以查询

--参数文件位置
$ORACLE_HOME/dbs/init.ora  
$ORACLE_HOME/dbs/initorcl.ora   --文件中指定了spfile的位置 SPFILE='+DATA/orcl/spfileorcl.ora'

--数据库参数
SELECT t.NAME,t.VALUE,t.DISPLAY_VALUE,t.DESCRIPTION FROM v$parameter t;
show v$parameter
show parameter parallel/shared_pool
--修改数据库参数
scope=spfile --更改仅在参数文件中应用，重启后生效
scope=memory --更改仅在内存中应用，更改立即在内存中生效，重启后消失
scope=both --内存和文件均生效，重启后不丢失
exp:alter session set NLS_DATE_FORMAT='mon dd yyyy';

##数据库启动阶段描述
一、startup nomount 
实例启动状态 --指定控制文件、备份及恢复  --需要参数文件
搜索spfile<SID> or init<SID>.ora 分配SGA，启动后台进程  打开alert<SID>.log及跟踪文件 asmcmd>cd +DATA/ORCL/spfileorcl.ora
二、alter databse mount  
数据库装载                                --需要控制文件
数据库与之前的启动文件关联 
1、定位打开参数文件中的控制文件 --多路复用时需要所有文件都可用
2、通过控制文件来获取数据文件   --所有数据文件都是可用状态
3、联机重做日志文件             --每个日志组中至少两个成员分配在不同的磁盘组中，并且至少有一个可用
适用完整的数据库恢复  
三、alter databse open 
实例启动 
数据库打开 
打开联机重做日志文件   --数据文件及联机重做日志文件

--数据库启/停命令
startup
startup nomount
alter database mount
alter database open;
startup force;
--回退未提交的更改、数据库缓冲区及高速缓存写入数据文件、释放资源
shutdown immediate/abort/normal/transactional


=======数据库的组成=========
#######数据库实例#######
---内存++
----SGA+
-----buffer cache 高速缓冲区 用户存储所有用户查询及更改的数据,内存中的数据，被改后的数据叫做dirty buffer
-----share pool   共享池 用于存放解析语句的执行计划 共享池、数据字典缓存、sql查询及PL/SQL结果缓存
-----large pool   大型池 用于共享服务器的进程使用
-----redo log     日志缓冲区 用户存放DML的重做日志
-----java pool 
-----stream pool 
----PGA+
-----排序
-----合并
---后台进程++
----PMON 用户会话链接数据库、监视会话，若有异常立即回滚

----SMON 查找及验证所有的控制文件和联机重做日志文件来打开数据库

----DBWn 数据库写进程 可以分配多个 将buffer cache 中的数据写入数据文件,延迟写，批量定时写
1、没有可用的缓冲区干净块（1、脏块 未写入磁盘 2、正在被会话占用的块 ）
2、脏块太多
3、每3秒 对缓冲区做一次清理
4、check point 
5、关闭数据库

----LGWR 日志写进程只能有一个 顺序写入联机重做文件，速写，频繁写
触发条件：
1、commit
2、三分之一满
3、DBWn 脏块写入数据文件
----CKPT 检查点进程 指示DBWn将将脏块写入数据文件

----ARCn 归档日志进程 用户将联机重做日志文件变满后将数据写入归档日志文件中

----MMON 自我监视、自我调节进程  AWR ADDM 每小时1次

----LREG 监听注册数据库


##share pool
--库缓存 存储SQL语句的执行计划
--数据字典缓存 存储执行过SQL的表
--SQL查询和pl/sql函数结果缓存 函数查询缓存

#######数据库#######
---控制文件
数据库的记忆，用来维护数据库的一致性（联机重做日志文件、数据文件、归档日志文件的位置及数据库完成性信息） --采用放在不同磁盘组的多路复用
show parameter controlfile
---数据文件 
---联机重做日志文件 redo log （至少两组、每组至少两个成员） --采用放在不同磁盘组的多路复用
---归档日志文件 archive log 
---参数文件 （记录数据库相关参数及SGA中各个区域的分配大小）
show parameter spfile 
---口令文件
---跟踪文件及警报日志 
show parameter background_dump_dest    alert_orcl.log

######两do一点
redo
undo
checkpoint 

当执行commit时，返回commit compelete ，数据仍然在内存中，并不会马上出发，dbwr写数据到数据文件，而旧数据依然在数据文件中。
那么当主机掉电时，内存就会丢失，为了保证数据的持久性，引入redo log。
redo log中记录了，第几个数据文件，第几个块，第几行，第几列被修改成了什么值，变更向量，当前端返回commit compelete时，就意味着redo
log buffer已经写入到redo log file中。
undo 中记录了，第几个数据文件，第几个块，第几行，第几列原来的数值是什么。 

##ora-01555 snapshot too old 快照过旧
如果，一个查询在遇到查询开始后，需要访问undo段中的旧版数据，但是由于undo段中的数据已经被覆盖，就会导致一致性读失败。
也就是undo段的空间不够大或者undo_retention时间较短。
排查原因，查看占用undo段的SQL。
--解决方法：
1、合理增大undo表空间
2、undo_retention 默认900S。
如果运行时间最长的查询为1800秒，那么这个参数就应该设置为1800。随后，oracle就会设法将所有的undo撤销数据保留1800秒，从而不会出现快照过久的错误。
3、为了保证还原保留期生效，不会因为undo不足，而被覆盖
SQL> show parameter undo

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
undo_management                      string      AUTO
undo_retention                       integer     900
undo_tablespace                      string      UNDOTBS1

SQL> SELECT t.TABLESPACE_NAME,t.CONTENTS,t.RETENTION FROM dba_tablespaces t WHERE t.TABLESPACE_NAME like 'UNDOTBS1';
TABLESPACE_NAME                CONTENTS  RETENTION
------------------------------ --------- -----------
UNDOTBS1                       UNDO      GUARANTEE --生效

alter tablespace UNDOTBS1 RETENTION GUARANTEE;

#####关于redo log的覆盖
redo log三种状态：active、inactive、current
当三组redo log的状态是active active 和current三个日志组时，这时要发生日志组的切换，但是覆盖的前提是inactive状态，就是该日志组已经写入到
archive log。如果这时是active，那没有inactive，怎么办呢。
   会强制触发dbwr把一部分buffer中的脏块数据，写入到数据文件中，这时active的日志组，就可以覆盖了。
   也就是无论是否开启归档，都不会影响实例的一致性恢复。
redo log中包含了提交的事务也包含未提交的事务

####锁####
oracle行锁：DML操作，操作不同行的数据（无论这一行有没有主键），相互之间不影响。操作相同行的数据，会出现等待。
oracle表锁：DDL语句，增加索引（不加online）。
####关于archive log   
##非归档模式
备份：冷备（一致性备份），不能热备
还原：用于实例崩溃，数据文件都是完好的，只有restore的方式,因为没有归档日志，所以也就没有recover。
##归档模式
备份：热备（非一致性备份）
还原：用于数据文件损坏，可以还原到最后一次commit的状态。
完全恢复：数据库备份+归档日志+online redo log 
##备份及恢复
restore 还原数据文件，就是拷贝dbf文件到原路径。
recover 回放备份时间点之后的归档日志archive log，当前active及current的redo log 

##scan_ip日志
su - grid
lsnrctl status listener_scan1

======用户及权限管理=======
##用户创建
create/alter user [user_name] identified by [password]
default tablespace [tablespace_name] temporary tablespace [tmp_tablespace]
profile [profile_name]
password expire --用户立即修改密码
account unlock
quota  unlimited on users; --创建配额

--删除用户 <连同用户拥有的对象>
drop user [user_name] <cascade> ;

--查看为哪些用户授予了sysdba、sysoper权限
SELECT * FROM V$pwfile_Users;

--权限管理（系统权限和对象权限）
--用户不限制表空间的写入权限
grant unlimited tablespace to HX_FP  ;
--系统权限 dba_sys_privs
create session --允许连接数据库
alter database --允许更改数据库文件
alter system   --允许修改系统
grant privilege to [user_name];
--对象权限 dba_tab_privs
insert/update/delete/select/alter/execute
create tablespace/alter tablespace/drop tablespace --创建修改删除表空间
grant any object privilege --授予他人任何权限
create any table --创建任何表
insert/update/delete/select any table --增删改查任何表
GRANT SELECT  ON sjyy.cxtj_jsydfpcx_sy   TO J2_CX;
SELECT 'grant select on ' ||t.owner||'.'||t.table_name || ' to wb_cx;' FROM dba_tables t WHERE t.OWNER='HX_QX';
--系统权限 系统权限传递不会撤销
grant privilege to [user_name] <with admin option>;
revoke privilege from [user_name];
revoke dba from db_smbs_sjyy;
--对象权限 对象权限的撤销将会级联
grant privilege on hr.scott to [user_name] <with grant option>;
revoke privilege on schema.table from [user_name];

--系统默认自带用户
SELECT * FROM DBA_USERS_WITH_DEFPWD;

--创建角色
create role [role_name] <with admin option/with grant option>;

--角色赋权 dba_role_privs 
grant privilege to [role_name];
grant privilege on hr.scott to [role_name] <with grant option>; 

--角色赋权用户
grant [role_name] to [user_name];


--预定义角色权限
connect   --仅有create session 
resource  --创建数据库对象和过程
dba
public   --此角色在每个用户中多存在，若把一个表授予给public,则所有的用户都可以访问这个表<grant select on hr.emp to public>
select_catalog_role
schema_admin

##查询权限汇总
SELECT * FROM dba_role_privs t WHERE t.granted_role='YS_ROLE';
SELECT t.grantee,t.owner,t.table_name,t.privilege,t.grantable FROM dba_tab_privs t WHERE t.grantee='YS_ROLE'
union all
SELECT b.grantee,to_char(null),to_char(null),b.privilege,b.admin_option FROM dba_sys_privs b WHERE b.grantee='YS_ROLE';
--批量查询角色及权限
SELECT * FROM dba_role_privs t WHERE t.grantee = upper('&role_name') or t.granted_role=upper('&role_name');
SELECT t.grantee, t.owner, t.table_name, t.privilege, t.grantable
  FROM dba_tab_privs t
 WHERE t.grantee =upper('&role_name')
union all
SELECT b.grantee, to_char(null), to_char(null), b.privilege, b.admin_option
  FROM dba_sys_privs b
 WHERE b.grantee =upper('&role_name');
 
##DDL语法
增加字段语法：alter table tablename add (column datatype [default value][null/not null],….);

说明：alter table 表名 add (字段名 字段类型 默认值 是否为空);

   例：alter table sf_users add (HeadPIC blob);

   例：alter table sf_users add (userName varchar2(30) default '空' not null);

修改字段的语法：alter table tablename modify (column datatype [default value][null/not null],….); 

说明：alter table 表名 modify (字段名 字段类型 默认值 是否为空);

   例：alter table sf_InvoiceApply modify (BILLCODE number(4));

删除字段的语法：alter table tablename drop (column);

说明：alter table 表名 drop column 字段名;

   例：alter table sf_users drop column HeadPIC;

字段的重命名：

说明：alter table 表名 rename  column  列名 to 新列名   （其中：column是关键字）

 例：alter table sf_InvoiceApply rename column PIC to NEWPIC;

表的重命名：

说明：alter table 表名 rename to  新表名

   例：alter table sf_InvoiceApply rename to  sf_New_InvoiceApply;
   
--sqlplus指定用户
alter session set current_schema=hr;
   
##查询库中的所有GV$视图
select * from v$fixed_table;

##查询GV$视图的创建语句
select * from v$fixed_view_definition;

##管理配置文件
--查询当前给每个用户分配的配置文件
SELECT t.username,t.profile FROM dba_users t ;

--查看配置文件内容
SELECT * FROM dba_profiles t WHERE t.profile='DEFAULT'

--配置文件创建脚本    
@$ORACLE_HOME/rdbms/admin/utlpwdmg.sql

--redo log 切换
ALTER SYSTEM SWITCH LOGFILE        对单实例数据库或RAC中的当前实例执行日志切换，

ALTER SYSTEM ARCHIVE LOG CURRENT   会对数据库中的所有实例执行日志切换

--rman控制文件：
RMAN> backup as copy current controlfile  format '/u01/oracle/bak/control01.ctl';
--rman参数文件：
RMAN> backup as copy spfile format '/u01/oracle/bak/spfileorcl.ora';

--控制文件跟踪
SQL> alter database backup controlfile to trace;

Database altered.

SQL> select value from v$diag_info  where name='Default Trace File';

VALUE
--------------------------------------------------------------------------------
/u01/app/oracle/diag/rdbms/racdb/racdb/trace/racdb_ora_23305.trc

--执行检查点
-当前实例
SQL>alter system checkpoint local;
-rac全局
SQL>alter system checkpoint global;


##杀掉会话
1、单实例
alter system kill session '25,889' [immediate];
2、RAC跨节点杀会话 
alter system kill session 'SID,serial#,@1'  --杀掉1节点的进程 
alter system kill session 'SID,serial#,@2'  --杀掉2节点的进程 

##动态性能统计
--系统范围
SELECT * FROM v$sysstat;
SELECT * FROM v$system_event;
--特定会话
SELECT * FROM v$session;
SELECT * FROM v$session_event;
--特定于服务
SELECT * FROM v$service_stats;
SELECT * FROM v$service_event;

--故障优化与排除
SELECT * FROM v$database;
SELECT * FROM v$instance;
SELECT * FROM v$parameter;
SELECT * FROM v$spparameter;
SELECT * FROM v$process;
SELECT * FROM v$bgprocess;
SELECT * FROM v$px_process_sysstat;
SELECT * FROM v$system_event;

--磁盘
SELECT * FROM v$datafile;
SELECT * FROM v$filestat;
SELECT * FROM v$log;
SELECT * FROM v$log_history;
SELECT * FROM v$dbfile;
SELECT * FROM v$tempfile;
SELECT * FROM v$tempseg_usage;
SELECT * FROM v$segment_statistics; 

--内存
SELECT * FROM v$buffer_pool_statistics;
SELECT * FROM v$librarycache;
SELECT * FROM v$sgainfo;
SELECT * FROM v$pgastat;

--争用
SELECT * FROM v$lock;
SELECT * FROM v$undostat;
SELECT * FROM v$waitstat;
SELECT * FROM v$latch;

--参数视图(动态参数与静态参数)
SELECT t."INST_ID",t."NAME",t."DISPLAY_VALUE",t."ISSES_MODIFIABLE",t."ISSYS_MODIFIABLE" FROM gv$parameter t where t."NAME" like '%&para_name%' order by t."NAME",t."INST_ID";
-DISPLAY_VALUE     格式化后大小
-ISSES_MODIFIABLE  会话级别是否可以改变
-ISSYS_MODIFIABLE  系统级别： IMMEDIATE（立即生效，不重启实例）  DEFERRED（延期生效） FALSE（重启实例生效）

在rac环境中，修改参数时，ISSYS_MODIFIABLE=IMMEDIATE，但是报：ORA-32018: parameter cannot be modified in memory on another instance
可以在两个节点上分别执行：
alter system set sga_target=3G scope=both sid='oradb1';
alter system set sga_target=3G scope=both sid='oradb2';

--oracle默认自建的用户
SELECT * FROM DBA_USERS_WITH_DEFPWD;

--无效的PL/SQL对象查找：
SELECT * FROM dba_objects t WHERE t.status='INVAILD'

--建索引语句
create index idx_name on table_name(cloumn_name1,cloumn_name2) tablespace tablespace_name nologging online <local> parallel 4;
alter idex_name logging;

oralce服务器由实例和数据库组成。
--实例：RAM和CPU中的内存结构及进程，用户可以启停实例；
--数据库：磁盘上的数据文件
--控制文件： 数据库的记忆，用来维护数据库的一致性，连接实例与数据库的重要参数文件，其中的指针指向数据文件及联机重做日志文件。

--创建UNDO表空间
create undo tablespace undo_tbs2 datafile '+DATA/orcl/datafile/undo_tbs2'  size 10M;
create  tablespace undo_tbs2 datafile '+DATA/orcl/datafile/undo_tbs2'  size 10M;


alter database datafile 3 autoextend off; --取dba_data_files.file_id 

--调整表空间大小
alter database datafile 7 resize 100M;

--删除表空间及数据文件
drop tablespace TEST_01 including contents and datafiles
--给表空间添加数据文件
ALTER TABLESPACE TEST_01 ADD DATAFILE '+DATA/orcl/datafile/test_02' SIZE 100M;

--设置新的UNDO表空间
alter system set undo_tablespace=undo_tbs2 scope=memory;

ALTER DATABASE DATAFILE '+DATA/orcl/datafile/undo_tbs2'  ONLINE /OFFLINE FOR DROP;

--闪回表查询   <一定要带上删除时的过滤条件>

alter session set nls_date_format='dd-mm-yy hh24:mi:ss';

select sysdate from  dual;--2017/1/25 0:04:42 

--查询10分钟前的数据
select * from t1 as of timestamp(systimestamp-10/14440) where t1.object_id=1002;

--在v$undostat 中指定时间的数据 SELECT * FROM v$undostat;
select * from t1 as of timestamp to_timestamp ('24-01-17 23:55:12','dd-mm-yy hh24:mi:ss') where t1.object_id=1000;

--查看数据库实例
SELECT * FROM v$instance;  parallel--NO 单实例 YES RAC

--数据库信息查看
SELECT * FROM v$database;


--流配置查看
SELECT * FROM dba_streams_administrator;

--识别数据库的物理结构
SELECT * FROM v$datafile;
SELECT * FROM dba_data_files;
--临时表空间
SELECT * FROM v$tempfile;
--日志文件
SELECT * FROM v$logfile;
--控制文件
SELECT * FROM v$controlfile;

--SGA 各区域内存分配
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

--PGA 内存分配
SELECT name,CASE WHEN t."UNIT"= 'bytes' THEN
                round(t."VALUE"/1024/1024/1024,2)
                when t."UNIT" is null then t."VALUE"
             END as size_G   from v$pgastat t;

--后台进程
SELECT * FROM v$bgprocess t WHERE t.PADDR<>'00';

--查看正在运行的进程及数量
SELECT * FROM v$session t order by t.PROGRAM;
SELECT t.PROGRAM,t.ADDR FROM v$process t  order by t.PROGRAM;

--查找表空间所属的数据文件
SELECT * FROM dba_extents t WHERE t.owner='CZ' and t.segment_name='T66';--file_id
SELECT * FROM dba_data_files t WHERE t.FILE_ID=4;

SELECT * FROM v$spparameter;
SELECT * FROM v$parameter t WHERE t.NAME like '%spfile%';

--查看系统的动态视图字典表
SELECT * FROM v$fixed_table;
SELECT * FROM v$fixed_view_definition;

--字典表统计信息收集
exec dbms_stats.gather_fixed_objects_stats;
exec dbms_stats.gather_dictionary_stats;
execute dbms_stats.gather_schema_stats('SYS');


--oracle 代码的查错
su - oracle
oerr ora 15046
--查看表空间对应数据数据文件的位置 
SELECT t.NAME tablespace_name,d.NAME,d.BYTES/1024/1024/1024 size_G FROM v$tablespace t ,v$datafile d WHERE t.TS#=d.TS# order by t.NAME;
--查看联机重做日志文件的成员及位置
SELECT m.GROUP#,m.MEMBER,g.ARCHIVED,g.STATUS,m.TYPE,m.IS_RECOVERY_DEST_FILE,g.BYTES/1024/1024 size_M FROM v$log g,v$logfile m WHERE g.GROUP#=m.GROUP# order by m.GROUP#,m.MEMBER

--插件监听及TNS
图形界面： netca、netmgr
--更改监听
alter system set local_listener=ORCL12<TNSNAME.ORA中的别名> scope=both;
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
  
##rowid说明
rowid 数据行的身份证号，代表一行的唯一身份，共有18位，采用6/3/6/3的分割方式。
SELECT  t.rowid,t.* FROM hx_dj.dj_nsrxx t;
AACGwi     ACj     AAAAeE   AAA
object#   file#    block#   row#
表空间    数据文件 

  
--使用omf(oracle文件系统管理) 
自动创建大小为100M 可自动扩展 最大32G的表空间
show parameter db_create
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_create_file_dest                  string      --存放数据文件的位置
db_create_online_log_dest_1          string      --存放redo log 联机重做日志
db_create_online_log_dest_2          string
db_create_online_log_dest_3          string
db_create_online_log_dest_4          string
db_create_online_log_dest_5          string

--指定存放数据文件的路径
alter system set db_create_file_dest='/oracle/ora_data/jsdb' scope=both;
--指定存放redolog的路径 
alter system set db_create_online_log_dest_1='+ORACL_DATA';
alter system set db_create_online_log_dest_2='+FRA_DATA';
--查看成员
SELECT v."THREAD#",le."GROUP#",v."STATUS",v."ARCHIVED","MEMBER",v."BYTES"/1024/1024 SIZE_M FROM v$logfile le,v$log v WHERE le."GROUP#"=v."GROUP#" ORDER BY 1,2;
--添加redolog
ALTER DATABASE  
    ADD LOGFILE THREAD 1 GROUP 5 SIZE 50M;  --给节点1添加组5，大小为50M的redolog
--删除redolog
    ALTER DATABASE DROP LOGFILE  GROUP 5; 
--添加成员
ALTER DATABASE   
   ADD LOGFILE MEMBER '+ORACL_DATA'
   TO GROUP 6;
--删除成员
ALTER DATABASE   
   DROP LOGFILE MEMBER '+ORACL_DATA/crsdb/onlinelog/group_6.285.968922535'

--OMF验证
create tablespace OMF;
alter tablespace OMF add datafile;

##创建DBLINK public
create public database link orcl12connect to cz identified by cz using 'ORCL12';   //ORCL12要在tnsname.ora中有配置。

--rac中：如果要针对固定的用户创建并且仅限这个用户使用，那么就必须登录这个用户，再创建。
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
--创建只能给创建人使用的dblink
create public database link orcl121
connect to cz identified by cz using 'ORCL12';
--删除DBLINK
DROP [PUBLIC] DATABASE LINK zrhs_link
--查询DBLINK 
SELECT * FROM dba_db_links;
--修改DBLINK密码
ALTER  PUBLIC database link BIGDATA_NFZCDB94 connect to CZ identified by "CZ_1QAZ";
--不限制登陆失败次数
alter profile default limit FAILED_LOGIN_ATTEMPTS UNLIMITED;
--同义词可以在不同的库之间相互引用。
同库之间，也可引用同义词的同义词
--创建同义词
CREATE OR REPLACE SYNONYM "SJYY"."SB_ZZS_YBNSR_FB_JDCXSFPQD" FOR "NF_FDM_H"."SB_ZZS_YBNSR_FB_JDCXSFPQD";
CREATE OR REPLACE SYNONYM sjyy.dzdz_fpxx_zzsfp FOR dzdz.dzdz_fpxx_zzsfp@sjyydb_dzdz;
--查看同义词
SELECT * FROM dba_synonyms;
--批量创建同义词
SELECT 'CREATE OR REPLACE SYNONYM ' ||aa.owner||'.'||aa.synonym_name||' FOR ' ||aa.table_owner||'.'||aa.table_name||'@SJYY_12_94;'
FROM  (SELECT * FROM dba_synonyms t WHERE t.owner='SJYY')aa;

SELECT 'CREATE SYNONYM ' ||aa.owner||'.'||aa.table_name||' FOR ' ||aa.owner||'.'||aa.table_name||'@SJYY_12_94;'
FROM  (SELECT * FROM dba_tables t WHERE t.TABLESPACE_NAME NOT IN ('SYSTEM','SYSAUX') AND t.OWNER<>'SJYY')aa;

SELECT 'CREATE or replace SYNONYM SJYY.'||aa.table_name||' FOR ' ||aa.owner||'.'||aa.table_name||'@sjyyys96_bigdata11;'
FROM  (SELECT t.OWNER,t.TABLE_NAME FROM dba_tables t WHERE t.OWNER='DZDZ')aa;

SELECT 'CREATE or replace SYNONYM sx_mdm_db.'||aa.table_name||' FOR ' ||aa.owner||'.'||aa.table_name||';'
FROM  (SELECT t.OWNER,t.TABLE_NAME FROM dba_tables t WHERE t.OWNER='SX_ADM_MDM' AND t.TABLE_NAME LIKE 'M%')aa;

--删除同义词
DROP [PUBLIC] SYNONYM [schema.]sysnonym_name
--批量删除同义词
SELECT 'drop SYNONYM ' ||aa.owner||'.'||aa.synonym_name||'; ' FROM  dba_synonyms aa WHERE aa.owner LIKE 'HX%' OR aa.OWNER LIKE  'GS%';

--批量获取注释
SELECT 'COMMENT ON COLUMN '||t.owner||'.'||t.table_name||'.'||t.column_name|| ' IS '''||t.comments||''';' FROM dba_col_comments t WHERE t.owner='TSSH' AND t.comments IS NOT NULL;

--批量建表
SELECT 'CREATE TABLE '||t.owner||'.'||t.table_name|| ' as select * from '||t.owner||'.'||t.table_name||'@SJYYDB_CKTS;' FROM all_tables@sjyydb_ckts t WHERE t.owner='TSSH';


--表空间管理
PCTFREE--保留块中10%的空间，当没有可用的空间时就会启用行移动到空间充足的块。
行移动--UPDATE产生；
行链接--由于insert导致当前的块空间不足，比如插入20K的数据，而目前只有8K，就必须再分配3个块才可以。

--启动行移动及段收缩来降低高水位线，但是会使索引过期。
alter table t1 enable row movement;  --启动行移动
alter table t1 shrink space compact cascade;--开启段收缩连同索引

--管理可恢复的空间分配
当由于空间不足导致加载大量的数据失败时，可在空间不足的情况下，挂起会话，当问题解决后可继续，并且可以设置超时时间。
alter session enable resumable [TIMEOUT <seconds>];
alter session enable resumable timeout 10;

--收集直方图统计信息
select 'execute dbms_stats.gather_table_stats(ownname =>''' || a.owner ||
          ''',tabname =>''' || a.table_name ||
          ''',estimate_percent =>5,degree=>7,cascade =>true,method_opt=>''for all columns size auto'');'
       as stats_sql
  from  dba_tables a
 where a.owner = upper('&owner')
   and a.table_name = upper('&tabname');
       
--for all columns size auto     自动收集列直方图统计信息
--for all columns size skewonly 自动收集列数据倾斜较大的统计信息
--for all columns size repeat   收集之前收集过的直方图统计信息
--for all columns size 1        删除列的直方图统计信息
--for columns size auto a b     对表的列a列b自动收集直方图统计信息


--no_invaildate=>flase      刷新执行计划
--no_invaildate=>true       不刷新执行计划

--查询直方图信息
select owner, table_name, column_name, histogram from dba_tab_col_statistics where table_name = 'T_SKEW1' ;

频率直方图（Frequency,Freq）：频率直方图只适用于目标列的distinct值小于或者等于254的情形
高度平衡直方图（Height Balanced,HtBal）：当distinct值大于254，那么只能使用高度平衡直方图

直方图是一种列的特殊的统计信息，主要用来描述列上的数据分布情况。当数据分布严重倾斜时，直方图可以用小的提升cardinality评估的准确度。构造直方图最主要的原因就是帮助优化器在表中数据验证倾斜是做出最好的选择
。例如，表中的某个列上数据占据了整个表的80%（数据分布倾斜），相关的索引就可能无法帮助减少满足查询所需的I/O数量。创建直方图可以让基于成本的优化器知道何时使用索引才最合适。

直方图实际存储在数据字典sys.histgrm$中，可以通过数据字典dba_tab_historgrams,dba_part_histograms和dba_subpart_histograms来分别查看表，分区表的分区和分区表的子分区的直方图信息。

--estimate_percent 采样率
通过设置采样率，来去评估表的统计信息，为了更精准的统计信息，ORACLE使用 
estimate_percent =>dbms_stats.auto_sample_size 

##expdp/impdp   参考：http://www.linuxidc.com/Linux/2013-07/87891p3.htm http://www.linuxidc.com/Linux/2013-06/86383.htm
Data Pump有以下三个部分组成：
客户端工具：expdp/impdp
Data Pump API (即DBMS_DATAPUMP)
Metadata API（即DMBS_METADATA)
启动后在v$process中包含两个进程 DM00  DW00 
导出和导入必须有这两个角色
grant EXP_FULL_DATABASE to HR;        --导出权限
grant IMP_FULL_DATABASE to HR;          --导入权限

---查看dump输出目录
SELECT * FROM dba_directories t WHERE t.directory_name='DATA_PUMP_DIR';--默认路径
也可以自行创建路径
mkdir -p /data/oracle_backup
chown oracle:oinstall /data/oracle_backup
CREATE DIRECTORY dpump_dir AS '/data/oracle_backup';
GRANT READ, WRITE ON DIRECTORY dpump_dir TO hr; --hr用户对目录有操作新的权限
--expdp 5种模式
--导出全库/schema(用户)/表/表空间
expdp user_name<具有导出权限的登录用户> FULL=y/SCHEMAS=hr,sh,oe/TABLES=hr.employees,SH.jobs/TABLESPACES=tbs_4, tbs_5, tbs_6 DUMPFILE=expdat%u.dmp DIRECTORY=dpump_dir LOGFILE=export.log 
CONTENT=data_only  --包含内容
CLUSTER=N          --启用群集
PARALLEL=8         --并行度
compression=all    --压缩<文件大小减少至1/7>  四个选项，分别是ALL、DATA_ONLY、METADATA_ONLY和NONE
FILESIZE=2G        --单个文件大小
ENCRYPTION=data_only  --加密内容  --可选
ENCRYPTION_PASSWORD=password --加密密码 --可选
QUERY=hr.employees:"WHERE department_id > 10 AND salary > 10000"  --添加导出时的过滤条件--仅在导出表时才用此参数
SAMPLE=70      --添加导出时数据的百分比--仅在导出表时才用此参数 
table_exists_action  skip 是如果已存在表，则跳过并处理下一个对象；append是为表增加数据；truncate是截断表，然后为其增加新数据；replace是删除已存在表，重新建表并追加数据
--数据不落地直接灌入
impdp user_cz/user_cz directory=DUMP_USER_CZ  logfile=DUMP_USER_CZ.log TABLES=LS85_PARA.CY_SERV_T REMAP_schema=LS85_PARA:user_cz  network_link=YS113_YS179_CZ query=LS85_PARA.CY_SERV_T:\"where serv_id=10841437\" table_exists_action=replace EXCLUDE=INDEX,STATISTICS parallel 8;                                    " 

--数据不落地直接灌入 参数文件
impdp user_cz/user_cz directory=DUMP_USER_CZ  logfile=DUMP_USER_CZ.log parfile=parfile.txt REMAP_schema=LS85_PARA:user_cz  network_link=YS113_YS179_CZ table_exists_action=replace; 

parfile.txt(parfile可以随意命名)
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





元数据过滤
元数据解析采用EXCLUDE，INCLUDE参数，注意：它们俩互斥。
EXCLUDE<不包含>例子：
expdp FULL=YES DUMPFILE=expfull.dmp EXCLUDE=SCHEMA:"='HR'"
> expdp hr DIRECTORY=dpump_dir1 DUMPFILE=hr_exclude.dmp EXCLUDE=VIEW,METADATA,
PACKAGE, FUNCTION,INDEX,STATISTICS 
--不包含LOG开头的表
exclude=table:"like 'LOG%'"

INCLUDE<不包含>例子：
SCHEMAS=HR
DUMPFILE=expinclude.dmp
DIRECTORY=dpumexpincludep_dir1
LOGFILE=.log
INCLUDE=TABLE:"IN ('EMPLOYEES', 'DEPARTMENTS')"
INCLUDE=PROCEDURE
INCLUDE=INDEX:"LIKE 'EMP%'"


--impdp与expdp相似

Schema模式
设置Schema参数，语法如下
SCHEMAS=schema_name [,...]

下面这个例子导入hr数据到hr schema下

> impdp hr SCHEMAS=hr DIRECTORY=dpump_dir1 LOGFILE=schemas.log
DUMPFILE=expdat.dmp

Table模式


设置Table参数，语法如下：
TABLES=[schema_name.]table_name[:partition_name]

如果没有指定schema_name，默认表示导入当前用户的schema下，如：
> impdp hr DIRECTORY=dpump_dir1 DUMPFILE=expfull.dmp TABLES=employees,jobs

也可以导入指定的分区：
> impdp hr DIRECTORY=dpump_dir1 DUMPFILE=expdat.dmp 
TABLES=sh.sales:sales_Q1_2012,sh.sales:sales_Q2_2012

Tablespace模式
设置Tablespace参数，其语法如下：
TABLESPACES=tablespace_name [, ...]

下面是一个例子，要注意的是：这些要导入的tablespace必须已经存在，否则会导入失败。
> impdp hr DIRECTORY=dpump_dir1 DUMPFILE=expfull.dmp TABLESPACES=tbs_1,tbs_2,tbs_3,tbs_4

Transpotable Tablespace模式
设置Transpotable_tablespace参数，其语法定义如下：
TRANSPORT_TABLESPACES=tablespace_name [, ...]

REMAP_SCHEMA=source_schema:target_schema这个参数很常用，可以让你导入到不同的schema中，如果target_schema不存在，导入时会自动创建，下面是一个例子：
> expdp system SCHEMAS=hr DIRECTORY=dpump_dir1 DUMPFILE=hr.dmp

> impdp system DIRECTORY=dpump_dir1 DUMPFILE=hr.dmp REMAP_SCHEMA=hr:scott

REMAP_TABLE=[schema.]old_tablename[.partition]:new_tablename可以在导入时重命名表或分区，下面是一个例子：
> impdp hr DIRECTORY=dpump_dir1 DUMPFILE=expschema.dmp
TABLES=hr.employees REMAP_TABLE=hr.employees:emps

REMAP_TABLESPACE=source_tablespace:target_tablespace在导入时修改表空间名，下面是一个例子：
> impdp hr REMAP_TABLESPACE=tbs_1:tbs_6 DIRECTORY=dpump_dir1
  DUMPFILE=employees.dmp

SELECT * FROM v$database ;--PLATFORM_NAME
SELECT * FROM v$transportable_platform;  --字节序列格式转换
--在源数据库上用rman登录目标数据库
convert datafile '/u01/app/oracle/admin/orcl/dpdump/hrtab.dump' to platform 'AIX-Based Systems (64-bit)' format '/u01/app/oracle/admin/orcl/dpdump/hrtab_aix.dump';

SELECT * FROM dba_rsrc_consumer_groups;
SELECT * FROM dba_users;
SELECT * FROM dba_rsrc_plan_directives;

--查询对象的数据变化量
衡量统计信息失效的标准就是数据变化量的10%
select * from dba_tab_modifications;
当有数据变化时，不会立即显示出来，需要手动刷新。
begin
	dbms_stats.flush_database_monitoring_info();
end;

==========创建作业===========
--查看调度作业
SELECT * FROM dba_scheduler_jobs;
--查看计划任务进程
SELECT * FROM v$process t WHERE t.PROGRAM like '%J%';
--调度程序 <最基本的对象：作业>
--show parameter job  --若为0 则不会运行调度程序
job_queue_processes                  integer     1000 
dbms_scheduler.create_job;    --作业
dbms_scheduler.create_program; --程序
dbms_scheduler.create_schedule; --时间表

--job_type                                                  job_action 
PLSQL_BLOCK：匿名PL/SQL 块                        'insert into times values (sysdate)'

STORED_PROCEDURE：命名的PL/SQL、Java 或外部过程   'begin HR.cleanup_events; end; '

EXECUTABLE：可以从操作系统(OS) 命令行执行的命令    '/home/usr/dba/rman/nightly_incr.sh'


exec dbms_scheduler.create_job(job_name => 'savedate', job_type => 'plsql_block',job_action =>'insert into times values (sysdate);',start_date =>sysdate,repeat_interval => 'freq=minutely;interval=1',enabled => true,auto_drop => false);

exec dbms_scheduler.create_job(job_name => 'savedate_por', job_type => 'STORED_PROCEDURE',job_action =>'CZ.TEST01',start_date =>sysdate,repeat_interval => 'freq=minutely;interval=1',enabled => true,auto_drop => false);

--查询作业
SELECT * FROM dba_scheduler_jobs t WHERE t.job_name=upper('savedate');

--查询作业的工作日志记录
SELECT * FROM dba_scheduler_job_log t WHERE t.JOB_NAME=upper('savedate');

--禁用/启用作业
exec dbms_scheduler.disable('savedate_p');
exec dbms_scheduler.enable('savedate');

--删除作业
exec dbms_scheduler.drop_job('savedate_por');

--物化视图JOB
select job,log_user,to_char(next_date,'DD-MON-YYYY HH24:MI:SS') next_date, interval,what from dba_jobs;
查看正在运行的作业
select * from dba_jobs_running;

物化视图的刷新时间可直接通过SQl脚本修改
alter materialized view ecif.V_NSRCX_ZJLSDJ                       refresh force on demand     start with to_date('31-10-2017 03:00:00', 'dd-mm-yyyy hh24:mi:ss') next to_date(concat(to_char( sysdate+1,'dd-mm-yyyy'),'03:00:00'),'dd-mm-yyyy hh24:mi:ss'); 

=======数据库的备份与恢复===========
--联机重做日志，至少两个日志组，每个日志组至少两个成员。
SELECT * FROM v$log;  --current 表示当前在使用
SELECT * FROM v$logfile;
--切换联机重做日志
alter system switch logfile;
--添加日志组
alter database add logfile group 4 '+FRA/orcl/onlinelog/group_4relog01' size 50M;
--添加日志组成员 完成后执行几次alter system switch logfile 就可生效
alter database add logfile member '+FRA/orcl/onlinelog/group_4relog02' to group 4;

--查看当前的控制文件
SELECT * FROM  v$controlfile;
--查看当前系统使用的控制文件副本
SELECT * FROM v$parameter t WHERE t.NAME='control_files';

--确定数据库的归档模式
SELECT archiver FROM v$instance;
SELECT log_mode FROM v$database;

--配置快速恢复区
--包括联机日志文件及多路复用副本、控制文件及多路复用副本、归档日志文件、rman备份文件等。
SELECT * FROM v$parameter t WHERE t.NAME like 'db_recovery%';
db_recovery_file_dest
db_recovery_file_dest_size

-快速恢复区使用率
SELECT substr(name, 1, 30) name, space_limit/1024/1024/1024 AS quota_G,
space_used/1024/1024/1024 AS used_G,
space_reclaimable/1024/1024/1024 AS reclaimable,
number_of_files AS files
FROM v$recovery_file_dest ;

-快速恢复区使用明细
select * from V$RECOVERY_AREA_USAGE;


-释放快速恢复区(删除归档)
RMAN> crosscheck archivelog all;
RMAN> delete noprompt expired archivelog all;
RMAN> DELETE noprompt ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE';
-删除2小时前的归档日志
delete noprompt archivelog all completed before 'sysdate -2/24'
-删除半小时前的归档日志（边导入边删除一般使用这条）
delete noprompt archivelog all completed before 'sysdate -0.5/24'
-查看产生的归档
select sum(blocks*block_size)/1024/1024/1024 from v$archive_log where dest_id=1 and completion_time>to_date('2021-08-01 15:30:00','yyyy-mm-dd hh24:mi:ss');
select sum(blocks*block_size)/1024/1024/1024 from v$archive_log where dest_id=1 and first_time>to_date('2021-08-01 15:30:00','yyyy-mm-dd hh24:mi:ss');
--查看redo、archivelog 序号
select name,thread#,sequence#,first_time,next_time,first_change#,next_change# from v$archived_log where sequence#=241 and thread#=1;
select sequence#,status,group# from v$log;

--配置和使用
SELECT * FROM v$recovery_file_dest;
SELECT * FROM v$recovery_area_usage;

--切换archivelog模式
--完成备份是切换为archivelog模式的一个必须的步骤。
--查看归档日志文件
SELECT * FROM v$archived_log;
--归档日志、快速恢复区的指定
SELECT * FROM v$archive_dest;

======rman备份=======
--查看归档模式
archive log list;
--非归档模式下的整库备份
shutdown immedaite;
rman target /
RMAN> startup mount;
RMAN> backup database;

--归档模式备份
backup datafile 1,2;
--启用两个通道d1,d2,进行数据文件及归档日志文件的备份 SBT--磁带
rman>run {allocate channel d1 type disk; allocate channel d2 type disk/SBT; backup as compressed backupset database;backup as compressed backupset archivelog all <delete all input>;}

--查看数据文件备份
SELECT * FROM v$backup_files;
SELECT * FROM v$backup_piece;
SELECT * FROM v$backup_piece_details;
SELECT * FROM v$backup_datafile;
SELECT * FROM v$backup_datafile_details;
SELECT * FROM v$backup_datafile_summary;

--查看控制文件备份
SELECT * FROM v$backup_controlfile_details;
SELECT * FROM v$backup_controlfile_summary;

--查看归档日志文件备份
SELECT * FROM v$backup_archivelog_details;
SELECT * FROM v$backup_archivelog_summary;

--创建恢复目录
sql>create tablespace rman_cata datafile '+DATA/orcl/datafile/rman_cata.dbf' size 150M;
create user rman identified by rman;
grant recovery_catalog_owner,connect,resource to rman; 

rman target / catalog rman@orcl --远程或本地数据库
create catalog tablespace rman_cata;
register database;
resync catalog;

--常见全局或本地脚本
create global script backup_src {backup database plus archivelog;}
--显示脚本名字
list script names;
--显示脚本内容
print global script backup_src;
--运行脚本
 run {execute script backup_src};
--删除脚本
delete script backup_src;

--增量备份
--0级 全备
backup incremental level 0 tablespace users;
--1级 增量备份（差异备份）
backup incremental level 1 tablespace users;
--1级 累积备份
backup incremental level 1 cumulative tablespace users;

--创建归档备份
创建固定时间的归档备份集
backup as compressed backupset database format '+FRA/orcl/archback/%U' tag save_1_year keep until time 'sysdate+365'; --目录必须在ASM对应的路径中存在
backup as compressed backupset database format '+FRA/orcl/archback/%U' tag save_forever keep  forever;     --永久保存

--配置多段备份
backup tablespace users section size 30M/10G;  --指定分段的大小

--验证库文件是最新的
--检查注册文件中备份集及归档日志文件，若存在则标记为expired,并删除。
run {crosscheck backupset; crosscheck archivelog all;delete expired backupset;delete expired archivelog all;}

----完整恢复
1、不重要数据文件恢复<丢失的文件不是system或undo的一部分>
--表空间
rman>sql "alter tablespace users offline immediate";
RMAN> restore tablespace users;
RMAN> recover tablespace users;
RMAN> sql "alter tablespace users online ";
--数据文件
alter database datafile 6 offline;
restore datafile 6;
recover datafile 6;
alter database datafile 6 online;

2、重要数据文件恢复<system或undo损坏>
关闭数据库：shutdown abort;
挂载数据库：startup mount;
restore tablespace/datafile system/1 ;
recover tablespace/datafile system/1 ;
alter database open;

----不完整恢复
查看当前的SCN
SELECT t.CURRENT_SCN FROM v$database t; 
--为特定的SCN创建还原点
create resotre point scn_now as of scn 1943513;
--删除指定的还原点
drop restore point scn_now;

--查看保存还原点的时间
show parameter keep_time;
control_file_record_keep_time        integer     7

--还原控制文件
startup nomount;
restore controlfile from autobackup;
alter database mount;
recover database;
alter database open resetlogs;

--联机重做日志组
SELECT * FROM v$log;
current --正在写入这个组，恢复实例时需要这个组
active  --恢复实例需要这个组，可能正在归档
inactive --恢复不需要这个组。
unused  --日志组未使用
clearing --alter database clear logfile;
clearing_current --清除中出错


--由于DROP导致表的删除，但是若添加了purge则无法闪回
SELECT t.original_name,'flashback table '||t.owner||'.'||t.original_name||' to before drop;',t.droptime FROM dba_recyclebin t WHERE t.owner='SJYY' AND  t.original_name='SB_ZZS_YBNSR_FB3_YSFWKCXM';

索引重命名
ALTER INDEX sjyy."BIN$W0ex0vC6IfDgUwwICgq/fA==$0" RENAME TO idx_aaa;
主键及约束重命名
ALTER TABLE sjyy.SB_ZZS_YBNSR_FB3_YSFWKCXM RENAME CONSTRAINT "BIN$W0ex0vC0IfDgUwwICgq/fA==$0" TO PK_PC59;

--添加主键
alter table student add constraint pk_student primary key(studentid) tablespace SJYY_TS;
--批量提取主键
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
--配置闪回数据库 
--需要在mount状态下开启 
1、--必须 ARCHIVELOG
SELECT t.LOG_MODE FROM v$database t;
2、--确保创建闪回恢复区的位置和大小
alter system set  db_recovery_file_dest='+FRA';
alter system set  db_recovery_file_dest_size=4G;
3、--设置保留时间 --单位：分钟
alter system set db_flashback_retention_target=240;
4、--启用闪回日志记录
alter database flashback on;
5、--打开数据库
alter database open;
6、--确认闪回已经配置完成及进程已启动
select flashback_on from v$database;
SELECT spid FROM v$process WHERE pname='RVWR';

--相关闪回查询视图
SELECT * FROM v$flashback_database_log;
SELECT * FROM v$flashback_database_stat;

--查询当前闪回缓冲区的大小
SELECT * FROM v$sgastat t WHERE t.NAME='flashback generation buff';

--RMAN备份优化
--查看备份进度
SELECT a.SID,b.SPID,a.CLIENT_INFO FROM v$session a,v$process b WHERE a.PADDR=a.SADDR and a.CLIENT_INFO='%rman%'; 

--ORACLE 组件版本查询 
select * from dba_registry;

--告警日志
show parameter background_dump_dest
/u01/app/oracle/diag/rdbms/orcl/orcl/alert
--跟踪文件
show parameter diag
/u01/app/oracle/diag/rdbms/orcl/orcl/trace

--警告历史信息
SELECT * FROM dba_alert_history;

--突出告警信息
SELECT * FROM dba_outstanding_alerts;

--ASM启动和关闭顺序
先关闭数据库实例，再关闭ASM实例
先启动ASM实例，再启动数据库实例
ASMCMD>shutdown abort 
ASMCMD>startup
--查看状态 
[oracle@edt3r10p1 ~]$ srvctl status asm

======添加磁盘ASM磁盘组========
--在虚拟机上添加磁盘<不用重启虚拟机>
[root@localhost ~]# echo "- - -" > /sys/class/scsi_host/host0/scan

--对磁盘做分区
fdisk /dev/sdc
--将分区转化为PV
pvcreate /dev/sdc
pvcreate /dev/sdc1
pvcreate /dev/sdc2
pvcreate /dev/sdc3

--创建VG
vgcreate VolGroup02 /dev/sdc1 /dev/sdc2
查看 vgscan 
查看明细 vgdisplay

--创建LV
lvcreate -L 968MB  -n LogVol03 VolGroup02

--格式化
mke2fs -j /dev/VolGroup02/LogVol03

--向oracle asm添加磁盘
oracleasm createdisk ASMDISK14 /dev/sdc4

1、找到未使用的磁盘。
在SELECT * FROM v$asm_disk;
--查看磁盘组
在SELECT * FROM v$asm_diskgroup;找到需要添加的磁盘组
2、添加：alter diskgroup FRA add disk 'ORCL:ASMDISK09';

--从磁盘组中删除磁盘
alter diskgroup FRA drop disk ASMDISK09;

--创建磁盘组及故障组  external, normal和high redunancy
create diskgroup DGA normal redundancy failgroup controlerA disk 'ORCL:ASMDISK09','ORCL:ASMDISK10' failgroup controlerB disk 'ORCL:ASMDISK11','ORCL:ASMDISK12';
--删除磁盘组
drop diskgroup DGA including contents;

--磁盘组对应的数据文件
SELECT b.GROUP_NUMBER,b.NAME,f.type, f.redundancy, f.striped, f.modification_date,
a.system_created, a.name FROM v$asm_alias a, v$asm_file f,v$asm_diskgroup b WHERE
a.file_number = f.file_number and a.group_number = f.group_number and a.GROUP_NUMBER=b.GROUP_NUMBER
and f.type='DATAFILE';

--获取绑定变量的值
select instance_number,
       sql_id,
       name,
       datatype_string,
       last_captured,
       value_string
  from dba_hist_sqlbind
 where sql_id = '06qn4w6am2d2v'
 order by LAST_CAPTURED desc, POSITION ;

--开启归档
shutdown immediate; –关闭数据库 
startup mount; – 打开数据库 
alter database archivelog;—开启归档日志 
alter database open;–开启数据库 
archive log list; – 查看归档日志是否开启

--关闭归档
shutdown immediate;                      
startup mount;                           
alter database noarchivelog;             
alter database open;                     
archive log list;

--单实例归档修改
原归档路径采用快速恢复区，所以修改原有，需要重启数据库，但是修改log_archive_dest_n是可以直接生效的，就变成了多路复用
SQL> alter system set log_archive_dest='/opt/oracle/arch_dir' scope=spfile sid='*';
重启生效：
startup force 

--归档日志每天增长统计
SELECT t."THREAD#",to_char(t."COMPLETION_TIME",'yyyymmdd'),sum(t."BLOCKS"*t."BLOCK_SIZE"/1024/1024/1024) size_G FROM v$archived_log t group by t."THREAD#",to_char(t."COMPLETION_TIME",'yyyymmdd') order by 2 desc;

/* 监控每小时的归档个数 */
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

/* 查看当天每小时归档数据量 */  
select logtime,  
       count(*),  
       round(sum(blocks * block_size)/1024/1024/1024,2) gbsize  
  from (select trunc(first_time, 'hh') as logtime, a.BLOCKS, a.BLOCK_SIZE  
          from v$archived_log a  
         where a.DEST_ID = 1  
           and a.FIRST_TIME > trunc(sysdate))  
 group by logtime  
 order by logtime desc; 

 /* 查看最近一周每天归档数据量 */
 select logtime,  
       count(*),  
       round(sum(blocks * block_size)/1024/1024/1024,2) size_gb  
  from (select trunc(first_time, 'dd') as logtime, a.BLOCKS, a.BLOCK_SIZE  
          from v$archived_log a  
         where a.DEST_ID = 1  
           and a.FIRST_TIME > trunc(sysdate - 7))  
 group by logtime  
 order by logtime desc;
 
 
--消耗临时表空间的语句   
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

--占用临时表空大的历史会话和sql查询：
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
或：
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
--查看sql占用临时表空间最大值：
select max(a.temp_space_allocated / 1024 / 1024 / 1024) g
  from gv$active_session_history a
 where a.sql_id = '6uk7dr0n12f9n';


--临时表空间的使用情况
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

--扩展临时表空间
select d.file_name,d.tablespace_name,d.autoextensible from dba_temp_files d; 


ALTER TABLESPACE TEMP
 ADD TEMPFILE'/u01/oracle/oradata/NFZCDB/temp02.dbf'                                                                    
 SIZE 30G
 AUTOEXTEND ON
 NEXT 128M;

--查看共享内存使用情况
SELECT count(*),round(sum(t."SHARABLE_MEM")/1024/1024,2) FROM v$db_object_cache t;

--用户对应表空间使用情况
SELECT c.owner                                  "用户", 
       a.tablespace_name                        "表空间名", 
       total/1024/1024                          "表空间大小M", 
       free/1024/1024                           "表空间剩余大小M", 
       ( total - free )/1024/1024               "表空间使用大小M", 
       Round(( total - free ) / total, 4) * 100 "表空间总计使用率   %", 
       c.schemas_use/1024/1024                  "用户使用表空间大小M", 
       round((schemas_use)/total,4)*100         "用户使用表空间率  %"      
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
order by "用户","表空间名" ;                      

##找出最终阻塞的会话
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
 
##批量命名
取： 表名为：SB_CWBB_CJTJJ_ZCFZB  索引名为：idx_CJTJJ_ZCFZB_ZLBSCJUUID
SELECT distinct  'create index '||t.tab_owner||'.idx_' || trim (substr(t.tab_name,instr(t.tab_name,'_',-1,2)+1)) ||'_ZLBSCJUUID on '||t.tab_owner||'.'||trim(t.tab_name)||'(ZLBSCJUUID) online nologging;'FROM cz.create_index_t t;

##ORA-12720: operation requires database is in EXCLUSIVE mode
--如rac更改归档模式
在一台主机上执行：
alter system set cluster_database=false scope=spfile sid='*';
在两台主机上执行：
shutdown immediate
在一台主机上执行：
startup mount（必需要等2台机器同时shutdown完毕即可）
alter database noarchivelog;
alter database open;
alter system set cluster_database=true scope=spfile sid='*';
shutdown immediate;
在两台主机上执行：
Startup
此时修改完毕即可关闭归档，开启归档方法类似。

##ASM等待事件
select sid, state, event, seconds_in_wait, blocking_session
from   v$session
where  blocking_session is not null
or sid in (select blocking_session 
         from   v$session 
           where  blocking_session is not null)
 order by sid;
##历史等待事件查询
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
  

##给表加表锁
--加锁，会影响所有的ddl和dml以及expdp的操作
lock table cz.m_obj_cz in exclusive mode nowait;    //如果在plsqldev上执行的，不要点提交，执行完成就可以
--释放锁
通过lock_object杀掉进程。

##TOP 10 执行次数排序 
select * 
from (select executions,username,PARSING_USER_ID,sql_id,sql_text    
   from v$sql,dba_users where user_id=PARSING_USER_ID order by executions desc) 
where rownum <=5;

##TOP 10 物理读排序（消耗IO排序，即最差性能SQL、低效SQL排序） 
select * 
from (select DISK_READS,username,PARSING_USER_ID,sql_id,ELAPSED_TIME/1000000,sql_text    
   from v$sql,dba_users where user_id=PARSING_USER_ID order by DISK_READS desc) 
where rownum <=5;

注意：不要使用DISK_READS/ EXECUTIONS来排序，因为任何一条语句不管执行几次都会耗逻辑读和cpu，可能不会耗物理读（遇到LRU还会耗物理读，LRU规则是执行最不频繁的且最后一次执行时间距离现在最久远的就会被交互出buffer cache），是因为buffer cache存放的是数据块，去数据块里找行一定会消耗cpu和逻辑读的。Shared pool执行存放sql的解析结果，sql执行的时候只是去share pool中找hash value，如果有匹配的就是软解析。所以物理读逻辑读是在buffer cache中，软解析硬解析是在shared pool。

##TOP 10 逻辑读排序（消耗内存排序）
select * 
from (select BUFFER_GETS,username,PARSING_USER_ID,sql_id,ELAPSED_TIME/1000000,sql_text    
   from v$sql,dba_users where user_id=PARSING_USER_ID order by BUFFER_GETS desc) 
where rownum <=5;

注意：不要使用BUFFER_GETS/ EXECUTIONS来排序，因为任何一条语句不管执行几次都会耗逻辑读和cpu，可能不会耗物理读（遇到LRU还会耗物理读，LRU规则是执行最不频繁的且最后一次执行时间距离现在最久远的就会被交互出buffer cache），是因为buffer cache存放的是数据块，去数据块里找行一定会消耗cpu和逻辑读的。Shared pool执行存放sql的解析结果，sql执行的时候只是去share pool中找hash value，如果有匹配的就是软解析。所以物理读逻辑读是在buffer cache中，软解析硬解析是在shared pool）

##TOP 10 CPU排序(单位秒=cpu_time/1000000) 
select * 
from (select CPU_TIME/1000000,username,PARSING_USER_ID,sql_id,ELAPSED_TIME/1000000,sql_text    
   from v$sql,dba_users where user_id=PARSING_USER_ID order by CPU_TIME/1000000 desc) 
where rownum <=5;

注意：不要使用CPU_TIME/ EXECUTIONS来排序，因为任何一条语句不管执行几次都会耗逻辑读和cpu，可能不会耗物理读（遇到LRU还会耗物理读，LRU规则是执行最不频繁的且最后一次执行时间距离现在最久远的就会被交互出buffer cache），是因为buffer cache存放的是数据块，去数据块里找行一定会消耗cpu和逻辑读的。Shared pool执行存放sql的解析结果，sql执行的时候只是去share pool中找hash value，如果有匹配的就是软解析。所以物理读逻辑读是在buffer cache中，软解析硬解析是在shared pool。

##查询因PGA不足而使用临时表空间的最频繁的10条SQL语句 
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

##查看临时表空间使用率
方法一

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

方法二

SELECT a.tablespace_name, round(a.BYTES/1024/1024) total_M, round(a.bytes/1024/1024 - nvl(b.bytes/1024/1024, 0)) free_M, 
round(b.bytes/1024/1024) used,round(b.using/1024/1024) using 
  FROM (SELECT   tablespace_name, SUM (decode(autoextensible,'YES',MAXBYTES,bytes)) bytes FROM dba_temp_files GROUP BY tablespace_name) a, 
       (SELECT   tablespace_name, SUM (bytes_cached) bytes,sum(bytes_used) using FROM v$temp_extent_pool GROUP BY tablespace_name) b 
WHERE a.tablespace_name = b.tablespace_name(+)


估计undo需要多大 

SELECT (UR * (UPS * DBS)) AS "Bytes"  
FROM (select max(tuned_undoretention) AS UR from v$undostat),  
(SELECT undoblks/((end_time-begin_time)*86400) AS UPS  
FROM v$undostat  
WHERE undoblks = (SELECT MAX(undoblks) FROM v$undostat)),  
(SELECT block_size AS DBS  
FROM dba_tablespaces  
WHERE tablespace_name = (SELECT UPPER(value) FROM v$parameter WHERE name = 'undo_tablespace'));

##产生undo的当前活动会话是哪些 
方法一
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


方法二
select s.sid,s.serial#,s.sql_id,v.usn,r.status, v.rssize/1024/1024 mb
from dba_rollback_segs r, v$rollstat v,v$transaction t,v$session s
Where r.segment_id = v.usn and v.usn=t.xidusn and t.addr=s.taddr
order by 6 desc;

##查询Rman备份集详细信息（未过期的，过期并已删除的查不到）
SELECT B.RECID BackupSet_ID, 
       A.SET_STAMP, 
        DECODE (B.INCREMENTAL_LEVEL, 
                '', DECODE (BACKUP_TYPE, 'L', 'Archivelog', 'Full'), 
                1, 'Incr-1级', 
                0, 'Incr-0级', 
                B.INCREMENTAL_LEVEL) 
           "Type LV", 
        B.CONTROLFILE_INCLUDED "包含CTL", 
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

##查询Rman备份进度 
SELECT SID, SERIAL#, opname,ROUND(SOFAR/TOTALWORK*100)||'%' "%_COMPLETE", 
TRUNC(elapsed_seconds/60) || ':' || MOD(elapsed_seconds,60) elapsed, 
TRUNC(time_remaining/60) || ':' || MOD(time_remaining,60) remaining, 
CONTEXT,target,SOFAR, TOTALWORK 
FROM V$SESSION_LONGOPS 
WHERE OPNAME LIKE 'RMAN%' 
AND OPNAME NOT LIKE '%aggregate%' 
AND TOTALWORK != 0 
AND SOFAR <> TOTALWORK; 

##把XXX用户下面的某些YYY表赋权给user,XXX\YYY要大写 
set serveroutput on 
--XXX要大写 
declare tablename varchar2(200);     
    begin 
    for x IN (SELECT * FROM dba_tables where owner='XXX' and table_name like '%YYY%') loop   
    tablename:=x.table_name; 
    dbms_output.put_line('GRANT SELECT ON XXX.'||tablename||' to user'); 
    EXECUTE IMMEDIATE 'GRANT SELECT ON XXX.'||tablename||' TO user';  
    end loop; 
end;

##评估PGA该设置多少 
select PGA_TARGET_FOR_ESTIMATE from (select  * from V$PGA_TARGET_ADVICE
 where ESTD_OVERALLOC_COUNT=0 order by 1) where rownum=1; 
 
##评估SGA该设置多少
select SGA_SIZE from (select * from V$SGA_TARGET_ADVICE 
where ESTD_DB_TIME_FACTOR=1 order by 1) where rownum=1;

##统计所有表的容量大小(含分区字段、LOB字段) 
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

##RAC跨节点杀会话 
alter system kill session 'SID,serial#,@1'  --杀掉1节点的进程 
alter system kill session 'SID,serial#,@2'  --杀掉2节点的进程 

##DATAGUARD主备延迟多少时间的查询方法 
备 库sqlplus>select value from v$dataguard_stats where name='apply lag' 
或 
备库sqlplus>select ceil((sysdate-next_time)*24*60) "M" from v$archived_log where applied='YES' AND SEQUENCE#=(SELECT MAX(SEQUENCE#)  FROM V$ARCHIVED_LOG WHERE applied='YES'); 

##DG和ADG的区别
最早的容灾叫standby，恢复是存在延迟的，生产库生成归档后传去容灾端恢复，极端情况那就可能丢失一个归档的增量。另外恢复模式和只读状态只能二选一。
后来有了实时查询
后来有了既能只读打开又能增量恢复
这个后来就是adg

DG时代的数据同步方式如采用Redo Log的物理方式，则数据库同步数据快、耗用资源低，但存在一个大问题。
Oracle 11G以前的Data Guard物理备份数据库，可以以只读的方式打开数据，但这时日志的数据同步过程就停止了。而如果日志的数据同步处于执行过程中，则数据库就不能打开。也就是日志读、写两个状态是互相排斥的。而Active Data Guard则是主要解决这个问题。
