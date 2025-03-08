##oracle_RAC参数修改
1、oracle的参数文件保存在+ASM中。
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORA_DATA/crsdb/spfilecrsdb.ora

2、节点一备份参数文件
SQL> create pfile='/tmp/spfile_bak.ora' from spfile;

3、检查文件
[oracle@racnode01 db_1]$ ll /tmp/sfile_bak.ora 
-rw-r--r-- 1 oracle asmadmin 1569 Sep  6 14:43 /tmp/sfile_bak.ora

3、节点一修改参数
SQL> ALTER SYSTEM SET processes =500 scope=spfile sid='*';  

4、重启节点一，看看参数是否可以修改生效
SQL> shutdown immediate
SQL> startup 

-查看修改的参数是否成功
SQL> show parameter processes
processes                            integer     500

5、保证节点一参数正确的情况下，启动节点二

6、查看两个节点的参数文件，是否指向共享存储的参数文件
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORA_DATA/crsdb/spfilecrsdb.ora

PS：集中启动脚本
SQL> show parameter names

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
global_names                         boolean     FALSE
service_names                        string      racdb

[oracle@racnode01 ~]$ srvctl stop database -d racdb
[oracle@racnode01 ~]$ srvctl start database -d racdb  
[oracle@racnode01 ~]$ srvctl status database -d racdb     
Instance racdb1 is running on node racnode01
Instance racdb2 is running on node racnode02


###oracle参数回退
#当参数修改失败时，oracle数据库肯定是启动不起来的，这时先关闭节点一节点二数据库
1、节点一
SQL> shutdown immediate

2、从备份中恢复（也可以直接修改/tmp/spfile_bak.ora文件，把参数改正确，然后启动）
create spfile='+DATA/racdb/spfileracdb.ora' from pfile='/tmp/spfile_bak.ora';
3、启动数据库
SQL> startup
4、确定正确后，启动所有节点

##指定参数文件启动 ---只能指定静态参数文件
startup pfile='xxxxx'
startup pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initsxfxdb.ora_bak';













============================一下内容供参考========================================



--RAC环境修改SPFILE
1、为了以防万一，先把共享存储中的spfile的位置记录下来。
SQL> show parameter spfile

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORACL_DATA/crsdb/spfilecrsdb.
                                                 ora
2、创建pfile文件，以便修改，由于原有的路径中有init<SID>.ora文件会被覆盖，所以备份原有的文件。
mv initcrsdb1.ora initcrsdb1.ora_bak
create pfile from spfile;
create pfile='/tmp/ffile.ora' from spfile='+DATA/rac12/spfilerac12.ora';

3、有两种方法可以修改。
一、直接修改pfile文件，然后从pfile文件启动，验证参数修改是否成功。
二、创建当前实例的spfile文件。
create spfile from pfile;
-rw-r--r--. 1 oracle asmadmin 1557 Feb 22 15:44 initcrsdb1.ora
-rw-r-----. 1 oracle asmadmin 4608 Feb 22 15:47 spfilecrsdb1.ora

4、重启当前实例，则自动从spfile文件启动
shutdown immediate
startup 
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /u01/app/oracle/product/11.2.0
                                                 /db_1/dbs/spfilecrsdb1.ora
5、修改相关参数
alter system set sga_max_size=5120M scope=spfile;
6、重启后验证参数是否修改成功
7、从修改好的spfile生成pfile
SQL> create pfile from spfile;
8、查看pfile文件中的参数是否已经生效，然后删除当前实例的spfilecrsdb1.ora，否则实例会使用spfilecrsdb1.ora文件启动。
在initcrsdb1.ora中的最后一行添加 SPFILE='+ORACL_DATA/crsdb/spfilecrsdb.ora'              # line added by Agent 
9、关闭所有节点的数据库，把pfile文件放入到共享存储中，供所有节点使用。
create spfile='+ORACL_DATA/crsdb/spfilecrsdb.ora' from pfile;
10、启动所有的节点，验证参数是否都已经生效。



浅析RAC下SPFILE文件修改之整理三篇文章

第一篇：RAC下SPFILE文件修改

在RAC下spfile位置的修改与单节点环境不完全一致，有些地方需要特别注意，否则可能修改会失败。

 

下面用一个例子说明：SPFILE放在ASM中一个不正确的目录(+ARCH)中，现在想把它放在另外一个目录(+DBSYS)下。

 

以下是具体步骤：

 

1. 原spfile位置

SQL> show parameter spfile

 

NAME TYPE VALUE

