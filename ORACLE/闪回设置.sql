#######��������#######
#���ؼ���
Ϊ��ʹ���ݿ��ܹ����κ��߼�������Ѹ�ٻָ���oracle�Ƴ������ؼ��������øü��������Զ��м������Ｖ�����ݱ仯���лָ������������ݻָ���ʱ�䣬���Ҳ����򵥡�ͨ��SQL���Ϳ���ʵ�����ݵĻָ��������������ݿ�ָ���Ч�ʡ����ؼ��������ݿ�ָ�������ʷ��һ���ش�Ľ������Ӹ����ϸı������ݻָ���

���ؼ����������¸��

���ز�ѯ����FLASHBACK QUERY������ѯ��ȥĳ��ʱ����ĳ��SCNֵʱ���е�������Ϣ

���ذ汾��ѯ��FLASHBACK Version query������ѯ��ȥĳ��ʱ��λ�ĳ��SCN���ڱ������ݱ仯�������

���������ѯ��FLASHBACK Transaction Query��:�鿴ĳ����������������ڹ�ȥһ��ʱ������ݽ��е��޸ġ�

�������ݿ⣨FLASHBACK Database��:�����ݿ�ָ�����ȥĳ��ʱ����ĳ��SCNֵʱ��״̬

����ɾ����FLASHBACK drop�������Ѿ�ɾ���ı�������Ķ���ָ���ɾ��ǰ��״̬��

���ر�FLASHBACK table��:����ָ�����ȥ��ĳ��ʱ����ĳ��SCNֵʱ��״̬��

SCN�ǵ�oracle���ݿ���º���DBMS�Զ�ά�����ۻ�������һ�����֡�����ͨ����ѯ�����ֵ�V$DATABASE�е�CURRENT_SCN��õ�ǰ��SCN�š�

#���غ���
oracle�Ƽ�ָ��һ�����ػָ�����FLASHRECOVERY AERA����Ϊ��ű�����ָ���ص�Ĭ��λ�ã�����ORACLE�Ϳ���ʵ���Զ��Ļ��ڴ��̵ı�����ָ������ػָ�����һ�������洢�ָ���ص��ļ��Ĵ洢�ռ䣬�����û����д洢���лָ���ص��ļ���
���¼����ļ����Դ�������ػָ�����
�����ļ�
�鵵��־�ļ�
������־
�����ļ���SPFILE�Զ�����
RMAN���ݼ�
�����ļ�����

-���ػָ�����Ҫͨ������3����ʼ�����������ú͹���

db_recovery_file_dest��ָ�����ػָ�����λ��

db_recovery_file_dest_size��ָ�����ػָ����Ŀ��ÿռ�

db_flashback_retention_target���ò�����������������־�����ݱ�����ʱ�䣬����˵��ϣ���������ݿ��ܹ��ָ����������ʱ��㡣��λΪmin��Ĭ����1440min,��һ�졣��Ȼʵ���Ͽɻ��˵�ʱ�仹ȡ�������ػָ����Ĵ�С����Ϊ���汣���˻�������Ҫ��������־�������������Ҫ��db_recovery_file_dest_size����޸ġ�

-�������ػָ�����
�ѳ�ʼ������DB_RECOVERY_FILE_DEST��ֵ��ա�
db_recovery_file_dest_sizeֻ����DB_RECOVERY_FILE_DEST���֮��ſ������

##�����������ݿ�
--�������ݿ��ܹ�ʹ����Ѹ�ٵĻع�����ǰ��ĳ��ʱ������ĳ��SCN�ϣ�������ݿ���߼������лָ��ر����á�����Ҳ�Ǵ���������߼���ʱ�ָ����ݿ���ѵ�ѡ��
--�������ݿ���������ƣ�
�����ļ��𻵻�ʧ�Ƚ��ʹ��ϲ���ʹ���������ݿ���лָ����������ݿ�ֻ�ܻ��ڵ�ǰ�������е������ļ�
�������ݿ⹦������������������ݿ����ļ��ؽ������ñ��ݻָ������ļ�������ʹ���������ݿ�
����ʹ���������ݿ���������ļ���������
����ʹ���������ݿ⽫���ݿ�ָ�����������־�пɻ�õ������SCN֮ǰ��SCN����Ϊ������־�ļ���һ���������±�ɾ����������ʼ�ձ��������ػָ�����


1�����ݿ⴦�ڹ鵵ģʽ
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     3
Next log sequence to archive   5
Current log sequence           5

2����������
SQL> alter database FLASHBACK on;
SQL> select flashback_on from v$database;
FLASHBACK_ON
------------------
YES

alter system set db_recovery_file_dest='+DATA' scope=both sid='*';
alter system set db_recovery_file_dest_size=30G scope=both sid='*';
alter system set db_flashback_retention_target=1440 scope=both sid='*';     1440min=1day

��ʱ����ASM�������д���FLASHBACK�ļ���

-1@����SCN�ŵ�����
��¼��ǰSCN��
SQL> select current_scn from v$database;

          CURRENT_SCN
---------------------
             15723709
             
-�����ݿ������ɾ�ĵĲ���

-���ز���
�ر�����ʵ��
[oracle@racnode01 ~]$ srvctl stop database -d racdb
[oracle@racnode01 ~]$ srvctl status database -d racdb

-����ʵ��1
SQL> startup mount
SQL> flashback database to scn 15723709;
SQL> alter database open resetlogs;

-����ʵ��2
SQL>startup

-��ѯ���ؼ�¼
SELECT * FROM v$flashback_database_log t;

2@����ʱ��������
alter session set NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
SQL>   select sysdate from dual;
SYSDATE
-------------------
2019-11-21 10:58:24

-ͬ�����裬�ر�����ʵ��������ʵ��1
flashback database to timestamp(to_timestamp('2019-11-21 10:58:24','yy-mm-dd hh24:mi:ss')); 

##�������ر�
���ر��ǽ���ָ�����ȥ��ĳ��ʱ������ָ����SCN�����ûָ������ļ���ΪDBA�ṩ��һ�����ߡ����١���ݵĻָ���ʽ�����Իָ��Ա���е��޸ġ�ɾ��������ȴ���Ĳ�����
�������ر����ָ����е����ݵĹ��̣�ʵ�����ǶԱ����DML�����Ĺ��̡�oracle�Զ�ά��������������������������Լ���ȡ�

�û�����FALSHBACKANY TABLEϵͳȨ�ޣ����߾������������FLASHBACK����Ȩ��
�û��������������SELECT/INSERT/DELETE/ALTER����Ȩ��
�������������ROW MOVEMENT���ԣ����Բ������з�ʽ���У�
SQL> ALTER TABLE ���� ENABLE ROWMOVEMENT;

���ر��﷨��ʽ��
FLASHBACK TABLE [schema].table TO SCN |TIMESTAMP expression [ENABLE|DISABLE TRIGGERS]

����˵��:
SCN:����ָ���ָ����SCNʱ��״̬
TIMESTAMP:����ָ���ָ����ʱ���
ENABLE|DISABLETRIGGERS:�ڻָ��������ݵĹ����У����ϵĴ�����ʱ���û��Ǽ��Ĭ�������ã�

1��ȷ������SCN�Ż���ʱ��� ��ʹ�÷�Χ��INSERT/DELETE �����ã�truncate/drop ��
-�����ָ�������ƶ���һ�ű����Ը���ʱ��㣬���ض�Ρ�
alter table cz.test17 enable row movement;
flashback table cz.test17 to timestamp(to_timestamp('2019-11-21 11:34:46','yy-mm-dd hh24:mi:ss'));
--flashback table cz.test17 to scn 15723709;
alter table cz.test17 disable row movement;

PS: unable to read data - table definition has changed ���������ζ�ţ��������ص���ʱ��㡣

