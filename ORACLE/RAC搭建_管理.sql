ps –ef|grep LOCAL=NO|grep –v grep|awk '{print $2}'|xargs kill -9
--安装oracle linux ,切记一定在最后一步安装图形界面组件，desktop;
Desktops
Desktop
Desktop Platform
Fonts
General Purpose Desktop
Graphical Administration Tools
X Windows System

1、swap要与内存的大小相同

nod1和nod2分别执行
关闭防火墙
在rac1 和rac2 2个节点上分别执行如下语句：
 
[root@rac01 ~]# service iptables stop
[root@rac01 ~]# chkconfig iptables off
[root@rac01 ~]# chkconfig iptables --list
iptables 0:off 1:off 2:off 3:off 4:off 5:off 6:off
 
chkconfig iptables off ---永久
service iptables stop ---临时
/etc/init.d/iptables status ----会得到一系列信息，说明防火墙开着。
/etc/rc.d/init.d/iptables stop ----------关闭防火墙

--关闭NTP服务
--并手动设置两个节点时间一致
[root@node2 ~]# service ntpd stop  
Shutting down ntpd:                                        [FAILED]  
[root@node2 ~]# chkconfig ntpd off  
[root@node2 ~]# mv /etc/ntp.conf /etc/ntp.conf.original  
[root@node2 ~]# rm -rf /var/run/ntpd.pid  

--oracle为了简化时间的同步，在安装grid时，有了CTSS服务。
#当集群中有NTP服务器时，ctss是以一个观察者（Observer mode）的身份来监控，不一致的时间会写入到alert中，但不会主动调整。
root@dzswjnfdb1:/u01/app/11.2.0.4/grid/bin# ./crsctl check ctss
CRS-4700: The Cluster Time Synchronization Service is in Observer mode.
#当关掉NTP时，CTSS就是主动模式（Active mode），来调整主节点的时间同步。
[root@rac2 ~]# crsctl check ctss
CRS-4701: The Cluster Time Synchronization Service is in Active mode

关闭内核防火墙
vi /etc/sysconfig/selinux
SELINUX=disabled

--修改主机名
#centos 6.x
[root@racnod1 ~]# more /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=racnod1

#centos 7.x 
hostnamectl set-hostname racnode01
--脚本格式转换
yum install -y  dos2unix
dos2unix *


--修改hosts文件
vi /etc/hosts文件
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


--创建用户组及授权<认真看好目录的规划，否则会有权限的问题>
useradd -u 1100 -g oinstall -G asmadmin,asmdba,asmoper,oper,dba grid
useradd -u 1101 -g oinstall -G dba,asmdba,oper oracle
mkdir -p /u01/app/11.2.0/grid
mkdir -p /u01/app/grid
mkdir -p /u01/app/oracle
chown -R grid:oinstall /u01
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/

为oracle及grid设置密码
passwd oracle    --oracle123
passwd grid      --grid123

--挂载光盘
cd /etc/yum.repos.d/
mv public-yum-ol6.repo public-yum-ol6.repo_bak
vi /etc/yum.repos.d/dvd.repo
[dvd]
name=dvd
baseurl=file:///media/OL6.7\ x86_64\ Disc\ 1\ 20150728/
gpgcheck=0
enabled=1

--检查YUM配置
yum clean all
yum makecache
yum install oracle-rdbms-server-11gR2-preinstall-1.0-6.el6


--配置限制文件--可以在grid界面中进行fix修复
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


5. 配置共享存储
方法1：
--99-oracle-asmdevices.rules 
在做完多路径后，会在下面生成dm-*开头的聚合盘
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
--去处重复的记录
KERNEL=="dm-*", BUS=="block", PROGRAM=="/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/$name",RESULT=="14f504e46494c455259516a6c326d2d4a356b6f2d47486e75",NAME="asm-diskb",OWNER="grid",GROUP="asmadmin",MODE="0660"
KERNEL=="dm-*", BUS=="block", PROGRAM=="/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/$name",RESULT=="14f504e46494c45526132504e41652d334b636e2d4a307772",NAME="asm-diskd",OWNER="grid",GROUP="asmadmin",MODE="0660"
KERNEL=="dm-*", BUS=="block", PROGRAM=="/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/$name",RESULT=="14f504e46494c45524d57715571322d4a3064792d486a364e",NAME="asm-diskf",OWNER="grid",GROUP="asmadmin",MODE="0660"

