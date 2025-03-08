#####存储迁移#####
##系统版本
centos 7.4 
oracle 12.2
##替换ocr磁盘粗，由于是NORMAL模式，所以需要添加3块磁盘。
external 1个磁盘
normal   3个磁盘
high     5个磁盘

##数据磁盘组
external 1个磁盘
normal   2个磁盘
high     3个磁盘

1、查看当前的磁盘状态
SQL> SELECT t."INST_ID",t."GROUP_NUMBER",t."HEADER_STATUS",t."MODE_STATUS",t."FAILGROUP",t."PATH" ,t."MOUNT_DATE" FROM gv$asm_disk t order by t."INST_ID" ,t."GROUP_NUMBER";

   INST_ID GROUP_NUMBER HEADER_STATU MODE_ST FAILGROUP                      PATH                                               MOUNT_DATE
---------- ------------ ------------ ------- ------------------------------ -------------------------------------------------- -------------------
         1            1 MEMBER       ONLINE  MGMT_0000                      /dev/sdf                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0001                  /dev/sdc                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0000                  /dev/sdd                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0002                  /dev/sde                                           2020-08-31 09:51:35
         1            3 MEMBER       ONLINE  ORA_DATA_0000                  /dev/sdg                                           2020-08-31 09:51:36
         2            1 MEMBER       ONLINE  MGMT_0000                      /dev/sdf                                           2020-08-23 02:21:02
         2            2 MEMBER       ONLINE  OCR_DATA_0000                  /dev/sdd                                           2020-08-23 02:21:03
         2            2 MEMBER       ONLINE  OCR_DATA_0001                  /dev/sdc                                           2020-08-23 02:21:03
         2            2 MEMBER       ONLINE  OCR_DATA_0002                  /dev/sde                                           2020-08-23 02:21:03
         2            3 MEMBER       ONLINE  ORA_DATA_0000                  /dev/sdg                                           2020-08-23 02:21:03
         
2、分别在两个节点挂载共享盘
echo "- - -" > /sys/class/scsi_host/host0/scan
echo "- - -" > /sys/class/scsi_host/host1/scan
echo "- - -" > /sys/class/scsi_host/host2/scan

Disk /dev/sdh: 5368 MB, 5368709120 bytes, 10485760 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdi: 5368 MB, 5368709120 bytes, 10485760 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdj: 5368 MB, 5368709120 bytes, 10485760 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

vim /etc/udev/rules.d/99-oracleasm.rules
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c294ff022d105fd4
b82cb5d7d359", SYMLINK+="asm-diskb", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c298b942929d4997
cab5f34f821a", SYMLINK+="asm-diskc", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c296e8dc191efb8b
637e6861b0dc", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c29a1817e27132e4
15b66698cf64", SYMLINK+="asm-diske", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c2912d5b69cbbc98
6ea7adac5eeb", SYMLINK+="asm-diskf", OWNER="grid", GROUP="asmadmin", MODE="0660"

[root@12cnod01 rules.d]# lsscsi --scsi_id (要保证两个节点对应的scsi_id对应一致)
[0:0:0:0]    disk    VMware   Virtual disk     2.0   /dev/sda   -
[0:0:1:0]    disk    VMware   Virtual disk     2.0   /dev/sdb   -
[1:0:0:0]    disk    VMware   Virtual disk     2.0   /dev/sdc   36000c294ff022d105fd4b82cb5d7d359
[1:0:1:0]    disk    VMware   Virtual disk     2.0   /dev/sdd   36000c298b942929d4997cab5f34f821a
[1:0:2:0]    disk    VMware   Virtual disk     2.0   /dev/sde   36000c296e8dc191efb8b637e6861b0dc
[1:0:3:0]    disk    VMware   Virtual disk     2.0   /dev/sdf   36000c29a1817e27132e415b66698cf64
[1:0:4:0]    disk    VMware   Virtual disk     2.0   /dev/sdg   36000c2912d5b69cbbc986ea7adac5eeb
[1:0:6:0]    disk    VMware   Virtual disk     2.0   /dev/sdh   36000c29d93cd044a76801c8554b6eb01
[1:0:8:0]    disk    VMware   Virtual disk     2.0   /dev/sdi   36000c2912cd34c753f7a459b19bc1735
[1:0:9:0]    disk    VMware   Virtual disk     2.0   /dev/sdj   36000c2922a4efe69e51a9082d0650225