----------------------------------------------- ------------------------------

spfile string +ARCH/dwrac/spfiledwrac.ora

 

2. 拷贝spfile到其他目录

 

由于在ASM中，不能直接cp，需要通过迂回的办法实现。

 

sys@dwrac2> create pfile='/tmp/pfile.ora' from spfile;

 

File created.

 

sys@dwrac2> create spfile='+DBSYS/dwrac/spfiledwrac.ora' from pfile='/tmp/pfile.ora';

 

File created.

 

3. 修改所有节点$ORACLE_HOME/dbs/init下的参数文件

[oracle@dwdb04 dbs]$ vi initdwrac2.ora

 

SPFILE='+ARCH/dwrac/spfiledwrac.ora'

==>

SPFILE='+DBSYS/dwrac/spfiledwrac.ora'

 

 

4. 通过sqlplus方式重启实例

sys@dwrac2> shutdown immediate

Database closed.

Database dismounted.

ORACLE instance shut down.

sys@dwrac2> startup

ORACLE instance started.

 

Total System Global Area 5.2429E+10 bytes

Fixed Size 2193872 bytes

Variable Size 3707766320 bytes

Database Buffers 4.8671E+10 bytes

Redo Buffers 48136192 bytes

Database mounted.

Database opened.

sys@dwrac2> show parameter spfile

 

NAME TYPE VALUE

------------------------------------ -----------------------------------------

spfile string +DBSYS/dwrac/spfiledwrac.ora

 

可以发现，spfile已经修改成功。

 

5. 但是如果用过srvctl重启数据库，发现spfile又变回来了：

 

[oracle@dwdb02 dbs]$ srvctl stop instance-d dwrac -i dwrac1,dwrac2,dwrac3,dwrac4

 

[oracle@dwdb02 dbs]$ srvctl start instance-d dwrac -i dwrac1,dwrac2,dwrac3,dwrac4

 

[oracle@dwdb02 dbs]$ sqlplus "/assysdba"

 

sys@dwrac2> show parameter spfile

 

NAME TYPE VALUE

----------------------------------------------- ------------------------------

spfile string +ARCH/dwrac/spfiledwrac.ora

 

6. 原因及解决

 

这是为什么呢？实际上在RAC环境中，我们更多时候是用srvctl来管理RAC资源，而srvctl的信息来自ocr，包括spfile的位置信息。我们刚才那样做虽然修改了参数文件的位置，但是ocr并不知道，它还用原来的文件启动数据库。

我们可以用srvctl查看数据库的配置信息来确认：

 

[oracle@dwdb01 dbs]$ srvctl config database-d dwrac -a

dwdb01 dwrac1 /oracle/product/10.2.0/db

dwdb02 dwrac2 /oracle/product/10.2.0/db

dwdb03 dwrac3 /oracle/product/10.2.0/db

dwdb04 dwrac4 /oracle/product/10.2.0/db

DB_UNIQUE_NAME: dwrac

DB_NAME: dwrac

ORACLE_HOME: /oracle/product/10.2.0/db

SPFILE: +ARCH/dwrac/spfiledwrac.ora

DOMAIN: null

DB_ROLE: null

START_OPTIONS: null

POLICY: AUTOMATIC

ENABLE FLAG: DB ENABLED

 

可以看到，SPFILE的位置指向是+ARCH。解决方法是通过srvctl修改SPFILE的位置。

 

[oracle@dwdb01 dbs]$ srvctl modify database-d dwrac -p '+DBSYS/dwrac/spfiledwrac.ora'

[oracle@dwdb01 dbs]$ srvctl config database-d dwrac -a

dwdb01 dwrac1 /oracle/product/10.2.0/db

dwdb02 dwrac2 /oracle/product/10.2.0/db

dwdb03 dwrac3 /oracle/product/10.2.0/db

dwdb04 dwrac4 /oracle/product/10.2.0/db

DB_UNIQUE_NAME: dwrac

DB_NAME: dwrac

ORACLE_HOME: /oracle/product/10.2.0/db

SPFILE: +DBSYS/dwrac/spfiledwrac.ora

DOMAIN: null

DB_ROLE: null

START_OPTIONS: null

POLICY: AUTOMATIC

ENABLE FLAG: DB ENABLED

 

[oracle@dwdb01 dbs]$ srvctl stop database-d dwrac

[oracle@dwdb01 dbs]$ srvctl start database-d dwrac

sys@dwrac2> show parameter spfile

 

NAME TYPE VALUE

----------------------------------------------- ------------------------------

