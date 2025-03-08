#####oracle的内存管理分为AMM（自动内存管理）和ASMM（自动共享内存管理）#####
一、AMM（自动内存管理）
共享内存大小与dev/shm有关，在oracle 11g中新增的内存自动管理的参数MEMORY_TARGET,它能自动调整SGA和PGA，这个特性需要用到/dev/shm共享文件系统，
而且要求/dev/shm必须大于MEMORY_TARGET也就是要SGA+PGA，如果/dev/shm比MEMORY_TARGET小就会报错

1、查看共享内存
[oracle@sxfxdsj dbs]$ ipcs -m
------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status      
0x00000000 1966084    oracle     640        67108864   28                      
0x00000000 1998853    oracle     640        10200547328 28      --占用共享内存10G                  
0xaf180970 2031622    oracle     640        2097152    28   

2、调整AMM
2.1、首先设置dev/shm的大小
df -alh
tmpfs                             7.9G  2.6M  7.9G   1% /dev/shm

2.2、扩容大小
mount -t tmpfs shmfs -o size=10g /dev/shm
df -alh
tmpfs                              12G     0   10G   0% /dev/shm

3.3、添加自动挂载 
vi /etc/fstab
shmfs                  /dev/shm                 tmpfs   defaults,size=12g        0 0

3、开启自动内存管理（AMM）
memory_max_target和memory_target都设置为物理内存的70%
alter system set memory_target=16G scope=spfile;
alter system set memory_max_target=16G scope=spfile;
--设置SGA
alter system set sga_max_size=0 scope=spfile;
alter system set sga_target=0 scope=spfile;
--设置PGA
alter system set pga_aggregate_target=0 scope=spfile;

--验证结果
SQL> show parameter mem

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
hi_shared_memory_address             integer     0
memory_max_target                    big integer 0
memory_target                        big integer 0
shared_memory_address                integer     0
SQL> show parameter sga

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
lock_sga                             boolean     FALSE
pre_page_sga                         boolean     FALSE
sga_max_size                         big integer 9792M
sga_target                           big integer 0
SQL> show parameter pga

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
pga_aggregate_target                 big integer 2G



二、ASMM（自动共享内存管理）
##oracle建议内存设置##
oracle禁用AMM(AUTO Memory Management)自动内存管理，启动ASMM（automatic shared memory management），需要将memory_max_target和memory_target都设置为0。
--SGA和PGA的规划
SGA=主机内存*60%*70%
PGA=主机内存*60%*30% 

memory_max_target=0
memory_target=0
sga_max_size,sga_target=80G
pga_aggregate_target=20G 

2.1、 备份参数文件
create pfile='tmp/test.ora' from spfile;
2.2、设置memory_max_target和memory_target为0
alter system set memory_max_target=0 scope=spfile sid='*';
alter system set memory_target=0 scope=spfile sid='*';
--修改SGA
alter system set sga_max_size=80G scope=spfile sid='*';
alter system set sga_target =80G scope=spfile sid='*';
--修改PGA
alter system set pga_aggregate_target =20G scope=spfile sid='*';

--重启后验证
SQL> show parameter mem

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
hi_shared_memory_address             integer     0
memory_max_target                    big integer 0
memory_target                        big integer 0
shared_memory_address                integer     0
SQL> show parameter sga

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
lock_sga                             boolean     FALSE
pre_page_sga                         boolean     FALSE
sga_max_size                         big integer 31488M
sga_target                           big integer 31488M
SQL> show parameter pga 

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
pga_aggregate_target                 big integer 7864M


######QA#####
ORA-00843: Parameter not taking MEMORY_MAX_TARGET into account
ORA-00849: SGA_TARGET 6442450944 cannot be set to more than MEMORY_MAX_TARGET 0.

解决办法如下：
首先通过spfile创建pfile，删除memory_max_target和memory_target参数，然后重建新的spfile。启动数据库后执行如下命令：
alter system  reset memory_max_target scope=spfie;
alter system  reset memory_target scope=spfie;
重启数据库之后，发现如下错误：
ORA-27102: out of memory
Linux-x86_64 Error: 28: No space left on device

[root@ora10g ~]# getconf PAGESIZE
4096

vim /etc/sysctl.conf
--kernel.shmall 大于 SGA_MAX_SIZE的大小就可以，但不包括pga_aggregate_target
kernel.shmall=4194304，可以计算出共享页面大小为4194304*4096/1024/1024/1024=16G。只要SGA_MAX_SIZE设置的值大于16G就会报ORA-27102: out of memory错误。
将kernel.shmall=4194304*2=8388608，即共享页面大小为32G时，将SGA_MAX_SIZE=30G。

--参数生效
[root@ctaisdb ~]# sysctl -p

--调整了kernel.shmall就相当于调大了共享内存
[root@ctaisdb ~]# ipcs -m
key        shmid      owner      perms      bytes      nattch     status 
0x00000000 1474564    oracle     640        134217728  28                      
0x00000000 1507333    oracle     640        21340618752 28                      
0x5cc83398 1540102    oracle     640        2097152    28         

##通过内存顾问，优化内存大小
#PGA调整：
2个实例的RAC，分别为实例1和实例2.
SQL> SELECT t.INST_ID ,t.PGA_TARGET_FOR_ESTIMATE ,t.PGA_TARGET_FACTOR ,t.ESTD_EXTRA_BYTES_RW  FROM "GV$PGA_TARGET_ADVICE" t ORDER BY t.INST_ID ;

   INST_ID PGA_TARGET_FOR_ESTIMATE PGA_TARGET_FACTOR ESTD_EXTRA_BYTES_RW
