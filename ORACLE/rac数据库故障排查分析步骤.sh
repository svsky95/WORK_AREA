######rac���ݿ�һ�ڵ��쳣崻����������#####
һ����־����
���ݿ�����������nomount��mount��open״̬�鿴��־
--���нڵ��϶���
1�����ݿ�������alter��־
su - oracle
tail -f $ORACLE_BASE/diag/rdbms/racdb/racdb1/trace/alert_racdb1.log

2��ASM��־
su - grid
tail -f /u01/app/grid/diag/asm/+asm/+ASM1/trace/alert_+ASM1.log

3��crs��־
su - grid
tail -f  $ORACLE_HOME/log/racnode01/alertracnode01.log

4��CSS��־
su - grid
tail -f /u01/app/11.2.0/grid/log/rac1/cssd/ocssd.log

������������
��ԭ��ᵼ�£���������ʧ�ܣ���������һ���ڵ������
��oracle������ʱ�򣬻�������˽�е�IP��������ָ����˽��IP
�����ڵ��໥ping,�Ų��Ƿ��ж���
1���Ų�Private IP
more /etc/hosts
172.16.10.1 racnode01-priv
172.16.10.2 racnode02-priv

2��˽��IP�Ų�
ifconfig -a 
ens256:1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 169.254.229.118  netmask 255.255.0.0  broadcast 169.254.255.255
        ether 00:0c:29:28:5b:4d  txqueuelen 1000  (Ethernet)
ens256: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.16.10.1  netmask 255.255.255.0  broadcast 172.16.10.255
        inet6 fe80::be8a:3ed7:9a9c:4d7e  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:28:5b:4d  txqueuelen 1000  (Ethernet)
        RX packets 19024135  bytes 13184672436 (12.2 GiB)
        RX errors 0  dropped 1068  overruns 0  frame 0        //�鿴������
        TX packets 10788049  bytes 6872615786 (6.4 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

�����ڵ�����
����ĳ��ԭ���£�����ֵ�process���������󣬵��µĽڵ����𣬵������������Ͻڵ��ʱ�����ݿ�տ�ʼ������״̬��������dbwr��lmon���̺����������ر��ˣ��Ϳ��ܿ�ʼ�ڵ�����
1����������
�������˹��Ͻڵ�����ݿ⣬��Ⱥ����Ȼ���У��ǾͿ���ֻ�����ýڵ�����ݿ⣬��Ҫ��crs��Ⱥ��
2�����裺�ڵ�1 ����  �ڵ�2 ����
--Ϊ�˱�֤��ݹرգ���Ҫ�رռ�����ɱ���Ự��ɱ������
�رսڵ�1�����ݿ�
�����ڵ�1�����ݿ�
�����ڵ�2�����ݿ⣬���۲���־

�ġ������ļ���������
�����ڲ����ļ��������ݿ���nomount״̬�£��޷����ַ����ڴ�����������ʹ��ָ���Ĳ����ļ�����
1���������Ľڵ��ϣ��������������ļ�
create pfile='/home/oracle/pfile.ora_bak' from spfile;
�������ڵ�2
[oracle@racnode01 ~]$ scp pfile.ora_bak racnode01:/home/oracle
2��ɾ�����в���Ҫ�Ĳ�����һ�²���������
*.audit_file_dest='/u01/app/oracle/admin/racdb/adump'   
*.audit_trail='db'
*.cluster_database=TRUE
*.compatible='11.2.0.4.0'
*.control_files='+DATA/racdb/controlfile/current.256.1011625547','+DATA/racdb/controlfile/current.257.1011625547'
*.db_block_size=8192
*.db_name='racdb'
racdb2.instance_number=2
racdb1.instance_number=1
*.diagnostic_dest='/u01/app/oracle'

SQL> show parameter audit_file_dest
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest                      string      /u01/app/oracle/admin/racdb/ad
                                                 ump
                                                 
SQL> show parameter diagnostic_dest
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
diagnostic_dest                      string      /u01/app/oracle




#####���ϻ���######
##��������
һ�����������жϵ��µ�����
1���������ѵĳ��֣�����һ���ڵ��ϻ���CSS��־����ʾ��   /u01/app/11.2.0/grid/log/racnode01/cssd/ocssd.log
ssnmPollingThread: node racnode02 (2) at 50% heartbeat fatal, removal in 14.320 seconds
node 2 clean up, endp (0x6e0), init state 5, cur state 5

2���ڹ��Ͻڵ���Ҳ�ܿ���
node 1, racnode01, has a disk HB, but no network HB, DHB has rcfg

3������ָ��󣬹��Ͻڵ㣬�������¼��뼯Ⱥ�������������׵ļ�Ⱥ�������ü�Ⱥ����ѡ�١�


##�޹�ʵ������
--��Ⱥ��������
Reconfiguration started (old inc 0, new inc 10)

##�ڵ�������ֹLMON����
ocssd.log

member kill request from client

##���ݿ⼯Ⱥ����������
�����Ϊ���֣�
1���������ݿ�������رյ��µ��������á�
2������ĳһ�������߶����ʵ����ʧ���������������������á�
3������ĳһ�������߶����ʵ����ʧ���������������������á�
4������ĳһ�������߶�����ڴ��ںϵĺ�̨���̶�ʧ�������������á�
������أ�
1��ora-29740
���ݿ�ʵ������Ⱥ���𣬲��������ݿ������������á�
