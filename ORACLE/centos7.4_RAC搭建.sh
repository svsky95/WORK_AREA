##centos 7.4 RAC�
0��ִ����0-7�Ľű����ٽ��д��̵Ĺ��غ�ӳ�䡣
1���鿴���д���ID��
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

>>�������� ��SYMLINK��д���˴��̴�С-lum����λ-������
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

#####
KERNEL=="sd*", ENV{ID_SERIAL}=="201d3e8d8978a4e80", RUN+="/bin/sh -c 'mknod /dev/iscsi2_vote3 b $major $minor; chown grid:asmadmin /dev/iscsi2_vote3; chmod 0660 /dev/iscsi2_vote3'"
#####
5��������·��
ll /dev/sd*



##��װgridʱ��Ҫ���ohasd.service
1. ��root�û����������ļ�

#touch /usr/lib/systemd/system/ohas.service

#chmod 777 /usr/lib/systemd/system/ohas.service

2. ������������ӵ��´�����ohas.service�ļ���

[root@rac1 init.d]# vi /usr/lib/systemd/system/ohas.service
[Unit]
Description=Oracle High Availability Services
After=syslog.target

[Service]
ExecStart=/etc/init.d/init.ohasd run >/dev/null 2>&1 Type=simple
Restart=always

[Install]
WantedBy=multi-user.target

3. ��root�û��������������

systemctl daemon-reload
systemctl enable ohas.service
systemctl start ohas.service

4. �鿴����״̬

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

��ʱ״̬Ϊʧ�ܣ�ԭ�������ڻ�û��/etc/init.d/init.ohasd�ļ���

����������нű�root.sh �����ٱ�ohasd failed to start�����ˡ�



������Ǳ�ohasd failed to start���󣬿�����root.sh�ű�������init.ohasd֮��ohas.serviceû��������������������ο����£�

-->������root.shʱ��һֱˢ��/etc/init.d ��ֱ������ init.ohasd �ļ��������ֶ�����ohas.service���� ���systemctl start ohas.service
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


##��װoracle���ʱ�ı���
--Error in invoking target 'agent nmhs' of makefile
�л�����Ŀ¼��
cd /u01/app/oracle/product/11.2.0/db_1/sysman/lib

���ݣ�
cp ins_emagent.mk ins_emagent.mk-bak

vi  ins_emagent.mk
����/NMECTL ���в��ң����ٶ�λҪ�޸ĵ����ں���׷�Ӳ���-lnnz11        ��һ������ĸl   ��������������
$(SYSMANBIN)emdctl:
        $(MK_EMAGENT_NMECTL) -lnnz11
        
Ȼ������retry�����������װ��
