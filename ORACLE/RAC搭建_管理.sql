ps �Cef|grep LOCAL=NO|grep �Cv grep|awk '{print $2}'|xargs kill -9
--��װoracle linux ,�м�һ�������һ����װͼ�ν��������desktop;
Desktops
Desktop
Desktop Platform
Fonts
General Purpose Desktop
Graphical Administration Tools
X Windows System

1��swapҪ���ڴ�Ĵ�С��ͬ

nod1��nod2�ֱ�ִ��
�رշ���ǽ
��rac1 ��rac2 2���ڵ��Ϸֱ�ִ��������䣺
 
[root@rac01 ~]# service iptables stop
[root@rac01 ~]# chkconfig iptables off
[root@rac01 ~]# chkconfig iptables --list
iptables 0:off 1:off 2:off 3:off 4:off 5:off 6:off
 
chkconfig iptables off ---����
service iptables stop ---��ʱ
/etc/init.d/iptables status ----��õ�һϵ����Ϣ��˵������ǽ���š�
/etc/rc.d/init.d/iptables stop ----------�رշ���ǽ

--�ر�NTP����
--���ֶ����������ڵ�ʱ��һ��
[root@node2 ~]# service ntpd stop  
Shutting down ntpd:                                        [FAILED]  
[root@node2 ~]# chkconfig ntpd off  
[root@node2 ~]# mv /etc/ntp.conf /etc/ntp.conf.original  
[root@node2 ~]# rm -rf /var/run/ntpd.pid  

--oracleΪ�˼�ʱ���ͬ�����ڰ�װgridʱ������CTSS����
#����Ⱥ����NTP������ʱ��ctss����һ���۲��ߣ�Observer mode�����������أ���һ�µ�ʱ���д�뵽alert�У�����������������
root@dzswjnfdb1:/u01/app/11.2.0.4/grid/bin# ./crsctl check ctss
CRS-4700: The Cluster Time Synchronization Service is in Observer mode.
#���ص�NTPʱ��CTSS��������ģʽ��Active mode�������������ڵ��ʱ��ͬ����
[root@rac2 ~]# crsctl check ctss
CRS-4701: The Cluster Time Synchronization Service is in Active mode

�ر��ں˷���ǽ
vi /etc/sysconfig/selinux
SELINUX=disabled

--�޸�������
#centos 6.x
[root@racnod1 ~]# more /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=racnod1

#centos 7.x 
hostnamectl set-hostname racnode01
--�ű���ʽת��
yum install -y  dos2unix
dos2unix *


--�޸�hosts�ļ�
vi /etc/hosts�ļ�
#Public IP
192.168.31.201 racnod1
192.168.31.202 racnod2
 
#Private IP
192.168.1.101 rac1-priv
192.168.1.102 rac2-priv
 
#Virtual IP
192.168.31.203 racnod1-vip
192.168.31.204 racnod2-vip
 
#Scan IP
192.168.31.205 racnod-cluster


--�����û��鼰��Ȩ<���濴��Ŀ¼�Ĺ滮���������Ȩ�޵�����>
useradd -u 1100 -g oinstall -G asmadmin,asmdba,asmoper,oper,dba grid
useradd -u 1101 -g oinstall -G dba,asmdba,oper oracle
mkdir -p /u01/app/11.2.0/grid
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle
chown -R grid:oinstall /u01
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/

Ϊoracle��grid��������
passwd oracle    --oracle123
passwd grid      --grid123

--���ع���
cd /etc/yum.repos.d/
mv public-yum-ol6.repo public-yum-ol6.repo_bak
vi /etc/yum.repos.d/dvd.repo
[dvd]
name=dvd
baseurl=file:///media/OL6.7\ x86_64\ Disc\ 1\ 20150728/
gpgcheck=0
enabled=1

--���YUM����
yum clean all
yum makecache
yum install oracle-rdbms-server-11gR2-preinstall-1.0-6.el6


--���������ļ�--������grid�����н���fix�޸�
vi /etc/security/limits.conf
# grid-rdbms-server-11gR2-preinstall setting for nofile soft limit is 1024
grid   soft   nofile    1024

# grid-rdbms-server-11gR2-preinstall setting for nofile hard limit is 65536
grid   hard   nofile    65536

# grid-rdbms-server-11gR2-preinstall setting for nproc soft limit is 2047
grid   soft   nproc    2047

# grid-rdbms-server-11gR2-preinstall setting for nproc hard limit is 16384
grid   hard   nproc    16384

# grid-rdbms-server-11gR2-preinstall setting for stack soft limit is 10240KB
grid   soft   stack    10240


5. ���ù���洢
����1��
--99-oracle-asmdevices.rules 
�������·���󣬻�����������dm-*��ͷ�ľۺ���
[root@racnod1 mapper]# cd /dev/mapper
[root@racnod1 mapper]# ls -al
total 0
drwxr-xr-x.  2 root root    180 Dec 26 03:41 .
drwxr-xr-x. 18 root root   4060 Dec 26 03:41 ..
crw-rw----.  1 root root 10, 58 Dec 26 03:40 control
lrwxrwxrwx.  1 root root      7 Dec 26 03:40 mpatha -> ../dm-2   
lrwxrwxrwx.  1 root root      7 Dec 26 03:40 mpathb -> ../dm-4
lrwxrwxrwx.  1 root root      7 Dec 26 03:41 mpathc -> ../dm-3
lrwxrwxrwx.  1 root root      7 Dec 26 03:40 mpathcp1 -> ../dm-5
lrwxrwxrwx.  1 root root      7 Dec 26 03:40 vg_racnod1-lv_root -> ../dm-0
lrwxrwxrwx.  1 root root      7 Dec 26 03:40 vg_racnod1-lv_swap -> ../dm-1