---------- ----------------------- ----------------- -------------------
         1               141950976              .125          1441812480
         1               283901952               .25          1441812480
         1               567803904                .5          1441812480
         1               851705856               .75          1420922880
         1              1135607808                 1           229984256     <--PGA_TARGET_FACTOR=1 表示当前的设置值，从实例1上可以看到再向下调整，ESTD_EXTRA_BYTES_RW的数值不变，所以不用重新设置
         1              1362728960               1.2           229984256
         1              1589850112               1.4           229984256
         1              1816972288               1.6           229984256
         1              2044093440               1.8           229984256
         1              2271215616                 2           229984256
         1              3406823424                 3           229984256
         1              4542431232                 4           229984256
         1              6813646848                 6           229984256
         1              9084862464                 8           229984256
         2               141950976              .125            12722176
         2               283901952               .25            12722176
         2               567803904                .5            12722176
         2               851705856               .75                   0
         2              1135607808                 1                   0    <--PGA_TARGET_FACTOR=1 表示当前的设置值，从实例2上可以看到再向下调整，ESTD_EXTRA_BYTES_RW的数值不变，所以不用重新设置
         2              1362728960               1.2                   0
         2              1589850112               1.4                   0
         2              1816972288               1.6                   0
         2              2044093440               1.8                   0
         2              2271215616                 2                   0
         2              3406823424                 3                   0
         2              4542431232                 4                   0
         2              6813646848                 6                   0
         2              9084862464                 8                   0

PGA_TARGET_FOR_ESTIMATE  <--表示当前或者推荐PGA的大小，单位bytes.

#SGA调整
SQL> SELECT t.INST_ID ,t.SGA_SIZE ,t.SGA_SIZE_FACTOR ,t.ESTD_DB_TIME  FROM "GV$SGA_TARGET_ADVICE" t ORDER BY t.INST_ID ;

   INST_ID   SGA_SIZE SGA_SIZE_FACTOR ESTD_DB_TIME
---------- ---------- --------------- ------------
         1       5712            1.75         2386
         1       4896             1.5         2386
         1       4080            1.25         2386
         1       2448             .75         2389
         1       1632              .5         2490
         1       3264               1         2386         <-- 当前实例1的sga设置大小，SGA_SIZE单位是M，可通过调整大小，ESTD_DB_TIME若变小，说明，有优化空间
         1       6528               2         2386
         2       5712            1.75           34
         2       4896             1.5           34
         2       4080            1.25           34
         2       3264               1           34
         2       2448             .75           34
         2       1632              .5           34
         2       6528               2           34
		 
#内存调整
SELECT t.INST_ID ,t.MEMORY_SIZE ,t.MEMORY_SIZE_FACTOR ,t.ESTD_DB_TIME  FROM "GV$MEMORY_TARGET_ADVICE" t ORDER BY t.INST_ID ;
当一下参数时：
memory_max_target                    big integer 0
memory_target                        big integer 0
就是关闭了AMM，所以表中，没有数值。


##########################
##solaris共享内存调整#####
##########################
root用户下执行
projmod -sK "project.max-shm-memory=(priv,171798691840,deny)" user.oracle     --150G  
more /etc/project  


设置PGA：一定要在数据open的状态下：
alter system set pga_aggregate_target=1717986918 scope=spfile;
然后重启数据库才可以生效

--------------------------------------------------------------------------------------------------
Linux中的内核参数详解
[root@ora10g ~]# cat /etc/sysctl.conf
# Kernel sysctl configuration file for Red Hat Linux
#
# For binary values, 0 is disabled, 1 is enabled.  See sysctl(8) and
# sysctl.conf(5) for more details.

# Controls IP packet forwarding
net.ipv4.ip_forward = 0

# Controls source route verification
net.ipv4.conf.default.rp_filter = 1

# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0

# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0

# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1

# Controls the use of TCP syncookies
net.ipv4.tcp_syncookies = 1

# Disable netfilter on bridges.
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

# Controls the default maxmimum size of a mesage queue
kernel.msgmnb = 65536

# Controls the maximum size of a message, in bytes
kernel.msgmax = 65536

# Controls the maximum shared segment size, in bytes
kernel.shmmax = 1051645952

# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 2097152
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.file-max = 65536
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default=262144
net.core.wmem_default=262144
net.core.rmem_max=262144
net.core.wmem_max=262144
vm.nr_hugepages=300
参数说明：
kernel.msgmnb    --每个消息队列的最大长度。
kernel.msgmax     --每个消息最大长度
kernel.shmmax     --单个共享内存段的最大值
SHMMAX Available physical memory Defines the maximum allowable size of one shared memory segment. The SHMMAX setting should be large enough to hold the entire SGA in one shared memory segment. A low setting can cause creation of multiple shared memory segments which may lead to performance degradation.
kernel.shmmax     --共享内存页数
kernel.shmall 参数是控制共享内存页数 。Linux 共享内存页大小为4KB, 共享内存段的大小都是共享内存页大小的整数倍。一个共享内存段的最大大小是16G，那么需要共享内存页数是 16GB/4KB=16777216KB/4KB=4194304 