--oracle��������
--ע�⣬����ϵͳ������solaris��oracle enterprise linux
����SSD��ʹ�ÿ��Է�Ϊ���֣�
1��С�����ݿ⣬���԰����ݿ�ֱ�Ӳ�����SSD�ϡ�
2���������ݿ⣬���������ļ������������������SSD�ϣ�
show parameter db_flash_cache
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_flash_cache_file                  string
db_flash_cache_size                  big integer 0

alter system set db_flash_cache_size=1024M scope=spfile;
alter system set db_flash_cache_file='/ora_data/test_db.dbf' scope=spfile;

--֮���������ݿ⡣

--���ñ�����
none     �鲻�ᱻ����
default  �������������ȼ����л���
keep     �����ȼ����л��棬���Ҳ��ᱻ�Ƴ����棬����û�п��õ�Ĭ�Ͽ�

alter table sales_test storage(flash_cache none/default/keep);
alter index idx_dale storage(flash_cache none/default/keep);

��oracle 11g ��ʼ��ȫ��ɨ��ͨ�����ƹ�buffer cache��ֱ�Ӵ�Ӳ�̶�ȡ����db_flash_cache�Ǵӻ�����ת�ƹ����ģ�����ȫ��ɨ���ǲ��ܴ�db_flash_cache�л�õġ