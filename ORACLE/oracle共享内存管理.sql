#####oracle���ڴ�����ΪAMM���Զ��ڴ������ASMM���Զ������ڴ����#####
һ��AMM���Զ��ڴ����
�����ڴ��С��dev/shm�йأ���oracle 11g���������ڴ��Զ�����Ĳ���MEMORY_TARGET,�����Զ�����SGA��PGA�����������Ҫ�õ�/dev/shm�����ļ�ϵͳ��
����Ҫ��/dev/shm�������MEMORY_TARGETҲ����ҪSGA+PGA�����/dev/shm��MEMORY_TARGETС�ͻᱨ��

1���鿴�����ڴ�
[oracle@sxfxdsj dbs]$ ipcs -m
------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status      
0x00000000 1966084    oracle     640        67108864   28                      
0x00000000 1998853    oracle     640        10200547328 28      --ռ�ù����ڴ�10G                  
0xaf180970 2031622    oracle     640        2097152    28   

2������AMM
2.1����������dev/shm�Ĵ�С
df -alh
tmpfs                             7.9G  2.6M  7.9G   1% /dev/shm

2.2�����ݴ�С
mount -t tmpfs shmfs -o size=10g /dev/shm
df -alh
tmpfs                              12G     0   10G   0% /dev/shm

3.3������Զ����� 
vi /etc/fstab
shmfs                  /dev/shm                 tmpfs   defaults,size=12g        0 0

3�������Զ��ڴ����AMM��
memory_max_target��memory_target������Ϊ�����ڴ��70%
alter system set memory_target=16G scope=spfile;
alter system set memory_max_target=16G scope=spfile;
--����SGA
alter system set sga_max_size=0 scope=spfile;
alter system set sga_target=0 scope=spfile;
--����PGA
alter system set pga_aggregate_target=0 scope=spfile;

--��֤���
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



����ASMM���Զ������ڴ����
##oracle�����ڴ�����##
oracle����AMM(AUTO Memory Management)�Զ��ڴ��������ASMM��automatic shared memory management������Ҫ��memory_max_target��memory_target������Ϊ0��
--SGA��PGA�Ĺ滮
SGA=�����ڴ�*60%*70%
PGA=�����ڴ�*60%*30% 

memory_max_target=0
memory_target=0
sga_max_size,sga_target=80G
pga_aggregate_target=20G 

2.1�� ���ݲ����ļ�
create pfile='tmp/test.ora' from spfile;
2.2������memory_max_target��memory_targetΪ0
alter system set memory_max_target=0 scope=spfile sid='*';
alter system set memory_target=0 scope=spfile sid='*';
--�޸�SGA
alter system set sga_max_size=80G scope=spfile sid='*';
alter system set sga_target =80G scope=spfile sid='*';
--�޸�PGA
alter system set pga_aggregate_target =20G scope=spfile sid='*';

--��������֤
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

����취���£�
����ͨ��spfile����pfile��ɾ��memory_max_target��memory_target������Ȼ���ؽ��µ�spfile���������ݿ��ִ���������
alter system  reset memory_max_target scope=spfie;
alter system  reset memory_target scope=spfie;
�������ݿ�֮�󣬷������´���
ORA-27102: out of memory
Linux-x86_64 Error: 28: No space left on device

[root@ora10g ~]# getconf PAGESIZE
4096

vim /etc/sysctl.conf
--kernel.shmall ���� SGA_MAX_SIZE�Ĵ�С�Ϳ��ԣ���������pga_aggregate_target
kernel.shmall=4194304�����Լ��������ҳ���СΪ4194304*4096/1024/1024/1024=16G��ֻҪSGA_MAX_SIZE���õ�ֵ����16G�ͻᱨORA-27102: out of memory����
��kernel.shmall=4194304*2=8388608��������ҳ���СΪ32Gʱ����SGA_MAX_SIZE=30G��

--������Ч
[root@ctaisdb ~]# sysctl -p

--������kernel.shmall���൱�ڵ����˹����ڴ�
[root@ctaisdb ~]# ipcs -m
key        shmid      owner      perms      bytes      nattch     status 
0x00000000 1474564    oracle     640        134217728  28                      
0x00000000 1507333    oracle     640        21340618752 28                      
0x5cc83398 1540102    oracle     640        2097152    28         

