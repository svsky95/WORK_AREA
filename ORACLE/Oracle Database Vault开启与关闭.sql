--Oracle Database Vault������ر�
https://blog.csdn.net/a545578125/article/details/42916105

##�������µ��쳣
--file:///C:/Users/svsky95/Documents/WXWork/1688853282469452/Cache/File/2020-12/Doc%20ID%201997729.1.mht
The command "skgxpinfo" can be used to query which IPC protocol is used, it showed:

oradb1@sc1n1:~$ $ORACLE_HOME/bin/skgxpinfo
rds

when it should have returned:

oradb1@sc1n1:~$ $ORACLE_HOME/bin/skgxpinfo
udp

--Relink the oracle executable with the correct IPC protocol (here UDP), also make sure RAC is enabled (rac_on):
cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk rac_on ipc_g ioracle

--����rac
crsctl stop crs 