for i in b c d e f g h i j k l m ;
do
echo "KERNEL==\"dm-*\", BUS==\"block\", PROGRAM==\"/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/\$name\",RESULT==\"`scsi_id --whitelisted --replace-whitespace --device=/dev/sd$i`\",NAME=\"asm-disk$i\",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracleasm.rules
done

cat /etc/udev/rules.d/99-oracle-asmdevices.rules
--ȥ���ظ��ļ�¼
KERNEL=="dm-*", BUS=="block", PROGRAM=="/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/$name",RESULT=="14f504e46494c455259516a6c326d2d4a356b6f2d47486e75",NAME="asm-diskb",OWNER="grid",GROUP="asmadmin",MODE="0660"
KERNEL=="dm-*", BUS=="block", PROGRAM=="/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/$name",RESULT=="14f504e46494c45526132504e41652d334b636e2d4a307772",NAME="asm-diskd",OWNER="grid",GROUP="asmadmin",MODE="0660"
KERNEL=="dm-*", BUS=="block", PROGRAM=="/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/$name",RESULT=="14f504e46494c45524d57715571322d4a3064792d486a364e",NAME="asm-diskf",OWNER="grid",GROUP="asmadmin",MODE="0660"

--exsi������
for i in b c;
do
echo "KERNEL==\"sd*\", BUS==\"scsi\",PROGRAM==\"/sbin/scsi_id -g -u /dev/\$name\", RESULT==\"`/sbin/scsi_id -g -u /dev/sd$i`\", NAME=\"asm-disk$i\", OWNER=\"grid\",GROUP=\"asmadmin\", MODE=\"0660\"" >> /etc/udev/rules.d/99-oracle-asmdevices.rules
done


/sbin/partprobe /dev/sdb1  --���ر䶯
/sbin/start_udev

[root@racnod1 mapper]# ll /dev/asm*
brw-rw----. 1 grid asmadmin 253, 2 Dec 26 04:04 /dev/asm-diskb
brw-rw----. 1 grid asmadmin 253, 4 Dec 26 04:04 /dev/asm-diskd
brw-rw----. 1 grid asmadmin 253, 3 Dec 26 03:40 /dev/asm-diskf
brw-rw----. 1 grid asmadmin 253, 3 Dec 26 04:04 /dev/asm-diskg



--����oracle��grid�������ļ�
su - grid
vi .bash_profile
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_SID=+ASM1  # RAC1  --ÿ���ڵ�һ��
export ORACLE_SID=+ASM2  # RAC2
export ORACLE_UNQNAME=crsdb
export ORACLE_BASE=/u01/app/grid
export ORACLE_HOME=/u01/app/11.2.0/grid
export TNS_ADMIN=/u01/app/oracle/product/11.2.0/db_1/network/admin
export PATH=/usr/sbin:/u01/app/11.2.0/grid/bin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
grid_home=/u01/app/grid/

source .bash_profile

su - oracle
vi .bash_profile
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_SID=crsdb1  # RAC1  ---ÿ���ڵ�һ��
export ORACLE_SID=crsdb2  # RAC2
export ORACLE_UNQNAME=crsdb
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export TNS_ADMIN=$ORACLE_HOME/network/admin
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib


�رղ���Ҫ�ķ���
chkconfig autofs off
chkconfig acpid off
chkconfig sendmail off
chkconfig cups-config-daemon off
chkconfig cpus off
chkconfig xfs off
chkconfig lm_sensors off
chkconfig gpm off
chkconfig openibd off
chkconfig pcmcia off
chkconfig cpuspeed off
chkconfig nfslock off
chkconfig ip6tables off
chkconfig rpcidmapd off
chkconfig apmd off
chkconfig sendmail off
chkconfig arptables_jf off
chkconifg microcode_ctl off
chkconfig rpcgssd off
chkconfig ntpd off


--��ʼ��װgrid
Ϊ�˳���OUIͼ�λ���װ�����鰲װVNC
���Դ��Ĺ����а�װ��
cd /media/OL6.7\ x86_64\ Disc\ 1\ 20150728/Packages/
rpm -ivh tigervnc-server-1.1.0-16.el6.x86_64.rpm

-->����ͼ�ΰ�װ�ĵ�


####################################����Ϊ�ο�����###################################

--��asmca����ASM������
--��װ���ݿ����dbca�������ݿ�

--SSH����--������grid���Զ���װ
��oracle�����ÿ���ڵ�ִ��
 
Ϊssh��scp�������ӣ������Ƿ���ڣ�
ls -l /usr/local/bin/ssh
ls -l /usr/local/bin/scp
�������򴴽�
/bin/ln -s /usr/bin/ssh /usr/local/bin/ssh
/bin/ln -s /usr/bin/scp /usr/local/bin/scp
 

 
Ϊoracle�û�����SSH��
�����û��Ĺ��׺�˽�ף���ÿ���ڵ���ִ�У�
su �C oracle
 mkdir ~/.ssh
 cd .ssh
 ssh-keygen -t rsa
 ssh-keygen -t dsa
 
�ڽڵ�1�ϣ������нڵ��authorized_keys�ļ��ϳ�һ������������ļ����Ǹ����ڵ�.ssh�µ�ͬ���ļ��� 
su - oracle
 touch authorized_keys
 ssh RACNOD1.localdomain cat /home/oracle/.ssh/id_rsa.pub >> authorized_keys
 ssh RACNOD2.localdomain cat /home/oracle/.ssh/id_rsa.pub >> authorized_keys
 ssh RACNOD1.localdomain cat /home/oracle/.ssh/id_dsa.pub >> authorized_keys
 ssh RACNOD2.localdomain cat /home/oracle/.ssh/id_dsa.pub >> authorized_keys
[oracle@rac01 ~]# scp authorized_keys RACNOD2.localdomain:/home/oracle/.ssh/

�ֱ���ÿ���ڵ���ִ�м����Ƿ�ɹ�:
[oracle@rac01 ~]# ssh RACNOD1.localdomain date
[oracle@rac01 ~]# ssh RACNOD2.localdomain date

--ΪGRID����
su �C grid
 mkdir ~/.ssh
 cd .ssh
 ssh-keygen -t rsa
 ssh-keygen -t dsa
ssh RACNOD1.localdomain cat /home/grid/.ssh/id_rsa.pub >> authorized_keys
 ssh RACNOD2.localdomain cat /home/grid/.ssh/id_rsa.pub >> authorized_keys
 ssh RACNOD1.localdomain cat /home/grid/.ssh/id_dsa.pub >> authorized_keys
 ssh RACNOD2.localdomain cat /home/grid/.ssh/id_dsa.pub >> authorized_keys
 scp authorized_keys RACNOD2.localdomain:/home/grid/.ssh/

11g-bug
Adding Clusterware entries to upstart
 /bin/dd if=/var/tmp/.oracle/npohasd of=/dev/nullbs=1024 count=1


--Ϊ��Ⱥ���ӽڵ�

grid> cluvfy stage -pre nodeadd -n racnod3  --���ӽڵ��������
Check for consistency of root user's primary group passed

Checking OCR integrity...

OCR integrity check passed

Checking Oracle Cluster Voting Disk configuration...

Oracle Cluster Voting Disk configuration check passed
Time zone consistency check passed'
--���grid
sh /u01/app/11.2.0/grid/oui/bin/addNode.sh "CLUSTER_NEW_NODES={racnod3}" "CLUSTER_NEW_VIRTUAL_HOSTNAMES={racnod3-vip}"
--���oracle
sh /u01/app/oracle/product/11.2.0/db_1/oui/bin/addNode.sh "CLUSTER_NEW_NODES={racnod3}"
./addNode.sh -silent ��CLUSTER_NEW_NODES={racnod3}�� ��CLUSTER_NEW_VIRTUAL_HOSTNAMES={racnod3-vip}��
�����Լ�
export IGNORE_PREADDNODE_CHECKS=Y 

srvctl config database -d crsdb
srvctl stop nodeapps -n racnod2 -f 
sh /u01/app/oracle/product/11.2.0/db_1/oui/bin/runInstaller.sh -updateNodeList ORACLE_HOME=$ORACLE_HOME ��CLUSTER_NODES={racnod2}�� -local
--CRS �����ļ�
/u01/app/oraInventory/ContentsXML/inventory.xml


/u01/app/11.2.0/grid/bin/crsctl delete node -n racnod2
olsnodes -t -s
cd /u01/app/11.2.0/grid/oui/bin/
./runInstaller.sh -updateNodeList ORACLE_HOME=$ORACLE_HOME "CLUSTER_NODES=racnod1" CRS=TRUE -silent -local
cd /u01/app/oracle/product/11.2.0/db_1/oui/bin/ 
./runInstaller.sh -updateNodeList ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1 CLUSTER_NODES=racnod1 -silent -local
 
--grid ��װǰ���
/home/grid/db/linux.x64_11gR2_grid/grid
./runcluvfy.sh stage -pre crsinst -n racnod1,racnod2 -fixup -verbose   racnod1��racnod2 --������

�ֱ������޸��ű�
sh /tmp/CVU_11.2.0.1.0_grid/runfixup.sh


[grid@node1 grid]$ ./runcluvfy.sh stage -pre crsinst -n node1,node2 -fixup -verbose
/bin/rm: cannot remove directory '/tmp/bootstrap': Operation not permitted
./runcluvfy.sh: line 99: /tmp/bootstrap/ouibootstrap.log: Permission denied
chown -R grid:oinstall /tmp/bootstrap
chmod -R 777 /tmp/bootstrap

./root.sh 
Running Oracle 11g root.sh script...

The following environment variables are set as:
    ORACLE_OWNER= grid
    ORACLE_HOME=  /u01/app/11.2.0/grid

Enter the full pathname of the local bin directory: [/usr/local/bin]: 
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root.sh script.
Now product-specific root actions will be performed.
2017-03-01 15:25:01: Parsing the host name
2017-03-01 15:25:01: Checking for super user privileges
2017-03-01 15:25:01: User has super user privileges
Using configuration parameter file: /u01/app/11.2.0/grid/crs/install/crsconfig_params
Creating trace directory
/u01/app/11.2.0/grid/bin/clscfg.bin: error while loading shared libraries: libcap.so.1: cannot open shared object file: No such file or directory
Failed to create keys in the OLR, rc = 127, 32512
OLR configuration failed 

rpm -ivh compat-libcap1-1.10-1.x86_64.rpm

cd /u01/app/11.2.0/grid/crs/install
./roothas.pl -delete -force -verbose
./rootcrs.pl -verbose -deconfig -force -lastnode


/u01/app/11.2.0/grid

������ DATA

sh /u01/app/11.2.0/grid/root.sh

su - oracle
dbca  --���ݿ�������

su - grid

asmcmd  --�����鴴��

dbca --�������ݿ⡣

--��ʾȺ����Դ
[grid@racnod1 ~]$ crsctl stat res -t
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources      --������Դ
--------------------------------------------------------------------------------
ora.DATA.dg
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                                                           
ora.LISTENER.lsnr
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
ora.asm
               ONLINE  ONLINE       racnod1                  Started             
               ONLINE  ONLINE       racnod2                  Started             
