--关于数据库误操作权限导致无法启动
这次故障的机器的用了ASM实例，但是是单机的，所以就么有CRS进程，但是有ohasd进程。
1、找一台配置接近的系统备份权限
(备份的目录取决于误操作的目录，如果是在 / 下，就需要备份 / 的下所有权限)
[root@12cnod01 ~]# getfacl -R /home >homesc.bak    
getfacl: Removing leading '/' from absolute path names

2、还原权限
在目标机器上，看好目录是否对应，比如ORACLE_BASE及ORACLE_HOME可能就和备份的不一样，需要修改文件后，再执行。
setfacl --restore=homesc.bak  //任意目录执行

验证启动asm及oracle实例是否正常

3、有可能在启动asm的提示权限不足，或者不能分配共享内存
[root@12cnod01 ~]# su - grid
[grid@12cnod01 ~]$ sqlplus / as sysasm

4、排查共享内存
共享内存与/dev/shm里的文件有关，ora_asm都是grid.oinstall权限,对照正常的环境权限进行修改。   

