Oracle11g����
����ʱ�䣺 2014/11/11 11:58
����ʱ�䣺 2014/11/18 22:39

#========================================================================
#     FileName: 11gR2����.txt
#         Desc: 
#       Author: PeiZhengfeng
#        Email: peizhengfeng@hthorizon.com
#     HomePage: http://www.hthorizon.com
#      Version: 0.0.1
#      Created: 2014-10-24 14:00:27
#   LastChange: 2014-10-24 14:00:27
#      History:
#========================================================================

    1. �ڴ����
    .   1.1 �����ڴ����
    .   1.2 ��������
    .   1.3 ���Կ��ǵĲ���
    2. ����profile
    3. ����CRS����
    4. �޸ļ����˿�
    5. �ر��Զ�ִ�е�JOB
    6. ����AWR����ʱ��
    7. ֹͣora.crf����
    8. RMAN����Ҫ����
    9. ����Ŀ¼Ȩ��
    10. ����redo
    .   10.1 ����redo��
    .   10.2 ����redo��ĳ�Ա
    .   10.3 ɾ��redo��
    .   10.4 ɾ��redo���Ա


=========================================================================================
1. �ڴ����

1.1 �����ڴ����
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

1.2 ��������
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
alter system set "_clusterwide_global_transactions"=false scope=spfile sid='*';               #11g�����ԣ�ȱʡ��true�����ܻᵼ��DBLINK HANG����UNDO���飬ͬʱOGG�Ľ���Ҳ�������

1.3 ���Կ��ǵĲ���
*************************************************
alter system set audit_trail=none scope=spfile sid='*';
alter system set "_resource_manager_always_on"=FALSE scope=both sid='*';
*.event="28401 trace name context forever,level 1"     # �ر�logon delay����ֹ������������Ե��µ�library cache lock/pin
*._bloom_filter_enabled                                        # bloom�㷨������disable
*._bloom_pruning_enabled
*._datafile_write_errors_crash_instance=false          # ���Կ���
*._high_priority_processes='LMS*|LGWR|PMON'         # ��߽��̵����ȼ�

=========================================================================================
2. ����profile
SQL> alter profile default limit PASSWORD_LIFE_TIME unlimited;
Profile altered.

SQL> alter profile default limit FAILED_LOGIN_ATTEMPTS unlimited;
Profile altered.

=========================================================================================
3. ����CRS����
/oracle/product/11.2.0/grid/bin/crsctl set css misscount 150
/oracle/product/11.2.0/grid/bin/crsctl set css disktimeout 200

/oracle/product/11.2.0/grid/bin/crsctl get css misscount
/oracle/product/11.2.0/grid/bin/crsctl get css disktimeout

=========================================================================================
4. �޸ļ����˿�
srvctl modify scan_listener -p "TCP:1621"
srvctl stop scan_listener
srvctl start scan_listener
srvctl modify listener -l LISTENER_SCAN1 -p "TCP:1621"
srvctl stop listener
srvctl start listener

=========================================================================================
5. �ر��Զ�ִ�е�JOB
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
6. ����AWR����ʱ��
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
7. ֹͣora.crf����
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
8. RMAN����Ҫ����
RMAN> CONFIGURE SNAPSHOT CONTROLFILE NAME TO '<shared_disk>/snapcf_<DBNAME>.f';
�ο�: ORA-245: In RAC environment from 11.2 onwards Backup Or Snapshot controlfile needs to be in shared location (�ĵ� ID 1472171.1)

=========================================================================================
9. ����Ŀ¼Ȩ��
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
10. ����redo

10.1 ����redo��
alter database add logfile thread 1   group 1  ('/redo/inas/redo11.dbf') size 2048M;
alter database add logfile thread 1   group 2  ('/redo/inas/redo21.dbf') size 2048M;
alter database add logfile thread 1   group 3  ('/redo/inas/redo31.dbf') size 2048M;
alter database add logfile thread 1   group 4  ('/redo/inas/redo41.dbf') size 2048M;

10.2 ����redo��ĳ�Ա
alter database add logfile member
  '/redo/inas/redo12.dbf' to group 1,
  '/redo/inas/redo22.dbf' to group 2,
  '/redo/inas/redo32.dbf' to group 3,
  '/redo/inas/redo42.dbf' to group 4;

10.3 ɾ��redo��
alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;
alter database drop logfile group 4;

10.4 ɾ��redo���Ա
alter database drop logfile member '/redo/inas/redo92.dbf';
alter database drop logfile member '/redo/inas/redo102.dbf';
alter database drop logfile member '/redo/inas/redo112.dbf';
alter database drop logfile member '/redo/inas/redo122.dbf';
alter database drop logfile member '/redo/inas/redo132.dbf';
alter database drop logfile member '/redo/inas/redo142.dbf';
alter database drop logfile member '/redo/inas/redo152.dbf';
alter database drop logfile member '/redo/inas/redo162.dbf';

--RAC ���߲����Ż�


��ǰ���ݿ��У��Ѿ������˰󶨱�����̽��Ĭ�����ã�����ϵͳ�Զ��ռ�ͳ����Ϣ�������ݱ��������ݴ���������б������¿��ܻᵼ�� SQL �������⣬��Ҫ��ע��

�������ݿ�ʵ������11�汾�У������������Ӧ�α깲������������_optimizer_extended_cursor_sharing_rel����Ϊ NONE��
�ο����alter system set "_optimizer_extended_cursor_sharing_rel"='NONE';