for i in b c d e f g h i j k l m;
do
echo "KERNEL==\"sd*\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$name\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sd$i`\",SYMLINK+=\"asm-disk$i\",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\""
done


KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c29d93cd044a76801c8554b6eb01", SYMLINK+="asm-diskh", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c2912cd34c753f7a459b19bc1735", SYMLINK+="asm-diski", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c2922a4efe69e51a9082d0650225", SYMLINK+="asm-diskj", OWNER="grid", GROUP="asmadmin", MODE="0660"

--重新加载分区
/sbin/partprobe /dev/sdh
/sbin/partprobe /dev/sdi
/sbin/partprobe /dev/sdj

--用udevadm进行测试
udevadm test /sys/block/sdh
udevadm info --query=all --path=/sys/block/sdh
udevadm info --query=all --name=asm-diskh

--启动udev
/usr/sbin/udevadm control --reload-rules
systemctl status systemd-udevd.service
systemctl enable systemd-udevd.service

--查看新挂载的磁盘是都被grid识别(所有实例操作)
su - grid
[grid@12cnod01 ~]$ sqlplus / as sysasm
SQL> SELECT t."INST_ID",t."GROUP_NUMBER",t."HEADER_STATUS",t."MODE_STATUS",t."FAILGROUP",t."PATH" ,t."MOUNT_DATE" FROM gv$asm_disk t order by t."INST_ID" ,t."GROUP_NUMBER";

   INST_ID GROUP_NUMBER HEADER_STATU MODE_ST FAILGROUP                      PATH                                               MOUNT_DATE
---------- ------------ ------------ ------- ------------------------------ -------------------------------------------------- -------------------
         1            0 CANDIDATE    ONLINE                                 /dev/sdh
         1            0 CANDIDATE    ONLINE                                 /dev/sdi
         1            0 CANDIDATE    ONLINE                                 /dev/sdj
         1            1 MEMBER       ONLINE  MGMT_0000                      /dev/sdf                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0002                  /dev/sde                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0001                  /dev/sdc                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0000                  /dev/sdd                                           2020-08-31 09:51:35
         1            3 MEMBER       ONLINE  ORA_DATA_0000                  /dev/sdg                                           2020-08-31 09:51:36
         2            1 MEMBER       ONLINE  MGMT_0000                      /dev/sdf                                           2020-08-23 02:21:02
         2            2 MEMBER       ONLINE  OCR_DATA_0000                  /dev/sdd                                           2020-08-23 02:21:03
         2            2 MEMBER       ONLINE  OCR_DATA_0002                  /dev/sde                                           2020-08-23 02:21:03
         2            2 MEMBER       ONLINE  OCR_DATA_0001                  /dev/sdc                                           2020-08-23 02:21:03
         2            3 MEMBER       ONLINE  ORA_DATA_0000                  /dev/sdg                                           2020-08-23 02:21:03
         
###OCR迁移###
1、创建OCR的磁盘组（实例1创建）
SQL> CREATE DISKGROUP OCR2_DATA NORMAL REDUNDANCY DISK '/dev/sdh', '/dev/sdi', '/dev/sdj';

Diskgroup created.
--实例2需要挂载
alter diskgroup OCR2_DATA mount;
--验证实例1和实例2均为正常状态
SQL> SELECT t."INST_ID",t."GROUP_NUMBER",t."HEADER_STATUS",t."MODE_STATUS",t."FAILGROUP",t."PATH" ,t."MOUNT_DATE" FROM gv$asm_disk t order by t."INST_ID" ,t."GROUP_NUMBER";

   INST_ID GROUP_NUMBER HEADER_STATU MODE_ST FAILGROUP                      PATH                                               MOUNT_DATE
