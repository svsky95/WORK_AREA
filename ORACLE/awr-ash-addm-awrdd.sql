--����oracle�������ܹ���
��Ҫ������AWR��ASH��ADDM��AWRDD���ĸ����ߡ�
--AWR�ǹ�ע���ݿ���������ܵı���   sqlplus��ִ��@?/rdbms/admin/awrrpt.sql
--ASH�����ݿ��еĵȴ��¼�����ЩSQL�����Ӧ�ı���  sqlplus��ִ��@?/rdbms/admin/ashrpt.sql
--ADDM��Oracle������һЩ����     sqlplus��ִ��@?/rdbms/admin/addmrpt.sql
--AWRDD��Oracle��Բ�ͬʱ�ε����ܵ�һ���ȶԱ��棬�����������9��ϵͳ���������������ʱ����������ܶ��˾���֪����������9�����������9����ʲô��ͬ�����Ǿ�����������档  sqlplus��ִ��@?/rdbms/admin/awrddrpt.sql 
--AWRSQRPT��ͳ��ͳ����Ϣ��ִ�мƻ���   sqlplus��ִ��@?/rdbms/admin/awrsqrpt.sql  --��Ҫ����sql_id 
--sql�Ż�����    @?/rdbms/admin/sqltrpt.sql

--segment advisor 
--�������ƶ�
alter table HX_SB.SB_CGS_CLDAXX enable row movement;
--����������
alter table HX_SB.SB_CGS_CLDAXX shrink space;