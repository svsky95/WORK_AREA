######ORACLE����洢����###########
##��·������
http://blog.csdn.net/lihuarongaini/article/details/54698089
--���ι���洢����openfile��ΪSAN�Ĺ��أ����òο�openfile_iscsi�洢���
����RAC�ڵ��Ϸֱ�װ���������߱��ذ�װ��ϵͳ���ж�����Щ����
#iSCSI initiator
yum install iscsi-initiator-utils*
#��·�������װ
yum install device-mapper*
-��������
rpm -qa|grep device-mapper
device-mapper-multipath-0.4.9-72.el6.x86_64
device-mapper-persistent-data-0.2.8-2.el6.x86_64
device-mapper-1.02.79-8.el6.x86_64
device-mapper-event-libs-1.02.79-8.el6.x86_64
device-mapper-event-1.02.79-8.el6.x86_64
device-mapper-multipath-libs-0.4.9-72.el6.x86_64
device-mapper-libs-1.02.79-8.el6.x86_64

##���в��������ڵ㶼Ҫִ��
1��iscsi initiator��Ҫͨ��iscsiadm������������Ȳ鿴�ṩ�����iscsi target����������Щtarget:
[root@raclhr-12cR1-N1 ~]# iscsiadm --mode discovery --type sendtargets --portal 10.10.8.54
[  OK  ] iscsid: [  OK  ]
192.168.59.200:3260,1 iqn.2006-01.com.openfiler:tsn.5e423e1e4d90
192.168.2.200:3260,1 iqn.2006-01.com.openfiler:tsn.5e423e1e4d90
[root@raclhr-12cR1-N1 ~]# ps -ef|grep iscsi
root      2619     2  0 11:32 ?        00:00:00 [iscsi_eh]
root      2651     1  0 11:32 ?        00:00:00 iscsiuio
root      2658     1  0 11:32 ?        00:00:00 iscsid
root      2659     1  0 11:32 ?        00:00:00 iscsid
root      2978 56098  0 11:33 pts/1    00:00:00 grep iscsi

2��������
[root@raclhr-12cR1-N1 ~]# iscsiadm --mode node --targetname iqn.2006-01.com.openfiler:tsn.8585774acddb �Cportal 10.10.8.54:3260 --login
--�ڵ�1
[root@racnod1 ~]# fdisk -l| grep dev
Disk /dev/sda: 53.7 GB, 53687091200 bytes
/dev/sda1   *           2         501      512000   83  Linux
/dev/sda2             502       51200    51915776   8e  Linux LVM
Disk /dev/mapper/vg_racnod1-lv_root: 42.5 GB, 42547019776 bytes
Disk /dev/mapper/vg_racnod1-lv_swap: 10.6 GB, 10611589120 bytes
Disk /dev/sdc: 1073 MB, 1073741824 bytes  --�мǿ��������ڵ���̷�Ҫ��ͬ����Сһ�£�˳����Բ�һ��
Disk /dev/sdb: 1073 MB, 1073741824 bytes  --�����Ƕ�·���洢����������IP��һ��LUN��
Disk /dev/mapper/mpatha: 1073 MB, 1073741824 bytes --��·������󣬾ͻ����

--�ڵ�2
[root@racnod2 ~]# fdisk -l| grep dev
Disk /dev/sda: 53.7 GB, 53687091200 bytes
/dev/sda1   *           2         501      512000   83  Linux
/dev/sda2             502       51200    51915776   8e  Linux LVM
Disk /dev/mapper/vg_racnod2-lv_root: 42.5 GB, 42547019776 bytes
Disk /dev/mapper/vg_racnod2-lv_swap: 10.6 GB, 10611589120 bytes
Disk /dev/sdb: 1073 MB, 1073741824 bytes
Disk /dev/sdc: 1073 MB, 1073741824 bytes

3��������·��
3.1������·�����������ں�ģ����
modprobe dm-multipath
modprobe dm-round-robin

