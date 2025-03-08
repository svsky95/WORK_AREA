--oracle JOB 
��toad ���愓��job�������_�����{��dbms_job.submit(),�M�Є����ģ��҂�����ͨ�^dba_jobs ���ԃ��������Ϣ��Ȼ��10g����һ���µĄ������� dbms_scheduler����create_job()����dba_jobs�� ������job������dba_scheduler_jobs �鿴������Ϣ����Ԕ����
���ߵ��P�S�ǣ�dbms_scheduler ����dba_jobs


�����Bdbms_scheduler ���䅢��

grant create job to somebody;

 -- job ����

 begin

 dbms_scheduler.create_job (

 job_name => 'AGENT_LIQUIDATION_JOB',

 job_type => 'STORED_PROCEDURE',

 job_action => 'AGENT_LIQUIDATION.LIQUIDATION', --�洢������

 start_date => sysdate,

 repeat_interval => 'FREQ=MONTHLY; INTERVAL=1; BYMONTHDAY=1;BYHOUR=1;BYMINUTE=0;BYSECOND=0', -- ���£����Ϊ1��(��),ÿ��1��,�賿1��

 comments => 'ִ�д�������ֳ���'

 );

 end;

 /

-- job ��ѯ

 select owner, job_name, state from dba_scheduler_jobs;

 select job_name, state from user_scheduler_jobs;

--�\��

dbms_scheduler.run_job('COLA_JOB',TRUE); -- true����ͬ��ִ��

--����

dbms_scheduler.enable('BACKUP_JOB');

--����

dbms_scheduler.disable('BACKUP_JOB');

--ֹͣ

     dbms_scheduler.stop_job(job_name => 'COLA_JOB',force => TRUE);

--�h��

 dbms_scheduler.drop_job(job_name => 'COLA_JOB',force => TRUE);)

����DBMS_SCHDULER.CREATE_JOB�ĳ��Å���:

��ʼʱ�� (start_time);

 �ظ�Ƶ�� (repeat_interval);

 ����ʱ�� (end_time)

 job_name: ����˼��,ÿ��job��������һ��������

 schedule_name: ��������˼ƻ���������ָ���ƻ�������

 job_type: Ŀǰ֧����������:
               PL/SQL��: PLSQL_BLOCK,

      �洢����: STORED_PROCEDURE

      �ⲿ����: EXECUTABLE (�ⲿ���������һ��shell�ű�,Ҳ�����ǲ���ϵͳ�����ָ��).

 job_action: ����job_type�Ĳ�ͬ��job_action�в�ͬ�ĺ���.

    ���job_typeָ�����Ǵ洢���̣�����Ҫָ���洢���̵�����;

    ���job_typeָ������PL/SQL�飬����Ҫ����������PL/SQL����;

    ���job_typeָ�����ⲿ���򣬾���Ҫ����script�����ƻ��߲���ϵͳ��ָ����

enabled: �����Ѿ�˵���ˣ�ָ��job��������Ƿ��Զ�����

 comments: ����job�ļ�˵��


2. ָ��job��ִ��Ƶ��

10G ֧������ģʽ��repeat_interval,

��һ����PL/SQL���ʽ����Ҳ��dbms_job������ʹ�õ�,����SYSDATE+1, SYSDATE + 30/24*60;

 �ڶ��־����������ʽ��

����MON��ʾ����һ,SUN��ʾ������,DAY��ʾÿ��,WEEK��ʾÿ�ܵȵ�. ������������ʹ���������ʽ�����ӣ�

 repeat_interval => 'FREQ=HOURLY; INTERVAL=2'

ÿ��2Сʱ����һ��job

 repeat_interval => 'FREQ=DAILY'

    ÿ������һ��job

 repeat_interval => 'FREQ=WEEKLY; BYDAY=MON,WED,FRI'

 ÿ�ܵ�1,3,5����job

 repeat_interval => 'FREQ=YEARLY; BYMONTH=MAR,JUN,SEP,DEC; BYMONTHDAY=30'

    ÿ���3,6,9,12�µ�30������job

 Repeat_interval=>��FREQ=DAILY;INTERVAL=1;BYHOUR=12��

 �ù�crontab����Ӧ�ö�����������ʶ�ĸо��ɣ��Ǻ�

������˵˵ʹ���������ʽ�Ĺ���:

�������ʽ������Ϊ������:

��һ������Ƶ�ʣ�Ҳ����"FREQ"����ؼ��֣����Ǳ���ָ����;

�ڶ�������ʱ������Ҳ����"INTERVAL"����ؼ��֣�ȡֵ��Χ��1-999. ���ǿ�ѡ�Ĳ���;

���һ�����Ǹ��ӵĲ���,�����ھ�ȷ��ָ�����ں�ʱ��,��Ҳ�ǿ�ѡ�Ĳ���,����������Щֵ���ǺϷ���:

BYMONTH,

BYWEEKNO,

BYYEARDAY,

BYMONTHDAY,
BYDAY

BYHOUR,

BYMINUTE,

BYSECOND

 (��ϸ�Ĳ���˵����ο� dbms_scheduler��ʹ��˵��)

��Ȼ˵����repeat_interval,�����Ҫ��:"��û��һ�ּ��ķ������ó�������˵��������job��ÿ������ʱ�䣬�Լ���һ�ε�����ʱ����?"

 dbms_scheduler���ṩ��һ������evaluate_calendar_string,���Ժܷ��������������. �������������:

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

����������:

Next Run on: 03/22/2004 07:00:00

Next Run on: 03/22/2004 15:00:00

Next Run on: 03/23/2004 07:00:00

Next Run on: 03/23/2004 15:00:00

Next Run on: 03/24/2004 07:00:00

Next Run on: 03/24/2004 15:00:00

Next Run on: 03/25/2004 07:00:00

--SCHEDULER JOB������ϵ�yҕ�D

select * from dict where table_name like '%SCHEDULER_JOB%'

��Ҫ����DBA_SCHEDULER_JOB_LOG ��Ĭ�J����һ���£� �cDBA_SCHEDULER_JOB_RUN_DETAILS



