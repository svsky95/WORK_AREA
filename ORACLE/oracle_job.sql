--oracle JOB 
在toad 界面創建job，看其腳本是調用dbms_job.submit(),進行創建的，我們可以通過dba_jobs 來查詢到它的信息，然而10g后有一個新的創建函數 dbms_scheduler包的create_job()代替dba_jobs， 創建的job可以在dba_scheduler_jobs 查看到，信息更加詳細。
兩者的關係是：dbms_scheduler 代替dba_jobs


下面介紹dbms_scheduler 及其參數

grant create job to somebody;

 -- job 创建

 begin

 dbms_scheduler.create_job (

 job_name => 'AGENT_LIQUIDATION_JOB',

 job_type => 'STORED_PROCEDURE',

 job_action => 'AGENT_LIQUIDATION.LIQUIDATION', --存储过程名

 start_date => sysdate,

 repeat_interval => 'FREQ=MONTHLY; INTERVAL=1; BYMONTHDAY=1;BYHOUR=1;BYMINUTE=0;BYSECOND=0', -- 按月，间隔为1个(月),每月1号,凌晨1点

 comments => '执行代理商清分程序'

 );

 end;

 /

-- job 查询

 select owner, job_name, state from dba_scheduler_jobs;

 select job_name, state from user_scheduler_jobs;

--運行

dbms_scheduler.run_job('COLA_JOB',TRUE); -- true代表同步执行

--啟用

dbms_scheduler.enable('BACKUP_JOB');

--禁用

dbms_scheduler.disable('BACKUP_JOB');

--停止

     dbms_scheduler.stop_job(job_name => 'COLA_JOB',force => TRUE);

--刪除

 dbms_scheduler.drop_job(job_name => 'COLA_JOB',force => TRUE);)

调用DBMS_SCHDULER.CREATE_JOB的常用參數:

开始时间 (start_time);

 重复频率 (repeat_interval);

 结束时间 (end_time)

 job_name: 顾名思义,每个job都必须有一个的名称

 schedule_name: 如果定义了计划，在这里指定计划的名称

 job_type: 目前支持三种类型:
               PL/SQL块: PLSQL_BLOCK,

      存储过程: STORED_PROCEDURE

      外部程序: EXECUTABLE (外部程序可以是一个shell脚本,也可以是操作系统级别的指令).

 job_action: 根据job_type的不同，job_action有不同的含义.

    如果job_type指定的是存储过程，就需要指定存储过程的名字;

    如果job_type指定的是PL/SQL块，就需要输入完整的PL/SQL代码;

    如果job_type指定的外部程序，就需要输入script的名称或者操作系统的指令名

enabled: 上面已经说过了，指定job创建完毕是否自动激活

 comments: 对于job的简单说明


2. 指定job的执行频率

10G 支持两种模式的repeat_interval,

第一种是PL/SQL表达式，这也是dbms_job包中所使用的,例如SYSDATE+1, SYSDATE + 30/24*60;

 第二种就是日历表达式。

例如MON表示星期一,SUN表示星期天,DAY表示每天,WEEK表示每周等等. 下面来看几个使用日历表达式的例子：

 repeat_interval => 'FREQ=HOURLY; INTERVAL=2'

每隔2小时运行一次job

 repeat_interval => 'FREQ=DAILY'

    每天运行一次job

 repeat_interval => 'FREQ=WEEKLY; BYDAY=MON,WED,FRI'

 每周的1,3,5运行job

 repeat_interval => 'FREQ=YEARLY; BYMONTH=MAR,JUN,SEP,DEC; BYMONTHDAY=30'

    每年的3,6,9,12月的30号运行job

 Repeat_interval=>’FREQ=DAILY;INTERVAL=1;BYHOUR=12’

 用过crontab的人应该都有种似曾相识的感觉吧，呵呵

下面再说说使用日历表达式的规则:

日历表达式基本分为三部分:

第一部分是频率，也就是"FREQ"这个关键字，它是必须指定的;

第二部分是时间间隔，也就是"INTERVAL"这个关键字，取值范围是1-999. 它是可选的参数;

最后一部分是附加的参数,可用于精确地指定日期和时间,它也是可选的参数,例如下面这些值都是合法的:

BYMONTH,

BYWEEKNO,

BYYEARDAY,

BYMONTHDAY,
BYDAY

BYHOUR,

BYMINUTE,

BYSECOND

 (详细的参数说明请参考 dbms_scheduler的使用说明)

