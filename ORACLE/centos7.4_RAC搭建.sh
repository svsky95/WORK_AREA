##centos 7.4 RAC搭建
0、执行完0-7的脚本后，再进行磁盘的挂载和映射。
1、查看所有磁盘ID号
lsscsi --scsi_id
[33:0:0:0]   disk    VMware   Virtual disk     2.0   /dev/sdd   36000c29d613137c55cb5c3482e92e93b

[root@hasmbs01 ~]# /usr/lib/udev/scsi_id -g -u /dev/sdd
36000c29d613137c55cb5c3482e92e93b
for i in b c d e f g h i j k l m;
do
echo "KERNEL==\"sd*\",SUBSYSTEM==\"block\",PROGRAM==\"/lib/udev/scsi_id -g -u -d /dev/\$name\",RESULT==\"`/lib/udev/scsi_id -g -u -d /dev/sd$i`\",SYMLINK+=\"asm-disk$i\",OWNER=\"grid\",GROUP=\"asmadmin\",MODE=\"0660\""
done


vim /etc/udev/rules.d/99-oracle-asmdevices.rules
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c294ff022d105fd4b82cb5d7d359", SYMLINK+="asm-diskb", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c298b942929d4997cab5f34f821a", SYMLINK+="asm-diskc", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c296e8dc191efb8b637e6861b0dc", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c29a1817e27132e415b66698cf64", SYMLINK+="asm-diske", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="36000c2912d5b69cbbc986ea7adac5eeb", SYMLINK+="asm-diskf", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="1ATA_VBOX_HARDDISK_VB8134c529-40d97810", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="1ATA_VBOX_HARDDISK_VB8134c529-40d97810", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="1ATA_VBOX_HARDDISK_VB8134c529-40d97810", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="1ATA_VBOX_HARDDISK_VB8134c529-40d97810", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="1ATA_VBOX_HARDDISK_VB8134c529-40d97810", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="1ATA_VBOX_HARDDISK_VB8134c529-40d97810", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="1ATA_VBOX_HARDDISK_VB8134c529-40d97810", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"
KERNEL=="sd*", SUBSYSTEM=="block", PROGRAM=="/usr/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/$name", RESULT=="1ATA_VBOX_HARDDISK_VB8134c529-40d97810", SYMLINK+="asm-diskd", OWNER="grid", GROUP="asmadmin", MODE="0660"

>>命名规则： 在SYMLINK下写明了磁盘大小-lum后四位-磁盘组
KERNEL=="sd*",SUBSYSTEM=="block",PROGRAM=="/lib/udev/scsi_id -g -u -d /dev/$name",RESULT=="36acb3b510041191b0de894a4000000dc",SYMLINK+="asm-5g-00dc-grid3",OWNER="grid",GROUP="asmadmin",MODE="0660"
KERNEL=="sd*",SUBSYSTEM=="block",PROGRAM=="/lib/udev/scsi_id -g -u -d /dev/$name",RESULT=="36acb3b510041191b0de80f1f00000039",SYMLINK+="asm-100g-0039-arch1",OWNER="grid",GROUP="asmadmin",MODE="0660"


2、重新加载分区
/sbin/partprobe /dev/sdb
/sbin/partprobe /dev/sdc
/sbin/partprobe /dev/sdd
/sbin/partprobe /dev/sde

3、用udevadm进行测试
udevadm test /sys/block/sdb
udevadm info --query=all --path=/sys/block/sdb
udevadm info --query=all --name=asm-diskb

4、启动udev
/usr/sbin/udevadm control --reload-rules
systemctl status systemd-udevd.service
systemctl enable systemd-udevd.service

#####
KERNEL=="sd*", ENV{ID_SERIAL}=="201d3e8d8978a4e80", RUN+="/bin/sh -c 'mknod /dev/iscsi2_vote3 b $major $minor; chown grid:asmadmin /dev/iscsi2_vote3; chmod 0660 /dev/iscsi2_vote3'"
#####
5、共享盘路径
ll /dev/sd*



##安装grid时需要添加ohasd.service
1. 以root用户创建服务文件

#touch /usr/lib/systemd/system/ohas.service

