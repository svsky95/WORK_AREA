##Oracle �ﻯ��ͼ
�ﻯ��ͼ���ﻯ��ͼ��־
�ﻯ��ͼ�Ĵ��������ڱ�
�ﻯ��ͼ��־�ǻ���ԭ��Ĵ����ģ�Ϊ�˼�¼�����Ϣ����Ϊ����primary key���������������Լ� rowid ��Ŀ����Ϊ�˵�ԭ���б仯ʱ�����Ը����ﻯ��ͼ
��־��������ˢ�¡�
�ﻯ��ͼ����ǰ̨���ݿ�ʹ������˵��ͬһ��ʵ�ʵı�,���к�һ�����ͬ����select�Ȳ���,����ʵ������һ����ͼ,һ����ϵͳʵ�ֶ���ˢ�������ݵ���ͼ(����ˢ��ʱ���ڶ����ﻯ��ͼ��ʱ�����ж���),ʹ���ﻯ��ͼ������ʵ����ͼ�����й���,���ﻯ��ͼȴ������ʹ��ʱ�Ŷ�ȡ,�������˶�ȡ�ٶ�,�ر����ó�ȡ����������ĳЩ��Ϣ�Լ����������ӱ�ʹ�ã������ﻯ��ͼռ�����ݿ���̿ռ䡣�����﷨����:

1����Դ�˴����ﻯ��ͼ��־���뿴�壬�Զ˵ı��п�����ͬ��ʣ�һ��Ҫ��ԭ���ϴ�����־��
1.1 �����ﻯ��ͼ��־�����ﻯ��ͼˢ�³ɹ����ﻯ��ͼ����־�ļ�¼��ɾ����
create materialized view log on NF_SSSL.NF_SSSL_SBYWRZ with  primary key/with rowid; 

1.2 ɾ���ﻯ��ͼ��־
drop materialized view log on hx_sb.sb_sbb
--�����Ѷ��������ı��ֱ�ִ������ sql��create materialized view log on ����  with primary key; 
��mlog$�ж�Ӧ�ı���һ���ֶ���ԭ�����������

--����δ���������ı��ֱ�ִ������ sql��create materialized view log on ����  with rowid;
��mlog$�ж�Ӧ�ı���һ���ֶ���M_ROW$$


2����Ŀ��ˣ�ͨ��DBlink�ķ�������ˢ���ﻯ��ͼ
CREATE MATERIALIZED VIEW sjyy.nf_sssl_sbywrz_2    --�ﻯ��ͼ����distinct���ܼ�FAST����
REFRESH FAST ON DEMAND          
NEXT SYSDATE + 1/(24*60)   --ÿ����ˢ��
WITH primary key           --����PRIMARY KEY   
AS 
SELECT * FROM NF_SSSL.NF_SSSL_SBYWRZ@SJYY_SNGSNFDB sb
 where sb.jyzt_dm = '00'
   and sb.sjgsrq >= to_date('2018-02-01', 'yyyy-mm-dd');
   
3��ɾ���ﻯ��ͼ
drop materialized view an_user_base_file_no_charge;

--ȷ���ﻯ��ͼ��ˢ��ʱ��
SELECT * FROM dba_jobs;  

--�鿴�ﻯ��ͼ��Ϣ
SELECT * FROM dba_mviews; //�ﻯ��ͼ��
SELECT * FROM dba_mview_logs; //ԭ�����ﻯ��ͼ��־��Ĺ�ϵ����ʵ����Ķ�Ӧ��ϵ���Ҳ�����Ӧ���ﻯ��ͼ��ʲô���ֵ�
SELECT * FROM sys.mlog$;
SELECT * FROM sys.snap$ t WHERE t.sowner='CZ'; //��ԭ����ﻯ��ͼ��־�б仯ʱ���ͻᰴʱ������ˢ�£���������ҵ��ﻯ��ͼ���µ�ˢ��ʱ��

--A�û�ˢ��B�û����ﻯ��ͼ
GRANT ALTER ANY MATERIALIZED VIEW TO ***;--***��Ϊ��Ҫ��Ȩ���û���



##����˵��
create materialized view [view_name]
refresh [fast|complete|force]
[
on [commit|demand] |
start with (start_time) next (next_time)
]
as
{�����ﻯ��ͼ�õĲ�ѯ���}

����ʵ�����£�

CREATE MATERIALIZED VIEW an_user_base_file_no_charge
             REFRESH COMPLETE START WITH SYSDATE
            NEXT TRUNC(SYSDATE+29)+5.5/24    --��ɫ���ֱ�ʾ��ָ����ʱ�俪ʼ��ÿ��һ��ʱ�䣨��nextָ������ˢ��һ��
AS
select distinct user_no
from cw_arrearage t
where (t.mon = dbms_tianjin.getLastMonth or
       t.mon = add_months(dbms_tianjin.getLastMonth, -1))


������Oracle�����ﻯ��ͼ��Materialized View,���¼��MV��ʱ�ĳ����﷨,�������ĺ�������:

1.refresh [fast|complete|force] ��ͼˢ�µķ�ʽ:
fast: ����ˢ��.����ǰһ��ˢ�µ�ʱ��Ϊt1,��ôʹ��fastģʽˢ���ﻯ��ͼʱ,ֻ����ͼ�����t1����ǰʱ�����,����仯��������.Ϊ�˼�¼���ֱ仯����������ˢ���ﻯ��ͼ����Ҫһ���ﻯ��ͼ��־��create materialized view log on ������������
complete:ȫ��ˢ�¡��൱������ִ��һ�δ�����ͼ�Ĳ�ѯ��䡣
force: ����Ĭ�ϵ�����ˢ�·�ʽ��������ʹ��fastģʽʱ������ˢ�½�����fast��ʽ������ʹ��complete��ʽ��

2.MV����ˢ�µ�ʱ�䣺
on demand:���û���Ҫˢ�µ�ʱ��ˢ�£������Ҫ���û��Լ�����ȥˢ�������ˣ�Ҳ����ʹ��job��ʱˢ�£�
on commit:���������������ύ��ʱ������ˢ��MV�е����ݣ�
start ��������ָ����ʱ�俪ʼ��ÿ��һ��ʱ�䣨��nextָ������ˢ��һ�Σ�


�ֶ�ˢ���ﻯ��ͼ��
begin
     dbms_mview.refresh(list=>'an_user_base_file_no_charge',
                                       METHOD=>'COMPLETE',
                                       PARALLELISM=>8);   --PARALLELISM���п��Ʋ���
end;
/

����ˢ�¾Ͳ���Ҫʹ��ʲô�����ˣ�ͨ������£���û���Ǹ���Ҫ�ġ�

begin
     dbms_mview.refresh(list=>'an_user_base_file_no_charge',
                                       METHOD=>'FAST',
                                       PARALLELISM=>1);
end;
/

--����job

exec dbms_job.run(774);

 --ͣ��job