既然说到了repeat_interval,你可能要问:"有没有一种简便的方法来得出，或者说是评估出job的每次运行时间，以及下一次的运行时间呢?"

 dbms_scheduler包提供了一个过程evaluate_calendar_string,可以很方便地完成这个需求. 来看下面的例子:

 SQL> set serveroutput on size 999999

declare

 L_start_date TIMESTAMP;

 l_next_date TIMESTAMP;

 l_return_date TIMESTAMP;

begin

l_start_date := trunc(SYSTIMESTAMP);

l_return_date := l_start_date;

for ctr in 1..10 loop

dbms_scheduler.evaluate_calendar_string(

'FREQ=DAILY; BYDAY=MON,TUE,WED,THU,FRI; BYHOUR=7,15', l_start_date, l_return_date, l_next_date

);

dbms_output.put_line('Next Run on: ' ||

to_char(l_next_date,'mm/dd/yyyy hh24:mi:ss')

);

l_return_date := l_next_date;

end loop;

end;

/

输出结果如下:

Next Run on: 03/22/2004 07:00:00

Next Run on: 03/22/2004 15:00:00

Next Run on: 03/23/2004 07:00:00

Next Run on: 03/23/2004 15:00:00

Next Run on: 03/24/2004 07:00:00

Next Run on: 03/24/2004 15:00:00

Next Run on: 03/25/2004 07:00:00

--SCHEDULER JOB的其他系統視圖

select * from dict where table_name like '%SCHEDULER_JOB%'

主要參考DBA_SCHEDULER_JOB_LOG （默認保存一個月） 與DBA_SCHEDULER_JOB_RUN_DETAILS



