--控制文件的多路复用
1、查看配置
SQL> show parameter control_file 

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
control_file_record_keep_time        integer     7
control_files                        string      +DATA/racdb/controlfile/curren
                                                 t.256.1011625547, +DATA/racdb/
                                                 controlfile/current.257.101162
                                                 5547
                                                 
2、备份参数文件
SQL>  create pfile='/home/oracle/pfile_bak' from spfile;

3、修改控制文件参数
--新增控制文件名：+DATA/racdb/controlfile/control_20200518_new    注意，不能以原始的控制文件命名格式去命名
SQL> alter system set control_files=' +DATA/racdb/controlfile/current.256.1011625547','+DATA/racdb/controlfile/current.257.1011625547','+DATA/racdb/controlfile/control_20200518_new' scope=spfile sid='*';

4、由于控制文件是静态参数，需要关闭数据库，并复制控制文件。
4.1、关闭数据库
[oracle@racnode01 ~]$ srvctl stop database -d racdb
[oracle@racnode01 ~]$ srvctl status  database -d racdb
Instance racdb1 is not running on node racnode01
Instance racdb2 is not running on node racnode02

5、复制控制文件
[grid@racnode01 ~]$ asmcmd
ASMCMD>cd +DATA/RACDB/CONTROLFILE
ASMCMD> ls
Current.256.1011625547
Current.257.1011625547
ASMCMD> cp Current.257.1011625547 control_20200518_new

6、启动数据库
先启动一个实例，查看参数文件是否生效
SQL> startup nomount;
日志里显示，参数文件已经生效
control_files            = "+DATA/racdb/controlfile/current.256.1011625547"
control_files            = "+DATA/racdb/controlfile/current.257.1011625547"
control_files            = "+DATA/racdb/controlfile/control_20200518_new"


