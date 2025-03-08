#######Logminer配置和使用#######
--Logminer由于需要重启数据库才可以使用，可以把归档日志文件拷贝到测试库路径下，然后导出到表后，再导回到生产库上。
在使用LogMiner之前需要确认Oracle是否带有进行LogMiner分析包，一般来说Windows操作系统Oracle10g以上都默认包含。如果不能确认，可以DBA身份登录系统，查看系统中是否存在运行LogMiner所需要的dbms_logmnr、dbms_logmnr_d包，如果没有需要安装LogMiner工具，必须首先要运行下面这样两个脚本：
1、$ORACLE_HOME/rdbms/admin/dbmslm.sql
2、$ORACLE_HOME/rdbms/admin/dbmslmd.sql.
这两个脚本必须均以DBA用户身份运行。其中第一个脚本用来创建DBMS_LOGMNR包，该包用来分析日志文件。第二个脚本用来创建DBMS_LOGMNR_D包，该包用来创建数据字典文件。

创建完毕后将包括如下过程和视图：

Dbms_logmnr_d.build      创建一个数据字典文件
Dbms_logmnr.add_logfile  在类表中增加日志文件以供分析
Dbms_logmnr.start_logmnr 使用一个可选的字典文件和前面确定要分析日志文件来启动LogMiner
Dbms_logmnr.end_logmnr   停止LogMiner分析

V$logmnr_dictionary      显示用来决定对象ID名称的字典文件的信息
V$logmnr_logs            在LogMiner启动时显示分析的日志列表
V$logmnr_contents        LogMiner启动后，可以使用该视图在SQL提示符下输入SQL语句来查询重做日志的内容

##创建数据字典文件
LogMiner工具实际上是由两个新的PL/SQL内建包（(DBMS_LOGMNR 和 DBMS_ LOGMNR_D）和四个V$动态性能视图（视图是在利用过程DBMS_LOGMNR.START_LOGMNR启动LogMiner时创建）组成。在使用LogMiner工具分析redo log文件之前，可以使用DBMS_LOGMNR_D 包将数据字典导出为一个文本文件。该字典文件是可选的，但是如果没有它，LogMiner解释出来的语句中关于数据字典中的部分（如表名、列名等）和数值都将是16进制的形式，我们是无法直接理解的。
INSERT INTO dm_dj_swry (rydm, rymc) VALUES (00005, '张三'); 
LogMiner解释出来的结果将是下面这个样子：
insert into Object#308(col#1, col#2) values (hextoraw('c30rte567e436'), hextoraw('4a6f686e20446f65')); 

创建数据字典的目的就是让LogMiner引用涉及到内部数据字典中的部分时为他们实际的名字，而不是系统内部的16进制。数据字典文件是一个文本文件，使用包DBMS_LOGMNR_D来创建。如果我们要分析的数据库中的表有变化，影响到库的数据字典也发生变化，这时就需要重新创建该字典文件。另外一种情况是在分析另外一个数据库文件的重作日志时，也必须要重新生成一遍被分析数据库的数据字典文件。
创建数据字典文件之前需要配置LogMiner文件夹：

#创建目录：
[root@racnode01 ~]# su - oracle
oracle@racnode01 ~]$ mkdir logmnr

CREATE DIRECTORY utlfile AS '/home/oracle/logmnr';
alter system set utl_file_dir='/home/oracle/logmnr' scope=spfile sid='*';
重启数据库，使参数生效
srvctl stop database -d racdb

#开启最小附加日志：
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
SELECT SUPPLEMENTAL_LOG_DATA_MIN FROM V$DATABASE;

####logminer是基于会话的，对于其它会话不可见，建议使用plsqldev的SQL窗口。
#创建数据字典文件
EXECUTE dbms_logmnr_d.build(dictionary_filename => 'dictionary.ora', dictionary_location =>'/home/oracle/logmnr');

#添加分析的文件，可以分析redo log及archive log
--onlinelog
BEGIN
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/onlinelog/group_2.261.1011625547',options=>dbms_logmnr.NEW);
END;
/

--查看载入的文件
SELECT * FROM v$logmnr_logs;

#开启分析
--无限制条件分析
begin
dbms_logmnr.start_logmnr(dictfilename=>'/home/oracle/logmnr/dictionary.ora');
end;
/


--有限制条件
-基于时间点
begin
  dbms_logmnr.start_logmnr(DictFileName => '/home/oracle/logmnr/dictionary.ora',
                           StartTime    => to_date('2013-6-8 00:00:00',
                                                   'YYYY-MM-DD HH24:MI:SS'),
                           EndTime      => to_date('2013-6-8 23:59:59',
                                                   'YYYY-MM-DD HH24:MI:SS '));
end;
/

-基于SCN
SQL> select current_scn from v$database;

          CURRENT_SCN
---------------------
             15723709


begin
  dbms_logmnr.start_logmnr(DictFileName => '/home/oracle/logmnr/dictionary.ora',
                           StartScn=>15887121,
                           EndScn=>15887221 );
end;
/



#查看结果
SELECT t."SEG_OWNER",t."SEG_NAME",t."SQL_REDO" FROM v$logmnr_contents t WHERE  t."SEG_OWNER"='LX' and t."SEG_NAME"='TEST02'; 

#误删除导致的数据丢失，也可以从redo log中找回
SELECT t."USERNAME",t."OS_USERNAME",t."MACHINE_NAME",t."SEG_OWNER",t."SEG_NAME",t."OPERATION",t."SQL_REDO",t."SQL_UNDO" FROM v$logmnr_contents t WHERE  t."SEG_OWNER"='CZ' and t."SEG_NAME"='TEST01' and t."OPERATION"='DELETE'; 

###归档日志添及分析
--批量生成语句，改修第一条记录为dbms_logmnr.NEW。
select 'dbms_logmnr.add_logfile(logfilename=>'''||name||''',options=>dbms_logmnr.ADDFILE);' from 
(SELECT name FROM v$archived_log t where to_char(t."COMPLETION_TIME",'YYYY/MM/DD HH24:MI:SS') between '2019/11/22 15:00:12' and  '2019/11/22 15:08:38' and t.thread#=1 and t."STANDBY_DEST"='NO');

begin
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_35.811.1025017211',options=>dbms_logmnr.NEW);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_36.803.1025017213',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_37.802.1025017213',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_38.795.1025017285',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_39.790.1025017289',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_40.789.1025017291',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_41.785.1025017297',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_42.778.1025017391',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_43.775.1025017395',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_44.768.1025017397',options=>dbms_logmnr.ADDFILE);
dbms_logmnr.add_logfile(logfilename=>'+DATA/racdb/archivelog/2019_11_22/thread_1_seq_45.765.1025017401',options=>dbms_logmnr.ADDFILE);
end;
/

begin
dbms_logmnr.start_logmnr(dictfilename=>'/home/oracle/logmnr/dictionary.ora');
end;
/

SELECT t."USERNAME",t."OS_USERNAME",t."MACHINE_NAME",t."SEG_OWNER",t."SEG_NAME",t."OPERATION",t."SQL_REDO",t."SQL_UNDO" FROM v$logmnr_contents t WHERE  t."SEG_OWNER"='CZ' and t."SEG_NAME"='TEST01' and t."OPERATION"='DELETE'; 