�������ݿ�ʵ������11�汾�У����� _optimizer_null_aware_antijoin ���� Oracle 11g ������²����������ڽ���ڷ����ӣ�Anti-Join��ʱ���������ϴ��ڿ�ֵ��NULL����������޷ǿ�Լ�������⡣���Ǹò������ȶ������ڽ϶�� Bug��Ϊ���ⴥ����� Bug������رա�
�ο����alter system set "_optimizer_null_aware_antijoin"=FALSE;

�������ݿ�ʵ������11�汾�У������������Ӧ�α깲������������_optimizer_extended_cursor_sharing����Ϊ NONE��
�ο����alter system set "_optimizer_extended_cursor_sharing"='NONE';

�������ݿ�ʵ������11�汾�У��������� _optimizer_adaptive_cursor_sharing �ܿ�������Ӧʽ�α깲��Ĳ�����Ϊ���� Oracle ����Ӧ�Ĵ���󶨱����Ŀ�̽��������ܻᴥ���������⡣ Oracle �����ڷǼ���ָ���£�����رյ���
�ο����alter system set "_optimizer_adaptive_cursor_sharing"=FALSE;

�������ݿ�ʵ������11�汾�У�����������Cardinality Feedback���� Oracle 11.2 ������Ĺ��� SQL �����Ż��������ԣ���������Ҫ���ͳ����Ϣ�¾ɡ���ֱ��ͼ����Ȼ��ֱ��ͼ���Ի������㲻׼ȷ�������Cardinality �����ļ���ֱ��Ӱ�쵽������ JOIN COST ����Ҫ�ĳɱ�������������� CBO ѡ�񲻵���ִ�мƻ������Ǹò������ڲ��ȶ����أ����ܻ����ִ��Ч�ʵ����⣬����ر��Ż���������
�ο����alter system set "_optimizer_use_feedback"=FALSE;

�������ݿ�ʵ������11�汾�У�����ִ�еĴ��������ڹ���ʱ��Ҫ�������ݺ���Ϣ��Ĭ�ϴ� Shared Pool �з����ڴ�ռ䡣�� _PX_use_large_pool=TRUE ʱ���н��̽��� Large Pool �з����ڴ棬���ٶԹ���أ�Shared Pool�������á�
�ο����alter system set "_PX_use_large_pool"=TRUE scope=spfile;

�������ݿ�ʵ������11�汾�У��������� _undo_autotune ���� undo retention���� undo �εı���ʱ�䣩���Զ����������� Oracle �Զ����� undo retention���� Oracle �������������ռ�� undo ��ռ䣬���ܻ��γ� undo ��ռ�����ã����齫��رա�
�ο����alter system set "_undo_autotune"=FALSE;

�������ݿ�ʵ������11�汾�У���������İ�ȫ���󣬽���ر������Сд���в��ԡ�
�ο����alter system set sec_case_sensitive_logon=FALSE;


�������ݿ�ʵ������11�汾RAC�У�����رռ�Ⱥ Undo Affinity�����ͼ�Ⱥ���������ⴥ����� BUG��
�ο����alter system set "_gc_undo_affinity"=FALSE scope=spfile;

�������ݿ�ʵ������11�汾RAC�У�DRM��Dynamic Resource Mastering������ Cache ��Դ Remaster ��Ƶ�������ⲿ�����ݵĽڵ��ϣ��Ӷ���� RAC �����ܡ����� DRM ��ʵ��ʹ���д������ Bug��Ƶ���� DRM ������ʵ����ʱ�� Hang ס������崻�������ر� DRM��
�ο����alter system set "_gc_policy_time"=0 scope=spfile;

���� ASM ��ʵ������11�汾�У���ǰʵ���� memory_target �����ϵͣ����ܻᵼ�� ASM ʵ���ڴ治�㣬Ӱ��ϵͳ���������У��������� ASM ʵ�����ڴ档
�ο����alter system set memory_target=2147483648 scope=spfile;

�������ݿ�ʵ������11�汾RAC�У�Ϊ�˽��ͼ�Ⱥ������ݽ��������鲢�н���ǿ���ڱ���ʵ�����䣬�Ա㽵�ͼ�Ⱥ������ݽ�����
�ο����alter system set parallel_force_local=TRUE;


�������ݿ�ʵ������ƣ�Audit�����ڼ����û���ִ�е����ݿ��������Ƽ�¼�ɴ��������ֵ�������ݿ������ǿ���ʱ�������ִ�н׶β�����Ƽ�¼��������Ʊ�AUD$�������SYSTEM��ռ䣬���Ϊ�˲�Ӱ��ϵͳ�����ܣ�����SYSTEM��ռ䣬�����AUD$�ƶ��������ı�ռ��ϣ����߹ر���ơ�
�ο����alter system set audit_trail='NONE' scope=spfile;

�������ݿ�ʵ������11�汾�У�����رշ���ʹ�ô�ĳ�ʼ������Extent����
�ο����alter system set "_partition_large_extents"=FALSE;

�������ݿ�ʵ������11�汾�У��ӳٶδ����ᵼ��ʹ�� Direct ��ʽ�� Export ������ DMP �ļ��޷��������루�ĵ� ID 1604983.1��������ر��ӳٶδ��������ԡ�
�ο����alter system set deferred_segment_creation=FALSE;

