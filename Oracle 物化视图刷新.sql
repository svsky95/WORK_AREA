##Oracle 物化视图
物化视图和物化视图日志
物化视图的创建，基于表。
物化视图日志是基于原表的创建的，为了记录变更信息，分为基于primary key（必须有主键）以及 rowid ，目的是为了当原表有变化时，可以根据物化视图
日志进行增量刷新。
物化视图对于前台数据库使用者来说如同一个实际的表,具有和一般表相同的如select等操作,而其实际上是一个视图,一个由系统实现定期刷新其数据的视图(具体刷新时间在定义物化视图的时候已有定义),使用物化视图更可以实现视图的所有功能,而物化视图却不是在使用时才读取,大大提高了读取速度,特别适用抽取大数据量表某些信息以及数据链连接表使用，但是物化视图占用数据库磁盘空间。具体语法如下:

1、在源端创建物化视图日志，请看清，对端的表有可能是同义词，一定要在原表上创建日志。
1.1 创建物化视图日志，当物化视图刷新成功后，物化视图的日志的记录会删除掉
create materialized view log on NF_SSSL.NF_SSSL_SBYWRZ with  primary key/with rowid; 

1.2 删除物化视图日志
drop materialized view log on hx_sb.sb_sbb
--对于已定义主键的表，分别执行以下 sql：create materialized view log on 表名  with primary key; 
在mlog$中对应的表，第一个字段是原表的主键列名

--对于未定义主键的表，分别执行以下 sql：create materialized view log on 表名  with rowid;
在mlog$中对应的表，第一个字段是M_ROW$$


2、在目标端，通过DBlink的方法创建刷新物化视图
CREATE MATERIALIZED VIEW sjyy.nf_sssl_sbywrz_2    --物化视图中有distinct不能加FAST参数
REFRESH FAST ON DEMAND          
NEXT SYSDATE + 1/(24*60)   --每分钟刷新
WITH primary key           --基于PRIMARY KEY   
AS 
SELECT * FROM NF_SSSL.NF_SSSL_SBYWRZ@SJYY_SNGSNFDB sb
 where sb.jyzt_dm = '00'
   and sb.sjgsrq >= to_date('2018-02-01', 'yyyy-mm-dd');
   
3、删除物化视图
drop materialized view an_user_base_file_no_charge;

--确认物化视图的刷新时间
SELECT * FROM dba_jobs;  

--查看物化视图信息
SELECT * FROM dba_mviews; //物化视图表
SELECT * FROM dba_mview_logs; //原表与物化视图日志表的关系，其实这里的对应关系是找不出对应的物化视图是什么名字的
SELECT * FROM sys.mlog$;
SELECT * FROM sys.snap$ t WHERE t.sowner='CZ'; //当原表的物化视图日志有变化时，就会按时间新型刷新，这里可以找到物化视图最新的刷新时间

--A用户刷新B用户的物化视图
GRANT ALTER ANY MATERIALIZED VIEW TO ***;--***：为需要授权的用户。



##参数说明
create materialized view [view_name]
refresh [fast|complete|force]
[
on [commit|demand] |
start with (start_time) next (next_time)
]
as
{创建物化视图用的查询语句}

具体实例如下：

CREATE MATERIALIZED VIEW an_user_base_file_no_charge
             REFRESH COMPLETE START WITH SYSDATE
            NEXT TRUNC(SYSDATE+29)+5.5/24    --红色部分表示从指定的时间开始，每隔一段时间（由next指定）就刷新一次
AS
select distinct user_no
from cw_arrearage t
where (t.mon = dbms_tianjin.getLastMonth or
       t.mon = add_months(dbms_tianjin.getLastMonth, -1))


以上是Oracle创建物化视图（Materialized View,以下简称MV）时的常用语法,各参数的含义如下:

1.refresh [fast|complete|force] 视图刷新的方式:
fast: 增量刷新.假设前一次刷新的时间为t1,那么使用fast模式刷新物化视图时,只向视图中添加t1到当前时间段内,主表变化过的数据.为了记录这种变化，建立增量刷新物化视图还需要一个物化视图日志表。create materialized view log on （主表名）。
complete:全部刷新。相当于重新执行一次创建视图的查询语句。
force: 这是默认的数据刷新方式。当可以使用fast模式时，数据刷新将采用fast方式；否则使用complete方式。

2.MV数据刷新的时间：
on demand:在用户需要刷新的时候刷新，这里就要求用户自己动手去刷新数据了（也可以使用job定时刷新）
on commit:当主表中有数据提交的时候，立即刷新MV中的数据；
start ……：从指定的时间开始，每隔一段时间（由next指定）就刷新一次；


手动刷新物化视图：
begin
     dbms_mview.refresh(list=>'an_user_base_file_no_charge',
                                       METHOD=>'COMPLETE',
                                       PARALLELISM=>8);   --PARALLELISM并行控制参数
