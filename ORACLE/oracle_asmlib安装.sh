--oracleASM��װ
oracle linux ��
http://public-yum.oracle.com/oracle-linux-6.html
--����������ϵ�϶࣬�������������ذ�
yum install kmod-oracleasm
--���·��������ο�
1��������Ҫ�鿴ϵͳ�İ汾�����ʹ��oracle linux 6/7.X �汾��
2������smlib��(�����oracle linux 6/7.X  ��������)
3�����ϵͳ��oracle linux 6/7.X����ôoracleasm-xxx���ں˰��Ͳ��ð�װ�ˣ�ϵͳ���С�
4������������������
a.oracleasm-support-2.1.8-1.el6.x86_64.rpm    --oracle linux�����������root�û��ֱ��ڸ����ڵ��ϰ�װ
b.oracleasmlib-2.0.12-1.el6.x86_64.rpm        --Ĭ�ϰ�װ���������أ���Ҫ�ӹ������� http://www.oracle.com/technetwork/topics/linux/asmlib/index-101839.html  

--����oracleasm
etc/init.d/oracleasm -h  --����

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

--ASM�������
1����ӹ������
fdisk -l
Disk /dev/sdb: 10.7 GB, 10737418240 bytes
64 heads, 32 sectors/track, 10240 cylinders
Units = cylinders of 2048 * 512 = 1048576 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

2�����̷���
fdisk /dev/sdb
p
1
w
-�����ͷ
dd if=/dev/zero of=/dev/sdb1 bs=1M count=10
3��ASM���̳�ʼ��
/usr/sbin/oracleasm init
4��ASM���̴���
/usr/sbin/oracleasm createdisk ORA_DISK1 /dev/sdb1
5��ɨ�����
/usr/sbin/oracleasm scandisks
6���г�ASM����
/usr/sbin/oracleasm listdisks
7���鿴����
/dev/oracleasm/disks

--�����д���������
su - gird
sqlplus / as sysasm
CREATE DISKGROUP DGA EXTERNAL REDUNDANCY  DISK '/dev/oracleasm/disks/ORA_DISK1';