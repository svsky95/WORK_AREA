######rac数据库一节点异常宕机的问题分析#####
一、日志分析
数据库重新启动到nomount、mount、open状态查看日志
--所有节点上都看
1、数据库事例的alter日志
su - oracle
tail -f $ORACLE_BASE/diag/rdbms/racdb/racdb1/trace/alert_racdb1.log

2、ASM日志
su - grid
tail -f /u01/app/grid/diag/asm/+asm/+ASM1/trace/alert_+ASM1.log

3、crs日志
su - grid
tail -f  $ORACLE_HOME/log/racnode01/alertracnode01.log

4、CSS日志
su - grid
tail -f /u01/app/11.2.0/grid/log/rac1/cssd/ocssd.log

二、心跳分析
有原因会导致，心跳网络失败，导致其中一个节点别驱逐
在oracle启动的时候，会有两个私有的IP，并非是指定的私有IP
两个节点相互ping,排查是否有丢包
1、排查Private IP
more /etc/hosts
172.16.10.1 racnode01-priv
172.16.10.2 racnode02-priv

2、私有IP排查
ifconfig -a 
ens256:1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 169.254.229.118  netmask 255.255.0.0  broadcast 169.254.255.255
        ether 00:0c:29:28:5b:4d  txqueuelen 1000  (Ethernet)
ens256: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.16.10.1  netmask 255.255.255.0  broadcast 172.16.10.255
        inet6 fe80::be8a:3ed7:9a9c:4d7e  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:28:5b:4d  txqueuelen 1000  (Ethernet)
        RX packets 19024135  bytes 13184672436 (12.2 GiB)
        RX errors 0  dropped 1068  overruns 0  frame 0        //查看丢包率
        TX packets 10788049  bytes 6872615786 (6.4 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

三、节点驱逐
由于某种原因导致，如出现的process进程数过大，导致的节点驱逐，但是在启动故障节点的时候，数据库刚开始是启动状态，启动了dbwr、lmon进程后，又重启被关闭了，就可能开始节点驱逐。
1、处理方法：
若重启了故障节点的数据库，集群后，依然不行，那就考虑只重启好节点的数据库，不要动crs集群。
2、步骤：节点1 正常  节点2 故障
--为了保证快递关闭，需要关闭监听，杀掉会话、杀掉进程
关闭节点1的数据库
启动节点1的数据库
启动节点2的数据库，并观察日志

四、参数文件导致问题
若由于参数文件导致数据库在nomount状态下，无法出现分配内存的情况，考虑使用指定的参数文件启动
1、在正常的节点上，备份下来参数文件
create pfile='/home/oracle/pfile.ora_bak' from spfile;
拷贝至节点2
[oracle@racnode01 ~]$ scp pfile.ora_bak racnode01:/home/oracle
2、删掉所有不必要的参数，一下参数必须有
*.audit_file_dest='/u01/app/oracle/admin/racdb/adump'   
*.audit_trail='db'
*.cluster_database=TRUE
*.compatible='11.2.0.4.0'
*.control_files='+DATA/racdb/controlfile/current.256.1011625547','+DATA/racdb/controlfile/current.257.1011625547'
*.db_block_size=8192
*.db_name='racdb'
racdb2.instance_number=2
racdb1.instance_number=1
*.diagnostic_dest='/u01/app/oracle'

SQL> show parameter audit_file_dest
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest                      string      /u01/app/oracle/admin/racdb/ad
                                                 ump
                                                 
SQL> show parameter diagnostic_dest
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
diagnostic_dest                      string      /u01/app/oracle




#####故障汇总######
##脑裂问题
一、心跳网络中断导致的脑裂
1、首先脑裂的出现，在另一个节点上会有CSS日志，提示：   /u01/app/11.2.0/grid/log/racnode01/cssd/ocssd.log
ssnmPollingThread: node racnode02 (2) at 50% heartbeat fatal, removal in 14.320 seconds
node 2 clean up, endp (0x6e0), init state 5, cur state 5

2、在故障节点中也能看到
node 1, racnode01, has a disk HB, but no network HB, DHB has rcfg

3、如果恢复后，故障节点，不能重新加入集群，建议重启整套的集群环境，让集群重新选举。


##无故实例重启
--集群重新配置
Reconfiguration started (old inc 0, new inc 10)

##节点驱逐，终止LMON进程
ocssd.log

member kill request from client

##数据库集群的重新配置
情况分为四种：
1、由于数据库启动或关闭导致的重新配置。
2、由于某一个（或者多个）实例丢失网络心跳，导致重新配置。
3、由于某一个（或者多个）实例丢失磁盘心跳，导致重新配置。
4、由于某一个（或者多个）内存融合的后台进程丢失，导致重新配置。
报错相关：
1、ora-29740
数据库实例被集群驱逐，并发生数据库层面的重新配置。