---------- ------------ ------------ ------- ------------------------------ -------------------------------------------------- -------------------
         1            1 MEMBER       ONLINE  MGMT_0000                      /dev/sdf                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0002                  /dev/sde                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0001                  /dev/sdc                                           2020-08-31 09:51:35
         1            2 MEMBER       ONLINE  OCR_DATA_0000                  /dev/sdd                                           2020-08-31 09:51:35
         1            3 MEMBER       ONLINE  ORA_DATA_0000                  /dev/sdg                                           2020-08-31 09:51:36
--         1            4 MEMBER       ONLINE  OCR2_DATA_0001                 /dev/sdi                                           2020-09-04 17:40:24
--         1            4 MEMBER       ONLINE  OCR2_DATA_0002                 /dev/sdj                                           2020-09-04 17:40:24
--         1            4 MEMBER       ONLINE  OCR2_DATA_0000                 /dev/sdh                                           2020-09-04 17:40:24
         2            1 MEMBER       ONLINE  MGMT_0000                      /dev/sdf                                           2020-08-31 09:51:35
         2            2 MEMBER       ONLINE  OCR_DATA_0002                  /dev/sde                                           2020-08-31 09:51:35
         2            2 MEMBER       ONLINE  OCR_DATA_0001                  /dev/sdc                                           2020-08-31 09:51:35
         2            2 MEMBER       ONLINE  OCR_DATA_0000                  /dev/sdd                                           2020-08-31 09:51:35
         2            3 MEMBER       ONLINE  ORA_DATA_0000                  /dev/sdg                                           2020-08-31 09:51:36
--         2            4 MEMBER       ONLINE  OCR2_DATA_0001                 /dev/sdj                                           2020-09-04 17:40:32
--         2            4 MEMBER       ONLINE  OCR2_DATA_0002                 /dev/sdi                                           2020-09-04 17:40:32
--         2            4 MEMBER       ONLINE  OCR2_DATA_0000                 /dev/sdh                                           2020-09-04 17:40:32

2、添加新的OCR信息到本地实例
2.1 查看
[root@12cnod01 rules.d]#  more /etc/oracle/ocr.loc
#Device/file +OCR_DATA getting replaced by device +OCR_DATA/racnode-cluster/OCRFILE/registry.255.1023132887 
ocrconfig_loc=+OCR_DATA/racnode-cluster/OCRFILE/registry.255.1023132887
local_only=false
2.2 添加
[root@12cnod01 rules.d]# ocrconfig -add +OCR2_DATA
2.3 确认
[root@12cnod01 rules.d]# more /etc/oracle/ocr.loc
#Device/file  getting replaced by device +OCR2_DATA/racnode-cluster/OCRFILE/registry.255.1050256437 
ocrconfig_loc=+OCR_DATA/racnode-cluster/OCRFILE/registry.255.1023132887
ocrmirrorconfig_loc=+OCR2_DATA/racnode-cluster/OCRFILE/registry.255.1050256437
2.4 检测 
[root@12cnod01 rules.d]#ocrcheck -config
Oracle Cluster Registry configuration is :
         Device/File Name         :  +OCR_DATA
         Device/File Name         : +OCR2_DATA

3、orc迁移到OCR2_DATA磁盘组上
[root@12cnod01 ~]# crsctl replace votedisk +OCR2_DATA  //一个节点的root执行
Successful addition of voting disk 6bbc233663e64f15bff9cc96dae23294.
Successful addition of voting disk eb29a466af504ff7bf6af07682d5c453.
Successful addition of voting disk f013d2c18a594f9cbfcba31df95e674e.
Successful deletion of voting disk 873dc6e2028f4f96bfff4c43591d1658.
Successful deletion of voting disk f41c50e10c984f8bbf586e8b56f805e7.
Successful deletion of voting disk 43d4fa46d3214fc6bfc46ee5bce0099c.
Successfully replaced voting disk group with +OCR2_DATA.
CRS-4266: Voting file(s) successfully replaced