--exsi共享盘
for i in b c;
do
echo "KERNEL==\"sd*\", BUS==\"scsi\",PROGRAM==\"/sbin/scsi_id -g -u /dev/\$name\", RESULT==\"`/sbin/scsi_id -g -u /dev/sd$i`\", NAME=\"asm-disk$i\", OWNER=\"grid\",GROUP=\"asmadmin\", MODE=\"0660\"" >> /etc/udev/rules.d/99-oracle-asmdevices.rules
done


/sbin/partprobe /dev/sdb1  --加载变动
/sbin/start_udev

[root@racnod1 mapper]# ll /dev/asm*
brw-rw----. 1 grid asmadmin 253, 2 Dec 26 04:04 /dev/asm-diskb
brw-rw----. 1 grid asmadmin 253, 4 Dec 26 04:04 /dev/asm-diskd
brw-rw----. 1 grid asmadmin 253, 3 Dec 26 03:40 /dev/asm-diskf
brw-rw----. 1 grid asmadmin 253, 3 Dec 26 04:04 /dev/asm-diskg



--配置oracle及grid的配置文件
su - grid
vi .bash_profile
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_SID=+ASM1  # RAC1  --每个节点一条
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
export ORACLE_SID=crsdb1  # RAC1  ---每个节点一条
export ORACLE_SID=crsdb2  # RAC2
export ORACLE_UNQNAME=crsdb
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export TNS_ADMIN=$ORACLE_HOME/network/admin
export PATH=/usr/sbin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib


关闭不需要的服务
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


--开始安装grid
为了出现OUI图形化安装，建议安装VNC
在自带的光盘中安装：
cd /media/OL6.7\ x86_64\ Disc\ 1\ 20150728/Packages/
rpm -ivh tigervnc-server-1.1.0-16.el6.x86_64.rpm

-->参照图形安装文档


####################################以下为参考内容###################################

--用asmca创建ASM磁盘组
--安装数据库后，用dbca创建数据库

--SSH互信--可以在grid中自动安装
以oracle身份在每个节点执行
 
为ssh和scp创建连接，检验是否存在：
ls -l /usr/local/bin/ssh
ls -l /usr/local/bin/scp
不存在则创建
/bin/ln -s /usr/bin/ssh /usr/local/bin/ssh
/bin/ln -s /usr/bin/scp /usr/local/bin/scp
 

 
为oracle用户配置SSH：
生成用户的公匙和私匙，在每个节点上执行：
su – oracle
 mkdir ~/.ssh
 cd .ssh
 ssh-keygen -t rsa
 ssh-keygen -t dsa
 
在节点1上，把所有节点的authorized_keys文件合成一个，再用这个文件覆盖各个节点.ssh下的同名文件： 
su - oracle
 touch authorized_keys
 ssh RACNOD1.localdomain cat /home/oracle/.ssh/id_rsa.pub >> authorized_keys
 ssh RACNOD2.localdomain cat /home/oracle/.ssh/id_rsa.pub >> authorized_keys
 ssh RACNOD1.localdomain cat /home/oracle/.ssh/id_dsa.pub >> authorized_keys
 ssh RACNOD2.localdomain cat /home/oracle/.ssh/id_dsa.pub >> authorized_keys
[oracle@rac01 ~]# scp authorized_keys RACNOD2.localdomain:/home/oracle/.ssh/

分别在每个节点上执行检验是否成功:
[oracle@rac01 ~]# ssh RACNOD1.localdomain date
[oracle@rac01 ~]# ssh RACNOD2.localdomain date

--为GRID创建
su – grid
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