spfile string +DBSYS/dwrac/spfiledwrac.ora

 

可以看到，此时Oracle是用新的spfile启动的。

 

7.总结

在RAC环境下修改spfile：

 

1. 需要修改$ORACLE_HOME/dbs下的相关文件，指向新文件

2. 需要用srvctl修改config信息，指向新文件

 

第二篇：Oracle ASM存储Spfile解析

以下来自论坛：

在之前的文章《Oracle Restart启动数据库实例故障一例》（http://space.itpub.net/17203031/viewspace-774622）中，笔者解决了一个由于使用create pfilefrom spfile引起的Restart无法启动数据库实例的故障。

 

严格的说，笔者并没有完全将其解决。主要体现在Spfile的使用和存放上。

 

1、问题简述

 

Oracle Database安装在ASM存储的时候，默认都是使用ASM保存Spfile参数文件。与早期的pfile文件不同，Spfile是具有二进制格式，能够支持部分参数的动态调整。

 

所以，我们出现问题的时候，发现Restart的配置信息中包括了ASM中的Spfile参数内容。

 

 

[oracle@SimpleLinux ~]$ srvctl config database -d ora11g

Database unique name: ora11g

Database name:

Oracle home: /u01/app/oracle/product/11.2.0/db_1

Oracle user: oracle

Spfile: +DATA/ORA11G/spfileora11g.ora

Domain:

Start options: open

Stop options: immediate

Database role: PRIMARY

Management policy: AUTOMATIC

Database instance: ora11g

Disk Groups: DATA,RECO

Services:

 

 

我们之前的修复方法，就是将spfile内容置空，让数据库实例启动使用默认路径$ORACLE_HOME/dbs的spfile和pfile参数进行检索。

 

 

SQL> show parameter spfile

 

NAME                                TYPE        VALUE

------------------------------------ -----------------------------------------

spfile                              string     /u01/app/oracle/product/11.2.0

                                                /db_1/dbs/spfileora11g.ora

 

 

但是此时，我们在ASM路径上是存在spfile上的。

 

 

ASMCMD> pwd       

+DATA/ORA11G

 

ASMCMD> ls

CONTROLFILE/

DATAFILE/

ONLINELOG/

PARAMETERFILE/

TEMPFILE/

spfileora11g.ora

 

 

在这种情况下，如果配置了ASM目录的spfile启动标志，启动Restart会报错。

 

 

[oracle@SimpleLinux ~]$ srvctl modify database -d ora11g-p +DATA/ora11g/spfileora11g.ora

[oracle@SimpleLinux ~]$ srvctl start database -d ora11g

PRCR-1079 : Failed to start resource ora.ora11g.db

CRS-5010: Update of configuration file "/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora"failed: details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

CRS-5017: The resource action "ora.ora11g.db start" encounteredthe following error:

CRS-5010: Update of configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in "/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

. For details refer to "(:CLSN00107:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log".

 

CRS-2674: Start of 'ora.ora11g.db' on 'simplelinux' failed

 

 

2、分析和思考

 

一起冷静想想~

 

Pfile和spfile是参数文件经历的两个阶段。在umount阶段，Oracle是通过参数$ORACLE_HOME和$ORACLE_SID进行目录定位，定位到$ORACLE_HOME/dbs或者$ORACLE_HOME/database，到里面寻找制定规则的参数文件。

 

Oracle首先会去寻找Spfile，之后才会去找Pfile。我们通过create spfile和create pfile可以实现两者的转化。

 

一个比较常见的问题案例是：如果我们把启动参数改错了，启动不了了，那么怎么办？标准的做法是通过create pfilefrom spfile，拿到一个文本格式的参数pfile。在里面修改启动参数，纠正错误。启动时候，使用startuppfile=xxx使用“指定的pfile”启动数据库实例，再通过create spfile from pfile将变化固化下来。

 

Oracle Restart提供的配置参数spfile其实是很诡异的。从直观上看，好像是有startup数据库实例，后面可以自己去指定参数文件，类似于startupspfile=xxx的作用。但是实际上，startup是不支持spfile这样的参数的。

 

如果这个参数是用于指定，那么在Restart启动的时候我们已经设置争取的spfile位置，指定位置上面也有文件。但是根本没有效果，Oracle还是寻找参数文件。

 

那么，就只有一种可能性：即使Oracle使用Restart启动，也不是依靠指定的spfile，还是按照原有的规则运行。

 

网络上有一种方法，说的是如果我们需要指定一个spfile启动文件的时候，应该怎么做。答案是建立一个空的pfile文件，里面直接指定SPFILE参数的文件位置。

 