ora.gsd
               OFFLINE OFFLINE      racnod1                                      
               OFFLINE OFFLINE      racnod2                                      
ora.net1.network
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
ora.ons
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
ora.registry.acfs
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
--------------------------------------------------------------------------------
Cluster Resources   --��Ⱥ��Դ
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       racnod1                                      
ora.crsdb.db
      1        ONLINE  ONLINE       racnod2                  Open                
      2        ONLINE  ONLINE       racnod1                  Open                
ora.cvu
      1        ONLINE  ONLINE       racnod2                                                                                       
ora.oc4j
      1        ONLINE  ONLINE       racnod2                                                                                                                                        
ora.racnod1.vip
      1        ONLINE  ONLINE       racnod1                                      
ora.racnod2.vip
      1        ONLINE  ONLINE       racnod2                                      
ora.scan1.vip
      1        ONLINE  ONLINE       racnod1         
      
ora.LISTENER_SCAN1.lsnr��ora.scan1.vip����Ӧ��ϵ���֣���������ͬһ̨�����ϡ�

     
##oracle RAC������˳��
[root@racnode01 ~]# crsctl check crs 
CRS-4638: Oracle High Availability Services is online     
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online

1��OHAS���棬����Ⱥ�ĳ�ʼ����Դ�ͽ���
2��CSS���棬 ���𹹽���Ⱥ����֤��Ⱥ��һ����
3��CRS���棬 �������Ⱥ�ĸ���Ӧ�ó�����Դ
4��EVM���棬 �����ڼ�Ⱥ֮�䴫�ݼ�Ⱥ�¼�

ASM���ڵĴ����飬ͨ��Ȩ���ǣ�
brw-rw----   1 grid asmadmin   8,  32 Jun  4 15:03 sdc
brw-rw----   1 grid asmadmin   8,  48 Jun  4 15:03 sdd
brw-rw----   1 grid asmadmin   8,  64 Jun  4 15:00 sde

     
--�鿴ʵ����ڵ����ϸ��Ϣ
crsctl stat res -v 
      NAME=ora.FRA_DATA.dg
TYPE=ora.diskgroup.type
LAST_SERVER=racnod1
STATE=ONLINE on racnod1
TARGET=ONLINE
CARDINALITY_ID=ONLINE
CREATION_SEED=85
RESTART_COUNT=0
FAILURE_COUNT=0
FAILURE_HISTORY=
ID=ora.FRA_DATA.dg racnod1 1
INCARNATION=1
LAST_RESTART=NEVER
LAST_STATE_CHANGE=02/03/2018 14:38:20
STATE_DETAILS=
INTERNAL_STATE=STABLE

LAST_SERVER=racnod2
STATE=ONLINE on racnod2
TARGET=ONLINE
CARDINALITY_ID=ONLINE
CREATION_SEED=85
RESTART_COUNT=0
FAILURE_COUNT=0
FAILURE_HISTORY=
ID=ora.FRA_DATA.dg racnod2 1
INCARNATION=1
LAST_RESTART=NEVER
LAST_STATE_CHANGE=02/09/2018 18:34:14
STATE_DETAILS=
INTERNAL_STATE=STABLE

RAC��ڵ�ɱ�Ự 
alter system kill session 'SID,serial#,@1'  --ɱ��1�ڵ�Ľ��� 
alter system kill session 'SID,serial#,@2'  --ɱ��2�ڵ�Ľ��� 