--����ں�������
[root@raclhr-12cR1-N1 Packages]# lsmod |grep multipath
dm_multipath           17724  1 dm_round_robin
dm_mod                 84209  16 dm_multipath,dm_mirror,dm_log

3.2������·�����multipath����Ϊ����������
[root@raclhr-12cR1-N1 Packages]# chkconfig  --level 2345 multipathd on
[root@raclhr-12cR1-N1 Packages]#
[root@raclhr-12cR1-N1 Packages]# chkconfig  --list|grep multipathd
multipathd      0:off   1:off   2:on    3:on    4:on    5:on    6:off

3.3������multipath����
[root@raclhr-12cR1-N1 Packages]# service multipathd restart
ux_socket_connect: No such file or directory
Stopping multipathd daemon: [FAILED]
Starting multipathd daemon: [  OK  ]

4�����ö�·�����/etc/multipath.conf
--���������ļ�
/sbin/mpathconf --enable --find_multipaths y --with_module y --with_chkconfig y

4.1���鿴����ȡ�洢��������������߼���lun��wwid��Ϣ
multipath -v0
more /etc/multipath/wwids
[root@racnod1 ~]#  more /etc/multipath/wwids
# Multipath wwids, Version : 1.0
# NOTE: This file is automatically maintained by multipath and multipathd.
# You should not need to edit this file in normal circumstances.
#
# Valid WWIDs:
/14f504e46494c45524149775630592d4e31324c2d776c7755/

[root@racnod1 ~]# more /etc/multipath/bindings
# Multipath bindings, Version : 1.0
# NOTE: this file is automatically maintained by the multipath program.
# You should not need to edit this file in normal circumstances.
#
# Format:
# alias wwid
#
mpatha 14f504e46494c45524149775630592d4e31324c2d776c7755

4.2������multipath����
service multipathd restart
4.3���鿴��·��������
[root@racnod1 ~]#  multipath -ll
mpatha (14f504e46494c45524149775630592d4e31324c2d776c7755) dm-2 OPNFILER,VIRTUAL-DISK
size=1.0G features='0' hwhandler='0' wp=rw
|-+- policy='round-robin 0' prio=1 status=active
| `- 33:0:0:0 sdc 8:32 active ready running
`-+- policy='round-robin 0' prio=1 status=enabled
  `- 34:0:0:0 sdb 8:16 active ready running

4.4������multipath���ú�,����/dev/mapper�����ɶ�·���߼���
[root@racnod1 ~]# ll /dev/mapper/
total 0
crw-rw----. 1 root root 10, 58 Mar  2 21:51 control
lrwxrwxrwx. 1 root root     12 Mar  2 22:29 mpatha -> ../asm-diskb
lrwxrwxrwx. 1 root root      7 Mar  2 21:51 vg_racnod1-lv_root -> ../dm-0
lrwxrwxrwx. 1 root root      7 Mar  2 21:51 vg_racnod1-lv_swap -> ../dm-1
[root@racnod1 ~]# ll /dev/dm*
brw-rw----. 1 root disk 253, 0 Mar  2 21:51 /dev/dm-0
brw-rw----. 1 root disk 253, 1 Mar  2 21:51 /dev/dm-1
brw-rw----. 1 root disk 253, 2 Mar  2 22:30 /dev/dm-2  --�µ��߼���

����ֱ��pvcreate /dev/dm-2  --Ҳ����ֱ��fdisk /dev/dm-2

5������UDEV����
����1��99-oracleasm.rules
���ڶ�·���У��ۺ���ɺ���ʵֻ��һ�������ã�Ϊ�˷�ֹWWID�ظ���ֻ��Ҫ��һ���Ϳ��ԡ�

--�ű�
##centos6.x
for i in f g h i j k l m ;
do
echo "KERNEL==\"dm-*\", BUS==\"block\", PROGRAM==\"/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/\$name\",RESULT==\"`scsi_id --whitelisted --replace-whitespace --device=/dev/sd$i`\",NAME=\"asm-disk$i\",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" >> /etc/udev/rules.d/99-oracleasm.rules
done

--��ʾ����b c ����һ���̣����Ծ�����b��
for i in b;
do
echo "KERNEL==\"dm-*\", BUS==\"block\", PROGRAM==\"/sbin/scsi_id --whitelisted --replace-whitespace --device=/dev/\$name\",RESULT==\"`scsi_id --whitelisted --replace-whitespace --device=/dev/sd$i`\",NAME=\"asm-disk$i\",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\"" 
done

##centos7.x
1��ȷ���̷�
for i in b c d e f g h i j k l m;
do
echo "KERNEL==\"sd*\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$name\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sd$i`\",SYMLINK+=\"asm-disk$i\",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\""
done