综合几种思路，我们可以设想到Spfile保存在ASM里面，同时让Restart和sqlplus启动时候可以访问到ASMSpfile的方法。

 

3、配置ASM上SPFILE启动

 

首先是创建出ASM上的spfile。注意：创建spfile的时候一定是从pfile创建，所以需要转换一下。

 

 

SQL> startuppfile=/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora

ORACLE instance started.

 

Total System Global Area  263639040bytes

Fixed Size                  1344312bytes

Variable Size             134221000bytes

Database Buffers          125829120bytes

Redo Buffers                2244608bytes

Database mounted.

Database opened.

SQL> show parameter spfile

 

NAME                                TYPE        VALUE

------------------------------------ -----------------------------------------

spfile                               string

 

SQL> create spfile='+DATA/ORA11G/spfileora11g.ora'from pfile;

File created.

 

 

此时，我们在ASM里面可以看到生成的spfile二进制文件。

 

 

ASMCMD> ls -l

Type           Redund  Striped Time             Sys  Name

                                                Y    CONTROLFILE/

                                                Y    DATAFILE/

                                                Y    ONLINELOG/

                                                Y    PARAMETERFILE/

                                                Y    TEMPFILE/

                                                N   spfileora11g.ora => +DATA/ORA11G/PARAMETERFILE/spfile.267.829130539

 

 

第二部是创建维护一个“转发”参数文件。

 

 

 

SQL> shutdown immediate;

Database closed.

Database dismounted.

ORACLE instance shut down.

 

[oracle@SimpleLinux ~]$ cd $ORACLE_HOME

[oracle@SimpleLinux db_1]$ cd dbs

[oracle@SimpleLinux dbs]$ ls -l

total 28

-rw-rw---- 1 oracle asmadmin 1544 Sep 12 12:58 hc_ora11g.dat

-rw-r--r-- 1 oracle oinstall 2851 May 15 2009 init.ora

-rwxr-x--- 1 oracle oinstall  959 Oct 18 09:51 initora11g.ora

-rwxrwx--- 1 oracle oinstall  887Sep 29 09:31 initora11g.ora.bk

-rw-r----- 1 oracle asmadmin   24Sep 12 12:58 lkORA11G

-rw-r----- 1 oracle oinstall 1536 Sep 12 13:11 orapwora11g

-rw-r----- 1 oracle asmadmin 2560 Oct 18 09:57spfileora11g.ora

 

 

在里面要完成两件事情，一个是将dbs目录下面的spfile删除。因为依据Oracle启动的原则，是先找spfile，之后再找pfile。第二件是修改文本参数文件，作为转发。

 

 

[oracle@SimpleLinux dbs]$ mv spfileora11g.ora spfileora11g.ora.bk

 

[oracle@SimpleLinux dbs]$ cat initora11g.ora

SPFILE='+DATA/ora11g/spfileora11g.ora’ –注意：不能包括*前缀或者SID前缀

 

[oracle@SimpleLinux dbs]$ ls -l

total 28

-rw-rw---- 1 oracle asmadmin 1544 Sep 12 12:58 hc_ora11g.dat

-rw-r--r-- 1 oracle oinstall 2851 May 15 2009 init.ora

-rwxr-x--- 1 oracle oinstall   41Oct 18 10:07 initora11g.ora

-rwxrwx--- 1 oracle oinstall  887Sep 29 09:31 initora11g.ora.bk

-rw-r----- 1 oracle asmadmin   24Sep 12 12:58 lkORA11G

-rw-r----- 1 oracle oinstall 1536 Sep 12 13:11 orapwora11g

-rw-r----- 1 oracle asmadmin 2560 Oct 18 09:57 spfileora11g.ora.bk

 

 

使用srvctl关闭和启动数据库。

 

 

[oracle@SimpleLinux dbs]$ srvctl start database -d ora11g

[oracle@SimpleLinux dbs]$ srvctl config database -d ora11g

Database unique name: ora11g

Database name:

Oracle home: /u01/app/oracle/product/11.2.0/db_1

Oracle user: oracle

Spfile: +DATA/ora11g/spfileora11g.ora

Domain:

Start options: open

Stop options: immediate

Database role: PRIMARY

Management policy: AUTOMATIC

Database instance: ora11g

Disk Groups: DATA,RECO

Services:

 

[oracle@SimpleLinux dbs]$ srvctl status database -d ora11g

Database is running.

 

 

数据库中，spfile参数被设置为ASM路径。

 

 