4、分别确认两个节点已经迁移完成
[root@12cnod01 ~]# ocrcheck && crsctl query css votedisk
Status of Oracle Cluster Registry is as follows :
         Version                  :          4
         Total space (kbytes)     :     409568
         Used space (kbytes)      :       2204
         Available space (kbytes) :     407364
         ID                       :  213344230
         Device/File Name         :  +OCR_DATA
                                    Device/File integrity check succeeded
         Device/File Name         : +OCR2_DATA
                                    Device/File integrity check succeeded

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

         Cluster registry integrity check succeeded

         Logical corruption check succeeded

##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   6bbc233663e64f15bff9cc96dae23294 (/dev/sdh) [OCR2_DATA]
 2. ONLINE   eb29a466af504ff7bf6af07682d5c453 (/dev/sdi) [OCR2_DATA]
 3. ONLINE   f013d2c18a594f9cbfcba31df95e674e (/dev/sdj) [OCR2_DATA]
Located 3 voting disk(s).

[root@12cnod02 ~]# ocrcheck && crsctl query css votedisk
Status of Oracle Cluster Registry is as follows :
         Version                  :          4
         Total space (kbytes)     :     409568
         Used space (kbytes)      :       2204
         Available space (kbytes) :     407364
         ID                       :  213344230
         Device/File Name         :  +OCR_DATA
                                    Device/File integrity check succeeded
         Device/File Name         : +OCR2_DATA
                                    Device/File integrity check succeeded

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

         Cluster registry integrity check succeeded

         Logical corruption check succeeded

##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   6bbc233663e64f15bff9cc96dae23294 (/dev/sdh) [OCR2_DATA]
 2. ONLINE   eb29a466af504ff7bf6af07682d5c453 (/dev/sdj) [OCR2_DATA]
 3. ONLINE   f013d2c18a594f9cbfcba31df95e674e (/dev/sdi) [OCR2_DATA]
Located 3 voting disk(s).

5、迁移参数文件
[root@12cnod01 ~]#  su - grid
Last login: Mon Sep  7 09:23:50 CST 2020
[grid@12cnod01 ~]$ sqlplus / as sysdba
SQL>  show parameter pfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +OCR_DATA/racnode-cluster/ASMP
                                                 ARAMETERFILE/registry.253.1023
                                                 132885
                                                 
SQL> create pfile='/tmp/asmpfile.ora' from spfile;

File created.

Elapsed: 00:00:00.19
SQL> create spfile='+OCR2_DATA' from pfile='/tmp/asmpfile.ora'; //把参数文件创建到新的磁盘组

File created.

6、删除磁盘组
[root@12cnod01 ~]# ocrconfig -delete +OCR_DATA

7、再次检查节点1和节点2，确认已经完成了迁移。
[root@12cnod01 ~]# ocrconfig -delete +OCR_DATA
[root@12cnod01 ~]# ocrcheck && crsctl query css votedisk
Status of Oracle Cluster Registry is as follows :
         Version                  :          4
         Total space (kbytes)     :     409568
         Used space (kbytes)      :       2204
         Available space (kbytes) :     407364
         ID                       :  213344230
         Device/File Name         : +OCR2_DATA
                                    Device/File integrity check succeeded

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

         Cluster registry integrity check succeeded

         Logical corruption check succeeded

##  STATE    File Universal Id                File Name Disk group
--  -----    -----------------                --------- ---------
 1. ONLINE   6bbc233663e64f15bff9cc96dae23294 (/dev/sdh) [OCR2_DATA]
 2. ONLINE   eb29a466af504ff7bf6af07682d5c453 (/dev/sdi) [OCR2_DATA]
 3. ONLINE   f013d2c18a594f9cbfcba31df95e674e (/dev/sdj) [OCR2_DATA]
Located 3 voting disk(s).