�������� ��SYMLINK��д���˴��̴�С-lum����λ-������
KERNEL=="sd*",SUBSYSTEM=="block",PROGRAM=="/lib/udev/scsi_id -g -u -d /dev/$name",RESULT=="36acb3b510041191b0de894a4000000dc",SYMLINK+="asm-5g-00dc-grid3",OWNER="grid",GROUP="asmadmin",MODE="0660"
KERNEL=="sd*",SUBSYSTEM=="block",PROGRAM=="/lib/udev/scsi_id -g -u -d /dev/$name",RESULT=="36acb3b510041191b0de80f1f00000039",SYMLINK+="asm-100g-0039-arch1",OWNER="grid",GROUP="asmadmin",MODE="0660"

2�����¼��ط���
/sbin/partprobe /dev/sdb
/sbin/partprobe /dev/sdc
/sbin/partprobe /dev/sdd
/sbin/partprobe /dev/sde

3����udevadm���в���
udevadm test /sys/block/sdb
udevadm info --query=all --path=/sys/block/sdb
udevadm info --query=all --name=asm-diskb

4������udev
/usr/sbin/udevadm control --reload-rules
systemctl status systemd-udevd.service
systemctl enable systemd-udevd.service

--���ļ�/etc/udev/rules.d/99-oracleasm.rules�����ݿ������ڵ�2��Ȼ������udev��
[root@raclhr-12cR1-N1 ~]# start_udev
Starting udev: [  OK  ]
--��������һ���ڵ��г���һ����ʾ��--�����ĵȴ�
udev still not settled. Waiting.
udevadm settle - timeout of 0 seconds reached, the event queue contains:
  /sys/devices/virtual/block/dm-2 (3240)

udev still not settled. Waiting.
udevadm settle - timeout of 0 seconds reached, the event queue contains:
  /sys/devices/virtual/block/dm-2 (3245)

udev still not settled. Waiting.
udevadm settle - timeout of 0 seconds reached, the event queue contains:
  /sys/devices/virtual/block/dm-2 (3252)
udev still not settled. Waiting.[  OK  ]

#####�鿴��������Ϣ#####
su - grid
SELECT t."INST_ID",
       t."GROUP_NUMBER",
       t."HEADER_STATUS",
       t."MODE_STATUS",
       t."FAILGROUP",
       t.total_mb,
       t.free_mb,
       t."MOUNT_DATE",
       'kfed read '||t."PATH"||'|'||'grep -A 3 -B 3 dskname' kfed_comm 
  FROM gv$asm_disk t
 order by t."INST_ID", t."GROUP_NUMBER";

--�鿴������Ϣ
��Ҫ�������ϣ���grid�鿴
kfed read /dev/sdk| grep -A 3 -B 3 dskname
[grid@12cnod01 ~]$ kfed read /dev/sdk| grep -A 3 -B 3 dskname
kfdhdb.dsknum:                        1 ; 0x024: 0x0001
kfdhdb.grptyp:                        1 ; 0x026: KFDGTP_EXTERNAL      //������������
kfdhdb.hdrsts:                        3 ; 0x027: KFDHDR_MEMBER
kfdhdb.dskname:               MGMT_0001 ; 0x028: length=9             //��������
kfdhdb.grpname:                    MGMT ; 0x048: length=4             //���ڴ���������
kfdhdb.fgname:                MGMT_0001 ; 0x068: length=9             
kfdhdb.siteguid[0]:                   0 ; 0x088: 0x00

