--�����ļ��Ķ�·����
1���鿴����
SQL> show parameter control_file 

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
control_file_record_keep_time        integer     7
control_files                        string      +DATA/racdb/controlfile/curren
                                                 t.256.1011625547, +DATA/racdb/
                                                 controlfile/current.257.101162
                                                 5547
                                                 
2�����ݲ����ļ�
SQL>  create pfile='/home/oracle/pfile_bak' from spfile;

3���޸Ŀ����ļ�����
--���������ļ�����+DATA/racdb/controlfile/control_20200518_new    ע�⣬������ԭʼ�Ŀ����ļ�������ʽȥ����
SQL> alter system set control_files=' +DATA/racdb/controlfile/current.256.1011625547','+DATA/racdb/controlfile/current.257.1011625547','+DATA/racdb/controlfile/control_20200518_new' scope=spfile sid='*';

4�����ڿ����ļ��Ǿ�̬��������Ҫ�ر����ݿ⣬�����ƿ����ļ���
4.1���ر����ݿ�
[oracle@racnode01 ~]$ srvctl stop database -d racdb
[oracle@racnode01 ~]$ srvctl status  database -d racdb
Instance racdb1 is not running on node racnode01
Instance racdb2 is not running on node racnode02

5�����ƿ����ļ�
[grid@racnode01 ~]$ asmcmd
ASMCMD>cd +DATA/RACDB/CONTROLFILE
ASMCMD> ls
Current.256.1011625547
Current.257.1011625547
ASMCMD> cp Current.257.1011625547 control_20200518_new

6���������ݿ�
������һ��ʵ�����鿴�����ļ��Ƿ���Ч
SQL> startup nomount;
��־����ʾ�������ļ��Ѿ���Ч
control_files            = "+DATA/racdb/controlfile/current.256.1011625547"
control_files            = "+DATA/racdb/controlfile/current.257.1011625547"
control_files            = "+DATA/racdb/controlfile/control_20200518_new"