8、重启集群
先关闭实例1和实例2的数据库
[root@12cnod01 ~]# crsctl stop crs && crsctl start crs  
[root@12cnod02 ~]# crsctl stop crs && crsctl start crs

9、检查参数文件存在于新的磁盘组
[grid@12cnod01 ~]$ sqlplus / as sysasm
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +OCR2_DATA/racnode-cluster/ASM
                                                 PARAMETERFILE/registry.253.105
                                                 0485467
                                                 
10、删掉原磁盘组
10.1 删除磁盘组的前提是，其它的节点此磁盘组是dismount，否则删除不掉。
10.2 在其它节点上dismount其它磁盘组
--节点2
SQL> alter diskgroup OCR_DATA  dismount;
SQL> select INST_ID,group_number,name,sector_size,block_size,allocation_unit_size,state,type,round(total_mb/1024,2) total_G,round(free_mb/1024,2) free_G from gv$asm_diskgroup order by 1;

   INST_ID GROUP_NUMBER NAME                 SECTOR_SIZE BLOCK_SIZE ALLOCATION_UNIT_SIZE STATE       TYPE      TOTAL_G     FREE_G
---------- ------------ -------------------- ----------- ---------- -------------------- ----------- ------ ---------- ----------
         1            3 ORA_DATA                     512       4096              4194304 MOUNTED     EXTERN         50      41.45
         1            2 OCR2_DATA                    512       4096              1048576 MOUNTED     NORMAL         15      14.29
         1            1 MGMT                         512       4096              4194304 MOUNTED     EXTERN         50       7.44
         1            4 OCR_DATA                     512       4096              4194304 MOUNTED     NORMAL         15      14.57
         2            2 OCR2_DATA                    512       4096              1048576 MOUNTED     NORMAL         15      14.29
         2            1 MGMT                         512       4096              4194304 MOUNTED     EXTERN         50       7.44
--         2            0 OCR_DATA                       0          0                    0 DISMOUNTED                  0          0
         2            3 ORA_DATA                     512       4096              4194304 MOUNTED     EXTERN         50      41.45
        
--节点1上删除
SQL> drop diskgroup OCR_DATA including contents;     

Diskgroup dropped. 

###数据盘迁移###
根据添加磁盘的步骤，添加磁盘
SQL> select INST_ID,group_number,name,sector_size,block_size,allocation_unit_size,state,type,round(total_mb/1024,2) total_G,round(free_mb/1024,2) free_G from gv$asm_diskgroup order by 1;

   INST_ID GROUP_NUMBER NAME                 SECTOR_SIZE BLOCK_SIZE ALLOCATION_UNIT_SIZE STATE       TYPE      TOTAL_G     FREE_G
---------- ------------ -------------------- ----------- ---------- -------------------- ----------- ------ ---------- ----------
         1            2 OCR2_DATA                    512       4096              1048576 MOUNTED     NORMAL         15      14.29
         1            1 MGMT                         512       4096              4194304 MOUNTED     EXTERN         50       7.44
         1            3 ORA_DATA                     512       4096              4194304 MOUNTED     EXTERN         50       41.4
         2            2 OCR2_DATA                    512       4096              1048576 MOUNTED     NORMAL         15      14.29
         2            1 MGMT                         512       4096              4194304 MOUNTED     EXTERN         50       7.44
         2            3 ORA_DATA                     512       4096              4194304 MOUNTED     EXTERN         50       41.4
         
SQL> SELECT t."INST_ID",t."GROUP_NUMBER",t."HEADER_STATUS",t."MODE_STATUS",t."FAILGROUP",t."PATH" ,t."MOUNT_DATE" FROM gv$asm_disk t order by t."INST_ID" ,t."GROUP_NUMBER";

   INST_ID GROUP_NUMBER HEADER_STATU MODE_ST FAILGROUP                      PATH                                               MOUNT_DATE
---------- ------------ ------------ ------- ------------------------------ -------------------------------------------------- -------------------
         1            0 CANDIDATE    ONLINE                                 /dev/sdk
         1            0 FORMER       ONLINE                                 /dev/sdc                                           2020-09-07 09:36:18
         1            0 FORMER       ONLINE                                 /dev/sdd                                           2020-09-07 09:36:18
         1            0 FORMER       ONLINE                                 /dev/sde                                           2020-09-07 09:36:18
         1            0 CANDIDATE    ONLINE                                 /dev/sdl
         1            1 MEMBER       ONLINE  MGMT_0000                      /dev/sdf                                           2020-09-07 09:36:04
         1            2 MEMBER       ONLINE  OCR2_DATA_0000                 /dev/sdh                                           2020-09-07 09:36:04
         1            2 MEMBER       ONLINE  OCR2_DATA_0001                 /dev/sdi                                           2020-09-07 09:36:04
         1            2 MEMBER       ONLINE  OCR2_DATA_0002                 /dev/sdj                                           2020-09-07 09:36:04
         1            3 MEMBER       ONLINE  ORA_DATA_0000                  /dev/sdg                                           2020-09-07 09:36:05
         2            0 FORMER       ONLINE                                 /dev/sdc                                           2020-09-07 09:36:18
         2            0 CANDIDATE    ONLINE                                 /dev/sdk
         2            0 FORMER       ONLINE                                 /dev/sdd                                           2020-09-07 09:36:18
         2            0 CANDIDATE    ONLINE                                 /dev/sdl
         2            0 FORMER       ONLINE                                 /dev/sde                                           2020-09-07 09:36:18
         2            1 MEMBER       ONLINE  MGMT_0000                      /dev/sdf                                           2020-09-07 09:36:04
         2            2 MEMBER       ONLINE  OCR2_DATA_0002                 /dev/sdj                                           2020-09-07 09:36:04
         2            2 MEMBER       ONLINE  OCR2_DATA_0001                 /dev/sdi                                           2020-09-07 09:36:04
         2            2 MEMBER       ONLINE  OCR2_DATA_0000                 /dev/sdh                                           2020-09-07 09:36:04
         2            3 MEMBER       ONLINE  ORA_DATA_0000                  /dev/sdg                                           2020-09-07 09:36:05  
         
1、给MGMT和ORA_DATA添加磁盘组
sqlplus / as sysasm
alter diskgroup ORA_DATA add disk '/dev/sdk' rebalance power 7;
alter diskgroup MGMT add disk '/dev/sdl' rebalance power 11; 

2、查看平衡
SOFAR：就是目前为止挪动的AU数量
EST_WORK：估计要挪动的AU数量
EST_RATE：估计每分钟挪动的AU数量
EST_MINUTES：估计挪动多少分钟
重平衡的过程就是从其他的磁盘向新磁盘挪动数据的过程，如果数据量很大，这个时间会很长，可以更改power值加快速度，默认power值为1，可根据存储性能将此值设置大一些（power取值0-11），数据平衡完毕复原power值即可

SQL> select * from gv$asm_operation; 

   INST_ID GROUP_NUMBER OPERA PASS      STAT      POWER     ACTUAL      SOFAR   EST_WORK   EST_RATE EST_MINUTES ERROR_CODE                                CON_ID
---------- ------------ ----- --------- ---- ---------- ---------- ---------- ---------- ---------- ----------- -------------------------------------------- ----------
         2            1 REBAL COMPACT   WAIT         11                                                                                                        0
         2            1 REBAL REBALANCE WAIT         11                                                                                                        0
         2            1 REBAL REBUILD   WAIT         11                                                                                                        0
         2            3 REBAL COMPACT   RUN           7          7        496          0        357           0                                                0
         2            3 REBAL REBALANCE DONE          7          7       1097       1097          0           0                                                0
         2            3 REBAL REBUILD   DONE          7          7          0          0          0           0                                                0
         1            1 REBAL COMPACT   WAIT         11         11          0          0          0           0                                                0
         1            1 REBAL REBALANCE RUN          11         11       1116       5444      81630           0                                                0
         1            1 REBAL REBUILD   DONE         11         11          0          0          0           0                                                0
         1            3 REBAL COMPACT   WAIT          7                                                                                                        0
         1            3 REBAL REBALANCE WAIT          7                                                                                                        0
         1            3 REBAL REBUILD   WAIT          7                                                                                                        0
       5          5       1712       1712          0           0    
       
