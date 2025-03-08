--方法1：
dbca都是用oracle用户调取，所以在xhell中直接新建oracle用户的连接会话，不要从root用户切换。
之后直接dbca就行了。

--centos 7.4
yum groupinstall -y "GNOME Desktop"
然后再用oracle用户登录

env | grep DISPLAY
[root@host94 ~]# export DISPLAY=92.76.20.150:0.0      //192.168.0.11 为自己笔记本的IP地址
[root@host94 ~]# xhost +
access control disabled, clients can connect from any host
xhost:  must be on local machine to enable or disable access control.
[root@host94 ~]# su - oracle
[root@host94 ~]#export LANG=en_US.UTF-8
[oracle@host94 ~]$ dbca

su - oracle
dbca
exit
xhost +
