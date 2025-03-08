--oracle pfile��spfile˵��
�� Oracle ʵ������ʱ�����ӳ�ʼ�������ļ��ж�ȡ��������ʵ����ʼ������С����ʼ�������ļ�ֻ��Ҫָ������ DB_NAME ��ֵ����������������Ĭ��ֵ
��ʼ�������ļ�������ֻ��(��̬)���ı��ļ� (pfile)�����Ƕ�/д(��̬)�Ķ������ļ� (spfile)�������Ʋ����ļ�����Ϊ�����������ļ�(Server Parameter File)��
pfile �����ü��±�����ֱ���޸ģ��ұ�������������Ч��spfile ���� alter system �����������޸ģ���Ч��ʱ�޺����������޸�����Ĳ��� scope ��������

++++++�������ļ������޸ģ������ֱ�ӵ��£����ݿ��Ҳ��������ļ�

--scope=spfile    �������ļ���Ч
The change is applied in the server parameter file only. The effect is as follows:

No change is made to the current instance.
For both dynamic and static parameters, the change is effective at the next startup and is persistent.
This is the only SCOPE specification allowed for static parameters.

--scope=memory    ���ڴ���Ч
The change is applied in memory only. The effect is as follows:

The change is made to the current instance and is effective immediately.
For dynamic parameters, the effect is immediate, but it is not persistent because the server parameter file is not updated.
For static parameters, this specification is not allowed.

--SCOPE=BOTH
The change is applied in both the server parameter file and memory. The effect is as follows:

The change is made to the current instance and is effective immediately.
For dynamic parameters, the effect is persistent because the server parameter file is updated.
For static parameters, this specification is not allowed.

ʵ��������ʼ�������ļ�����˳��spfileORACLE_SID.ora -> spfile.ora -> initORACLE_SID.ora

create pfile/spfile from spile/pfile  �������໥ת����  create pfile from spfile='spfileorcl.ora';  

--ָ�������ļ����� ---ֻ��ָ����̬�����ļ�
startup pfile='xxxxx'
startup pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initsxfxdb.ora_bak';
create spfile='+ORA_DATA/crsdb/spfilecrsdb.ora' from pfile;
create spfile='+DATA/racdb/spfileracdb.ora' from pfile='/home/oracle/pfile_new';
create pfile ='/export/home/oracle/spfilesngsnfdb_bak.ora' from spfile='+DATA/sngsnfdb/spfilesngsnfdb.ora';

--rac�����ļ��ο�
cd $ORACLE_HOME/dbs
vim initorcldb1.ora
spfile='+ORA_DATA/orcldb/spfileorcldb.ora'
--show parameter spfile
���Բ鿴��Ӧ�Ĳ��������ļ�
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /u01/app/oracle/product/10.2.0
                                                 /db_1/dbs/spfilebyisdb.ora
                                                 
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /u01/app/oracle/product/10.2.0
                                                 /db_1/dbs/spfile.ora

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string                                      --·��Ϊ�գ�˵�����þ�̬�����ļ�����


--�����ڵ������ݿ������ʱ�򣬿����ȴ�����̬�����ļ���Ȼ���޸����ã�֮����ת����oracle�Ĳ����ļ�������

--������ݿ�����ʱû����ASM�е�spfile����������ͨ��initsid.ora���ļ�ȥָ��spfile;


##sql_wallet
sqlnet.wallet_override= true
��zdlra�豸��ȥ�������ݿ���û�����⣬���ǣ������ݿ�ʵ���ر�ʱ�����ܻ����ʵ������ʱ�����ܷ���ASM�е�spfile�ļ�������ASM�������ġ�
���������ǣ�ע�͵��������������Ȼ��Ϳ����������ݿ��ˣ��������������»�ԭ�������ɡ