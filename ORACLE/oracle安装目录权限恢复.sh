3、getfacl、setfacl命令
a.在节点2上获取文件及目录的权限:
     # getfacl -pR /oracle > backup.txt
b.拷贝 backup.txt 至节点1
c.替换backup.txt中的rac2为rac1、ASM2为ASM1、orcl2为orcl1
--ASM= ASM2 -> ASM1     :%s/ASM1/ASM2/g 
--实例 = crsdb2  -> crsdb1    :%s/crsdb2/crsdb1/g 
--主机名 racnode2 -> racnode1   :%s/racnode2/racnode1/g 
     vi bakcup.txt
     :1,$s/rac2/rac1/g  回车 (:n,$s/ rac2/ rac1/g 替换第 n 行开始到最后一行中每一行所有rac2为rac1) 
d.在节点1上恢复权限（切到backup.txt目录下）
     # setfacl --restore=backup.txt
e. crsctl start crs
f.srvctl start instance -d orcl -i orcl1
g.检查验证。

显然，第三种方式，就两条命令，简便快捷！不管对/oracle 进行chown –R 还是 chmod –R 操作，只要二节点正常，就可以从二节点那边“拷贝”正确权限。