SQL> show parameter spfile;

 

NAME                                 TYPE        VALUE

------------------------------------ -----------------------------------------

spfile                              string     +DATA/ora11g/spfileora11g.ora

 

 

故障彻底解决。

 

4、结论

 

综合上面的实验，我们可以看到ASM下Spfile使用的方法。ASM下的Spfile并不是抛弃原有的启动规则，而是借助原有的pfile进行了目标转接。之后笔者查看MOS中的对应方案，官方推荐的也是这样的做法。

 

这样就需要一个前提，就是dbs或者database目录中不能包括spfile。如果包括了，Oracle设置的转接机制就被替换掉了。

 

另一个问题是我们一直看到的错误提示信息，提示参数文件initora11g.ora格式不能识别。笔者的理解是，原始的文件是笔者使用create pfilefrom spfile创建出来的，默认的SPFILE=XXX的内容被覆盖。而Oracle Restart不能识别这种非转接内容文件，所以报错。

第三篇：Oracle Restart启动数据库实例故障一例

网络整理：

Oracle Restart是11gR2中推出的重要高可用（HighAvailability）特性。在Single Instance情况下，Clusterware形成一个可用性维护框架，Oracle组件服务都是在这个维护管理框架上进行管理。

 

Oracle Restart从职责上负责两方面的功能，一个是Oracle各个服务组件的自动启动。鉴于组件间复杂的依赖关系，使用Restart自动的进行启动顺序调节是比较好的一种策略。另一个功能是高可用支持，如果某一个组件意外被终止运行，比如异常中断，Oracle Restart是可以定期的检查“治下”组件的生存情况，一旦检查出问题就会进行自动的启动。

 

目前单实例Oracle使用Oracle Restart支持的组件内容有：监听器Listener、Oracle实例和数据库、ASM实例、ASM磁盘组、数据库服务Service和ONS（OracleNotification Service）。

 

本篇记录笔者遇到的一个故障场景，不甚复杂，和行业大牛们大作不敢相比。权当思路记录，留待需要的朋友不时之需。

 

1、问题故障出现

 

在一台11gR2的Oracle上，笔者部署了单实例ASM实例和磁盘组结构，并且在上面部署了SingleInstance Oracle。由于是测试使用，笔者在上面进行过一些测试和实验，今天启动服务器之后，发现问题。

 

 

grid@SimpleLinux simplelinux]$ uptime

 13:58:13 up 2:24, 1 user, load average: 0.03, 0.02, 0.00

[grid@SimpleLinux simplelinux]$ ps -ef |grep pmon

grid      3212    1  0 11:35 ?        00:00:01 asm_pmon_+ASM

grid    27724 27685  0 13:58 pts/0    00:00:00 grep pmon

 

 

根据标准的Oracle Restart配置，ASM实例、ASM磁盘组和数据库实例都是在Restart管理范围，应该是随着服务器启动而自动启动。但是从实际情况看，ASM实例已经自动启动，数据库实例没有启动。

 

同RAC结构一样，Restart也是借助服务器启动过程中，以ohasd为首的高可用守护进程进行步步启动动作。

 

这种情况下，查看日志信息是最好的选择，看看那个环节出现问题。

 

 

[grid@SimpleLinux simplelinux]$ pwd

/u01/app/grid/product/11.2.0/grid/log/simplelinux

[grid@SimpleLinux simplelinux]$ ls -l |grep alert

-rw-rw---- 1 grid oinstall 14494Oct 17 11:35 alertsimplelinux.log

 

 

对grid和clusterware的日志，都是保留在$ORACLE_HOME/log下的目录从中。Alert<sid>.log是主日志，也是检查的起始点。通常是里面发现的问题，进行进一步的分析动作。

 

 

[ohasd(2744)]CRS-2767:Resource staterecovery not attempted for 'ora.diskmon' as its target state is OFFLINE

2013-10-17 11:35:34.373

[cssd(3130)]CRS-1601:CSSD Reconfigurationcomplete. Active nodes are simplelinux .

2013-10-17 11:35:50.094

[/u01/app/grid/product/11.2.0/grid/bin/oraagent.bin(3072)]CRS-5010:Updateof configuration file "/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora"failed: details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

2013-10-17 11:35:55.645

[/u01/app/grid/product/11.2.0/grid/bin/oraagent.bin(3072)]CRS-5010:Updateof configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

2013-10-17 11:35:55.806

[ohasd(2744)]CRS-2807:Resource'ora.ora11g.db' failed to start automatically.

 

 