--为集群增加节点

grid> cluvfy stage -pre nodeadd -n racnod3  --增加节点条件检查
Check for consistency of root user's primary group passed

Checking OCR integrity...

OCR integrity check passed

Checking Oracle Cluster Voting Disk configuration...

Oracle Cluster Voting Disk configuration check passed
Time zone consistency check passed'
--添加grid
sh /u01/app/11.2.0/grid/oui/bin/addNode.sh "CLUSTER_NEW_NODES={racnod3}" "CLUSTER_NEW_VIRTUAL_HOSTNAMES={racnod3-vip}"
--添加oracle
sh /u01/app/oracle/product/11.2.0/db_1/oui/bin/addNode.sh "CLUSTER_NEW_NODES={racnod3}"
./addNode.sh -silent “CLUSTER_NEW_NODES={racnod3}” “CLUSTER_NEW_VIRTUAL_HOSTNAMES={racnod3-vip}”
跳过自检
export IGNORE_PREADDNODE_CHECKS=Y 

srvctl config database -d crsdb
srvctl stop nodeapps -n racnod2 -f 
sh /u01/app/oracle/product/11.2.0/db_1/oui/bin/runInstaller.sh -updateNodeList ORACLE_HOME=$ORACLE_HOME “CLUSTER_NODES={racnod2}” -local
--CRS 配置文件
/u01/app/oraInventory/ContentsXML/inventory.xml


/u01/app/11.2.0/grid/bin/crsctl delete node -n racnod2
olsnodes -t -s
cd /u01/app/11.2.0/grid/oui/bin/
./runInstaller.sh -updateNodeList ORACLE_HOME=$ORACLE_HOME "CLUSTER_NODES=racnod1" CRS=TRUE -silent -local
cd /u01/app/oracle/product/11.2.0/db_1/oui/bin/ 
./runInstaller.sh -updateNodeList ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1 CLUSTER_NODES=racnod1 -silent -local
 
--grid 安装前检查
/home/grid/db/linux.x64_11gR2_grid/grid
./runcluvfy.sh stage -pre crsinst -n racnod1,racnod2 -fixup -verbose   racnod1，racnod2 --主机名

分别运行修复脚本
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

磁盘组 DATA

sh /u01/app/11.2.0/grid/root.sh

su - oracle
dbca  --数据库配置向导

su - grid

asmcmd  --磁盘组创建

dbca --创建数据库。

--显示群集资源
[grid@racnod1 ~]$ crsctl stat res -t
--------------------------------------------------------------------------------
NAME           TARGET  STATE        SERVER                   STATE_DETAILS       
--------------------------------------------------------------------------------
Local Resources      --本地资源
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
Cluster Resources   --集群资源
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
      
ora.LISTENER_SCAN1.lsnr与ora.scan1.vip，对应关系出现，并出现在同一台主机上。

     
##oracle RAC启动的顺序
[root@racnode01 ~]# crsctl check crs 
CRS-4638: Oracle High Availability Services is online     
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online

1、OHAS层面，负责集群的初始化资源和进程
2、CSS层面， 负责构建集群并保证集群的一致性
3、CRS层面， 负责管理集群的各种应用程序资源
4、EVM层面， 负责在集群之间传递集群事件

ASM挂在的磁盘组，通常权限是：
brw-rw----   1 grid asmadmin   8,  32 Jun  4 15:03 sdc
brw-rw----   1 grid asmadmin   8,  48 Jun  4 15:03 sdd
brw-rw----   1 grid asmadmin   8,  64 Jun  4 15:00 sde

     
--查看实例与节点的详细信息
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

RAC跨节点杀会话 
alter system kill session 'SID,serial#,@1'  --杀掉1节点的进程 
alter system kill session 'SID,serial#,@2'  --杀掉2节点的进程 


