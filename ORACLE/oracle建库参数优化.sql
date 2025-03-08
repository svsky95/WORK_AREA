Oracle11g建库
创建时间： 2014/11/11 11:58
更新时间： 2014/11/18 22:39

#========================================================================
#     FileName: 11gR2建库.txt
#         Desc: 
#       Author: PeiZhengfeng
#        Email: peizhengfeng@hthorizon.com
#     HomePage: http://www.hthorizon.com
#      Version: 0.0.1
#      Created: 2014-10-24 14:00:27
#   LastChange: 2014-10-24 14:00:27
#      History:
#========================================================================

    1. 内存参数
    .   1.1 基本内存参数
    .   1.2 其它参数
    .   1.3 可以考虑的参数
    2. 调整profile
    3. 调整CRS参数
    4. 修改监听端口
    5. 关闭自动执行的JOB
    6. 设置AWR保存时间
    7. 停止ora.crf服务
    8. RMAN备份要配置
    9. 设置目录权限
    10. 调整redo
    .   10.1 增加redo组
    .   10.2 增加redo组的成员
    .   10.3 删除redo组
    .   10.4 删除redo组成员


=========================================================================================
1. 内存参数

1.1 基本内存参数
*************************************************
alter system set sga_max_size=100g scope=spfile sid='*';
alter system set sga_target=0 scope=spfile sid='*';
alter system set shared_pool_size=6g scope=spfile sid='*';
alter system set db_cache_size=24g scope=spfile sid='*';
alter system set java_pool_size=300M scope=spfile sid='*';
alter system set large_pool_size=200M scope=spfile sid='*';
alter system set streams_pool_size=500m scope=spfile sid='*';
alter system set "_memory_imm_mode_without_autosga"=FALSE scope=spfile sid='*';
alter system set processes=2000 scope=spfile sid='*';
alter system set sessions=2250 scope=spfile sid='*';

1.2 其它参数
*************************************************
alter system set job_queue_processes=100 scope=spfile sid='*';
alter system set DB_FILES=2000 scope=spfile sid='*';
alter system set log_archive_max_processes=2 scope=spfile sid='*';
alter system set nls_date_format='YYYY-MM-DD HH24:MI:SS' scope=spfile sid='*';
alter system set open_cursors=3000 scope=spfile sid='*';
alter system set open_links_per_instance=48 scope=spfile sid='*';
alter system set open_links=100 scope=spfile sid='*';
alter system set parallel_max_servers=20 scope=spfile sid='*';
alter system set session_cached_cursors=200 scope=spfile sid='*';
alter system set undo_retention=10800 scope=spfile sid='*';
alter system set "_undo_autotune"=false scope=spfile sid='*';
alter system set "_partition_large_extents"=false scope=spfile sid='*';
alter system set "_use_adaptive_log_file_sync"=false scope=spfile sid='*';
alter system set "_optimizer_use_feedback"=false scope=spfile sid='*';
alter system set fast_start_mttr_target=300 scope=spfile sid='*';
alter system set deferred_segment_creation=false scope=spfile sid='*';
alter system set "_external_scn_logging_threshold_seconds"=600 scope=spfile sid='*';
alter system set "_external_scn_rejection_threshold_hours"=24 scope=spfile sid='*';
alter system set result_cache_max_size=0 scope=spfile sid='*';
alter system set "_cleanup_rollback_entries"=2000 scope=spfile sid='*';
alter system set parallel_force_local=true scope=spfile sid='*';
alter system set "_gc_policy_time"=0 scope=spfile sid='*';
alter system set "_clusterwide_global_transactions"=false scope=spfile sid='*';               #11g新特性，缺省是true，可能会导致DBLINK HANG死、UNDO坏块，同时OGG的解析也会出问题

1.3 可以考虑的参数
*************************************************
alter system set audit_trail=none scope=spfile sid='*';
alter system set "_resource_manager_always_on"=FALSE scope=both sid='*';
*.event="28401 trace name context forever,level 1"     # 关闭logon delay，防止大量密码错误尝试导致的library cache lock/pin
*._bloom_filter_enabled                                        # bloom算法，可以disable
*._bloom_pruning_enabled
*._datafile_write_errors_crash_instance=false          # 可以考虑
*._high_priority_processes='LMS*|LGWR|PMON'         # 提高进程的优先级

=========================================================================================
2. 调整profile
SQL> alter profile default limit PASSWORD_LIFE_TIME unlimited;
Profile altered.

SQL> alter profile default limit FAILED_LOGIN_ATTEMPTS unlimited;
Profile altered.

=========================================================================================
3. 调整CRS参数
/oracle/product/11.2.0/grid/bin/crsctl set css misscount 150
/oracle/product/11.2.0/grid/bin/crsctl set css disktimeout 200

/oracle/product/11.2.0/grid/bin/crsctl get css misscount
/oracle/product/11.2.0/grid/bin/crsctl get css disktimeout