end;
/

增量刷新就不需要使用什么并行了，通常情况下，是没有那个必要的。

begin
     dbms_mview.refresh(list=>'an_user_base_file_no_charge',
                                       METHOD=>'FAST',
                                       PARALLELISM=>1);
end;
/

--启动job

exec dbms_job.run(774);

 --停用job

EXEC DBMS_JOB.BROKEN(job#,TRUE); 

EXEC DBMS_JOB.BROKEN(774, TRUE); 




oracle 物化视图的自动刷新方法：

	方法1，直接在创建的时候，指定start with ，如下代表每分钟执行1次

	create materialized view big_table_mv nologging

	refresh fast on demand

	with rowid

	START WITH TO_DATE('18-03-2011 10:09:08', 'DD-MM-YYYY HH24:MI:SS') NEXT SYSDATE + 1 / 60*24

	as select * from big_table;

	


	方法2：编写批量刷新某个用户的所有物化视图的procedure，然后结合job可以定时去执行，

	create or replace procedure  pro_refresh_maview   is

	begin

	 declare  CURSOR   c_number   is

	select user||'.'||mview_name  mview_name from user_mviews;

	    my_re     c_number%rowtype;

	    begin

	    open   c_number;

	    loop

	   exit  when c_number%notfound;

	   fetch c_number  into  my_re;

	   DBMS_MVIEW.REFRESH(my_re.mview_name,'C');

	   end loop;

	   close c_number;

	   end;

	   end  pro_refresh_maview  ;    

	刷新某一个物化视图的存储过程mv_emp：

	CREATE OR REPLACE PROCEDURE auto_refresh_mview_job_proc

	AS

	BEGIN

	dbms_mview.REFRESH('mv_emp');

	END;

	/

	创建前面存储过程pro_refresh_maview的job（每五分钟执行一次存储过程)这压根就自动刷新了

	declare

	   pro_refresh_maview_job number;

	begin

	  dbms_job.submit( pro_refresh_maview_job,'pro_refresh_maview;',sysdate,'sysdate+1/24/60*5');     ##绿色部分是前面创建的存储过程。红色部分是自己编写的名字

	  end;

	2、查询job的ID,前面创建的job,

	select * from dba_jobs; 

	select * from all_jobs; 

	select * from user_jobs;

	3、根据job的id手动执行前面该job ， 

	begin

	  dbms_job.run(44);

	  end;


	批量刷新某个用户的全部的物化视图，使用游标，这样只能执行一个

	begin

	for rec in (select user||'.'||mview_name  mview_name from user_mviews)

	loop

	DBMS_MVIEW.REFRESH(rec.mview_name,'C');

	end loop;

	end;

	总结：oracle数据库物化视图定时刷新就两种方法，一种是创建的过程中指定start with参数，一种是procedure+jop，当然在程序里面也可以去控制自动刷新物化视图。

 
##物化视图日志过大处理##
巡检发现数据库有张表超过200G，通过名称判断是某张表的物化视图日志，表大小是200M左右，每小时刷新一次物化视图，正常刷新完成会自动清理物化视图日志，现在要根据现象进行排查。

通过分析Oracle系统视图，我们发现当前物化视图（MV_ORG_PERSON）定义语句用到refresh force，此选项提供fast和complete两种选择，当无法做快速刷新时会自动选择全量刷新；系统视图dba_mviews中last_refresh_type字段值显示为COMPLETE，证明上次物化视图为全量刷新，结合dba_mview_analysis中的fullrefreshtim字段，发现一次全量刷新需要7秒左右，检查物化视图日志mlog$_table_name及mlog$_table_name1中的snaptime$$字段，存在大量时间为4000/1/1的值，再检查dba_base_table_mviews中的MVIEW_LAST_REFRESH_TIME字段，时间为2017/2/21，这代表从2017/2/21开始物化视图日志中的数据并未被物化视图用到，因此得出以下结论：

此物化视图日志并未对当前物化视图提供快速刷新功能，导致自动选择全量刷新；

注释：dba_base_table_mviews 此视图提供使用物化视图日志进行快速刷新的时间，必须同时满足有创建物化视图日志并使用了快速刷新两个条件才会更新MVIEW_LAST_REFRESH_TIME字段的值

 准备对物化视图日志mlog$_table_name进行清理，操作步骤如下：

1、删除物化视图日志
由于物化视图日志表，记录原表的更新，为了保证一致性，需要先锁定原表。
LOCK TABLE T_600_RESULTS IN EXCLUSIVE MODE nowait; 
Drop materialized view log on table_name;
释放锁，就是杀掉进程
2、手动刷新物化视图，检查状态

3、业务人员检查业务状态

 