###RAC启动实例和关闭  srvctl --help 帮助 以ora.开头的资源都用srvctl
##关闭流程
--有OGG的节点，先关闭OGG的所有进程
srvctl start/stop database -d crsdb
--为保证关闭的快些，建议逐一实例关闭
-杀掉正在连接的session
SELECT 'ALTER SYSTEM KILL SESSION ''' || T.SID || ',' || t."SERIAL#" ||''';' kill_command  FROM GV$SESSION T WHERE T.SQL_ID IN (SELECT t."SQL_ID" FROM gv$session t WHERE t."STATUS"='ACTIVE');
-杀掉远程的session
ps –ef|grep LOCAL=NO|grep –v grep|awk '{print $2}'|xargs kill -9
ps -ef | grep ora_ | awk -F " " '{ print "kill -9 "$2 }'|sh 
SELECT 'ALTER SYSTEM KILL SESSION ''' || T.SID || ',' || t."SERIAL#" ||''';' kill_command  FROM GV$SESSION T WHERE T.SQL_ID IN (SELECT t."SQL_ID" FROM gv$session t WHERE t."STATUS"='ACTIVE');
-执行完两个节点后，逐一关闭两个节点数据库
shutdown immediate

--逐一关闭节点的crs服务
-root用户执行
crsctl stop crs

##启动流程
-服务器启动后，默认会自动启动进去服务，若没有启动，请手动启动相关服务。
[root@racnod1 ~]# crsctl start crs     --此过程很慢，耐心等待
CRS-4123: Oracle High Availability Services has been started.
--告警日志
tail -f $ORACLE_HOME/log/racnod1/alertracnod1.log 
--crs日志
su - grid
tail -f  $ORACLE_HOME/log/racnod1/crsd/crsd.log   --实例分别记录的日志
--观察启动状态
[root@racnod1 ~]# crsctl stat res -t
--启动数据库
srvctl start/stop database -d crsdb
-也可以逐一启动
startup

 
--启动oracle集群
首先确保Oracle High Availability Services daemon (OHASD) is running on all the cluster nodes
crsctl start/stop cluster -all
crsctl start/stop cluster -n racnode1 racnode3

--指定节点关闭
crsctl start cluster/stop -n racnode1 racnode4

--启动所有组件进程包括OHASD one node
crsctl start/stop crs

--出现CRS-4639: Could not contact Oracle High Availability Services
crsctl start crs 

--如果有组件正在运行，可能导致crsctl stop crs失败，需强制关闭
crsctl stop crs -f

--各个组件日志
GRID_HOME= /u01/app/11.2.0/grid/log
--举例：/u01/app/11.2.0.4/grid/log/dzswjnfdb2/crsd
--crs告警日志
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

--ASM日志
ls $ORACLE_BASE/diag/asm/+asm/+ASM
alert  cdump  hm  incident  incpkg  ir  lck  metadata  stage  sweep  trace


--管理临时表空间--用于不能在内存中完成的排序操作  节点共享一个表空间
gv$sort_segment --查询当前和最大排序段的使用情况   --用inst_id来分离每个实例的数据
gv$tempseg_usage --查看临时段的详细使用信息
v$tempfile --确定一个临时表空间的使用的临时文件
PS--当gv$sort_segment 的feed_extents和free_requests若他们定期增长，应当考虑增大临时表空间

--管理联机重做日志 --为了实例恢复，建议把联机重做日志放在共享存储中
v$log 
v$logfile

###RAC中开启归档模式
--节点1
--修改归档的ASM存档路径
alter diskgroup DATA add directory '+DATA/ARCHIVELOG';    --DATA 磁盘组名称
alter system set log_archive_dest='+DATA/ARCHIVELOG' scope=spfile sid='*';
alter system set cluster_database=false scope=spfile sid='crsdb1';

--关闭所有访问的数据库实例
srvctl stop database -d crsdb
srvctl status database -d crsdb

--归档开启 节点1
备份参数文件
create pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/pfile.ora_bak' from spfile;

--节点1启动实例
startup mount 
alter database archivelog;
--实例重新设置为TRUE
alter system set cluster_database=true scope=spfile sid='crsdb1';
--关闭本地数据库实例
shutdown immediate
--启动所有节点数据库
srvctl start database -d crsdb

--管理闪回区域
show parameter db_recovery
db_recovery_file_dest                string      +DATAFILE
db_recovery_file_dest_size           big integer 5727M
------------------------------------ ----------- ------------------------------
show parameter flashback
db_flashback_retention_target        integer     1440   --单位（分钟） 保留一天的闪回日志

--开启闪回
alter system set cluster_database=false scope=spfile sid='srcdb1';
srvctl stop database -d srcdb
startup mount 
alter database flashback on
shutdown immediate
srvctl start database -d srcdb

--可以为某个表空间设置闪回
startup mount 
alter tablespace user flashback on;
alter database open;

###使用srvctl 配置管理和控制数据库
srvctl --help    srvctl status service -h 查看后续的参数
--显示配置数据库
srvctl config database
crsdb
--显示数据库的详细信息
srvctl config database -d crsdb 
--启动、关闭所有实例
srvctl stop/start/status database -d crsdb

srvctl stop/start/status nodeapps -n srcdb1

--数据库对象管理
--管理表空间
为了减少oracle RAC 环境中产生的争用，建议开启ASSM（自动段空间管理）
SELECT t.TABLESPACE_NAME,t.SEGMENT_SPACE_MANAGEMENT FROM dba_tablespaces t;
MANUAL--手动
AUTO--自动
--管理索引
为了防止B树索引块的争用，建议使用分区索引或反向键索引来避免争用
--服务
用于管理RAC中的工作量，针对同一种工作量使用相同的服务。
v$services
--CLB_GOAL 表示服务的目标 long 长时间生存的链接准备 short 较短的数据库链接

--TAF 故障转移策略

--OCR 保存集群的注册信息
crs启动时，会先访问OCR中的信息


--RAC关闭顺序
1、关闭数据库实例
srvctl stop database -d crsdb
2、关闭磁盘组 --实验环境有两个磁盘组，DATA OCR(存放群集注册文集及仲裁盘)
srvctl stop diskgroup -g DATA 
srvctl stop diskgroup -g OCR --会运行在一个节点上，从节点上关闭
3、关闭ASM的自动文件管理
crsctl stop resource ora.registry.acfs
4、关闭ASM --查看关闭状态 crsctl  stat resource -t  crs_stat -t  
srvctl stop asm -o immediate --时间稍慢

--开启
srvctl start asm -o open 
srvctl status asm
srvctl start database -d crsdb

--LISTENER_SCAN1的开启和关闭 scanIP 转移
srvctl stop scan_listener 
srvctl start scan_listener -n racnod1 --可选择运行节点

--群集文件自动启动进程
[grid@racnod1 ~]$ ps -ef | grep crsd.bin
root      3073     1  1 20:58 ?        00:00:07 /u01/app/11.2.0/grid/bin/crsd.bin reboot
grid      4583  3045  0 21:05 pts/0    00:00:00 grep crsd.bin
[grid@racnod1 ~]$ ps -ef | grep cssd.bin
grid      2602     1  1 20:57 ?        00:00:06 /u01/app/11.2.0/grid/bin/ocssd.bin 
grid      4653  3045  0 21:06 pts/0    00:00:00 grep cssd.bin
[grid@racnod1 ~]$ ps -ef | grep evmd.bin
grid      2810     1  0 20:57 ?        00:00:02 /u01/app/11.2.0/grid/bin/evmd.bin
grid      4704  3045  0 21:06 pts/0    00:00:00 grep evmd.bin

--检查集群状态
[grid@racnod1 ~]$ crsctl check cluster
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online

--检查CRS状态
[grid@racnod1 ~]$ crsctl check crs
CRS-4638: Oracle High Availability Services is online
CRS-4537: Cluster Ready Services is online
CRS-4529: Cluster Synchronization Services is online
CRS-4533: Event Manager is online

--显示集群资源状态
[grid@racnod1 ~]$ crsctl stat res -t 或者 crs_stat -t
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
      
--OCR管理
--检查OCR完整性
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
         
--OCR备份
--查看当前的备份 root用户查看
[root@racnod2 ~]# ocrconfig -showbackup

racnod2     2017/03/18 05:06:13     /u01/app/11.2.0/grid/cdata/rac-cluster/backup00.ocr

racnod2     2017/03/18 05:06:13     /u01/app/11.2.0/grid/cdata/rac-cluster/day.ocr

racnod2     2017/03/18 05:06:13     /u01/app/11.2.0/grid/cdata/rac-cluster/week.ocr

racnod2     2017/03/19 23:36:04     /u01/app/11.2.0/grid/cdata/rac-cluster/backup_20170319_233604.ocr

--手动执行备份
[root@racnod2 ~]# ocrconfig -manualbackup

racnod2     2017/03/19 23:41:06     /u01/app/11.2.0/grid/cdata/rac-cluster/backup_20170319_234106.ocr

--等待时间
当一个会话没有正在使用CPU时，它可能在等待某一个资源，可能在等待某一动作的完成，也可能就是在等待下一步的工作，与所有这些有关的，都称为等待时间。

--单实例，ASM无法配置
http://blog.csdn.net/wuweilong/article/details/22309235


##oracle_RAC参数修改
1、oracle的参数文件保存在+ASM中。
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORA_DATA/crsdb/spfilecrsdb.ora

2、节点一备份参数文件
SQL> create pfile='/tmp/spfile_bak.ora' from spfile;

3、检查文件
[oracle@racnode01 db_1]$ ll /tmp/sfile_bak.ora 
-rw-r--r-- 1 oracle asmadmin 1569 Sep  6 14:43 /tmp/sfile_bak.ora

3、节点一修改参数
SQL> ALTER SYSTEM SET processes =500 scope=spfile sid='*';  

4、重启节点一，看看参数是否可以修改生效
SQL> shutdown immediate
SQL> startup 

-查看修改的参数是否成功
SQL> show parameter processes
processes                            integer     500

5、保证节点一参数正确的情况下，启动节点二

6、查看两个节点的参数文件，是否指向共享存储的参数文件
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORA_DATA/crsdb/spfilecrsdb.ora

PS：集中启动脚本
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


###oracle参数回退
#当参数修改失败时，oracle数据库肯定是启动不起来的，这时先关闭节点一节点二数据库
1、节点一
SQL> shutdown immediate

2、从备份中恢复（也可以直接修改/tmp/spfile_bak.ora文件，把参数改正确，然后启动）
create spfile='+DATA/racdb/spfileracdb.ora' from pfile='/tmp/spfile_bak.ora';
3、启动数据库
SQL> startup
4、确定正确后，启动所有节点

##指定参数文件启动 ---只能指定静态参数文件
startup pfile='xxxxx'
startup pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initsxfxdb.ora_bak';

-------spfile说明
--参数启动说明
在[oracle@racnod2 dbs]$ cd $ORACLE_HOME/dbs 
hc_crsdb2.dat  initcrsdb2.ora  init.ora  orapwcrsdb2  
--initcrsdb2.ora 静态参数文件，可以编辑修改
[oracle@racnod2 dbs]$ more initcrsdb2.ora 
SPFILE='+ORA_DATA/crsdb/spfilecrsdb.ora'   
--也就是oracle先从本地的spfileSID.ora启动，找不到再找initcrsdb2.ora，这个文件指向共享存储中的spfile

在RAC环境中，当在本地存在spfileSID.ora的时候，实例会从本地启动。
数据库从本地的spfileSID.ora启动，因为spfileSID.ora的优先级大于initSID.ora。
SQL> show parameter spfile;
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /u01/app/oracle/product/11.2.0
                                                 /db_1/dbs/spfilecrsdb1.ora
--需要重命名：mv spfilecrsdb1.ora spfilecrsdb1.ora_bak 要不然就又从本地spfile启动了

###RAC 修改参数
默认情况下，不带SID只能在本实例生效，所以最好带上参数
--两个节点同时生效
ALTER SYSTEM SET UNDO_RETENTION = 1800 scope=both sid='*';   
--分别修改各个节点
ALTER SYSTEM SET UNDO_RETENTION = 1800 scope=both sid='sngsnfdb1';
ALTER SYSTEM SET UNDO_RETENTION = 1800 scope=both sid='sngsnfdb2';
--在修改SGA的时候，两个节点的大小可以不同，并且可以共用一个spfile
alter system set sga_max_size=50 scope=spfile sid='sngsnfdb1';
alter system set sga_target=50 scope=spfile sid='sngsnfdb1';
alter system set sga_max_size=40 scope=spfile sid='sngsnfdb2';
alter system set sga_target=40 scope=spfile sid='sngsnfdb2';

--db_files修改
SQL> show parameter db_files

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_files                             integer     2000

alter system set db_files=2500 scope=spfile sid='*';





--QA
1、在ASMCA 创建磁盘组时，出现磁盘问题.
sqlplus / as sysasm
alter system set asm_diskstring='/dev/asm-disk*'; 
show parameter disk

2、由于安装目录的规划不当，导致dbca时 不能发现ASM磁盘组。
/u01/app/11.2.0/grid/bin 
ls -al oracle
-rwsrwsrwx. 1 grid oinstall 209914513 Apr 12 19:17 oracle
chmod 6777 oracle
usermod -a -G asmdba oracle
usermod -a -G dba oracle
[root@hostoracle bin]# id oracle
uid=1101(oracle) gid=1000(oinstall) groups=1000(oinstall),1020(asmadmin),1021(asmdba),1031(dba)


--VNC安装
[root@host01 home]# rpm -ivh tigervnc-server-1.0.90-0.17.20110314svn4359.el6.x86_64.rpm 
warning: tigervnc-server-1.0.90-0.17.20110314svn4359.el6.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID ec551f03: NOKEY
Preparing...                ########################################### [100%]
   1:tigervnc-server        ########################################### [100%]
vi /etc/sysconfig/vncservers 
--添加如下内容
# VNCSERVERS="2:myusername"
# VNCSERVERARGS[2]="-geometry 800x600 -nolisten tcp -localhost"
  VNCSERVERS="1:root"
  VNCSERVERARGS[1]="-geometry 800x600 -nolisten tcp -localhost"

##ohasd进程启动
/etc/init.d/ohasd start/stop 

###集群监听及VIP飘移
注意：
1、VIP是通过节点拉起来的，并非服务启动
2、可以通过启动本地的listener来拉起VIP
3、无论crs在两个节点上怎么启动，都会按照/etc/hosts 下规划的IP去分配
srvctl start listener -n racnod1/racnod2
ora.racnod1.vip
      1        ONLINE  ONLINE       racnod1                                      
ora.racnod2.vip
      1        ONLINE  ONLINE       racnod2  
正常的情况下，这个两个VIP是分配在两个节点上的，当一个节点故障时，才会飘移到另一个节点上。
--节点一
eth0      Link encap:Ethernet  HWaddr 00:0C:29:37:13:93  
          inet addr:10.10.8.49  Bcast:10.10.8.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe37:1393/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2608540 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2861630 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:5019116799 (4.6 GiB)  TX bytes:1758110130 (1.6 GiB)

eth0:1    Link encap:Ethernet  HWaddr 00:0C:29:37:13:93              --VIP的虚拟网卡
          inet addr:10.10.8.51  Bcast:10.10.8.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
--手动故障切换
ifconfig eth0:1 down  
之后这个虚拟IP会在这个节点上消失，飘移到了节点二上。
eth0      Link encap:Ethernet  HWaddr 00:0C:29:38:9B:55  
          inet addr:10.10.8.50  Bcast:10.10.8.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe38:9b55/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:640400 errors:0 dropped:0 overruns:0 frame:0
          TX packets:700537 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1211639086 (1.1 GiB)  TX bytes:383966911 (366.1 MiB)

eth0:1    Link encap:Ethernet  HWaddr 00:0C:29:38:9B:55            --节点二的VIP
          inet addr:10.10.8.52  Bcast:10.10.8.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

eth0:2    Link encap:Ethernet  HWaddr 00:0C:29:38:9B:55            --VIP 节点一上的VIP
          inet addr:10.10.8.51  Bcast:10.10.8.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

--crsctl stat res -t 
ora.LISTENER.lsnr
               ONLINE  OFFLINE      racnod1    --节点一监听offline                                      
               ONLINE  ONLINE       racnod2
           
ora.racnod1.vip
      1        ONLINE  INTERMEDIATE racnod2                  FAILED OVER   --节点一的VIP转到节点二上  
ora.racnod2.vip
      1        ONLINE  ONLINE       racnod2         
                          
这时在用SCAN_IP 去连接数据库，是很难被分配到节点一上的

--RAC节点配置
-节点一
[grid@racnod1 admin]$ more listener.ora
LISTENER=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER))))            # line added by Agent
LISTENER_SCAN1=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1))))                # line added by Agent
ENABLE_GLOBAL_DYNAMIC_ENDPOINT_LISTENER_SCAN1=ON                # line added by Agent
ENABLE_GLOBAL_DYNAMIC_ENDPOINT_LISTENER=ON              # line added by Agent
[grid@racnod1 admin]$ more endpoints_listener.ora 
LISTENER_RACNOD1=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=racnod1-vip)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.10.8.49)(PORT=1521)(IP=FIRST))))               # line added 
by Agent   --配置的VIP地址
-节点二
[root@racnod2 admin]# more listener.ora
LISTENER_SCAN1=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER_SCAN1))))                # line added by Agent
LISTENER=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=IPC)(KEY=LISTENER))))            # line added by Agent
ENABLE_GLOBAL_DYNAMIC_ENDPOINT_LISTENER=ON              # line added by Agent
ENABLE_GLOBAL_DYNAMIC_ENDPOINT_LISTENER_SCAN1=ON                # line added by Agent
[root@racnod2 admin]# more endpoints_listener.ora 
LISTENER_RACNOD2=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=racnod2-vip)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=10.10.8.50)(PORT=1521)(IP=FIRST))))               # line added 
by Agent  --配置的VIP地址

##集群命令##
查询集群状态
crsctl check cluster -all
检查资源状态
crsctl status resource -t
核心堆栈状态
crsctl status res -t -int
查看集群下都配置了哪些数据库
srvctl config
查看RAC数据库的具体配置信息
srvctl config database -db racdb_icn1gb
RAC数据库运行状态
srvctl status database -db racdb_icn1gb
查看监听状态
srvctl status listener
查看scan监听状态
srvctl status scan_listener
添加服务
srvctl add service -db racdb_icn1gb -service srv_abc -r racdb1 -a racdb2
启动服务
srvctl start service -db racdb_icn1gb -service srv_abc
查看指定服务的状态
srvctl status service -db racdb_icn1gb -service srv_abc
查看数据库下所有的服务状态
srvctl status service -db racdb_icn1gb
移动服务
srvctl relocate service -db racdb_icnfb -service srv_test -oldinst racdb1 -newinst racdb2
停止数据库
srvctl stop database -db racdb_icn1gb -o immediate
启动数据库
srvctl start database -db racdb_icn1gb
停止实例
srvctl stop instance -db racdb_icn1gb -i racdb1 -o immediate
srvctl stop instance -db racdb_icn1gb -i racdb1 -o immediate -force
启动实例
srvctl start instance -db racdb_icn1gb -i racdb1
查看ASM模式
asmcmd showclustermode
检查集群件自启动状态
crsctl config crs
禁止集群件自启动
crsctl disable crs
停止集群件
crsctl start crs
集群件日志
$ORACLE_BASE/diag/crs/${主机名}/crstrace
ASM日志
$ORACLE_BASE/diag/asm/+asm/${ASM实例名}/trace