EXEC DBMS_JOB.BROKEN(job#,TRUE); 

EXEC DBMS_JOB.BROKEN(774, TRUE); 




oracle �ﻯ��ͼ���Զ�ˢ�·�����

	����1��ֱ���ڴ�����ʱ��ָ��start with �����´���ÿ����ִ��1��

	create materialized view big_table_mv nologging

	refresh fast on demand

	with rowid

	START WITH TO_DATE('18-03-2011 10:09:08', 'DD-MM-YYYY HH24:MI:SS') NEXT SYSDATE + 1 / 60*24

	as select * from big_table;

	


	����2����д����ˢ��ĳ���û��������ﻯ��ͼ��procedure��Ȼ����job���Զ�ʱȥִ�У�

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

	ˢ��ĳһ���ﻯ��ͼ�Ĵ洢����mv_emp��

	CREATE OR REPLACE PROCEDURE auto_refresh_mview_job_proc

	AS

	BEGIN

	dbms_mview.REFRESH('mv_emp');

	END;

	/

	����ǰ��洢����pro_refresh_maview��job��ÿ�����ִ��һ�δ洢����)��ѹ�����Զ�ˢ����

	declare

	   pro_refresh_maview_job number;

	begin

	  dbms_job.submit( pro_refresh_maview_job,'pro_refresh_maview;',sysdate,'sysdate+1/24/60*5');     ##��ɫ������ǰ�洴���Ĵ洢���̡���ɫ�������Լ���д������

	  end;

	2����ѯjob��ID,ǰ�洴����job,

	select * from dba_jobs; 

	select * from all_jobs; 

	select * from user_jobs;

	3������job��id�ֶ�ִ��ǰ���job �� 

	begin

	  dbms_job.run(44);

	  end;


	����ˢ��ĳ���û���ȫ�����ﻯ��ͼ��ʹ���α꣬����ֻ��ִ��һ��

	begin

	for rec in (select user||'.'||mview_name  mview_name from user_mviews)

	loop

	DBMS_MVIEW.REFRESH(rec.mview_name,'C');

	end loop;

	end;

	�ܽ᣺oracle���ݿ��ﻯ��ͼ��ʱˢ�¾����ַ�����һ���Ǵ����Ĺ�����ָ��start with������һ����procedure+jop����Ȼ�ڳ�������Ҳ����ȥ�����Զ�ˢ���ﻯ��ͼ��

 
##�ﻯ��ͼ��־������##
Ѳ�췢�����ݿ����ű���200G��ͨ�������ж���ĳ�ű���ﻯ��ͼ��־�����С��200M���ң�ÿСʱˢ��һ���ﻯ��ͼ������ˢ����ɻ��Զ������ﻯ��ͼ��־������Ҫ������������Ų顣

ͨ������Oracleϵͳ��ͼ�����Ƿ��ֵ�ǰ�ﻯ��ͼ��MV_ORG_PERSON����������õ�refresh force����ѡ���ṩfast��complete����ѡ�񣬵��޷�������ˢ��ʱ���Զ�ѡ��ȫ��ˢ�£�ϵͳ��ͼdba_mviews��last_refresh_type�ֶ�ֵ��ʾΪCOMPLETE��֤���ϴ��ﻯ��ͼΪȫ��ˢ�£����dba_mview_analysis�е�fullrefreshtim�ֶΣ�����һ��ȫ��ˢ����Ҫ7�����ң�����ﻯ��ͼ��־mlog$_table_name��mlog$_table_name1�е�snaptime$$�ֶΣ����ڴ���ʱ��Ϊ4000/1/1��ֵ���ټ��dba_base_table_mviews�е�MVIEW_LAST_REFRESH_TIME�ֶΣ�ʱ��Ϊ2017/2/21��������2017/2/21��ʼ�ﻯ��ͼ��־�е����ݲ�δ���ﻯ��ͼ�õ�����˵ó����½��ۣ�

���ﻯ��ͼ��־��δ�Ե�ǰ�ﻯ��ͼ�ṩ����ˢ�¹��ܣ������Զ�ѡ��ȫ��ˢ�£�

ע�ͣ�dba_base_table_mviews ����ͼ�ṩʹ���ﻯ��ͼ��־���п���ˢ�µ�ʱ�䣬����ͬʱ�����д����ﻯ��ͼ��־��ʹ���˿���ˢ�����������Ż����MVIEW_LAST_REFRESH_TIME�ֶε�ֵ

 ׼�����ﻯ��ͼ��־mlog$_table_name�������������������£�

1��ɾ���ﻯ��ͼ��־
�����ﻯ��ͼ��־����¼ԭ��ĸ��£�Ϊ�˱�֤һ���ԣ���Ҫ������ԭ��
LOCK TABLE T_600_RESULTS IN EXCLUSIVE MODE nowait; 
Drop materialized view log on table_name;
�ͷ���������ɱ������
2���ֶ�ˢ���ﻯ��ͼ�����״̬

3��ҵ����Ա���ҵ��״̬

 

