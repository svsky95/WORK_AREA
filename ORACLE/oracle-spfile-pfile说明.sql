--oracle pfile及spfile说明
当 Oracle 实例启动时，它从初始化参数文件中读取参数进行实例初始化，最小化初始化参数文件只需要指定参数 DB_NAME 的值，所有其他参数有默认值
初始化参数文件可以是只读(静态)的文本文件 (pfile)，或是读/写(动态)的二进制文件 (spfile)，二进制参数文件被称为服务器参数文件(Server Parameter File)。
pfile 可以用记事本进行直接修改，且必须重启才能生效。spfile 须用 alter system 命令来进行修改，生效的时限和作用域由修改命令的参数 scope 来决定。

++++++二进制文件不可修改，否则会直接导致，数据库找不到参数文件

--scope=spfile    仅参数文件生效
The change is applied in the server parameter file only. The effect is as follows:

No change is made to the current instance.
For both dynamic and static parameters, the change is effective at the next startup and is persistent.
This is the only SCOPE specification allowed for static parameters.

--scope=memory    仅内存生效
The change is applied in memory only. The effect is as follows:

The change is made to the current instance and is effective immediately.
For dynamic parameters, the effect is immediate, but it is not persistent because the server parameter file is not updated.
For static parameters, this specification is not allowed.

--SCOPE=BOTH
The change is applied in both the server parameter file and memory. The effect is as follows:

The change is made to the current instance and is effective immediately.
For dynamic parameters, the effect is persistent because the server parameter file is updated.
For static parameters, this specification is not allowed.

实例启动初始化参数文件查找顺序：spfileORACLE_SID.ora -> spfile.ora -> initORACLE_SID.ora

create pfile/spfile from spile/pfile  来进行相互转换。  create pfile from spfile='spfileorcl.ora';  

--指定参数文件启动 ---只能指定静态参数文件
startup pfile='xxxxx'
startup pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initsxfxdb.ora_bak';
create spfile='+ORA_DATA/crsdb/spfilecrsdb.ora' from pfile;
create spfile='+DATA/racdb/spfileracdb.ora' from pfile='/home/oracle/pfile_new';
create pfile ='/export/home/oracle/spfilesngsnfdb_bak.ora' from spfile='+DATA/sngsnfdb/spfilesngsnfdb.ora';

--rac参数文件参考
cd $ORACLE_HOME/dbs
vim initorcldb1.ora
spfile='+ORA_DATA/orcldb/spfileorcldb.ora'
--show parameter spfile
可以查看对应的参数启动文件
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
spfile                               string                                      --路径为空，说明是用静态参数文件启动


--所以在调整数据库参数的时候，可以先创建静态参数文件，然后修改配置，之后再转换回oracle的参数文件启动。

--如果数据库启动时没有用ASM中的spfile启动，可以通过initsid.ora的文件去指定spfile;


##sql_wallet
sqlnet.wallet_override= true
用zdlra设备，去备份数据库是没有问题，但是，当数据库实例关闭时，可能会出现实例启动时，不能发现ASM中的spfile文件，但是ASM是正常的。
处理方法就是：注释掉上面这个参数，然后就可以启动数据库了，当启动后，再重新还原回来即可。