=========================================================================================
4. 修改监听端口
srvctl modify scan_listener -p "TCP:1621"
srvctl stop scan_listener
srvctl start scan_listener
srvctl modify listener -l LISTENER_SCAN1 -p "TCP:1621"
srvctl stop listener
srvctl start listener

=========================================================================================
5. 关闭自动执行的JOB
SQL> select client_name,status from DBA_AUTOTASK_CLIENT;

CLIENT_NAME                                                      STATUS
---------------------------------------------------------------- --------
auto optimizer stats collection                                  ENABLED
auto space advisor                                               ENABLED
sql tuning advisor                                               ENABLED

begin
  DBMS_AUTO_TASK_ADMIN.DISABLE(
    client_name => 'auto optimizer stats collection',
    operation => NULL,
    window_name => NULL);
end;
/

=========================================================================================
6. 设置AWR保存时间
SQL> select * from DBA_HIST_WR_CONTROL;

      DBID SNAP_INTERVAL
---------- ---------------------------------------------------------------------------
RETENTION                                                                   TOPNSQL
--------------------------------------------------------------------------- ----------
593940352 +00000 01:00:00.0
+00008 00:00:00.0                                                           DEFAULT

BEGIN
  DBMS_WORKLOAD_REPOSITORY.modify_snapshot_settings(
    retention => 50400);
END;
/

SQL> select * from DBA_HIST_WR_CONTROL;

       DBID SNAP_INTERVAL
---------- ---------------------------------------------------------------------------
RETENTION                                                                   TOPNSQL
--------------------------------------------------------------------------- ----------
2033568290 +00000 01:00:00.0
+00035 00:00:00.0                                                           DEFAULT

=========================================================================================
7. 停止ora.crf服务
[grid@inas4g01 ~]$ $ORACLE_HOME/bin/crsctl stop res ora.crf -init
CRS-2673: Attempting to stop 'ora.crf' on 'inas4g01'
CRS-2677: Stop of 'ora.crf' on 'inas4g01' succeeded

[grid@inas4g01 ~]$ $ORACLE_HOME/bin/crsctl stat res ora.crf -init -p
NAME=ora.crf
TYPE=ora.crf.type
......
AUTO_START=always
ENABLED=1
......

[root@inas4g01 ~]# /oracle/product/11.2.0/grid/bin/crsctl modify res ora.crf -attr "ENABLED=0" -init
[root@inas4g01 ~]# /oracle/product/11.2.0/grid/bin/crsctl modify res ora.crf -attr AUTO_START=never -init

=========================================================================================
8. RMAN备份要配置
RMAN> CONFIGURE SNAPSHOT CONTROLFILE NAME TO '<shared_disk>/snapcf_<DBNAME>.f';
参考: ORA-245: In RAC environment from 11.2 onwards Backup Or Snapshot controlfile needs to be in shared location (文档 ID 1472171.1)

=========================================================================================
9. 设置目录权限
chown oracle:dba /redo
chown oracle:dba /sysdata
chown oracle:dba /archlog
chown oracle:dba /oradata01
chown oracle:dba /oradata02

mkdir -p /redo/inas
mkdir -p /sysdata/inas
mkdir -p /archlog/inas
mkdir -p /oradata01/inas
mkdir -p /oradata02/inas

=========================================================================================
10. 调整redo

10.1 增加redo组
alter database add logfile thread 1   group 1  ('/redo/inas/redo11.dbf') size 2048M;
alter database add logfile thread 1   group 2  ('/redo/inas/redo21.dbf') size 2048M;
alter database add logfile thread 1   group 3  ('/redo/inas/redo31.dbf') size 2048M;
alter database add logfile thread 1   group 4  ('/redo/inas/redo41.dbf') size 2048M;

10.2 增加redo组的成员
alter database add logfile member
  '/redo/inas/redo12.dbf' to group 1,
  '/redo/inas/redo22.dbf' to group 2,
  '/redo/inas/redo32.dbf' to group 3,
  '/redo/inas/redo42.dbf' to group 4;

10.3 删除redo组
alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;
alter database drop logfile group 4;

10.4 删除redo组成员
alter database drop logfile member '/redo/inas/redo92.dbf';
alter database drop logfile member '/redo/inas/redo102.dbf';
alter database drop logfile member '/redo/inas/redo112.dbf';
alter database drop logfile member '/redo/inas/redo122.dbf';
alter database drop logfile member '/redo/inas/redo132.dbf';
alter database drop logfile member '/redo/inas/redo142.dbf';
alter database drop logfile member '/redo/inas/redo152.dbf';
alter database drop logfile member '/redo/inas/redo162.dbf';

--RAC 上线参数优化


当前数据库中，已经启用了绑定变量窥探（默认启用），且系统自动收集统计信息，在数据表中列数据存在严重倾斜的情况下可能会导致 SQL 性能问题，需要关注。