###RAC����ʵ���͹ر�  srvctl --help ���� ��ora.��ͷ����Դ����srvctl
##�ر�����
--��OGG�Ľڵ㣬�ȹر�OGG�����н���
srvctl start/stop database -d crsdb
--Ϊ��֤�رյĿ�Щ��������һʵ���ر�
-ɱ���������ӵ�session
SELECT 'ALTER SYSTEM KILL SESSION ''' || T.SID || ',' || t."SERIAL#" ||''';' kill_command  FROM GV$SESSION T WHERE T.SQL_ID IN (SELECT t."SQL_ID" FROM gv$session t WHERE t."STATUS"='ACTIVE');
-ɱ��Զ�̵�session
ps �Cef|grep LOCAL=NO|grep �Cv grep|awk '{print $2}'|xargs kill -9
ps -ef | grep ora_ | awk -F " " '{ print "kill -9 "$2 }'|sh 
SELECT 'ALTER SYSTEM KILL SESSION ''' || T.SID || ',' || t."SERIAL#" ||''';' kill_command  FROM GV$SESSION T WHERE T.SQL_ID IN (SELECT t."SQL_ID" FROM gv$session t WHERE t."STATUS"='ACTIVE');
-ִ���������ڵ����һ�ر������ڵ����ݿ�
shutdown immediate

--��һ�رսڵ��crs����
-root�û�ִ��
crsctl stop crs

##��������
-������������Ĭ�ϻ��Զ�������ȥ������û�����������ֶ�������ط���
[root@racnod1 ~]# crsctl start crs     --�˹��̺��������ĵȴ�
CRS-4123: Oracle High Availability Services has been started.
--�澯��־
tail -f $ORACLE_HOME/log/racnod1/alertracnod1.log 
--crs��־
su - grid
tail -f  $ORACLE_HOME/log/racnod1/crsd/crsd.log   --ʵ���ֱ��¼����־
--�۲�����״̬
[root@racnod1 ~]# crsctl stat res -t
--�������ݿ�
srvctl start/stop database -d crsdb
-Ҳ������һ����
startup

 
--����oracle��Ⱥ
����ȷ��Oracle High Availability Services daemon (OHASD) is running on all the cluster nodes
crsctl start/stop cluster -all
crsctl start/stop cluster -n racnode1 racnode3

--ָ���ڵ�ر�
crsctl start cluster/stop -n racnode1 racnode4

--��������������̰���OHASD one node
crsctl start/stop crs

--����CRS-4639: Could not contact Oracle High Availability Services
crsctl start crs 

--���������������У����ܵ���crsctl stop crsʧ�ܣ���ǿ�ƹر�
crsctl stop crs -f

--���������־
GRID_HOME= /u01/app/11.2.0/grid/log
--������/u01/app/11.2.0.4/grid/log/dzswjnfdb2/crsd
--crs�澯��־
/u01/app/11.2.0/grid/log/racnod2/alertracnod2.log

About the Oracle Clusterware Component Log Files
In each of the following log file locations, hostname is the name of the node, for example, racnode2 and CRS_home is the directory in which the Oracle Clusterware software was installed.

The log files for the CRS daemon, crsd, can be found in the following directory:

GRID_HOME/log/hostname/crsd/
The log files for the CSS daemon, cssd, can be found in the following directory:

GRID_HOME/log/hostname/cssd/
The log files for the EVM daemon, evmd, can be found in the following directory:

GRID_HOME/log/hostname/evmd/
The log files for the Oracle Cluster Registry (OCR) can be found in the following directory:

GRID_HOME/log/hostname/client/

--ASM��־
ls $ORACLE_BASE/diag/asm/+asm/+ASM
alert  cdump  hm  incident  incpkg  ir  lck  metadata  stage  sweep  trace


--������ʱ��ռ�--���ڲ������ڴ�����ɵ��������  �ڵ㹲��һ����ռ�
gv$sort_segment --��ѯ��ǰ���������ε�ʹ�����   --��inst_id������ÿ��ʵ��������
gv$tempseg_usage --�鿴��ʱ�ε���ϸʹ����Ϣ
v$tempfile --ȷ��һ����ʱ��ռ��ʹ�õ���ʱ�ļ�
PS--��gv$sort_segment ��feed_extents��free_requests�����Ƕ���������Ӧ������������ʱ��ռ�

--��������������־ --Ϊ��ʵ���ָ������������������־���ڹ���洢��
v$log 
v$logfile

###RAC�п����鵵ģʽ
--�ڵ�1
--�޸Ĺ鵵��ASM�浵·��
alter diskgroup DATA add directory '+DATA/ARCHIVELOG';    --DATA ����������
alter system set log_archive_dest='+DATA/ARCHIVELOG' scope=spfile sid='*';
alter system set cluster_database=false scope=spfile sid='crsdb1';

--�ر����з��ʵ����ݿ�ʵ��
srvctl stop database -d crsdb
srvctl status database -d crsdb

--�鵵���� �ڵ�1
���ݲ����ļ�
create pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/pfile.ora_bak' from spfile;

--�ڵ�1����ʵ��
startup mount 
alter database archivelog;
--ʵ����������ΪTRUE
alter system set cluster_database=true scope=spfile sid='crsdb1';
--�رձ������ݿ�ʵ��
shutdown immediate
--�������нڵ����ݿ�
srvctl start database -d crsdb

--������������
show parameter db_recovery
db_recovery_file_dest                string      +DATAFILE
db_recovery_file_dest_size           big integer 5727M
------------------------------------ ----------- ------------------------------
show parameter flashback
db_flashback_retention_target        integer     1440   --��λ�����ӣ� ����һ���������־

--��������
alter system set cluster_database=false scope=spfile sid='srcdb1';
srvctl stop database -d srcdb
startup mount 
alter database flashback on
shutdown immediate
srvctl start database -d srcdb

--����Ϊĳ����ռ���������
startup mount 
alter tablespace user flashback on;
alter database open;

###ʹ��srvctl ���ù���Ϳ������ݿ�
srvctl --help    srvctl status service -h �鿴�����Ĳ���
--��ʾ�������ݿ�
srvctl config database
crsdb
--��ʾ���ݿ����ϸ��Ϣ
srvctl config database -d crsdb 
--�������ر�����ʵ��
srvctl stop/start/status database -d crsdb

srvctl stop/start/status nodeapps -n srcdb1

--���ݿ�������
--�����ռ�
Ϊ�˼���oracle RAC �����в��������ã����鿪��ASSM���Զ��οռ����
SELECT t.TABLESPACE_NAME,t.SEGMENT_SPACE_MANAGEMENT FROM dba_tablespaces t;
MANUAL--�ֶ�
AUTO--�Զ�
--��������
Ϊ�˷�ֹB������������ã�����ʹ�÷��������������������������
--����
���ڹ���RAC�еĹ����������ͬһ�ֹ�����ʹ����ͬ�ķ���
v$services
--CLB_GOAL ��ʾ�����Ŀ�� long ��ʱ�����������׼�� short �϶̵����ݿ�����

--TAF ����ת�Ʋ���

--OCR ���漯Ⱥ��ע����Ϣ
crs����ʱ�����ȷ���OCR�е���Ϣ


--RAC�ر�˳��
1���ر����ݿ�ʵ��
srvctl stop database -d crsdb
2���رմ����� --ʵ�黷�������������飬DATA OCR(���Ⱥ��ע���ļ����ٲ���)
srvctl stop diskgroup -g DATA 
srvctl stop diskgroup -g OCR --��������һ���ڵ��ϣ��ӽڵ��Ϲر�
3���ر�ASM���Զ��ļ�����
crsctl stop resource ora.registry.acfs
4���ر�ASM --�鿴�ر�״̬ crsctl  stat resource -t  crs_stat -t  
srvctl stop asm -o immediate --ʱ������

--����
srvctl start asm -o open 
srvctl status asm
srvctl start database -d crsdb

--LISTENER_SCAN1�Ŀ����͹ر� scanIP ת��
srvctl stop scan_listener 
srvctl start scan_listener -n racnod1 --��ѡ�����нڵ�

--Ⱥ���ļ��Զ���������
[grid@racnod1 ~]$ ps -ef | grep crsd.bin
root      3073     1  1 20:58 ?        00:00:07 /u01/app/11.2.0/grid/bin/crsd.bin reboot
grid      4583  3045  0 21:05 pts/0    00:00:00 grep crsd.bin
[grid@racnod1 ~]$ ps -ef | grep cssd.bin
grid      2602     1  1 20:57 ?        00:00:06 /u01/app/11.2.0/grid/bin/ocssd.bin 
grid      4653  3045  0 21:06 pts/0    00:00:00 grep cssd.bin
[grid@racnod1 ~]$ ps -ef | grep evmd.bin
grid      2810     1  0 20:57 ?        00:00:02 /u01/app/11.2.0/grid/bin/evmd.bin
grid      4704  3045  0 21:06 pts/0    00:00:00 grep evmd.bin

--��鼯Ⱥ״̬
[grid@racnod1 ~]$ crsctl check cluster
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online

--���CRS״̬
[grid@racnod1 ~]$ crsctl check crs
CRS-4638: Oracle High Availability Services is online
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online

--��ʾ��Ⱥ��Դ״̬
[grid@racnod1 ~]$ crsctl stat res -t ���� crs_stat -t
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources
--------------------------------------------------------------------------------
ora.DATA.dg
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
ora.LISTENER.lsnr
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
ora.OCR.dg
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
ora.asm
               ONLINE  ONLINE       racnod1                  Started             
               ONLINE  ONLINE       racnod2                  Started             
ora.gsd
               OFFLINE OFFLINE      racnod1                                      
               OFFLINE OFFLINE      racnod2                                      
ora.net1.network
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
ora.ons
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
ora.registry.acfs
               ONLINE  ONLINE       racnod1                                      
               ONLINE  ONLINE       racnod2                                      
--------------------------------------------------------------------------------
Cluster Resources
--------------------------------------------------------------------------------
ora.LISTENER_SCAN1.lsnr
      1        ONLINE  ONLINE       racnod1                                      
ora.crsdb.db
      1        ONLINE  ONLINE       racnod2                  Open                
      2        ONLINE  ONLINE       racnod1                  Open                
ora.cvu
      1        ONLINE  ONLINE       racnod2                                      
ora.oc4j
      1        ONLINE  ONLINE       racnod2                                      
ora.racnod1.vip
      1        ONLINE  ONLINE       racnod1                                      
ora.racnod2.vip
      1        ONLINE  ONLINE       racnod2                                      
ora.scan1.vip
      1        ONLINE  ONLINE       racnod1                           
      
--OCR����
--���OCR������
[grid@racnod1 bin]$ ocrcheck
Status of Oracle Cluster Registry is as follows :
         Version                  :          3
         Total space (kbytes)     :     262120
         Used space (kbytes)      :       3088
         Available space (kbytes) :     259032
         ID                       : 1942533950
         Device/File Name         :       +OCR
                                    Device/File integrity check succeeded

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

         Cluster registry integrity check succeeded

         Logical corruption check bypassed due to non-privileged user
         
--OCR����
--�鿴��ǰ�ı��� root�û��鿴
[root@racnod2 ~]# ocrconfig -showbackup

racnod2     2017/03/18 05:06:13     /u01/app/11.2.0/grid/cdata/rac-cluster/backup00.ocr

racnod2     2017/03/18 05:06:13     /u01/app/11.2.0/grid/cdata/rac-cluster/day.ocr

racnod2     2017/03/18 05:06:13     /u01/app/11.2.0/grid/cdata/rac-cluster/week.ocr

racnod2     2017/03/19 23:36:04     /u01/app/11.2.0/grid/cdata/rac-cluster/backup_20170319_233604.ocr

--�ֶ�ִ�б���
[root@racnod2 ~]# ocrconfig -manualbackup

racnod2     2017/03/19 23:41:06     /u01/app/11.2.0/grid/cdata/rac-cluster/backup_20170319_234106.ocr

--�ȴ�ʱ��
��һ���Ựû������ʹ��CPUʱ���������ڵȴ�ĳһ����Դ�������ڵȴ�ĳһ��������ɣ�Ҳ���ܾ����ڵȴ���һ���Ĺ�������������Щ�йصģ�����Ϊ�ȴ�ʱ�䡣

--��ʵ����ASM�޷�����
http://blog.csdn.net/wuweilong/article/details/22309235


##oracle_RAC�����޸�
1��oracle�Ĳ����ļ�������+ASM�С�
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORA_DATA/crsdb/spfilecrsdb.ora

2���ڵ�һ���ݲ����ļ�
SQL> create pfile='/tmp/spfile_bak.ora' from spfile;

3������ļ�
[oracle@racnode01 db_1]$ ll /tmp/sfile_bak.ora 
-rw-r--r-- 1 oracle asmadmin 1569 Sep  6 14:43 /tmp/sfile_bak.ora

3���ڵ�һ�޸Ĳ���
SQL> ALTER SYSTEM SET processes =500 scope=spfile sid='*';  

4�������ڵ�һ�����������Ƿ�����޸���Ч
SQL> shutdown immediate
SQL> startup 

-�鿴�޸ĵĲ����Ƿ�ɹ�
SQL> show parameter processes
processes                            integer     500

5����֤�ڵ�һ������ȷ������£������ڵ��

6���鿴�����ڵ�Ĳ����ļ����Ƿ�ָ����洢�Ĳ����ļ�
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORA_DATA/crsdb/spfilecrsdb.ora

PS�����������ű�
SQL> show parameter names

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
global_names                         boolean     FALSE
service_names                        string      racdb

[oracle@racnode01 ~]$ srvctl stop database -d racdb
[oracle@racnode01 ~]$ srvctl start database -d racdb  
[oracle@racnode01 ~]$ srvctl status database -d racdb     
Instance racdb1 is running on node racnode01
Instance racdb2 is running on node racnode02


###oracle��������
#�������޸�ʧ��ʱ��oracle���ݿ�϶��������������ģ���ʱ�ȹرսڵ�һ�ڵ�����ݿ�
1���ڵ�һ
SQL> shutdown immediate

2���ӱ����лָ���Ҳ����ֱ���޸�/tmp/spfile_bak.ora�ļ����Ѳ�������ȷ��Ȼ��������
create spfile='+DATA/racdb/spfileracdb.ora' from pfile='/tmp/spfile_bak.ora';
3���������ݿ�
SQL> startup
4��ȷ����ȷ���������нڵ�

##ָ�������ļ����� ---ֻ��ָ����̬�����ļ�
startup pfile='xxxxx'
startup pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initsxfxdb.ora_bak';

-------spfile˵��
--��������˵��
��[oracle@racnod2 dbs]$ cd $ORACLE_HOME/dbs 
hc_crsdb2.dat  initcrsdb2.ora  init.ora  orapwcrsdb2  
--initcrsdb2.ora ��̬�����ļ������Ա༭�޸�
[oracle@racnod2 dbs]$ more initcrsdb2.ora 
SPFILE='+ORA_DATA/crsdb/spfilecrsdb.ora'   
--Ҳ����oracle�ȴӱ��ص�spfileSID.ora�������Ҳ�������initcrsdb2.ora������ļ�ָ����洢�е�spfile

��RAC�����У����ڱ��ش���spfileSID.ora��ʱ��ʵ����ӱ���������
���ݿ�ӱ��ص�spfileSID.ora��������ΪspfileSID.ora�����ȼ�����initSID.ora��
SQL> show parameter spfile;
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /u01/app/oracle/product/11.2.0
                                                 /db_1/dbs/spfilecrsdb1.ora
--��Ҫ��������mv spfilecrsdb1.ora spfilecrsdb1.ora_bak Ҫ��Ȼ���ִӱ���spfile������

###RAC �޸Ĳ���
Ĭ������£�����SIDֻ���ڱ�ʵ����Ч��������ô��ϲ���
--�����ڵ�ͬʱ��Ч
ALTER SYSTEM SET UNDO_RETENTION = 1800 scope=both sid='*';   
--�ֱ��޸ĸ����ڵ�
ALTER SYSTEM SET UNDO_RETENTION = 1800 scope=both sid='sngsnfdb1';
ALTER SYSTEM SET UNDO_RETENTION = 1800 scope=both sid='sngsnfdb2';
--���޸�SGA��ʱ�������ڵ�Ĵ�С���Բ�ͬ�����ҿ��Թ���һ��spfile
alter system set sga_max_size=50 scope=spfile sid='sngsnfdb1';
alter system set sga_target=50 scope=spfile sid='sngsnfdb1';
alter system set sga_max_size=40 scope=spfile sid='sngsnfdb2';
alter system set sga_target=40 scope=spfile sid='sngsnfdb2';

--db_files�޸�
SQL> show parameter db_files

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_files                             integer     2000

alter system set db_files=2500 scope=spfile sid='*';





--QA
1����ASMCA ����������ʱ�����ִ�������.
sqlplus / as sysasm
alter system set asm_diskstring='/dev/asm-disk*'; 
show parameter disk

2�����ڰ�װĿ¼�Ĺ滮����������dbcaʱ ���ܷ���ASM�����顣
/u01/app/11.2.0/grid/bin 
ls -al oracle
-rwsrwsrwx. 1 grid oinstall 209914513 Apr 12 19:17 oracle
chmod 6777 oracle
usermod -a -G asmdba oracle
usermod -a -G dba oracle
[root@hostoracle bin]# id oracle
uid=1101(oracle) gid=1000(oinstall) groups=1000(oinstall),1020(asmadmin),1021(asmdba),1031(dba)


--VNC��װ
[root@host01 home]# rpm -ivh tigervnc-server-1.0.90-0.17.20110314svn4359.el6.x86_64.rpm 
warning: tigervnc-server-1.0.90-0.17.20110314svn4359.el6.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID ec551f03: NOKEY
Preparing...                ########################################### [100%]
   1:tigervnc-server        ########################################### [100%]
vi /etc/sysconfig/vncservers 
--�����������
# VNCSERVERS="2:myusername"
# VNCSERVERARGS[2]="-geometry 800x600 -nolisten tcp -localhost"
  VNCSERVERS="1:root"
  VNCSERVERARGS[1]="-geometry 800x600 -nolisten tcp -localhost"

##ohasd��������
/etc/init.d/ohasd start/stop 

###��Ⱥ������VIPƮ��
ע�⣺
1��VIP��ͨ���ڵ��������ģ����Ƿ�������
2������ͨ���������ص�listener������VIP
3������crs�������ڵ�����ô���������ᰴ��/etc/hosts �¹滮��IPȥ����
srvctl start listener -n racnod1/racnod2
ora.racnod1.vip
      1        ONLINE  ONLINE       racnod1                                      
ora.racnod2.vip
      1        ONLINE  ONLINE       racnod2  
����������£��������VIP�Ƿ����������ڵ��ϵģ���һ���ڵ����ʱ���Ż�Ʈ�Ƶ���һ���ڵ��ϡ�
--�ڵ�һ
eth0      Link encap:Ethernet  HWaddr 00:0C:29:37:13:93  
          inet addr:10.10.8.49  Bcast:10.10.8.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe37:1393/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2608540 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2861630 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:5019116799 (4.6 GiB)  TX bytes:1758110130 (1.6 GiB)

eth0:1    Link encap:Ethernet  HWaddr 00:0C:29:37:13:93              --VIP����������
          inet addr:10.10.8.51  Bcast:10.10.8.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
--�ֶ������л�
ifconfig eth0:1 down  
֮���������IP��������ڵ�����ʧ��Ʈ�Ƶ��˽ڵ���ϡ�
eth0      Link encap:Ethernet  HWaddr 00:0C:29:38:9B:55  
          inet addr:10.10.8.50  Bcast:10.10.8.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe38:9b55/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:640400 errors:0 dropped:0 overruns:0 frame:0
          TX packets:700537 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1211639086 (1.1 GiB)  TX bytes:383966911 (366.1 MiB)

eth0:1    Link encap:Ethernet  HWaddr 00:0C:29:38:9B:55            --�ڵ����VIP
          inet addr:10.10.8.52  Bcast:10.10.8.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

eth0:2    Link encap:Ethernet  HWaddr 00:0C:29:38:9B:55            --VIP �ڵ�һ�ϵ�VIP
          inet addr:10.10.8.51  Bcast:10.10.8.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

--crsctl stat res -t 
ora.LISTENER.lsnr
               ONLINE  OFFLINE      racnod1    --�ڵ�һ����offline                                      
               ONLINE  ONLINE       racnod2
           
ora.racnod1.vip
      1        ONLINE  INTERMEDIATE racnod2                  FAILED OVER   --�ڵ�һ��VIPת���ڵ����  
ora.racnod2.vip
      1        ONLINE  ONLINE       racnod2         
                          
��ʱ����SCAN_IP ȥ�������ݿ⣬�Ǻ��ѱ����䵽�ڵ�һ�ϵ�

--RAC�ڵ�����
-�ڵ�һ
[grid@racnod1 admin]$ more listener.ora
LISTENER=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER))))            # line added by Agent
LISTENER_SCAN1=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1))))                # line added by Agent
ENABLE_GLOBAL_DYNAMIC_ENDPOINT_LISTENER_SCAN1=ON                # line added by Agent
ENABLE_GLOBAL_DYNAMIC_ENDPOINT_LISTENER=ON              # line added by Agent
[grid@racnod1 admin]$ more endpoints_listener.ora 
LISTENER_RACNOD1=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=racnod1-vip)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.10.8.49)(PORT=1521)(IP=FIRST))))               # line added 
by Agent   --���õ�VIP��ַ
-�ڵ��
[root@racnod2 admin]# more listener.ora
LISTENER_SCAN1=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1))))                # line added by Agent
LISTENER=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER))))            # line added by Agent
ENABLE_GLOBAL_DYNAMIC_ENDPOINT_LISTENER=ON              # line added by Agent
ENABLE_GLOBAL_DYNAMIC_ENDPOINT_LISTENER_SCAN1=ON                # line added by Agent
[root@racnod2 admin]# more endpoints_listener.ora 
LISTENER_RACNOD2=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=racnod2-vip)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.10.8.50)(PORT=1521)(IP=FIRST))))               # line added 
by Agent  --���õ�VIP��ַ

##��Ⱥ����##
��ѯ��Ⱥ״̬
crsctl check cluster -all
�����Դ״̬
crsctl status resource -t
���Ķ�ջ״̬
crsctl status res -t -int
�鿴��Ⱥ�¶���������Щ���ݿ�
srvctl config
�鿴RAC���ݿ�ľ���������Ϣ
srvctl config database -db racdb_icn1gb
RAC���ݿ�����״̬
srvctl status database -db racdb_icn1gb
�鿴����״̬
srvctl status listener
�鿴scan����״̬
srvctl status scan_listener
��ӷ���
srvctl add service -db racdb_icn1gb -service srv_abc -r racdb1 -a racdb2
��������
srvctl start service -db racdb_icn1gb -service srv_abc
�鿴ָ�������״̬
srvctl status service -db racdb_icn1gb -service srv_abc
�鿴���ݿ������еķ���״̬
srvctl status service -db racdb_icn1gb
�ƶ�����
srvctl relocate service -db racdb_icnfb -service srv_test -oldinst racdb1 -newinst racdb2
ֹͣ���ݿ�
srvctl stop database -db racdb_icn1gb -o immediate
�������ݿ�
srvctl start database -db racdb_icn1gb
ֹͣʵ��
srvctl stop instance -db racdb_icn1gb -i racdb1 -o immediate
srvctl stop instance -db racdb_icn1gb -i racdb1 -o immediate -force
����ʵ��
srvctl start instance -db racdb_icn1gb -i racdb1
�鿴ASMģʽ
asmcmd showclustermode
��鼯Ⱥ��������״̬
crsctl config crs
��ֹ��Ⱥ��������
crsctl disable crs
ֹͣ��Ⱥ��
crsctl start crs
��Ⱥ����־
$ORACLE_BASE/diag/crs/${������}/crstrace
ASM��־
$ORACLE_BASE/diag/asm/+asm/${ASMʵ����}/trace