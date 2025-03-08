--�������ȴ��������Ĳ�ѯ
1����ѯĿǰ���ݿ�ĵȴ��¼�
select INST_ID,event,count(*) from Gv$session  where wait_class<>'Idle' group by  inst_id,event order by 1,3;

   INST_ID EVENT                                      COUNT(*)
---------- ---------------------------------------- ----------
         1 SQL*Net message to client                         1
         1 enq: TX - row lock contention                     3    --���ݿ�������ĵȴ���˵����������ڸ������ݿ⣬�������Ҳ�ڸ�����ͬ�����ݵ������ĵȴ�
         
2��ͨ���ȴ����¼���ѯ�����SQL��
SQL> select sql_id,count(*) from v$session where wait_class<>'Idle' and event='&event' group by sql_id;
Enter value for event: enq: TX - row lock contention   --�����¼������� 
old   1: select sql_id,count(*) from v$session where wait_class<>'Idle' and event='&event' group by sql_id
new   1: select sql_id,count(*) from v$session where wait_class<>'Idle' and event='enq: TX - row lock contention' group by sql_id

SQL_ID                                    COUNT(*)
--------------------------------------- ----------
6kbn11bq88dwv                                    1    --˵������������ȴ�SQL.
84a1a1yddxt34                                    2

3����ͨ��SQL_ID��ѯ�����SQL��ִ�мƻ�
--����SQL��ѯ
SQL> select t."SQL_FULLTEXT" from  v$sql t where t."SQL_ID"='&sql_id';
Enter value for sql_id: 6kbn11bq88dwv

SQL_FULLTEXT
--------------------------------------------------------------------------------
update al_user_test t set t.username='cz' where t.user_id=90

--��ѯִ�мƻ�
SQL> select * from table(dbms_xplan.display_cursor('&sql_id',null,'ADVANCED')); 
Enter value for sql_id: 6kbn11bq88dwv

4��killed��֮ǰ���������δ�ύ��ع�session
SQL> select object_name,machine,s.sid,s.serial# from v$locked_object l,dba_objects o ,v$session s where l.object_id=o.object_id and l.session_id=s.sid;
alter system kill session 'sid,serial#';

--����sid�ҵ���Ӧ��SQL
SQL> select sql_text from v$session a,v$sqltext_with_newlines b where DECODE(a.sql_hash_value, 0, prev_hash_value, sql_hash_value)=b.hash_value and a.sid=&sid order by piece;
Enter value for sid: 186

--�鿴������Լ����ڵȴ������û�����������SID
select w."USERNAME" "waiting session",
       w."MACHINE",
       w."SID",
       w."SERIAL#", 
       '|',
       b."USERNAME" "blocked session",
       w."MACHINE",
       b."SID",
       b."SERIAL#"
  from v$session w
  join v$session b 
    on (w."BLOCKING_SESSION" = b."SID")
 order by b."SID", w."SID";

--�鿴�Ѿ������������ִ��ʱ��
SELECT  t."SID",t."CTIME" seconds FROM v$lock t where t."LMODE">0 and t."TYPE"='TX' and t."BLOCK"=1 and t."SID"=&sid;

--��ѯ�����������Ϣ
 SELECT t."SESSION_ID",t."OBJECT_ID",t."ORACLE_USERNAME",t."OS_USER_NAME" ,t."PROCESS" FROM v$locked_object t where t."SESSION_ID"=&sid ;

--�鿴��Ӧsql��ִ��ʱ��
SELECT * FROM v$session tttt WHERE tttt."SQL_ID"='77zfd1z6uwq7g'; --paddr 

SELECT * FROM v$process t WHERE t."ADDR"='0000000CA8F7DCC0'   --spid  

�����ݿ������ϣ� ps -ef | grep 184516  
--�鿴�Ѿ�ִ�е�ʱ��
ps v 184516  

--������ض�̬��ͼ
#v$lock
-SID ������ӵ�л�������Դ��SID
-ID1��ID2��ͬ��ʶ���໥���õ���Դ
-LMODE>0�� ��ʾ����ӵ�����ĻỰ
LMODE	NUMBER	Lock mode in which the session holds the lock:
0 - none
1 - null (NULL)
2 - row-S (SS)
3 - row-X (SX)
4 - share (S)
5 - S/Row-X (SSX)
6 - exclusive (X)
-REQUEST>0�����������ĻỰ 
REQUEST	NUMBER	Lock mode in which the process requests the lock:
0 - none
1 - null (NULL)
2 - row-S (SS)
3 - row-X (SX)
4 - share (S)
5 - S/Row-X (SSX)
6 - exclusive (X)
-CTIME����������ģʽ��ĺ�ʱʱ�� 
-BLOCK��0-δ�谭������� 1-�����谭������� 2-������RAC����ʾ�ڱ���û���谭�������̣������п����谭�������ڵ�Ľ���

1	00000000814D9098	00000000814D90F0	136	TX	196634	856	0	6	196	0
2	0000000080BD4A08	0000000080BD4A80	36	TX	196634	856	6	0	219	1

#v$locked_object  SID=session_id
1	3	26	856	76864	36	CZ	svsky95	10796:14596	3
2	0	0	0	76864	136	CZ	svsky95	10796:14596	3

--���Ĳ�ѯ
select a.sid blocker_sid, a.serial#, a.username as blocker_username, b.type,
decode(b.lmode,0,'None',1,'Null',2,'Row share',3,'Row Exclusive',4,'Share',5,'Share Row Exclusive',6,'Exclusive') lock_mode,
b.ctime as time_held,c.sid as waiter_sid,
decode(c.request,0,'None',1,'Null',2,'Row share',3,'Row Exclusive',4,'Share',5,'Share Row Exclusive',6,'Exclusive') request_mode,
c.ctime time_waited  
from   v$lock b, v$enqueue_lock c, v$session a  
where  a.sid = b.sid and    b.id1= c.id1(+) and b.id2 = c.id2(+) and c.type(+) = 'TX' and  b.type = 'TX' and  b.block   = 1
order by time_held, time_waited;