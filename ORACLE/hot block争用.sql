--oralce ���ɽ��ٵ�redo��undo�����
1��direct load option (sql loader,insert /*+append*/ into )    --��ˮλ�߲���
2��create table ..,alter table.., nologging .
3��create index ..,alter index.., nologging .
4��create materialized view ,alter materialized view nologging.


--cache buffers chains ����������
�����sqlɨ�������ض������ݿ�ʱ���ͻᷢ��hot block�����cache buffers chains���á�
���������ͨ������ϵ����⣬�Ӵ�����ɨ����ͬ�����ݿ顣

--cache buffer lru chain ����������
db file scattered read ,cache buffers chains ,cache buffer lru chain ����sql���ִ��Ч�ʽϵ͵��£�sql����Ż�������Ч�ķ�����

--buffer lock
��������£�������session��ͬ�޸Ĳ�ͬ����ʱ���ǿ���ͬʱ�޸ģ������໥��Ӱ�죬��������������ͬʱ����ͬһ�����ݿ�ʱ���ͻ����buffer lock,��û��buffer lock,������������������

--select��buffer lock����
�����ڶ��session������ͬ�ı�ʱ�������db file sequanational read ,read by other sesson,db file scanttered read �ĵȴ��¼������ǵ��ڶ���ִ��ʱ�����������Ѿ�����ڸ��ٻ�������������صĵȴ��ͻ���ʧ��