我们定位到了问题片段，从上面标红的内容看。Clusterware在启动dismon服务之后，试图启动数据库，也就是ora.ora11g.db。在访问一个参数文件（注意是pfile）过程中，发现问题。

 

进一步检查指出的oraagent_grid.log日志，也没有过多的信息提示。

 

 

2013-10-17 11:35:50.049:[ora.ora11g.db][3013430160] {0:0:2} [start] sclsnInstAgent::sUpdateOratab fileupdated with dbName ora11g value /u01/app/oracle/product/11.2.0/db_1:N

2013-10-17 11:35:50.049:[ora.ora11g.db][3013430160] {0:0:2} [start] sclsnInstAgent::sUpdateOratab CSSunlock

2013-10-17 11:35:50.090:[ora.ora11g.db][3013430160] {0:0:2} [start] (:CLSN00014:)Failed to open file/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora

2013-10-17 11:35:50.091: [   AGENT][3013430160] {0:0:2}UserErrorException: Locale is

2013-10-17 11:35:50.091:[ora.ora11g.db][3013430160] {0:0:2} [start] clsnUtils::error Exception type=2string=

CRS-5010: Update of configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in "/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

 

 

从信息上看，是对pfile没有能够打开。

 

2、一次不成功的尝试

 

从日志信息上，看到是不能够打开文本参数控制文件。初步猜测是文件权限原因，下面进行检查。

 

 

[grid@SimpleLinux oraagent_grid]$ cd/u01/app/oracle/product/11.2.0/db_1/dbs/

[grid@SimpleLinux dbs]$ ls -l

total 20

-rw-rw---- 1 oracle asmadmin 1544 Sep 1212:58 hc_ora11g.dat

-rw-r--r-- 1 oracle oinstall 2851 May15  2009 init.ora

-rw-r----- 1 oracle oinstall  887 Sep 29 09:31 initora11g.ora

-rw-r----- 1 oracle asmadmin   24 Sep 12 12:58 lkORA11G

-rw-r----- 1 oracle oinstall 1536 Sep 1213:11 orapwora11g

[grid@SimpleLinux dbs]$ id oracle

uid=500(oracle) gid=500(oinstall)groups=500(oinstall),501(dba),502(oper),602(asmdba)

[grid@SimpleLinux dbs]$ id grid

uid=501(grid) gid=500(oinstall)groups=500(oinstall),501(dba),600(asmadmin),601(asmoper),602(asmdba)

 

 

权限内容是oracle用户读写、组用户读。从权限上看，grid和oracle读取和修改的问题不算特别严重。但是还是进行测试尝试。

 

 

[oracle@SimpleLinux dbs]$ chmod 770initora11g.ora

[oracle@SimpleLinux dbs]$ ls -l

total 20

-rw-rw---- 1 oracle asmadmin 1544 Sep 1212:58 hc_ora11g.dat

-rw-r--r-- 1 oracle oinstall 2851 May15  2009 init.ora

-rwxrwx--- 1 oracle oinstall  887 Sep 29 09:31 initora11g.ora

-rw-r----- 1 oracle asmadmin   24 Sep 12 12:58 lkORA11G

-rw-r----- 1 oracle oinstall 1536 Sep 1213:11 orapwora11g

 

 

尝试启动数据库。

 

 

[grid@SimpleLinux ~]$ srvctl start database-d ora11g

PRCR-1079 : Failed to startresource ora.ora11g.db

CRS-5010: Update of configurationfile "/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

CRS-5017: The resource action"ora.ora11g.db start" encountered the following error:

CRS-5010: Update of configurationfile "/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

. For details refer to"(:CLSN00107:)" in "/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log".

 

CRS-2674: Start of'ora.ora11g.db' on 'simplelinux' failed

 

 

启动失败。那么，试着使用传统sqlplus命令行方式启动是否可行？

 

 

[oracle@SimpleLinux ~]$ sqlplus /nolog

 

SQL*Plus: Release 11.2.0.3.0 Production onThu Oct 17 14:17:11 2013

 

Copyright (c) 1982, 2011, Oracle.  All rights reserved.

 

SQL> conn / as sysdba

Connected to an idle instance.

SQL> startup

ORACLE instance started.

 

Total System Global Area  263639040 bytes

Fixed Size                  1344312 bytes

Variable Size             134221000 bytes

Database Buffers          125829120 bytes

Redo Buffers                2244608 bytes

Database mounted.

Database opened.

SQL> quit

