--oracle��Ǩ��    
######��ʵ������ʵ��#######
##Ŀ�������ǰ�ã�
1����װoracle����ز��
2������oracle������û���������Ҫ����Ŀ¼��
3�����谲װoracle�����dbca����
##ԭ��������
1���鿴oracle��������
[oracle@oracle ~]$ su - oracle
oracle@oracle ~]$ more ~/.bash_profile 
PATH=$PATH:$HOME/bin:/opt/oracle/product/OPatch

export PATH
export ORACLE_SID=orcl11g
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/product
export PATH=$PATH:/$ORACLE_HOME/bin:$HOME/bin
export NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"

2������ORACLE_BASE���������ݵ�Ŀ���������
--ȷ������Ŀ¼���ڣ���pfileȥ�鿴
1��audit_file_dest='/opt/oracle/admin/orcl11g/adump'
2��control_files='/opt/oracle/oradata/orcl11g/control01.ctl','/opt/oracle/flash_recovery_area/orcl11g/control02.ctl'
3��db_recovery_file_dest='/opt/oracle/flash_recovery_area'
4��diagnostic_dest='/opt/oracle'
5��log_archive_dest
�����п��ܴ���Ȩ�޵����⣬������root���û�ȥ������֮���ٸı�����
su - root
cd /opt
scp -r oracle 10.10.8.56:/opt
--Ŀ������
cd /opt
chown -R oracle.oinstall oracle

##Ŀ������
1�����û�������
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

2���޸ĳɱ���IP
[oracle@orcl01 ~]$ vim /etc/hosts
10.10.8.56  orcl01

3���޸ļ���
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

4������ʵ�������ڴ治ͬ������֣�
ORA-00845: MEMORY_TARGET not supported on this system
--�޸ĺ��ʵĴ�Сȡ���� /dev/shm
SQL> create pfile='/tmp/spfile_bak.ora' from spfile;

--����ʱ���ֿ����ļ��汾�Ų�һ��
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

--ȡ���İ汾�ţ�ɾ��С�İ汾�ţ�Ȼ�󿽱���ĵ�С��·������������
cp -p control02.ctl /opt/oracle/oradata/orcl11g/
cd /opt/oracle/oradata/orcl11g/
rm -rf control01.ctl 
mv control02.ctl control01.ctl

--�ٴ�����
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

--���ڷ������쳣�̵磬����LGWRд������־�ļ�ʱʧ�ܣ��´������������ݿ�ʱ����Ҫ��ʵ�����ָ���
�����޷���������־�ļ����ȡ����Щredo��Ϣ����Ϊ�ϴζϵ�ʱ��д��־ʧ���ˡ�
�鿴��ǰ��־�ļ�����������²�ѯ������Կ�����ǰ��־��Ϊ1
SQL> select group#,sequence#,status,first_time,next_change# from v$log;

    GROUP#  SEQUENCE# STATUS           FIRST_TIM NEXT_CHANGE#
---------- ---------- ---------------- --------- ------------
         1      33064 CURRENT          24-DEC-19   2.8147E+14
         3      33063 INACTIVE         24-DEC-19    506891662
         2      33062 INACTIVE         24-DEC-19    506889767
         
----�ָ����ݿ⣬ָ��redo01.log��־
SQL> SELECT a."THREAD#",c."INSTANCE_NAME",a."GROUP#",a."STATUS",b."MEMBER",a."BYTES"/1024/1024 SIZE_M FROM v$log a,v$logfile b,gv$instance c where a."GROUP#"=b."GROUP#" and a."THREAD#"=c."THREAD#" order by 1,3;

   THREAD# INSTANCE_NAME        GROUP# STATUS           MEMBER                                                           SIZE_M
---------- ---------------- ---------- ---------------- ------------------------------------------------------------ ----------
         1 orcl11g                   1 CURRENT          /opt/oracle/oradata/orcl11g/redo01.log                               50
         1 orcl11g                   2 INACTIVE         /opt/oracle/oradata/orcl11g/redo02.log                               50
         1 orcl11g                   3 INACTIVE         /opt/oracle/oradata/orcl11g/redo03.log                               50
         
SQL> recover database until cancel using backup controlfile;
Specify log: {<RET>=suggested | filename | AUTO | CANCEL}
����-->> /opt/oracle/oradata/orcl11g/redo01.log
Media recovery complete.

SQL> alter database open resetlogs;

Database altered.

Elapsed: 00:00:06.53
SQL> select status from v$instance;

STATUS
------------
OPEN

5�����������������ɹ�����Ҫע��
SQL> alter system register;

6��ȷ������û���������spfile�������ݿ�
create spfile from pfile='/tmp/spfile_bak.ora';
startup force;



SQL> recover database  using backup controlfile until cancel;
{<RET>=suggested | filename | AUTO | CANCEL}

--auto
���ݿ��Լ����ҹ鵵��־����Ӧ��

--CANCEL
���ö����ö���

--filename 
ָ���ļ�

--���ڿ����ļ��������������ļ���ʵ���ļ����ּ�·������һ����������Ҫ����ָ����
alter database create datafile '/u01/app/oracle/dbs/unnamed006' as '/u01/app/oracle/dbs/prod1/test01.dbf'