2.INTERVAL��������ֵʾ��

 

    ÿ����ҹ12��            ''TRUNC(SYSDATE + 1)''     
    ÿ������8��30��         ''TRUNC(SYSDATE + 1) + ��8*60+30��/(24*60)''     
    ÿ���ڶ�����12��         ''NEXT_DAY(TRUNC(SYSDATE ), ''''TUESDAY'''' ) + 12/24''     
    ÿ���µ�һ�����ҹ12��    ''TRUNC(LAST_DAY(SYSDATE ) + 1)''     
    ÿ���������һ�������11�� ''TRUNC(ADD_MONTHS(SYSDATE + 2/24, 3 ), ''Q'' ) -1/24''     
    ÿ��������������6��10��    ''TRUNC(LEAST(NEXT_DAY(SYSDATE, ''''SATURDAY"), NEXT_DAY(SYSDATE, "SUNDAY"))) + ��6��60+10��/��24��60��''    
    ÿ3����ִ��һ��             'sysdate+3/(24*60*60)'   
    ÿ2����ִ��һ��           'sysdate+2/(24*60)'   
      
    1:ÿ����ִ��  
    Interval => TRUNC(sysdate,'mi') + 1/ (24*60) --ÿ����ִ��  
    interval => 'sysdate+1/��24*60��'  --ÿ����ִ��  
    interval => 'sysdate+1'    --ÿ��  
    interval => 'sysdate+1/24'   --ÿСʱ  
    interval => 'sysdate+2/24*60' --ÿ2����  
    interval => 'sysdate+30/24*60*60'  --ÿ30��  
    2:ÿ�춨ʱִ��  
    Interval => TRUNC(sysdate+1)  --ÿ���賿0��ִ��  
    Interval => TRUNC(sysdate+1)+1/24  --ÿ���賿1��ִ��  
    Interval => TRUNC(SYSDATE+1)+(8*60+30)/(24*60)  --ÿ������8��30��ִ��  
    3:ÿ�ܶ�ʱִ��  
    Interval => TRUNC(next_day(sysdate,'����һ'))+1/24  --ÿ��һ�賿1��ִ��  
    Interval => TRUNC(next_day(sysdate,1))+2/24  --ÿ��һ�賿2��ִ��  
    4:ÿ�¶�ʱִ��  
    Interval =>TTRUNC(LAST_DAY(SYSDATE)+1)  --ÿ��1���賿0��ִ��  
    Interval =>TRUNC(LAST_DAY(SYSDATE))+1+1/24  --ÿ��1���賿1��ִ��  
    5:ÿ���ȶ�ʱִ��  
    Interval => TRUNC(ADD_MONTHS(SYSDATE,3),'q')  --ÿ���ȵĵ�һ���賿0��ִ��  
    Interval => TRUNC(ADD_MONTHS(SYSDATE,3),'q') + 1/24  --ÿ���ȵĵ�һ���賿1��ִ��  
    Interval => TRUNC(ADD_MONTHS(SYSDATE+ 2/24,3),'q')-1/24  --ÿ���ȵ����һ�������11��ִ��  
    6:ÿ���궨ʱִ��  
    Interval => ADD_MONTHS(trunc(sysdate,'yyyy'),6)+1/24  --ÿ��7��1�պ�1��1���賿1��  
    7:ÿ�궨ʱִ��  
    Interval =>ADD_MONTHS(trunc(sysdate,'yyyy'),12)+1/24  --ÿ��1��1���賿1��ִ�� 


   
#######��job���ñ��ص�shell�ű�#######
##�ű�����oracle�û��´���
[oracle@racnode01 ~]$ vim test_job.sh
#!/bin/sh
echo "zzz ***"$(date) >>/home/oracle/job.log
echo "test----job"    >>/home/oracle/job.log

##job������sqlplus ��sys�û�����
exec  dbms_scheduler.drop_job('test_shell');
---����job
exec  dbms_scheduler.create_job(JOB_NAME=>'test_shell', job_type => 'EXECUTABLE',job_action=>'/bin/bash',number_of_arguments => 1,start_date => sysdate,repeat_interval=> 'sysdate+3/(24*60*60)', comments => 'test shell');
---���ò���
exec dbms_scheduler.set_job_argument_value(job_name=>'test_shell', argument_position=>1, argument_value=>'/home/oracle/test_job.sh') ;
--enable
exec dbms_scheduler.enable(NAME=>'test_shell');
--�ֶ�����
exec  dbms_scheduler.run_job(job_name => 'test_shell');

##��ѯ����
SELECT * FROM dba_scheduler_jobs;
SELECT * FROM dba_scheduler_job_run_details t WHERE t.JOB_NAME='TEST_SHELL';



##Ȩ�޵���
grant execute on NF_JFXT.JF_TAB_BAK to NF_JFXT;
grant create any table  to nf_jfxt;
grant select on NF_JFXT.NF_JFXT_DQJF to NF_JFXT;
grant select on NF_JFXT.NF_JFXT_ZRRDQJF to NF_JFXT;
grant debug any procedure to NF_JFXT; 
 
##�����洢����
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

##��������
begin

 dbms_scheduler.create_job (

 job_name => 'JF_TAB_BAK_PRO_D',

 job_type => 'STORED_PROCEDURE',

 job_action => 'CZ.JF_TAB_BAK', --�洢������

 start_date => sysdate,
 
 enabled   => true,

 repeat_interval => 'FREQ=DAILY; ByHour=10;ByMinute=45', -- ÿ��10:45ִ��

 comments => '���ֱ���'

 );

 end;
 
--��������
SQL> exec  dbms_scheduler.enable('cz.JF_TAB_BAK_PRO_D');
--��������
SQL> exec  dbms_scheduler.run_job(job_name => 'NF_JFXT.JF_TAB_BAK_PRO');

--�鿴�������е�JOB
SELECT * FROM Dba_Jobs_Running; 

--JOB��session�Ĺ���
SELECT b.inst_id ,B.SID, B.SERIAL#, C.SPID
  FROM DBA_JOBS_RUNNING A, gV$SESSION B, gV$PROCESS C
 WHERE A.SID = B.SID
   AND B.PADDR = C.ADDR;
   
--�鿴����
 SELECT * FROM dba_scheduler_jobs t WHERE t.JOB_NAME='JF_TAB_BAK_PRO_D' order by 2 desc; --enabled=true
 ����program_name = PG_DZDZ_01_BD_JS 
 �ҵ� SELECT * FROM dba_scheduler_programs t WHERE t.PROGRAM_NAME='PG_DZDZ_01_BD_JS';
 �õ�pck_dzdz_sjjs.P_SJ_JS_FPLX ���Ǵ洢���̣����ǰ�������
 �鿴packages�����ݣ�SELECT * FROM dba_source t WHERE t.name='PCK_DZDZ_SJJS' order by line; 

--�鿴������ϸ
 SELECT * FROM dba_scheduler_job_run_details t WHERE t.JOB_NAME='JF_TAB_BAK_PRO_D' order by 2 desc;  
-run_duration job����ʱ��


--�鿴������־
 SELECT * FROM dba_scheduler_job_log t WHERE t.JOB_NAME='JF_TAB_BAK_PRO_D' order by 2 desc;