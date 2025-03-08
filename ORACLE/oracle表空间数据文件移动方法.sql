--Oracle表空间数据文件移动的方法
一、针对可offline的非系统表空间
本例移动oracle的案例表空间(EXAMPLE表空间)，将其从
D:\ORADATA\ORCL\ 移动到 D:\ORACLE\ORADATA\
1.查看要改变的表空间的数据文件信息
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

2.将目标表空间设置为脱机状态
--批量脚本
select 'alter tablespace ' || t.tablespace_name|| ' offline;' from (select 
       distinct tablespace_name
  from dba_data_files where tablespace_name not in ('USERS','UNDOTBS1','SYSTEM','SYSAUX')) t ;
  
alter tablespace TS_HX_ZM_DAT offline;

3.再次查看目标表空间的状态，确保其已经是脱机状态
select file_id,
       tablespace_name,
       file_name,
       online_status,
       autoextensible,
       user_bytes / 1024 / 1024 size_M
  from dba_data_files
 where tablespace_name = 'TS_HX_ZM_DAT';
 
4.将原来的数据文件移动(或复制)到新的路径
SQL> ! mv /u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_02.dbf /home/oracle/app/oradata/NFZCDB/datafile/

5.修改该表空间的数据文件路径
alter tablespace TS_HX_ZM_DAT rename datafile '/u01/oracle/oradata/NFZCDB/TS_HX_ZM_DAT_02.dbf' to '/home/oracle/app/oradata/NFZCDB/datafile/TS_HX_ZM_DAT_02.dbf';
--批量脚本
select 'alter tablespace  '|| t.tablespace_name || ' rename datafile '''||t.file_name||''' to '''||t.file_name||'''  ;'
from (select 
        tablespace_name,file_name
  from dba_data_files where tablespace_name not in ('USERS','UNDOTBS1','SYSTEM','SYSAUX')) t;
6、确定修改的已经生效
select file_id,
       tablespace_name,
       file_name,
       online_status,
       autoextensible,
       user_bytes / 1024 / 1024 size_M
  from dba_data_files
 where tablespace_name = 'TS_HX_ZM_DAT';
 
7.修改该表空间为在线状态
alter tablespace TS_HX_ZM_DAT online;

二、系统表空间移动

该方法需要数据库处于mount状态

1.关闭运行中的数据库


SQL> shutdown immediate
 

2.启动数据库到mount状态

 
SQL> startup mount
 

3.移动系统表空间(SYSTEM表空间)的数据文件


SQL> host move D:\ORADATA\ORCL\SYSTEM01.DBF D:\ORACLE\ORADATA\
 

4.修改该表空间的数据文件路径

 
SQL> alter database rename file 'D:\ORADATA\ORCL\SYSTEM01.DBF' to 'D:\ORACLE\ORA
DATA\SYSTEM01.DBF';
 

5.启动数据库，打开实例
 
SQL> alter database open;
 

6.查看表空间修改结果

SQL> select tablespace_name,file_name,online_status from dba_data_files where ta
blespace_name='SYSTEM';
 
TABLESPACE_NAME FILE_NAME     ONLINE_
--------------- ----------------------------------- -------
SYSTEM  D:\ORACLE\ORADATA\SYSTEM01.DBF SYSTEM

#####其他移动方式#####
>>>在 Oracle 数据库 12c R1 版本中对数据文件的迁移或重命名不再
需要太多繁琐的步骤，即把表空间置为只读模式，接下来是对数据文件进行离线操作。
在 12c R1 中，可以使用 ALTER DATABASE MOVE DATAFILE 这样的 SQL 语句对数据文件
进行在线重命名和移动。而当此数据文件正在传输时，终端用户可以执行查询，DML
以及 DDL 方面的任务。另外，数据文件可以在存储设备间迁移，如从非 ASM 迁移至 ASM，
反之亦然
#重命名数据文件：
SQL>ALTER DATABASE MOVE DATAFILE '/u00/data/users01.dbf' TO
'/u00/data/users_01.dbf';
#从非 ASM 迁移数据文件至 ASM：
SQL>ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO '+DG_DATA';
#将数据文件从一个 ASM 磁盘群组迁移至另一个 ASM 磁盘群组：
SQL>ALTER DATABASE MOVE DATAFILE '+DG_DATA/DBNAME/DATAFILE/users_01.dbf ' TO
'+DG_DATA_02';
#在数据文件已存在于新路径的情况下，以相同的命名将其覆盖：
SQL>ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO
'/u00/data_new/users_01.dbf' REUSE;
SQL>ALTER DATABASE MOVE DATAFILE '/u00/data/users_01.dbf' TO
'/u00/data_new/users_01.dbf' KEEP;
当通过查询 v$session_longops 动态视图来移动文件时，你可以监控这一过程。另外，
你也可以引用 alert.log，Oracle 会在其中记录具体的行为。
 