PS����ע��һ�㣬�쳣����£�rac����ʵ��ASM��Ӧ�Ĵ��̷����ܲ�һ�£���Ҫ�ô���ͷ��Ϣȷ�ϡ�


--��Ӵ���
SQL> show parameter asm
asm_diskstring                       string      /ora_data/*, /dev/raw/raw*, /dev/asm*

alter system set asm_diskstring='/ora_data/*','/dev/raw/raw*','/dev/asm*';
SQL> alter diskgroup FRA_DATA add disk '/dev/asm-diskh'; 

##���ù���洢
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


##���豸����
--������洢�������������ڵ㿴���̣�����������
Disk /dev/sdi: 536.9 GB, 536870912000 bytes
255 heads, 63 sectors/track, 65270 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xd8100ffd

   Device Boot      Start         End      Blocks   Id  System
/dev/sdi1               1       65270   524281243+  83  Linux

Disk /dev/sdj: 536.9 GB, 536870912000 bytes
255 heads, 63 sectors/track, 65270 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xc12e7ad6

   Device Boot      Start         End      Blocks   Id  System
/dev/sdj1               1       65270   524281243+  83  Linux

-�༭�����ļ�
vim /etc/udev/rules.d/60-raw.rules
ACTION=="add", KERNEL=="sda1", RUN+="/bin/raw /dev/raw/raw1 %N"
ACTION=="add", KERNEL=="sdb1", RUN+="/bin/raw /dev/raw/raw2 %N"
ACTION=="add", KERNEL=="sdc1", RUN+="/bin/raw /dev/raw/raw3 %N"
ACTION=="add", KERNEL=="sdd1", RUN+="/bin/raw /dev/raw/raw4 %N"
ACTION=="add", KERNEL=="sde1", RUN+="/bin/raw /dev/raw/raw5 %N"
ACTION=="add", KERNEL=="sdf1", RUN+="/bin/raw /dev/raw/raw6 %N"
ACTION=="add", KERNEL=="sdg1", RUN+="/bin/raw /dev/raw/raw7 %N"
ACTION=="add", KERNEL=="sdi1", RUN+="/bin/raw /dev/raw/raw8 %N"
ACTION=="add", KERNEL=="sdj1", RUN+="/bin/raw /dev/raw/raw9 %N"
KERNEL=="raw*", OWNER="grid" GROUP="asmadmin", MODE="0660"

-����UDEV
/sbin/start_udev

--Starting udev: udevd[7871]: inotify_init failed: Too many open files
vi /etc/sysctl.conf �������� 
fs.inotify.max_user_instances=8192
sysctl -p

-�鿴Ȩ��
[root@sxgsdb1 ~]# ll /dev/raw/raw*
crw-rw---- 1 grid asmadmin 162, 1 3��   1 10:42 /dev/raw/raw1
crw-rw---- 1 grid asmadmin 162, 2 3��   1 10:42 /dev/raw/raw2
crw-rw---- 1 grid asmadmin 162, 3 3��   1 10:42 /dev/raw/raw3
crw-rw---- 1 grid asmadmin 162, 4 3��   1 10:42 /dev/raw/raw4
crw-rw---- 1 grid asmadmin 162, 5 3��   1 10:42 /dev/raw/raw5
crw-rw---- 1 grid asmadmin 162, 6 3��   1 10:42 /dev/raw/raw6
crw-rw---- 1 grid asmadmin 162, 7 3��   1 10:42 /dev/raw/raw7
crw-rw---- 1 grid asmadmin 162, 8 3��   1 10:25 /dev/raw/raw8
crw-rw---- 1 grid asmadmin 162, 9 3��   1 10:33 /dev/raw/raw9
crw-rw---- 1 grid asmadmin 162, 0 2��  28 11:03 /dev/raw/rawctl

##NFS����洢
����NFSĬ����/home�´��������ļ��������ȴ��������ļ�
mkdir -P /home/nfs_data
--�༭NFS�����ļ�
[root@localhost home]# more /etc/exports 
/home/nfs_data 10.10.8.0/24(rw,sync,no_all_squash,anonuid=1101,anongid=1000) --ֻ����̶����η���  anonuid=1101,anongid=1000 Ϊoracle�û�ID����ID

--�ֱ��������ڵ��Ϲ���
�������ڵ��ϴ��������ļ���
/ora_data 
mount -t nfs -o rw,hard,nointr,tcp,noac,vers=3,timeo=600,rsize=32768,wsize=32768 10.10.8.14:/home/nfs_data/  /ora_data

--д����̹����ļ�
vi /etc/fstab
10.10.8.14:/home/nfs_data /ora_data  nfs  rw,bg,hard,nointr,tcp,vers=3,timeo=600,rsize=32768,wsize=32768,actimeo=0  0 0

--��һ���ڵ��Ͻ��д������
dd if=/dev/zero of=/ora_data/disk8 bs=1024k count=1000
������Ȩ��
-rwxrwxrwx.  1 oracle oinstall 1048576000 Dec 29 07:05 disk2

1�����/dev/sdb�Ƿ���Ϊ/dev/asm-diskg��ʽ��asm����
[root@racnod1 ~]# ll /dev/asm*
brw-rw----. 1 grid asmadmin 253, 3 Apr 18 14:21 /dev/asm-diskd
brw-rw----. 1 grid asmadmin 253, 2 Apr 18 14:21 /dev/asm-diskf
brw-rw----. 1 grid asmadmin 253, 4 Apr 18 14:21 /dev/asm-diskg



#####centos7.4 ���������RAC#####
0��ִ����0-7�Ľű����ٽ��д��̵Ĺ��غ�ӳ�䡣
1���鿴���д���ID��
lsscsi --scsi_id
[33:0:0:0]   disk    VMware   Virtual disk     2.0   /dev/sdd   36000c29d613137c55cb5c3482e92e93b

[root@hasmbs01 ~]# /usr/lib/udev/scsi_id -g -u /dev/sdd
36000c29d613137c55cb5c3482e92e93b

-����1
vim /etc/udev/rules.d/99-oracle-asmdevices.rules
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c29d613137c55cb5c3482e92e93b", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
-����2
-sdg������ӵĴ��̣�Ҳ���ø�ʽ��
KERNEL=="sdg", NAME="asm_data1", OWNER="grid", GROUP="asmadmin", MODE="0660"   

->����1������2������

2�����¼��ط���
/sbin/partprobe /dev/sdb
/sbin/partprobe /dev/sdc
/sbin/partprobe /dev/sdd

3����udevadm���в���
udevadm test /sys/block/sdb
udevadm info --query=all --path=/sys/block/sdb
udevadm info --query=all --name=asm-diskb

4������udev
/usr/sbin/udevadm control --reload-rules
systemctl status systemd-udevd.service
systemctl enable systemd-udevd.service

#####
KERNEL=="sd*", ENV{ID_SERIAL}=="201d3e8d8978a4e80", RUN+="/bin/sh -c 'mknod /dev/iscsi2_vote3 b $major $minor; chown grid:asmadmin /dev/iscsi2_vote3; chmod 0660 /dev/iscsi2_vote3'"
#####
5��������·��
ll /dev/sd*

#####ASM��Ӵ���#####
1�������µĴ�����
--1�ڵ����
CREATE DISKGROUP test_DATA NORMAL/ REDUNDANCY DISK '/dev/sdc', '/dev/sdd', '/dev/sde';
--����ʵ����Ҫmount
alter diskgroup test_DATA mount;

2��ɾ��������
--�����ڵ���Ҫ��dismount
alter diskgroup TEST_DATA  dismount
--1�ڵ�ɾ��
drop diskgroup TEST_DATA including contents; 


1����ASM�������м���(grid�û���sysasm)
[grid@racnod1 ~]$ sqlplus / as sysasm
SQL> select instance_name from v$instance;

INSTANCE_NAME
----------------
+ASM1

SQL> select GROUP_NUMBER,NAME,TOTAL_MB,FREE_MB from v$asm_diskgroup;

GROUP_NUMBER NAME                             TOTAL_MB    FREE_MB
------------ ------------------------------ ---------- ----------
           1 OCR_DATA                            48800      48404
           2 ORA_DATA                            97632      93853

2���鿴����ӵĴ���
#centos6.x��ʾ����
SQL> select GROUP_NUMBER,DISK_NUMBER, MODE_STATUS,HEADER_STATUS, MODE_STATUS,state,TOTAL_MB,FREE_MB,name,PATH from v$asm_disk;
GROUP_NUMBER DISK_NUMBER MODE_ST HEADER_STATU MODE_ST STATE      TOTAL_MB    FREE_MB NAME                 PATH
------------ ----------- ------- ------------ ------- -------- ---------- ---------- -------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
           0           0 ONLINE  CANDIDATE    ONLINE  NORMAL            0          0                      /dev/asm_data1
           2           2 ONLINE  MEMBER       ONLINE  NORMAL         5115       4808 OCR_0002             /dev/asm_ocr3
           2           1 ONLINE  MEMBER       ONLINE  NORMAL         5115       4805 OCR_0001             /dev/asm_ocr2
           2           0 ONLINE  MEMBER       ONLINE  NORMAL         5115       4806 OCR_0000             /dev/asm_ocr1
           1           0 ONLINE  MEMBER       ONLINE  NORMAL      1048570      77184 DATA_0000            /dev/asm_data
#centos7.x��ʾ����
SQL> select GROUP_NUMBER,DISK_NUMBER, MODE_STATUS,HEADER_STATUS, MODE_STATUS,state,TOTAL_MB,FREE_MB,name,PATH from v$asm_disk;
GROUP_NUMBER DISK_NUMBER MODE_ST HEADER_STATU MODE_ST STATE      TOTAL_MB    FREE_MB NAME                 PATH
------------ ----------- ------- ------------ ------- -------- ---------- ---------- -------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
           0           0 ONLINE  CANDIDATE    ONLINE  NORMAL            0          0                      /dev/sdd    --����Ӵ���
           1           0 ONLINE  MEMBER       ONLINE  NORMAL       102400      97227 DATA_0000            /dev/sdb    --ʵ����Ӵ��̵�·��
           
SQL> alter diskgroup ORA_DATA add disk '/dev/sdd' rebalance power 5;

Diskgroup altered.

--asm��־
[grid@racnod2 ~]$ cd /u01/app/11.2.0/grid/log/diag/asm/+asm/+ASM2/trace
[grid@racnod2 trace]$ tail -f alert_+ASM2.log


--�鿴ƽ��
SOFAR������ĿǰΪֹŲ����AU����
EST_WORK������ҪŲ����AU����
EST_RATE������ÿ����Ų����AU����
EST_MINUTES������Ų�����ٷ���
��ƽ��Ĺ��̾��Ǵ������Ĵ������´���Ų�����ݵĹ��̣�����������ܴ����ʱ���ܳ������Ը���powerֵ�ӿ��ٶȣ�Ĭ��powerֵΪ1���ɸ��ݴ洢���ܽ���ֵ���ô�һЩ��powerȡֵ0-11��������ƽ����ϸ�ԭpowerֵ����

SQL> select * from gv$asm_operation; 
--�鿴�������ݱ�ʾƽ�����
GROUP_NUMBER OPERA STAT      POWER     ACTUAL      SOFAR   EST_WORK   EST_RATE EST_MINUTES ERROR_CODE
------------ ----- ---- ---------- ---------- ---------- ---------- ---------- ----------- --------------------------------------------
           1 REBAL RUN           5          5       1712       1712          0           0


SQL> show parameter asm_power_limit;
--����ƽ�����ã�����0-11�� 0ֹͣ 11��ʾ�ٶ����
SQL> alter diskgroup ORA_DATA rebalance power 11;
ע��power=0��ֹͣrebalance����
Ҳ���ڼ���ʱֱ�����rebalanceָ����£�
SQL> alter diskgroup data_dg add disk '/dev/asm-diskh' rebalance power 8;
ע������Ӵ��̱����������̲�Ϊȫ���̣��о���������ͷ������ʹ��dd�������ͷ��Ϣ�����
dd if=/dev/zero of=/dev/sdd bs=4096 count=256 --����ͷ��Ϣ��Сһ����1M��

#####ASMɾ������#####
1��ɾ��ASM����
SQL> select GROUP_NUMBER,DISK_NUMBER, MODE_STATUS,HEADER_STATUS, MODE_STATUS,state,TOTAL_MB,FREE_MB,name,PATH from v$asm_disk;
GROUP_NUMBER DISK_NUMBER MODE_ST HEADER_STATU MODE_ST STATE      TOTAL_MB    FREE_MB NAME                 PATH
------------ ----------- ------- ------------ ------- -------- ---------- ---------- -------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
           1           0 ONLINE  MEMBER       ONLINE  NORMAL       102400      98939 DATA_0000            /dev/sdb
           1           1 ONLINE  MEMBER       ONLINE  NORMAL        51200      49486 DATA_0001            /dev/sdd
--�鿴��������
SQL> select INST_ID,group_number,name,sector_size,block_size,allocation_unit_size,state,type,total_mb,free_mb from gv$asm_diskgroup order by 1;

   INST_ID GROUP_NUMBER NAME                 SECTOR_SIZE BLOCK_SIZE ALLOCATION_UNIT_SIZE STATE       TYPE     TOTAL_MB    FREE_MB
---------- ------------ -------------------- ----------- ---------- -------------------- ----------- ------ ---------- ----------
         1            1 DATA                         512       4096              1048576 MOUNTED     EXTERN     153600     148425
         2            1 DATA                         512       4096              1048576 MOUNTED     EXTERN     153600     148425
                   
SQL> alter diskgroup DATA drop disk 'DATA_0000'; --����name��ɾ��
��SQL> alter diskgroup data_dg drop disk 'DATA_DG_0002' rebalance power 8;
--�鿴ƽ��״̬
SQL> select * from v$asm_operation;
--�鿴������״̬
SQL> select GROUP_NUMBER,DISK_NUMBER, MODE_STATUS,HEADER_STATUS, MODE_STATUS,state,TOTAL_MB,FREE_MB,name,PATH from v$asm_disk;
#�ȴ�����ƽ�����
GROUP_NUMBER DISK_NUMBER MODE_ST HEADER_STATU MODE_ST STATE      TOTAL_MB    FREE_MB NAME                 PATH
------------ ----------- ------- ------------ ------- -------- ---------- ---------- -------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
           1           0 ONLINE  MEMBER       ONLINE  DROPPING     102400     101542 DATA_0000            /dev/sdb
           1           1 ONLINE  MEMBER       ONLINE  NORMAL        51200      46883 DATA_0001            /dev/sdd
           
####ASM����ͷ����####
ͨ�� v$asm_disk �鿴�� C01 �� C03 �� header_status Ϊ member���Ѿ�����ĳ�������飬 �� mout_status �� CLOSED �رա�����ֱ�� alter diskgroup add disk �Ӵ��̣��ᱨ�� ���ȶԴ����� dd ������ header_status ״̬�ĳ� CANDIDATE(�ɼ������ģʽ)��

dd if=/dev/zero of=/dev/sdb count=1000
           