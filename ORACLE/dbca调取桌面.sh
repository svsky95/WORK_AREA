--����1��
dbca������oracle�û���ȡ��������xhell��ֱ���½�oracle�û������ӻỰ����Ҫ��root�û��л���
֮��ֱ��dbca�����ˡ�

--centos 7.4
yum groupinstall -y "GNOME Desktop"
Ȼ������oracle�û���¼

env | grep DISPLAY
[root@host94 ~]# export DISPLAY=92.76.20.150:0.0      //192.168.0.11 Ϊ�Լ��ʼǱ���IP��ַ
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