Disconnected from Oracle Database 11gEnterprise Edition Release 11.2.0.3.0 - Production

With the Partitioning, Automatic StorageManagement, OLAP, Data Mining

and Real Application Testing options

[oracle@SimpleLinux ~]$ ps -ef | grep pmon

grid     3212     1  0 11:35 ?        00:00:02 asm_pmon_+ASM

oracle  27979     1  0 14:17 ?        00:00:00 ora_pmon_ora11g

oracle  28106 27921  0 14:17 pts/0    00:00:00 grep pmon

[oracle@SimpleLinux ~]$ srvctl statusdatabase -d ora11g

Database is running.

 

 

启动成功，使用sqlplus命令行可以启动，但是Oracle Restart启动就会失败。那么问题在哪儿？

 

3、Spfile vs. Pfile

 

从直观上看，Oracle Restart启动的时候是希望访问到参数文件pfile。从直观的感觉上，好像被替代很长时间的pfile为什么会被提及。利用已经启动的数据库实例，看一下当前使用的是什么参数文件。

 

 

SQL> show parameter spfile

 

NAME                                 TYPE        VALUE

----------------------------------------------- ------------------------------

spfile                               string

SQL>

 

 

当前启动是利用pfile启动的，刚刚我们对$ORACLE_HOME/dbs的检索也没有看到spfile文件。Oracle启动过程中，是默认先根据环境变量“拼凑”的路径查找spfile，之后才是pfile。系统spfile参数为空，说明当前使用的是pfile。

 

但是，对应到Oracle Restart里面的启动信息，似乎有些差别。

 

 

[grid@SimpleLinux ~]$ srvctl configdatabase -d ora11g

Database unique name: ora11g

Database name: ora11g

Oracle home:/u01/app/oracle/product/11.2.0/db_1

Oracle user: oracle

Spfile:+DATA/ora11g/spfileora11g.ora

Domain:

Start options: open

Stop options: immediate

Database role: PRIMARY

Management policy: AUTOMATIC

Database instance: ora11g

Disk Groups: DATA,RECO

Services:

 

 

明显出现不同。这个时候，笔者想起之前进行过实验，在ASM环境下进行spfile和pfile的生成操作。怀疑是这个过程中，存在Restart和实例信息的不匹配。

 

想出了第二种修复策略。

 

 

SQL> create spfile from pfile;

 

File created.

 

SQL> startup force

ORACLE instance started.

 

Total System Global Area  263639040 bytes

Fixed Size                  1344312 bytes

Variable Size             134221000 bytes

Database Buffers          125829120 bytes

Redo Buffers                2244608 bytes

Database mounted.

Database opened.

SQL> show parameter spfile

 

NAME                                 TYPE        VALUE

----------------------------------------------- ------------------------------

spfile                               string      /u01/app/oracle/product/11.2.0

                                                /db_1/dbs/spfileora11g.ora

 

 

设置恢复现有的spfile作为启动参数文件。试图让Restart和实例信息一致。

 

 

[oracle@SimpleLinux ~]$ srvctl modifydatabase -d ora11g-p /u01/app/oracle/product/11.2.0/db_1/dbs/spfileora11g.ora

[oracle@SimpleLinux ~]$ srvctl configdatabase -d ora11g

Database unique name: ora11g

Database name: ora11g

Oracle home:/u01/app/oracle/product/11.2.0/db_1

Oracle user: oracle

Spfile: /u01/app/oracle/product/11.2.0/db_1/dbs/spfileora11g.ora

Domain:

Start options: open

Stop options: immediate

Database role: PRIMARY

Management policy: AUTOMATIC

Database instance: ora11g

Disk Groups: DATA,RECO

Services:

 

 

实验启动，故障依然。

 

 

[oracle@SimpleLinux tmp]$ srvctl startdatabase -d ora11g

PRCR-1079 : Failed to start resourceora.ora11g.db

CRS-5010: Update of configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora"failed: details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

CRS-5017: The resource action"ora.ora11g.db start" encountered the following error:

CRS-5010: Update of configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

. For details refer to"(:CLSN00107:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log".

 

CRS-2674: Start of 'ora.ora11g.db' on'simplelinux' failed

 

 

第二次修复尝试以失败告终，Oracle Restart依然寻找那个pfile。但是笔者获得了方向，就是系统问题在于Restart中对数据库启动参数文件的不一致。

 

4、问题解决

 

Oracle Restart是一个很复杂的体系，在没有经验和资料的情况下，笔者也不能证明说是Oracle Bug之类的。

 

