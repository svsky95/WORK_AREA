--�ջ�ֹSQL�Ż�
##��������ʱ��Ҫѯ�ʣ�
1�����������һֱ��������������ӣ����ǽ����Ȼ���֡�
2�����������������ʲô��Ĳ���������򲹶��������ȡ�
##�ȴ��¼�����
--��ʾ�б�ռ䲻��ĵȴ�
statement suspended, wait error to be cleared 

--PX DEP Credit ���е���    
���ڱ����������˲��е��£��ɸ���ҵ���ʱ�ε�ִ�У��ʵ�ȥ�����С�

--gc buffer busy  �ȿ鵼��
ͨ��ҵ��ʹ�������ͬһ���飬���ڲ�ͬ�Ľڵ��ϣ������ȿ������

--RAC�����д���read by other session
��ʾ��̫����ӳٽϴ󣬴Ӷ��������á���ͨ���鿴Segments by Physical Reads ���ж���Щ��ľ���	 

--RAC������read by other session 


--��־�ȴ��й�
transaction�ϴ󣬵���per transaction ���٣����ɳ����д���ѭ��������û���������ύ��

--���ݿ�Ķ�̬����
����û�������ݿ�Ķ�̬�ռ�ͳ����Ϣ֮�ڣ������ͱ������ռ��������ű��ͳ����Ϣ�������ڽ�������������ֶ��ռ���Ҳ���������ݿ⶯̬������

--���ٻ������ĵȴ��¼�
##db file scattered read 
����ԭ��
����ȫ��ɨ����߿�������ɨ���й�
����ʱ����Ҫ��ѯ������ռȫ���30%����ʱ��ȫ��ɨ����ܱ���������Ч�ʸ��ߡ�

##db file sequential read 
����ԭ��
������Ĳ���������ѡ�������Ч�ʲ���
�Ӷ�ȡ��ʼ������SGA��buffer cache�Ĵ�С������ÿ�ζ���Ӳ����ȥ����
�Ż�sql��䣬���ٲ���Ҫ�Ŀ��ȡ
table access full
index full scan
index range scan
index fast full scan


##latch:cache buffers chains
����ԭ��
-��Ч��SQL
�������ͬʱɨ���Χ�������ͱ��ʵ��ļ���ɨ�跶Χ���Ż���ѯ��
-hot block
���ѽ�������ٿ�Ĵ�С�����Լ��ٿ������ɵ��������Ӷ�������ȿ飬����ͬ����Ҳ��������Դ�Ŀ���������Ҫɨ�����Ŀ顣

##latch:cache buffers lru chains
����ԭ��
-��Ч��SQL --ͬʱ���� db file scattered read<�����ļ���ɢ��ȡ>��latch:cache buffers chains�ķ���
������̵ĵ�Ч�Ĳ�ͬ��SQL�������������еĻ�����
�ʵ�������������ȡ��ȫ��ɨ��

##read by other session --ͬʱ����db file scattered read��db file sequential read
select/select �����buffer lock
����Ựͬʱ��ѯ��ͬ�Ŀ飬�������ļ�����buffer cache�����ǵ��ڶ���ִ��ʱbuffer cache�Ѿ��л�ȡ�����ݣ����ڻ����buffer lock�����Եȴ���ʧ��
���������
1���Ż�SQL���Ա�����С��I/O�������Ľ����
2����SGA��buffer cache��С�������ʵ�����

##free buffer wait
��û�п��еĻ�����ʱ���ͻ���DBWR����д������ֱ���������ݿ�д�뵽�����ļ�Ϊֹ����������лᷢ��free buffer wait��

����ԭ��#
��Ч��SQL  ���������Ŀ��л�����
��С�ĸ��ٻ�����  ���ٵĿ��л���������
DBWR�������½�

--����ٻ������ϵĵȴ��¼�
##latch:share pool 

����ԭ��
hard parsing Ӳ�������� --ʹ�ð󶨱������

##latch:ibrary cache 
����ԭ��:
hard parsing Ӳ�������� --ʹ�ð󶨱������

##TX���Ƕ�����ı��������������ִ��commit �� rollback�����ͷ�
-enq:TX-row lock contention 
���޸��ض�����
�޸�Ψһ��������
�޸�λͼ��������ֵ
����ԭ��:
����Ựͬʱ�޸��У�update
insert �ǲ�������enq:TX-row lock contention 

-enq:TX-allocate ITL entry
�޸Ŀ�ITL����Ҫ�޸ĵĵǼ���Ŀ

-enq:TX-index contention
����Ҷ�ڵ��Ϸ����ķָ�

--���ϵĵȴ��¼�
##enq:HW-contention 
Ϊ�˷�ֹ�������ͬʱ�޸�HWM����ˮλ�ߣ��ṩ������
����ԭ��
������insert
������update�����»ع��εĸ�ˮλ�߼������ߣ��ռ�����

--I/O �ϵĵȴ��¼�
##db file scattered read 
oracle��ִ��ȫ��ɨ�����ȫ����ɨ��ʱ��һ���Զ�ȡ���������ݣ�ÿ��ִ�ж�����������ڵȴ���
SQL> show parameter db_file

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_file_multiblock_read_count        integer     93

���������
--Ӧ�ó���
1����������ȫ��ɨ�������ȫɨ�衣�ж�ȫ��ɨ���Ƿ���������index range scan������
--oracle�ڴ��
1��buffer cache��С���ᵼ���ظ�������I/O��ͬʱҲ�����free buffer waits�ȴ��¼����ֵļ������ߡ�
2��ʹ�÷�����

##db file sequential read 
ÿ�η��������ʱ���ͻ��дεȴ��¼��ķ�����
����ԭ��
��Ч������ɨ�裬��Ǩ�ƣ�������
ʹ��ѡ���Խϲ�������Ƿ����ȴ�����Ҫԭ��

���������
--Ӧ�ó���
��������
--oracle�ڴ��
1��buffer cache��С���ᵼ���ظ�������I/O��ͬʱҲ�����free buffer waits�ȴ��¼����ֵļ������ߡ�

##direct path read 
�������в�ѯʱ�������˵ȴ��¼�

##direct path write
����directload������create table as select *,insert /*+append*/ ��

##direct path read temp direct path write temp 
����ʱ������������Ķ�д��������˵ȴ��¼���
��������PGA�йأ�����pga_aggregate_target�Ϳɽ����
������׼��
OLTP��pga_aggregate_target=(total_mem*80%)*20%
OLAP/DSS��pga_aggregate_target=(total_mem*80%)*50%

##direct path read temp(lob) direct path write temp(lob)

##db file parallel write 
�������ٻ�����������������ͨ��DBWRд�뵽���̵ġ�DBWR����д��������ݿ��I/O���ڴ��ڼ��ǻ��д˵ȴ���
���˵ȴ��������֣�������ж���������ص�IO�½�����
ͬʱ�ᾭ��free buffer waits�¼���write complete waits�¼�
���������
����DBWR�Ľ�������
����DB_writer-processes�Ĳ���ֵ���Ƽ�CPU_COUNT/8 �������Ӳ����첽�ķ�ʽ��

##control file parallel write
��������ļ��ĸ��½���֪�����½������ڼ��д˵ȴ��¼���

����ԭ��
1����־�ļ��л�Ƶ��
��־�ļ���С������������־���л���ÿ��������־���л�ʱ����Ҫ�Կ����ļ����и��£��˵ȴ��¼��ͻ��ӳ���
2��Ƶ���ļ���
Ĭ�ϵ�fast_start_mttr_target��ֵΪ0����ʾ�ر��Զ����㹦��

##log file sync
ָ���´�󣬰�redo buffer�е��ύ����д�뵽����������־�У�ֱ��LGWRд��ɹ����ڼ���д˵ȴ�ʱ��ĳ��֡�

����ԭ��
1���ύ�����Ƿ����
ÿִ��һ���ύ���ͻᷢ��һ��log file sync�ĵȴ����������ύ���Ϳ��ܵ��¹㷺�ĵȴ����֡�

2�����̵�I/O
Ӳ�̵�д�����ܣ��ᵼ�µȴ�ʱ����ӳ�����˽��飬��������־���ڱȽϿ�Ĵ����ϣ������������ļ�������ļ����ڲ�ͬ�Ĵ������Ǻ��б�Ҫ�ġ�

