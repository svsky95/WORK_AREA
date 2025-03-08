--oracle冷迁移    
######单实例到单实例#######
##目标服务器前置：
1、安装oracle的相关插件
2、创建oracle的相关用户，但不需要创建目录。
3、无需安装oracle软件及dbca建库
##原服务器：
1、查看oracle环境变量
[oracle@oracle ~]$ su - oracle
oracle@oracle ~]$ more ~/.bash_profile 
PATH=$PATH:$HOME/bin:/opt/oracle/product/OPatch

export PATH
export ORACLE_SID=orcl11g
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/product
export PATH=$PATH:/$ORACLE_HOME/bin:$HOME/bin
export NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"

2、拷贝ORACLE_BASE的所有内容到目标服务器。
--确保几个目录存在，从pfile去查看
1、audit_file_dest='/opt/oracle/admin/orcl11g/adump'
2、control_files='/opt/oracle/oradata/orcl11g/control01.ctl','/opt/oracle/flash_recovery_area/orcl11g/control02.ctl'
3、db_recovery_file_dest='/opt/oracle/flash_recovery_area'
4、diagnostic_dest='/opt/oracle'
5、log_archive_dest
由于有可能存在权限的问题，所以用root的用户去拷贝，之后再改变属组
su - root
cd /opt
scp -r oracle 10.10.8.56:/opt
--目标主机
cd /opt
chown -R oracle.oinstall oracle

##目标主机
1、配置环境变量
su - oracle
vim ~/.bash_profile
xport PATH
export TMP=/tmp
export LANG=en_US.UTF-8
export TMPDIR=$TMP
export ORACLE_SID=orcl11g
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/product
export ORACLE_UNQNAME=racdbdg
export TNS_ADMIN=$ORACLE_HOME/network/admin
export ORACLE_TERM=xterm
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export EDITOR=vi
export NLS_DATE_FORMAT='yyyy/mm/dd hh24:mi:ss'
umask 022

2、修改成本地IP
[oracle@orcl01 ~]$ vim /etc/hosts
10.10.8.56  orcl01

3、修改监听
[oracle@orcl01 ~]$ cd $ORACLE_HOME/network/admin
[oracle@orcl01 admin]$ vim listener.ora 

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.10.8.56)(PORT = 1521))
    )
  )

ADR_BASE_LISTENER = /opt/oracle

4、启动实例，若内存不同，会出现：
ORA-00845: MEMORY_TARGET not supported on this system
--修改合适的大小取决于 /dev/shm
SQL> create pfile='/tmp/spfile_bak.ora' from spfile;

--启动时发现控制文件版本号不一致
SQL> startup pfile='/tmp/spfile_bak.ora';
ORACLE instance started.

Total System Global Area 2722467840 bytes
Fixed Size                  2216464 bytes
Variable Size            1509953008 bytes
Database Buffers         1191182336 bytes
Redo Buffers               19116032 bytes
ORA-00214: control file '/opt/oracle/flash_recovery_area/orcl11g/control02.ctl'
version 494529 inconsistent with file
'/opt/oracle/oradata/orcl11g/control01.ctl' version 494527

--取最大的版本号，删除小的版本号，然后拷贝大的到小的路径，并重命名
cp -p control02.ctl /opt/oracle/oradata/orcl11g/
cd /opt/oracle/oradata/orcl11g/
rm -rf control01.ctl 
mv control02.ctl control01.ctl

--再次启动
SQL> startup pfile='/tmp/spfile_bak.ora';
ORACLE instance started.

Total System Global Area 2722467840 bytes
Fixed Size                  2216464 bytes
Variable Size            1509953008 bytes
Database Buffers         1191182336 bytes
Redo Buffers               19116032 bytes
Database mounted.
ORA-00600: internal error code, arguments: [kcratr_nab_less_than_odr], [1],
[33064], [772], [1403], [], [], [], [], [], [], []

--由于服务器异常短电，导致LGWR写联机日志文件时失败，下次重新启动数据库时，需要做实例级恢复，
而又无法从联机日志文件里获取到这些redo信息，因为上次断电时，写日志失败了。
查看当前日志文件情况，从以下查询结果可以看到当前日志组为1
SQL> select group#,sequence#,status,first_time,next_change# from v$log;

    GROUP#  SEQUENCE# STATUS           FIRST_TIM NEXT_CHANGE#
---------- ---------- ---------------- --------- ------------
         1      33064 CURRENT          24-DEC-19   2.8147E+14
         3      33063 INACTIVE         24-DEC-19    506891662
         2      33062 INACTIVE         24-DEC-19    506889767
         
----恢复数据库，指定redo01.log日志
SQL> SELECT a."THREAD#",c."INSTANCE_NAME",a."GROUP#",a."STATUS",b."MEMBER",a."BYTES"/1024/1024 SIZE_M FROM v$log a,v$logfile b,gv$instance c where a."GROUP#"=b."GROUP#" and a."THREAD#"=c."THREAD#" order by 1,3;

   THREAD# INSTANCE_NAME        GROUP# STATUS           MEMBER                                                           SIZE_M
---------- ---------------- ---------- ---------------- ------------------------------------------------------------ ----------
         1 orcl11g                   1 CURRENT          /opt/oracle/oradata/orcl11g/redo01.log                               50
         1 orcl11g                   2 INACTIVE         /opt/oracle/oradata/orcl11g/redo02.log                               50
         1 orcl11g                   3 INACTIVE         /opt/oracle/oradata/orcl11g/redo03.log                               50
         
SQL> recover database until cancel using backup controlfile;
Specify log: {<RET>=suggested | filename | AUTO | CANCEL}
输入-->> /opt/oracle/oradata/orcl11g/redo01.log
Media recovery complete.

SQL> alter database open resetlogs;

Database altered.

Elapsed: 00:00:06.53
SQL> select status from v$instance;

STATUS
------------
OPEN

5、启动监听，若不成功，需要注册
SQL> alter system register;

6、确定所有没有问题后，用spfile启动数据库
create spfile from pfile='/tmp/spfile_bak.ora';
startup force;



SQL> recover database  using backup controlfile until cancel;
{<RET>=suggested | filename | AUTO | CANCEL}

--auto
数据库自己查找归档日志进行应用

--CANCEL
能用多少用多少

--filename 
指定文件

--由于控制文件中描述的数据文件与实际文件名字及路径都不一样，所以需要重新指定。
alter database create datafile '/u01/app/oracle/dbs/unnamed006' as '/u01/app/oracle/dbs/prod1/test01.dbf'