对于数据库实例，在11版本中，建议禁用自适应游标共享，将隐含参数_optimizer_extended_cursor_sharing_rel设置为 NONE。
参考命令：alter system set "_optimizer_extended_cursor_sharing_rel"='NONE';

对于数据库实例，在11版本中，参数 _optimizer_null_aware_antijoin 是在 Oracle 11g 引入的新参数，它用于解决在反连接（Anti-Join）时，关联列上存在空值（NULL）或关联列无非空约束的问题。但是该参数不稳定，存在较多的 Bug，为避免触发相关 Bug，建议关闭。
参考命令：alter system set "_optimizer_null_aware_antijoin"=FALSE;

对于数据库实例，在11版本中，建议禁用自适应游标共享，将隐含参数_optimizer_extended_cursor_sharing设置为 NONE。
参考命令：alter system set "_optimizer_extended_cursor_sharing"='NONE';

对于数据库实例，在11版本中，隐含参数 _optimizer_adaptive_cursor_sharing 能控制自适应式游标共享的部分行为，由 Oracle 自适应的处理绑定变量的窥探，但这可能会触发性能问题。 Oracle 建议在非技术指导下，将其关闭掉。
参考命令：alter system set "_optimizer_adaptive_cursor_sharing"=FALSE;

对于数据库实例，在11版本中，基数反馈（Cardinality Feedback）是 Oracle 11.2 中引入的关于 SQL 性能优化的新特性，该特性主要针对统计信息陈旧、无直方图或虽然有直方图但仍基数计算不准确的情况，Cardinality 基数的计算直接影响到后续的 JOIN COST 等重要的成本计算评估，造成 CBO 选择不当的执行计划。但是该参数存在不稳定因素，可能会带来执行效率的问题，建议关闭优化器反馈。
参考命令：alter system set "_optimizer_use_feedback"=FALSE;

对于数据库实例，在11版本中，并行执行的从属进程在工作时需要交换数据和信息，默认从 Shared Pool 中分配内存空间。当 _PX_use_large_pool=TRUE 时并行进程将从 Large Pool 中分配内存，减少对共享池（Shared Pool）的争用。
参考命令：alter system set "_PX_use_large_pool"=TRUE scope=spfile;

对于数据库实例，在11版本中，隐含参数 _undo_autotune 负责 undo retention（即 undo 段的保持时间）的自动调整，若由 Oracle 自动负责 undo retention，则 Oracle 会根据事务量来占用 undo 表空间，可能会形成 undo 表空间的争用，建议将其关闭。
参考命令：alter system set "_undo_autotune"=FALSE;

对于数据库实例，在11版本中，若无特殊的安全需求，建议关闭密码大小写敏感策略。
参考命令：alter system set sec_case_sensitive_logon=FALSE;


对于数据库实例，在11版本RAC中，建议关闭集群 Undo Affinity，降低集群交互，避免触发相关 BUG。
参考命令：alter system set "_gc_undo_affinity"=FALSE scope=spfile;

对于数据库实例，在11版本RAC中，DRM（Dynamic Resource Mastering）负责将 Cache 资源 Remaster 到频繁访问这部分数据的节点上，从而提高 RAC 的性能。但是 DRM 在实际使用中存在诸多 Bug，频繁的 DRM 会引发实例长时间 Hang 住甚至是宕机，建议关闭 DRM。
参考命令：alter system set "_gc_policy_time"=0 scope=spfile;

对于 ASM 库实例，在11版本中，当前实例的 memory_target 参数较低，可能会导致 ASM 实例内存不足，影响系统的正常运行，建议增大 ASM 实例的内存。
参考命令：alter system set memory_target=2147483648 scope=spfile;

对于数据库实例，在11版本RAC中，为了降低集群间的数据交互，建议并行进程强制在本地实例分配，以便降低集群间的数据交互。
参考命令：alter system set parallel_force_local=TRUE;


对于数据库实例，审计（Audit）用于监视用户所执行的数据库操作，审计记录可存在数据字典表，当数据库的审计是开启时，在语句执行阶段产生审计记录。由于审计表（AUD$）存放在SYSTEM表空间，因此为了不影响系统的性能，保护SYSTEM表空间，建议把AUD$移动到其他的表空间上，或者关闭审计。
参考命令：alter system set audit_trail='NONE' scope=spfile;

对于数据库实例，在11版本中，建议关闭分区使用大的初始化区（Extent）。
参考命令：alter system set "_partition_large_extents"=FALSE;

对于数据库实例，在11版本中，延迟段创建会导致使用 Direct 方式的 Export 出来的 DMP 文件无法正常导入（文档 ID 1604983.1），建议关闭延迟段创建的特性。
参考命令：alter system set deferred_segment_creation=FALSE;