3������������־�ļ�д���������
�ر����ڴ�����������ϼ����������������ͻ���ٺ�̨д��Ĺ�����������Ҳ�ɽ����

���������
1���Ƿ���ڲ���Ҫ�����ݣ�ʹ��nologging��
2���������޸�Ϊunusable״̬���������ݡ���nologging��ʽ�ؽ���
3����������redo buffer��
4����redo log ���ڽϿ�Ĵ洢�ϣ������д������ܡ�
����lGWR�ǵ����̣�Ϊ�˽��д������⣬��12c�󣬻���LGNN slave���̰���redo buffer ��redo log��д�롣 

##log file parallel write
LGWR��redo buffer�е����ݼ�¼��������־�ļ���ִ�б�Ҫ��IO���ú��ڹ��������ڼ䣬�ͻ��еȴ�ʱ��ĳ��֡�
��log file sync�������������ͬ��

##log buffer space
����redo buffer��д��������¼��Ϊ�˻��redo buffer�еı�Ҫ�ռ䣬��û���ʵ��Ŀռ䣬�ͻᷢ���˵ȴ���

���������� ���� redo bufferʱ������û�п��еĿռ䣬����log buffer space�������ʵ�����redo buffer;
log buffer space �� log file switch conpletion �ȴ�ͬʱ���֣���������־�ļ���С����log file switch conpletion�ȴ������ӣ�����־�л���ɺ�����log buffer space��
Ϊ�˼���log buffer space,������redo buffer�Ĵ�Сʱ��log file sync �ȴ����ܻ����ӣ���Ϊ����д����־�ļ���������������ɵȴ���

##log file switch completion,log file switch checkpoint incomplete,log file switch archiving needed
��redo log��active active ��current������־��ʱ����ʱҪ������־����л������Ǹ��ǵ�ǰ����inactive״̬�����Ǹ���־���Ѿ�д�뵽
archive log�������ʱ��active����û��inactive����ô���ء�
   ��ǿ�ƴ���dbwr��һ����buffer�е�������ݣ�д�뵽�����ļ��У���ʱactive����־�飬�Ϳ��Ը����ˡ�
   Ҳ���������Ƿ�ʼ�鵵��������Ӱ��ʵ����һ���Իָ���
redo log�а������ύ������Ҳ����δ�ύ������

��������redo bufferд��redo logʱ����redo log����������д�룬����LGWR���������־���л���ֱ���л���ɣ�����log file switch completion��
�����ҪͶ���redo log����û����ɹ鵵�Ĺ��������������ĵȴ��¼����֣�
1�������������ʹ�õ�redo log��δ�������㣬��ȴ�DBWR���������㣬��ʱ�ȴ�log file switch checkpoint incomplete��
2�������������ʹ�õ�redo log��δ��ɹ鵵������̵ȴ�ARCH����ɹ鵵����ʱ�ȴ�log file switch archiving needed��

��������
����redo log����־�飬�ֶ��ű�����alter system checkpoint;

##SQL*NET more data from client
��ռ�����൱���صĵȴ��¼���������SQL������ִ�мƻ�û�����⣬����ֻҪ��ѯ��һ�������ͻᵼ�µȴ�����Ҫ���Ż��˲�ѯ��һ���Ǹ�����������Ӹ���������

--��ʷ�ȴ���ѯ
 with tt as
  (SELECT t.instance_number, t.user_id, t."SQL_ID", t."EVENT", count(1) CNT
     FROM DBA_HIST_ACTIVE_SESS_HISTORY t
    WHERE t."WAIT_CLASS" <> 'Idle'
      and t.sql_id is not null
      and t."SAMPLE_TIME" between
          to_date('2020-01-01 09:00:00', 'yyyy-mm-dd hh24:mi:ss') and
          to_date('2020-01-03 11:00:00', 'yyyy-mm-dd hh24:mi:ss')
    group by t.instance_number, t.user_id, t."SQL_ID", t."EVENT"
    order by count(1) desc)
 SELECT tt.instance_number, a.username, tt."SQL_ID", tt."EVENT", tt.CNT
   FROM tt, dba_users a
  where a.user_id = tt.user_id and rownum<11;