##ͨ���ڴ���ʣ��Ż��ڴ��С
#PGA������
2��ʵ����RAC���ֱ�Ϊʵ��1��ʵ��2.
SQL> SELECT t.INST_ID ,t.PGA_TARGET_FOR_ESTIMATE ,t.PGA_TARGET_FACTOR ,t.ESTD_EXTRA_BYTES_RW  FROM "GV$PGA_TARGET_ADVICE" t ORDER BY t.INST_ID ;

   INST_ID PGA_TARGET_FOR_ESTIMATE PGA_TARGET_FACTOR ESTD_EXTRA_BYTES_RW
---------- ----------------------- ----------------- -------------------
         1               141950976              .125          1441812480
         1               283901952               .25          1441812480
         1               567803904                .5          1441812480
         1               851705856               .75          1420922880
         1              1135607808                 1           229984256     <--PGA_TARGET_FACTOR=1 ��ʾ��ǰ������ֵ����ʵ��1�Ͽ��Կ��������µ�����ESTD_EXTRA_BYTES_RW����ֵ���䣬���Բ�����������
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
         2              1135607808                 1                   0    <--PGA_TARGET_FACTOR=1 ��ʾ��ǰ������ֵ����ʵ��2�Ͽ��Կ��������µ�����ESTD_EXTRA_BYTES_RW����ֵ���䣬���Բ�����������
         2              1362728960               1.2                   0
         2              1589850112               1.4                   0
         2              1816972288               1.6                   0
         2              2044093440               1.8                   0
         2              2271215616                 2                   0
         2              3406823424                 3                   0
         2              4542431232                 4                   0
         2              6813646848                 6                   0
         2              9084862464                 8                   0

PGA_TARGET_FOR_ESTIMATE  <--��ʾ��ǰ�����Ƽ�PGA�Ĵ�С����λbytes.

#SGA����
SQL> SELECT t.INST_ID ,t.SGA_SIZE ,t.SGA_SIZE_FACTOR ,t.ESTD_DB_TIME  FROM "GV$SGA_TARGET_ADVICE" t ORDER BY t.INST_ID ;

   INST_ID   SGA_SIZE SGA_SIZE_FACTOR ESTD_DB_TIME
---------- ---------- --------------- ------------
         1       5712            1.75         2386
         1       4896             1.5         2386
         1       4080            1.25         2386
         1       2448             .75         2389
         1       1632              .5         2490
         1       3264               1         2386         <-- ��ǰʵ��1��sga���ô�С��SGA_SIZE��λ��M����ͨ��������С��ESTD_DB_TIME����С��˵�������Ż��ռ�
         1       6528               2         2386
         2       5712            1.75           34
         2       4896             1.5           34
         2       4080            1.25           34
         2       3264               1           34
         2       2448             .75           34
         2       1632              .5           34
         2       6528               2           34
		 
#�ڴ����
SELECT t.INST_ID ,t.MEMORY_SIZE ,t.MEMORY_SIZE_FACTOR ,t.ESTD_DB_TIME  FROM "GV$MEMORY_TARGET_ADVICE" t ORDER BY t.INST_ID ;
��һ�²���ʱ��
memory_max_target                    big integer 0
memory_target                        big integer 0
���ǹر���AMM�����Ա��У�û����ֵ��


##########################
##solaris�����ڴ����#####
##########################
root�û���ִ��
projmod -sK "project.max-shm-memory=(priv,171798691840,deny)" user.oracle     --150G  
more /etc/project  


����PGA��һ��Ҫ������open��״̬�£�
alter system set pga_aggregate_target=1717986918 scope=spfile;
Ȼ���������ݿ�ſ�����Ч

--------------------------------------------------------------------------------------------------
Linux�е��ں˲������
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
����˵����
kernel.msgmnb    --ÿ����Ϣ���е���󳤶ȡ�
kernel.msgmax     --ÿ����Ϣ��󳤶�
kernel.shmmax     --���������ڴ�ε����ֵ
SHMMAX Available physical memory Defines the maximum allowable size of one shared memory segment. The SHMMAX setting should be large enough to hold the entire SGA in one shared memory segment. A low setting can cause creation of multiple shared memory segments which may lead to performance degradation.
kernel.shmmax     --�����ڴ�ҳ��
kernel.shmall �����ǿ��ƹ����ڴ�ҳ�� ��Linux �����ڴ�ҳ��СΪ4KB, �����ڴ�εĴ�С���ǹ����ڴ�ҳ��С����������һ�������ڴ�ε�����С��16G����ô��Ҫ�����ڴ�ҳ���� 16GB/4KB=16777216KB/4KB=4194304 