--��ʱ��
1��ȫ����ʱ�� 
--���ڻỰ�� on commit preserve rows 
1����session�����˳����Զ���ɾ���������ն�������
2������ڲ�ͬ�ĻỰ�����ݶ�������ͬ��session�����������ǲ�ͬ�ġ�
create global temporary table T_TMP_session on commit preserve rows as select  * from dba_objects where 1=2;

--��������� on commit delete rows
1��commit���Զ�������ݡ�
ʹ�÷�Χ��
1�������һ�ε��ù�������Ҫ�����ռ�¼���ٲ����¼��
create global temporary table t_tmp_transaction on commit delete rows as select * from dba_objects where 1=2;

--��ʱ��ռ䲻��
��������ʱ��ռ��У���û�еѿ�������SQL