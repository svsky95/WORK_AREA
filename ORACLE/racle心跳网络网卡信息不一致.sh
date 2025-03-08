#####oracle心跳网络网卡信息不一致#####
[root@12cnod02 ~]# oifcfg getif
会出现
PRIF-29 :warning : wildcard in network parameters can cause mismatch among Gpnp profile,OCR and system 
此问题出现的原因在于GPnP profile and OCR中记录的网卡信息，两个节点不一致，问题就是，当一个节点异常宕机时，另一个节点可能出现脑裂现象，
无法正常的接管应用，导致实例假死。

PS：节点1：
ens161: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 1.1.2.1  netmask 255.255.255.0  broadcast 1.1.2.255
        inet6 fe80::117a:d924:be8c:54ab  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:62:36:09  txqueuelen 1000  (Ethernet)
        RX packets 23119  bytes 2593358 (2.4 MiB)
        RX errors 0  dropped 115  overruns 0  frame 0
        TX packets 3263  bytes 847483 (827.6 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
节点2：
ens192: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 1.1.1.2  netmask 255.255.255.0  broadcast 1.1.1.255
        inet6 fe80::b242:c8ae:b943:caa5  prefixlen 64  scopeid 0x20<link>
        inet6 fe80::c102:52a0:37c7:6bdb  prefixlen 64  scopeid 0x20<link>
        inet6 fe80::11a5:bae8:3263:d45c  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:23:a7:65  txqueuelen 1000  (Ethernet)
        RX packets 172692  bytes 145926886 (139.1 MiB)
        RX errors 0  dropped 50  overruns 0  frame 0
        TX packets 94779  bytes 51677748 (49.2 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        
可以看出虽然，私有网络是好的，oracle数据库实例也是好的，但是就是会报这个警告。

--解决方法
1、以为只有一个虚拟网络，所以是不能删除的，可以采用新增的方式。
两个节点添加新的网卡，重新配置新的私有网段，然后添加配置。
oifcfg delif -global eth2     //删除网卡

oifcfg setif -global eth2/10.10.1.0:cluster_interconnect  //重新绑定网卡

oifcfg delif -global eth3

oifcfg setif -global eth3/10.0.1.0:cluster_interconnect


#####网卡名称修改#####  从生产上看，会导致所有网卡重命名，所以不建议修改。
##更改ens161为ens162

1、vim ifcfg-ens161 
NAME=ens162
DEVICE=ens162

2、mv ifcfg-ens161 ifcfg-ens162

3、vim 
3、[root@12cnod02 network-scripts]# grub2-mkconfig -o /boot/grub2/grub.cfg          
Generating grub configuration file ...                                           
Found linux image: /boot/vmlinuz-3.10.0-693.el7.x86_64                           
Found initrd image: /boot/initramfs-3.10.0-693.el7.x86_64.img                    
Found linux image: /boot/vmlinuz-0-rescue-de46a2a9ebf3422fa57a19f199375524       
Found initrd image: /boot/initramfs-0-rescue-de46a2a9ebf3422fa57a19f199375524.img
done                          

4、重启操作系统
reboot                                                 