应急预案：

         如果删除物化视图日志后对物化视图出现影响，手动添加物化视图日志，并重建物化视图，根据系统视图（dba_mview_analysis）提供时间，一次全量刷新在7秒钟左右。

         以下为应急预案步骤：

1、create materialized view log on table_name;

2、drop materialized view MV_table_name;

3、物化视图重建语句

4、业务人员检查业务状态


##锁定原表的物化视图日志收缩##
-对物化视图刷新基表强制独占锁
LOCK TABLE T_600_RESULTS IN EXCLUSIVE MODE nowait; 
--创建物化视图临时日志表
CREATE TABLE MV_TEMP_600_RESULTS NOLOGGING AS SELECT * FROM MLOG$_T_600_RESULTS 
--清理物化视图日志表
TRUNCATE TABLE MLOG$_T_600_RESULTS
--将临时日志表内容重新同步到物化视图日志表
INSERT INTO MLOG$_T_600_RESULTS SELECT * FROM MV_TEMP_600_RESULTS
--释放锁资源，执行回滚操作
ROLLBACK; 


#####物化视图日志表的在线收缩,由于物化视图日志表，频繁的插入删除，导致提高了高水位线，收缩的目的就是降低高水位线。
BEGIN
  DBMS_REDEFINITION.CAN_REDEF_TABLE(UNAME        => 'CZ',
                                    TNAME        => 'MLOG$_T_600_RESULTS',
                                    OPTIONS_FLAG => DBMS_REDEFINITION.cons_use_rowid);
END;

--创建在线重定义临时表
创建一张与原来基表对应一样的物化视图表
DROP TABLE MV_TEMP_600_RESULTS CASCADE CONSTRAINTS; 
create table MV_TEMP_600_RESULTS
(
  col1            NUMBER,
  snaptime$$      DATE,
  dmltype$$       VARCHAR2(1),
  old_new$$       VARCHAR2(1),
  change_vector$$ RAW(255),
  xid$$           NUMBER
)
SEGMENT CREATION IMMEDIATE;

drop table MV_TEMP_600_RESULTS;
--开始在线重定义操作
BEGIN
  DBMS_REDEFINITION.START_REDEF_TABLE(UNAME        => 'CZ',
                                      ORIG_TABLE   => 'MLOG$_T_600_RESULTS',
                                      INT_TABLE    => 'MV_TEMP_600_RESULTS',
                                      OPTIONS_FLAG => DBMS_REDEFINITION.CONS_USE_ROWID);
END;



--复制依赖对象 即：主键、索引、约束、check等 ,迁移原日志表中的数据到临时表中。
DECLARE
  NUM_ERRORS PLS_INTEGER;
BEGIN
  DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(UNAME            => 'CZ',
                                          ORIG_TABLE       => 'MLOG$_T_600_RESULTS',
                                          INT_TABLE        => 'MV_TEMP_600_RESULTS',
                                          COPY_INDEXES     => DBMS_REDEFINITION.CONS_ORIG_PARAMS,
                                          COPY_TRIGGERS    => TRUE,
                                          COPY_CONSTRAINTS => FALSE,
                                          COPY_PRIVILEGES  => TRUE,
                                          IGNORE_ERRORS    => FALSE,
                                          NUM_ERRORS       => NUM_ERRORS,
                                          COPY_STATISTICS  => TRUE);
END;

SELECT * FROM MLOG$_T_600_RESULTS;
SELECT * FROM MV_TEMP_600_RESULTS;

--开始在线重定义同步操作
BEGIN
  DBMS_REDEFINITION.SYNC_INTERIM_TABLE(UNAME      => 'CZ',
                                       ORIG_TABLE => 'MLOG$_T_600_RESULTS',
                                       INT_TABLE  => 'MV_TEMP_600_RESULTS');
END;
--完成在线重定义操作
BEGIN
  DBMS_REDEFINITION.FINISH_REDEF_TABLE(UNAME      => 'CZ',
                                       ORIG_TABLE => 'MLOG$_T_600_RESULTS',
                                       INT_TABLE  => 'MV_TEMP_600_RESULTS');
END;

--验证发现，原日志表的占用物理空间变少了，其实就是降低了高水位线
SELECT t.BYTES FROM dba_segments t WHERE t.segment_name='MLOG$_T_600_RESULTS';


SELECT * FROM sys.mlog$;
SELECT * FROM MLOG$_T_600_RESULTS;
SELECT * FROM MV_TEMP_600_RESULTS;

这里使用rowid方式，重定义完的表上会多出一个隐藏字段，从10.2开始M_ROW$$的隐藏列会被命名为SYS_%DATE%的形式，且默认即为unused状态：
SELECT * FROM DBA_UNUSED_COL_TABS WHERE TABLE_NAME = Q'{MLOG$_T_600_RESULTS}'
--
ALTER TABLE MLOG$_T_600_RESULTS DROP UNUSED COLUMNS; 