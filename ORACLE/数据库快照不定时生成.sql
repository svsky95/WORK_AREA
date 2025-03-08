##数据库快照不定时生成
1、由于数据库异常重启，导致的当前时间点端快照不生成。
2、由于快速恢复区满，导致释放空间后，依然不定时生成快照。

--处理方法
1、查看pmon进程是否存在
1、需要刷新快照生成策略
--在一个节点执行，两个节点均生效
retention => 28800   --快照保留期  20*24*60   保留20天
INTERVAL => 60       --间隔     每60分钟生成一次

SELECT 'exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention => 28800 ,INTERVAL => 60,dbid => ’' || DBID || '
’ );’' cmd  FROM dba_hist_wr_control;

exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(retention => 28800,INTERVAL => 60,dbid => ’3621313270’ );’