Ӧ��Ԥ����

         ���ɾ���ﻯ��ͼ��־����ﻯ��ͼ����Ӱ�죬�ֶ�����ﻯ��ͼ��־�����ؽ��ﻯ��ͼ������ϵͳ��ͼ��dba_mview_analysis���ṩʱ�䣬һ��ȫ��ˢ����7�������ҡ�

         ����ΪӦ��Ԥ�����裺

1��create materialized view log on table_name;

2��drop materialized view MV_table_name;

3���ﻯ��ͼ�ؽ����

4��ҵ����Ա���ҵ��״̬


##����ԭ����ﻯ��ͼ��־����##
-���ﻯ��ͼˢ�»���ǿ�ƶ�ռ��
LOCK TABLE T_600_RESULTS IN EXCLUSIVE MODE nowait; 
--�����ﻯ��ͼ��ʱ��־��
CREATE TABLE MV_TEMP_600_RESULTS NOLOGGING AS SELECT * FROM MLOG$_T_600_RESULTS 
--�����ﻯ��ͼ��־��
TRUNCATE TABLE MLOG$_T_600_RESULTS
--����ʱ��־����������ͬ�����ﻯ��ͼ��־��
INSERT INTO MLOG$_T_600_RESULTS SELECT * FROM MV_TEMP_600_RESULTS
--�ͷ�����Դ��ִ�лع�����
ROLLBACK; 


#####�ﻯ��ͼ��־�����������,�����ﻯ��ͼ��־��Ƶ���Ĳ���ɾ������������˸�ˮλ�ߣ�������Ŀ�ľ��ǽ��͸�ˮλ�ߡ�
BEGIN
  DBMS_REDEFINITION.CAN_REDEF_TABLE(UNAME        => 'CZ',
                                    TNAME        => 'MLOG$_T_600_RESULTS',
                                    OPTIONS_FLAG => DBMS_REDEFINITION.cons_use_rowid);
END;

--���������ض�����ʱ��
����һ����ԭ�������Ӧһ�����ﻯ��ͼ��
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
--��ʼ�����ض������
BEGIN
  DBMS_REDEFINITION.START_REDEF_TABLE(UNAME        => 'CZ',
                                      ORIG_TABLE   => 'MLOG$_T_600_RESULTS',
                                      INT_TABLE    => 'MV_TEMP_600_RESULTS',
                                      OPTIONS_FLAG => DBMS_REDEFINITION.CONS_USE_ROWID);
END;



--������������ ����������������Լ����check�� ,Ǩ��ԭ��־���е����ݵ���ʱ���С�
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

--��ʼ�����ض���ͬ������
BEGIN
  DBMS_REDEFINITION.SYNC_INTERIM_TABLE(UNAME      => 'CZ',
                                       ORIG_TABLE => 'MLOG$_T_600_RESULTS',
                                       INT_TABLE  => 'MV_TEMP_600_RESULTS');
END;
--��������ض������
BEGIN
  DBMS_REDEFINITION.FINISH_REDEF_TABLE(UNAME      => 'CZ',
                                       ORIG_TABLE => 'MLOG$_T_600_RESULTS',
                                       INT_TABLE  => 'MV_TEMP_600_RESULTS');
END;

--��֤���֣�ԭ��־���ռ������ռ�����ˣ���ʵ���ǽ����˸�ˮλ��
SELECT t.BYTES FROM dba_segments t WHERE t.segment_name='MLOG$_T_600_RESULTS';


SELECT * FROM sys.mlog$;
SELECT * FROM MLOG$_T_600_RESULTS;
SELECT * FROM MV_TEMP_600_RESULTS;

����ʹ��rowid��ʽ���ض�����ı��ϻ���һ�������ֶΣ���10.2��ʼM_ROW$$�������лᱻ����ΪSYS_%DATE%����ʽ����Ĭ�ϼ�Ϊunused״̬��
SELECT * FROM DBA_UNUSED_COL_TABS WHERE TABLE_NAME = Q'{MLOG$_T_600_RESULTS}'
--
ALTER TABLE MLOG$_T_600_RESULTS DROP UNUSED COLUMNS; 