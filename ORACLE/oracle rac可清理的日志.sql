#############oracle rac���������־#############
##�����ڵ㶼�У���Ҫ�ֱ�����
##oracle�û��£�
root@dzswjnfdb1:~# su - oracle
cd $ORACLE_BASE/diag/rdbms/snsmbs/snsmbs1
31M     alert
4.0K    cdump
4.0K    hm
2.5M    incident
4.0K    incpkg
4.0K    ir
4.0K    lck
3.5M    metadata
4.0K    metadata_dgif
4.0K    metadata_pv
12K     stage
4.0K    sweep
12M     trace


##grid�û���
[root@rac1 ~]# su - grid
[grid@rac1 ~]$ cd $ORACLE_BASE/diag/tnslsnr/rac1/listener
823M    alert
4.0K    cdump
4.0K    incident
4.0K    incpkg
4.0K    lck
264K    metadata
4.0K    metadata_dgif
4.0K    metadata_pv
4.0K    stage
4.0K    sweep
422M    trace


##CRS��־
[root@rac1 ~]# su - grid
[grid@rac1 grid]$ cd $ORACLE_HOME/log/rac1

--ɾ���ű�
find . -type f -name "*.trm" -or -name "*.trc" -mtime +2 |xargs rm -rf
find . -name "cdmp*" -type d -mtime +2 |xargs rm -rf 
find . -type f -name "*.xml"  -mtime +2 |xargs rm -rf