只要STAT还有RUN的状态就还是在平衡的状态,当查询不出数据时，说明平衡完成。

3、移除磁盘组
alter diskgroup MGMT drop disk MGMT_0000 rebalance power 11;
alter diskgroup ORA_DATA drop disk ORA_DATA_0000 rebalance power 11;

这时磁盘组又开始平衡了，具体查看磁盘的平衡情况，平衡完成后，磁盘组消失，迁移完成。
SQL> SELECT t."INST_ID",t."GROUP_NUMBER",t."HEADER_STATUS",t."MODE_STATUS",t."FAILGROUP",t."PATH" ,t.total_mb,t.free_mb,t."MOUNT_DATE" FROM gv$asm_disk t order by t."INST_ID" ,t."GROUP_NUMBER";

   INST_ID GROUP_NUMBER HEADER_STATU MODE_ST FAILGROUP                      PATH                   TOTAL_MB    FREE_MB MOUNT_DATE
---------- ------------ ------------ ------- ------------------------------ -------------------- ---------- ---------- -------------------
         1            0 FORMER       ONLINE                                 /dev/sdg                      0          0 2020-09-07 09:36:05
         1            0 FORMER       ONLINE                                 /dev/sdc                      0          0 2020-09-07 09:36:18
         1            0 FORMER       ONLINE                                 /dev/sdf                      0          0 2020-09-07 09:36:04
         1            0 FORMER       ONLINE                                 /dev/sdd                      0          0 2020-09-07 09:36:18
         1            0 FORMER       ONLINE                                 /dev/sde                      0          0 2020-09-07 09:36:18
         1            1 MEMBER       ONLINE  MGMT_0001                      /dev/sdk                  51200       7620 2020-09-07 15:55:27
         1            2 MEMBER       ONLINE  OCR2_DATA_0000                 /dev/sdh                   5120       4880 2020-09-07 09:36:04
         1            2 MEMBER       ONLINE  OCR2_DATA_0001                 /dev/sdi                   5120       4879 2020-09-07 09:36:04
         1            2 MEMBER       ONLINE  OCR2_DATA_0002                 /dev/sdj                   5120       4879 2020-09-07 09:36:04
         1            3 MEMBER       ONLINE  ORA_DATA_0001                  /dev/sdl                  51200      42396 2020-09-07 15:54:53
         2            0 FORMER       ONLINE                                 /dev/sdc                      0          0 2020-09-07 09:36:18
         2            0 FORMER       ONLINE                                 /dev/sdg                      0          0 2020-09-07 09:36:05
         2            0 FORMER       ONLINE                                 /dev/sdf                      0          0 2020-09-07 09:36:04
         2            0 FORMER       ONLINE                                 /dev/sde                      0          0 2020-09-07 09:36:18
         2            0 FORMER       ONLINE                                 /dev/sdd                      0          0 2020-09-07 09:36:18
         2            1 MEMBER       ONLINE  MGMT_0001                      /dev/sdl                  51200       7620 2020-09-07 15:55:25
         2            2 MEMBER       ONLINE  OCR2_DATA_0001                 /dev/sdi                   5120       4879 2020-09-07 09:36:04
         2            2 MEMBER       ONLINE  OCR2_DATA_0002                 /dev/sdj                   5120       4879 2020-09-07 09:36:04
         2            2 MEMBER       ONLINE  OCR2_DATA_0000                 /dev/sdh                   5120       4880 2020-09-07 09:36:04
         2            3 MEMBER       ONLINE  ORA_DATA_0001                  /dev/sdk                  51200      42396 2020-09-07 15:54:53

                   