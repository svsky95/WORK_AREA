--�鵵��־ռ�����̣����¿ͻ��˲����������ݿ�
1�����Ȳ鿴�˼���  lsnrctl status
2���鿴������Ķ˿����� netstat -an |grep 1521
3��df -alh �鿴������һ�����̵Ŀռ��Ѿ������þ������Կ����ж������ڹ鵵��־���´����þ�
4���鿴�鵵��־��λ�ã�
----ʹ�ù̶���Ŀ¼
archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            /u01/oracle/archive    --�鵵��־��λ��
Oldest online log sequence     12892
Next log sequence to archive   12894
Current log sequence           12894

----ʹ�ÿ��ٻָ���
SQL> archive log list;
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST   --ָ����ٻָ���
Oldest online log sequence     881
Next log sequence to archive   883
Current log sequence           883

SQL> show parameter DB_RECOVERY_FILE_DEST

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_recovery_file_dest                string      /u01/app/oracle/fast_recovery_    --�鵵��־���ڵ�λ��
                                                 area
db_recovery_file_dest_size           big integer 20G                               --���ٻָ�����С

���鵵��־����20G��Ҳ����ʾ�鵵��־����

--�鿴�鵵��־ʣ��
 SQL> select * from v$flash_recovery_area_usage;

FILE_TYPE            PERCENT_SPACE_USED PERCENT_SPACE_RECLAIMABLE NUMBER_OF_FILE
-------------------- ------------------ ------------------------- --------------
CONTROL FILE                         .1                         0
REDO LOG                           2.48                         0
ARCHIVED LOG                      65.41  <--ʹ�õİٷֱ�                       0             10 <--�ж����ļ�
BACKUP PIECE                       3.06                         0
IMAGE COPY                        27.67                         0              1
FLASHBACK LOG                         0                         0
FOREIGN ARCHIVED LOG                  0                         0 



--�޸Ĺ鵵����λ��
--�����ʹ�ÿ��ٻָ����������Ȱѿ��ٻָ�������Ϊ��
alter system set db_recovery_file_dest='';

--ָ�����µĹ鵵��־��·��������oralceȨ��
drwxr-xr-x   2 oracle oinstall   4096 Aug  5 13:52 arch

alter system set log_archive_dest='/oracle/arch' scope=both;

--�л���־�鿴�Ƿ��Ѿ��鵵���µ�·��
alter system switch logfile;



5��rman ɾ���鵵��־
rman target /
DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-3';  --����3��Ĺ鵵��־
--���ɾ����������Ҫ�ҵ��鵵��־��λ�ã��ֶ�ɾ��һ���ֺ���ִ�оͿ��Գɹ���


--------------------------------�ƻ����񣬶�ʱִ��rmang�鵵��־ɾ��------------------------------
--root�û�ִ��
[oracle@127 del_arch_log]$ more del_arch_log.sh                                                                 
export EDITOR=vi                               --������ root���û���ִ�У���Ҫ��oracle�Ļ����������ڽű���ǰ�棬more /home/oracle/.bash_profile
export ORACLE_SID=nfzcdb
export ORACLE_BASE=/home/oracle/app
export ORACLE_HOME=$ORACLE_BASE/oracle/product/11.2.0/dbhome_1
export GG_HOME=/home/oracle/ggs
export INVENTORY_LOCATION=/home/oracle/app/oraInventory
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib:/$GG_HOME:/$LD_LIBRARY_PATH
export NLS_LANG="American_america.zhs16gbk"
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:$GG_HOME
umask 022
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.141.x86_6
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH

su - oracle <<EOF
${ORACLE_HOME}/bin/rman nocatalog log=/u01/oracle/del_arch_log/del_arch$(date +%Y-%m-%d).log;
connect target /
#crosscheck archivelog all;
#delete noprompt expired archivelog all;
DELETE noprompt ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2';
exit;
EOF

--oracle�û�ִ��
${ORACLE_HOME}/bin/rman nocatalog log=/export/home/oracle/arch_del_logs/del_arch$(date +%Y-%m-%d).log <<EOF
connect target /
crosscheck archivelog all;
delete noprompt expired archivelog all;
DELETE noprompt ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2';
exit;
EOF

--solarisϵͳִ��
--oracle�û��µĻ�������
more /export/home/oracle/.profile

vim /export/home/oracle/clear_archivelog.sh
export ORACLE_SID=sngsnfdb2
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/sngsnfdb
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=.:$PATH:$ORACLE_HOME/bin
umask 022
export AWT_TOOLKIT=XToolkit
${ORACLE_HOME}/bin/rman nocatalog log=/export/home/oracle/arch_del_logs/del_arch$(date +%Y-%m-%d).log <<EOF
connect target /
crosscheck archivelog all;
delete noprompt expired archivelog all;
DELETE noprompt ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2';
exit;
EOF

--�ƻ�����cron log 
/var/cron/log 

>  CMD: sh /export/home/oracle/clear_archivelog.sh 
>  oracle 20900 c Fri Mar  1 16:53:00 2019
<  oracle 20900 c Fri Mar  1 16:54:29 2019        <--���������rc=127˵��ִ�нű�������

--�ƻ�����----
0 2 * * * /u01/oracle/del_arch_log/del_arch_log.sh









