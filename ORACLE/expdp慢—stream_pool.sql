�������� ԭ���� AMM (Automatic memory management ) ����Ϊ ASMM ��Automatic Shared Memory Management���� ԭ��ÿ���ܵ��߼������� 30���ӱ���� 4����Сʱ��
expdp ������ v$session ��ʾ�ĵȴ�Ϊ��
Streams AQ: enqueue blocked on low memory
wait for unread message on broadcast channel
������������������ ���ã�
ALTER SYSTEM SET STREAMS_POOL_SIZE=2G  SCOPE=spfile;
ALTER SYSTEM SET shared_pool_size=6G SCOPE=spfile;
ALTER SYSTEM SET "_shared_io_pool_size"=512M SCOPE=spfile;
�������ݿ⣺shutdown immeidate
�������������������startup force

������û��Ч������ѯ��������������£�
https://community.oracle.com/thread/3600240?start=15&tstart=0
https://oraculix.com/2014/12/05/data-pump-aq-tm-processes/
http://srinivasoguri.blogspot.co.uk/2016/02/streams-aq-enqueue-blocked-on-low-memory.html

���ˣ�����������һ���� ������������Ȼ��Ч��
���� ѹ����20G��dump �ļ�ֻ��Ҫ 23����