#chmod 777 /usr/lib/systemd/system/ohas.service

2. 将以下内容添加到新创建的ohas.service文件中

[root@rac1 init.d]# vi /usr/lib/systemd/system/ohas.service
[Unit]
Description=Oracle High Availability Services
After=syslog.target

[Service]
ExecStart=/etc/init.d/init.ohasd run >/dev/null 2>&1 Type=simple
Restart=always

[Install]
WantedBy=multi-user.target

3. 以root用户运行下面的命令

systemctl daemon-reload
systemctl enable ohas.service
systemctl start ohas.service

4. 查看运行状态

[root@rac1 init.d]# systemctl status ohas.service
ohas.service - Oracle High Availability Services
Loaded: loaded (/usr/lib/systemd/system/ohas.service; enabled)
Active: failed (Result: start-limit) since Fri 2015-09-11 16:07:32 CST; 1s ago
Process: 5734 ExecStart=/etc/init.d/init.ohasd run >/dev/null 2>&1 Type=simple (code=exited, status=203/EXEC)
Main PID: 5734 (code=exited, status=203/EXEC)

Sep 11 16:07:32 rac1 systemd[1]: Starting Oracle High Availability Services...
Sep 11 16:07:32 rac1 systemd[1]: Started Oracle High Availability Services.
Sep 11 16:07:32 rac1 systemd[1]: ohas.service: main process exited, code=exited, status=203/EXEC
Sep 11 16:07:32 rac1 systemd[1]: Unit ohas.service entered failed state.
Sep 11 16:07:32 rac1 systemd[1]: ohas.service holdoff time over, scheduling restart.
Sep 11 16:07:32 rac1 systemd[1]: Stopping Oracle High Availability Services...
Sep 11 16:07:32 rac1 systemd[1]: Starting Oracle High Availability Services...
Sep 11 16:07:32 rac1 systemd[1]: ohas.service start request repeated too quickly, refusing to start.
Sep 11 16:07:32 rac1 systemd[1]: Failed to start Oracle High Availability Services.
Sep 11 16:07:32 rac1 systemd[1]: Unit ohas.service entered failed state.

此时状态为失败，原因是现在还没有/etc/init.d/init.ohasd文件。

下面可以运行脚本root.sh 不会再报ohasd failed to start错误了。



如果还是报ohasd failed to start错误，可能是root.sh脚本创建了init.ohasd之后，ohas.service没有马上启动，解决方法参考以下：

-->当运行root.sh时，一直刷新/etc/init.d ，直到出现 init.ohasd 文件，马上手动启动ohas.service服务 命令：systemctl start ohas.service
ll /etc/init.d/init.ohasd
-rwxr-xr-x 1 root root 8782 Jun 22 14:17 /etc/init.d/init.ohasd
systemctl start ohas.service
[root@rac1 init.d]# systemctl status ohas.service
ohas.service - Oracle High Availability Services
Loaded: loaded (/usr/lib/systemd/system/ohas.service; enabled)
Active: active (running) since Fri 2015-09-11 16:09:05 CST; 3s ago
Main PID: 6000 (init.ohasd)
CGroup: /system.slice/ohas.service
6000 /bin/sh /etc/init.d/init.ohasd run >/dev/null 2>&1 Type=simple
6026 /bin/sleep 10


Sep 11 16:09:05 rac1 systemd[1]: Starting Oracle High Availability Services...
Sep 11 16:09:05 rac1 systemd[1]: Started Oracle High Availability Services.
Sep 11 16:09:05 rac1 su[6020]: (to grid) root on none


##安装oracle软件时的报错
--Error in invoking target 'agent nmhs' of makefile
切换如下目录：
cd /u01/app/oracle/product/11.2.0/db_1/sysman/lib

备份：
cp ins_emagent.mk ins_emagent.mk-bak

vi  ins_emagent.mk
查找/NMECTL 进行查找，快速定位要修改的行在后面追加参数-lnnz11        第一个是字母l   后面两个是数字
$(SYSMANBIN)emdctl:
        $(MK_EMAGENT_NMECTL) -lnnz11
        
然后重新retry，软件正常安装。
