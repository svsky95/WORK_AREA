--oracleASM安装
oracle linux 包
http://public-yum.oracle.com/oracle-linux-6.html
--由于依赖关系较多，必须联网，下载包
yum install kmod-oracleasm
--以下方法仅供参考
1、首先需要查看系统的版本，最好使用oracle linux 6/7.X 版本。
2、下载smlib包(如果是oracle linux 6/7.X  无需下载)
3、如果系统是oracle linux 6/7.X，那么oracleasm-xxx的内核包就不用安装了，系统中有。
4、下载如下两个包：
a.oracleasm-support-2.1.8-1.el6.x86_64.rpm    --oracle linux中有这个包，root用户分别在各个节点上安装
b.oracleasmlib-2.0.12-1.el6.x86_64.rpm        --默认安装，无需下载，需要从官网下载 http://www.oracle.com/technetwork/topics/linux/asmlib/index-101839.html  

--配置oracleasm
etc/init.d/oracleasm -h  --帮助

[root@racnod1 disks]# /etc/init.d/oracleasm configure
Configuring the Oracle ASM library driver.

This will configure the on-boot properties of the Oracle ASM library
driver.  The following questions will determine whether the driver is
loaded on boot and what permissions it will have.  The current values
will be shown in brackets ('[]').  Hitting <ENTER> without typing an
answer will keep that current value.  Ctrl-C will abort.

Default user to own the driver interface [grid]: grid
Default group to own the driver interface [asmdba]: asmdba
Start Oracle ASM library driver on boot (y/n) [y]: y
Scan for Oracle ASM disks on boot (y/n) [y]: y
Writing Oracle ASM library driver configuration: done
Initializing the Oracle ASMLib driver: [  OK  ]
Scanning the system for Oracle ASMLib disks: [  OK  ]

--ASM磁盘添加
1、添加共享磁盘
fdisk -l
Disk /dev/sdb: 10.7 GB, 10737418240 bytes
64 heads, 32 sectors/track, 10240 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

2、磁盘分区
fdisk /dev/sdb
p
1
w
-清理磁头
dd if=/dev/zero of=/dev/sdb1 bs=1M count=10
3、ASM磁盘初始化
/usr/sbin/oracleasm init
4、ASM磁盘创建
/usr/sbin/oracleasm createdisk ORA_DISK1 /dev/sdb1
5、扫描磁盘
/usr/sbin/oracleasm scandisks
6、列出ASM磁盘
/usr/sbin/oracleasm listdisks
7、查看磁盘
/dev/oracleasm/disks

--命令行创建磁盘组
su - gird
sqlplus / as sysasm
CREATE DISKGROUP DGA EXTERNAL REDUNDANCY  DISK '/dev/oracleasm/disks/ORA_DISK1';