一种思路可以进行尝试。对于Oracle Restart，各种组件都是在上面可插拔的。根据需要，我们可以进行动态的配置注册过程。从之前的情况看，数据库本身是没有问题的，应该就是配置过程中的故障。那么，modify配置是有问题的。可不可以将database ora11g剔除出Restart体系，之后再添加过来。

 

Srvctl的add和remove命令可以帮助我们实现功能。而且在add过程中，只有-o参数是强制的，输入ORACLE_HOME目录。

 

 

[oracle@SimpleLinux dbs]$ srvctl removedatabase -d ora11g

Remove the database ora11g? (y/[n]) y

[oracle@SimpleLinux dbs]$ srvctl add database -d ora11g -o/u01/app/oracle/product/11.2.0/db_1

[oracle@SimpleLinux dbs]$ srvctl configdatabase -d ora11g

Database unique name: ora11g

Database name:

Oracle home: /u01/app/oracle/product/11.2.0/db_1

Oracle user: oracle

Spfile:

Domain:

Start options: open

Stop options: immediate

Database role: PRIMARY

Management policy: AUTOMATIC

Database instance: ora11g

Disk Groups:

Services:

 

 

Spfile为空。试着重新启动。

 

 

[oracle@SimpleLinux dbs]$ srvctl start database -d ora11g

[oracle@SimpleLinux dbs]$ ps -ef | greppmon

grid     3215     1  0 14:47 ?        00:00:00 asm_pmon_+ASM

oracle    5265    1  0 15:22 ?        00:00:00 ora_pmon_ora11g

oracle   5386  3578  0 15:22 pts/0    00:00:00 grep pmon

[oracle@SimpleLinux dbs]$ srvctl configdatabase -d ora11g

Database unique name: ora11g

Database name:

Oracle home:/u01/app/oracle/product/11.2.0/db_1

Oracle user: oracle

Spfile:

Domain:

Start options: open

Stop options: immediate

Database role: PRIMARY

Management policy: AUTOMATIC

Database instance: ora11g

Disk Groups: DATA,RECO

Services:

 

 

启动成功！最后尝试看看reboot系统时，能否自动启动。

 

 

--重新启动系统

[root@SimpleLinux simplelinux]# ps -ef | grep pmon

grid      3213     1  015:27 ?        00:00:00 asm_pmon_+ASM

oracle    3270     1  015:27 ?        00:00:00 ora_pmon_ora11g

root      3336  3042  015:27 pts/0    00:00:00 grep pmon

 

 

[grid@SimpleLinux ~]$ lsnrctl status

LSNRCTL for Linux: Version 11.2.0.3.0 - Production on 17-OCT-2013 15:32:07

 

Copyright (c) 1991, 2011, Oracle. All rights reserved.

 

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1521)))

STATUS of the LISTENER

------------------------

Alias                     LISTENER

Version                   TNSLSNRfor Linux: Version 11.2.0.3.0 - Production

Start Date               17-OCT-2013 15:27:06

Uptime                    0 days 0hr. 5 min. 0 sec

Trace Level               off

Security                  ON: LocalOS Authentication

SNMP                      OFF

Listener Parameter File  /u01/app/grid/product/11.2.0/grid/network/admin/listener.ora

Listener Log File        /u01/app/grid/diag/tnslsnr/SimpleLinux/listener/alert/log.xml

Listening Endpoints Summary...

 (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))

  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=SimpleLinux.localdomain)(PORT=1521)))

Services Summary...

Service "+ASM" has 1 instance(s).

  Instance "+ASM", statusREADY, has 1 handler(s) for this service...

Service "ora11g" has 1 instance(s).

  Instance"ora11g", status READY, has 1 handler(s) for this service...

Service "ora11gXDB" has 1 instance(s).

  Instance "ora11g",status READY, has 1 handler(s) for this service...

The command completed successfully

 

SQL> show parameter spfile

 

NAME                                 TYPE        VALUE

------------------------------------ -----------------------------------------

spfile                              string     /u01/app/oracle/product/11.2.0/db_1/dbs/spfileora11g.ora

 

 

问题解决。

 

5、结论和反思

 

从直观的感觉看，这应该是Restart和原有命令协调的一个故障。原有create pfile之后，Restart似乎不能够支持pfile的启动了。另外，在修复过程中，我们始终看到不能对spfile修改参数生效，也是一个疑惑点。

 

能够肯定的是，在添加数据库ora11g的时候，没有明确指定启动spfile的位置，那么应该是进入了自动检索目录spfile-pfile的过程。所以系统得到修复。