2.INTERVAL参数常用值示例

 

    每天午夜12点            ''TRUNC(SYSDATE + 1)''     
    每天早上8点30分         ''TRUNC(SYSDATE + 1) + （8*60+30）/(24*60)''     
    每星期二中午12点         ''NEXT_DAY(TRUNC(SYSDATE ), ''''TUESDAY'''' ) + 12/24''     
    每个月第一天的午夜12点    ''TRUNC(LAST_DAY(SYSDATE ) + 1)''     
    每个季度最后一天的晚上11点 ''TRUNC(ADD_MONTHS(SYSDATE + 2/24, 3 ), ''Q'' ) -1/24''     
    每星期六和日早上6点10分    ''TRUNC(LEAST(NEXT_DAY(SYSDATE, ''''SATURDAY"), NEXT_DAY(SYSDATE, "SUNDAY"))) + （6×60+10）/（24×60）''    
    每3秒钟执行一次             'sysdate+3/(24*60*60)'   
    每2分钟执行一次           'sysdate+2/(24*60)'   
      
    1:每分钟执行  
    Interval => TRUNC(sysdate,'mi') + 1/ (24*60) --每分钟执行  
    interval => 'sysdate+1/（24*60）'  --每分钟执行  
    interval => 'sysdate+1'    --每天  
    interval => 'sysdate+1/24'   --每小时  
    interval => 'sysdate+2/24*60' --每2分钟  
    interval => 'sysdate+30/24*60*60'  --每30秒  
    2:每天定时执行  
    Interval => TRUNC(sysdate+1)  --每天凌晨0点执行  
    Interval => TRUNC(sysdate+1)+1/24  --每天凌晨1点执行  
    Interval => TRUNC(SYSDATE+1)+(8*60+30)/(24*60)  --每天早上8点30分执行  
    3:每周定时执行  
    Interval => TRUNC(next_day(sysdate,'星期一'))+1/24  --每周一凌晨1点执行  
    Interval => TRUNC(next_day(sysdate,1))+2/24  --每周一凌晨2点执行  
    4:每月定时执行  
    Interval =>TTRUNC(LAST_DAY(SYSDATE)+1)  --每月1日凌晨0点执行  
    Interval =>TRUNC(LAST_DAY(SYSDATE))+1+1/24  --每月1日凌晨1点执行  
    5:每季度定时执行  
    Interval => TRUNC(ADD_MONTHS(SYSDATE,3),'q')  --每季度的第一天凌晨0点执行  
    Interval => TRUNC(ADD_MONTHS(SYSDATE,3),'q') + 1/24  --每季度的第一天凌晨1点执行  
    Interval => TRUNC(ADD_MONTHS(SYSDATE+ 2/24,3),'q')-1/24  --每季度的最后一天的晚上11点执行  
    6:每半年定时执行  
    Interval => ADD_MONTHS(trunc(sysdate,'yyyy'),6)+1/24  --每年7月1日和1月1日凌晨1点  
    7:每年定时执行  
    Interval =>ADD_MONTHS(trunc(sysdate,'yyyy'),12)+1/24  --每年1月1日凌晨1点执行 


   
#######用job调用本地的shell脚本#######
##脚本需在oracle用户下创建
[oracle@racnode01 ~]$ vim test_job.sh
#!/bin/sh
echo "zzz ***"$(date) >>/home/oracle/job.log
echo "test----job"    >>/home/oracle/job.log

##job必须在sqlplus 中sys用户创建
exec  dbms_scheduler.drop_job('test_shell');
---创建job
exec  dbms_scheduler.create_job(JOB_NAME=>'test_shell', job_type => 'EXECUTABLE',job_action=>'/bin/bash',number_of_arguments => 1,start_date => sysdate,repeat_interval=> 'sysdate+3/(24*60*60)', comments => 'test shell');
---设置参数
exec dbms_scheduler.set_job_argument_value(job_name=>'test_shell', argument_position=>1, argument_value=>'/home/oracle/test_job.sh') ;
--enable
exec dbms_scheduler.enable(NAME=>'test_shell');
--手动调用
exec  dbms_scheduler.run_job(job_name => 'test_shell');

##查询任务
SELECT * FROM dba_scheduler_jobs;
SELECT * FROM dba_scheduler_job_run_details t WHERE t.JOB_NAME='TEST_SHELL';



##权限调整
grant execute on NF_JFXT.JF_TAB_BAK to NF_JFXT;
grant create any table  to nf_jfxt;
grant select on NF_JFXT.NF_JFXT_DQJF to NF_JFXT;
grant select on NF_JFXT.NF_JFXT_ZRRDQJF to NF_JFXT;
grant debug any procedure to NF_JFXT; 
 
##创建存储过程
create or replace procedure 
   jf_tab_bak
as
  lvDate varchar2(50);
  lvSql  varchar2(500);
begin
  select to_char(sysdate,'yyyyMMdd') into lvdate from dual;
  lvsql := 'create table hx_dj.dj_nsrxx_' || lvdate || ' as select * from hx_dj.dj_nsrxx';
  dbms_output.put_line(lvsql);
  EXECUTE IMMEDIATE lvsql;
end;

##创建任务
begin

 dbms_scheduler.create_job (

 job_name => 'JF_TAB_BAK_PRO_D',

 job_type => 'STORED_PROCEDURE',

 job_action => 'CZ.JF_TAB_BAK', --存储过程名

 start_date => sysdate,
 
 enabled   => true,

 repeat_interval => 'FREQ=DAILY; ByHour=10;ByMinute=45', -- 每天10:45执行

 comments => '积分备份'

 );

 end;
 
--开启任务
SQL> exec  dbms_scheduler.enable('cz.JF_TAB_BAK_PRO_D');
--调用任务
SQL> exec  dbms_scheduler.run_job(job_name => 'NF_JFXT.JF_TAB_BAK_PRO');

--查看正在运行的JOB
SELECT * FROM Dba_Jobs_Running; 

--JOB与session的关联
SELECT b.inst_id ,B.SID, B.SERIAL#, C.SPID
  FROM DBA_JOBS_RUNNING A, gV$SESSION B, gV$PROCESS C
 WHERE A.SID = B.SID
   AND B.PADDR = C.ADDR;
   
--查看任务
 SELECT * FROM dba_scheduler_jobs t WHERE t.JOB_NAME='JF_TAB_BAK_PRO_D' order by 2 desc; --enabled=true
 根据program_name = PG_DZDZ_01_BD_JS 
 找到 SELECT * FROM dba_scheduler_programs t WHERE t.PROGRAM_NAME='PG_DZDZ_01_BD_JS';
 得到pck_dzdz_sjjs.P_SJ_JS_FPLX 不是存储过程，就是包的名字
 查看packages的内容：SELECT * FROM dba_source t WHERE t.name='PCK_DZDZ_SJJS' order by line; 

--查看运行详细
 SELECT * FROM dba_scheduler_job_run_details t WHERE t.JOB_NAME='JF_TAB_BAK_PRO_D' order by 2 desc;  
-run_duration job持续时间


--查看运行日志
 SELECT * FROM dba_scheduler_job_log t WHERE t.JOB_NAME='JF_TAB_BAK_PRO_D' order by 2 desc;