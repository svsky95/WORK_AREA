#############oracle rac可清理的日志#############
##两个节点都有，需要分别清理
##oracle用户下：
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


##grid用户下
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


##CRS日志
[root@rac1 ~]# su - grid
[grid@rac1 grid]$ cd $ORACLE_HOME/log/rac1

--删除脚本
find . -type f -name "*.trm" -or -name "*.trc" -mtime +2 |xargs rm -rf
find . -name "cdmp*" -type d -mtime +2 |xargs rm -rf 
find . -type f -name "*.xml"  -mtime +2 |xargs rm -rf