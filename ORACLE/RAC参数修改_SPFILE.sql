##oracle_RAC�����޸�
1��oracle�Ĳ����ļ�������+ASM�С�
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORA_DATA/crsdb/spfilecrsdb.ora

2���ڵ�һ���ݲ����ļ�
SQL> create pfile='/tmp/spfile_bak.ora' from spfile;

3������ļ�
[oracle@racnode01 db_1]$ ll /tmp/sfile_bak.ora 
-rw-r--r-- 1 oracle asmadmin 1569 Sep  6 14:43 /tmp/sfile_bak.ora

3���ڵ�һ�޸Ĳ���
SQL> ALTER SYSTEM SET processes =500 scope=spfile sid='*';  

4�������ڵ�һ�����������Ƿ�����޸���Ч
SQL> shutdown immediate
SQL> startup 

-�鿴�޸ĵĲ����Ƿ�ɹ�
SQL> show parameter processes
processes                            integer     500

5����֤�ڵ�һ������ȷ������£������ڵ��

6���鿴�����ڵ�Ĳ����ļ����Ƿ�ָ����洢�Ĳ����ļ�
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORA_DATA/crsdb/spfilecrsdb.ora

PS�����������ű�
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


###oracle��������
#�������޸�ʧ��ʱ��oracle���ݿ�϶��������������ģ���ʱ�ȹرսڵ�һ�ڵ�����ݿ�
1���ڵ�һ
SQL> shutdown immediate

2���ӱ����лָ���Ҳ����ֱ���޸�/tmp/spfile_bak.ora�ļ����Ѳ�������ȷ��Ȼ��������
create spfile='+DATA/racdb/spfileracdb.ora' from pfile='/tmp/spfile_bak.ora';
3���������ݿ�
SQL> startup
4��ȷ����ȷ���������нڵ�

##ָ�������ļ����� ---ֻ��ָ����̬�����ļ�
startup pfile='xxxxx'
startup pfile='/u01/app/oracle/product/11.2.0/db_1/dbs/initsxfxdb.ora_bak';













============================һ�����ݹ��ο�========================================



--RAC�����޸�SPFILE
1��Ϊ���Է���һ���Ȱѹ���洢�е�spfile��λ�ü�¼������
SQL> show parameter spfile

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      +ORACL_DATA/crsdb/spfilecrsdb.
                                                 ora
2������pfile�ļ����Ա��޸ģ�����ԭ�е�·������init<SID>.ora�ļ��ᱻ���ǣ����Ա���ԭ�е��ļ���
mv initcrsdb1.ora initcrsdb1.ora_bak
create pfile from spfile;
create pfile='/tmp/ffile.ora' from spfile='+DATA/rac12/spfilerac12.ora';

3�������ַ��������޸ġ�
һ��ֱ���޸�pfile�ļ���Ȼ���pfile�ļ���������֤�����޸��Ƿ�ɹ���
����������ǰʵ����spfile�ļ���
create spfile from pfile;
-rw-r--r--. 1 oracle asmadmin 1557 Feb 22 15:44 initcrsdb1.ora
-rw-r-----. 1 oracle asmadmin 4608 Feb 22 15:47 spfilecrsdb1.ora

4��������ǰʵ�������Զ���spfile�ļ�����
shutdown immediate
startup 
SQL> show parameter spfile;

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
spfile                               string      /u01/app/oracle/product/11.2.0
                                                 /db_1/dbs/spfilecrsdb1.ora
5���޸���ز���
alter system set sga_max_size=5120M scope=spfile;
6����������֤�����Ƿ��޸ĳɹ�
7�����޸ĺõ�spfile����pfile
SQL> create pfile from spfile;
8���鿴pfile�ļ��еĲ����Ƿ��Ѿ���Ч��Ȼ��ɾ����ǰʵ����spfilecrsdb1.ora������ʵ����ʹ��spfilecrsdb1.ora�ļ�������
��initcrsdb1.ora�е����һ����� SPFILE='+ORACL_DATA/crsdb/spfilecrsdb.ora'              # line added by Agent 
9���ر����нڵ�����ݿ⣬��pfile�ļ����뵽����洢�У������нڵ�ʹ�á�
create spfile='+ORACL_DATA/crsdb/spfilecrsdb.ora' from pfile;
10���������еĽڵ㣬��֤�����Ƿ��Ѿ���Ч��



ǳ��RAC��SPFILE�ļ��޸�֮������ƪ����

��һƪ��RAC��SPFILE�ļ��޸�

��RAC��spfileλ�õ��޸��뵥�ڵ㻷������ȫһ�£���Щ�ط���Ҫ�ر�ע�⣬��������޸Ļ�ʧ�ܡ�

 

������һ������˵����SPFILE����ASM��һ������ȷ��Ŀ¼(+ARCH)�У������������������һ��Ŀ¼(+DBSYS)�¡�

 

�����Ǿ��岽�裺

 

1. ԭspfileλ��

SQL> show parameter spfile

 

NAME TYPE VALUE

----------------------------------------------- ------------------------------

spfile string +ARCH/dwrac/spfiledwrac.ora

 

2. ����spfile������Ŀ¼

 

������ASM�У�����ֱ��cp����Ҫͨ���ػصİ취ʵ�֡�

 

sys@dwrac2> create pfile='/tmp/pfile.ora' from spfile;

 

File created.

 

sys@dwrac2> create spfile='+DBSYS/dwrac/spfiledwrac.ora' from pfile='/tmp/pfile.ora';

 

File created.

 

3. �޸����нڵ�$ORACLE_HOME/dbs/init�µĲ����ļ�

[oracle@dwdb04 dbs]$ vi initdwrac2.ora

 

SPFILE='+ARCH/dwrac/spfiledwrac.ora'

==>

SPFILE='+DBSYS/dwrac/spfiledwrac.ora'

 

 

4. ͨ��sqlplus��ʽ����ʵ��

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

 

���Է��֣�spfile�Ѿ��޸ĳɹ���

 

5. ��������ù�srvctl�������ݿ⣬����spfile�ֱ�����ˣ�

 

[oracle@dwdb02 dbs]$ srvctl stop instance-d dwrac -i dwrac1,dwrac2,dwrac3,dwrac4

 

[oracle@dwdb02 dbs]$ srvctl start instance-d dwrac -i dwrac1,dwrac2,dwrac3,dwrac4

 

[oracle@dwdb02 dbs]$ sqlplus "/assysdba"

 

sys@dwrac2> show parameter spfile

 

NAME TYPE VALUE

----------------------------------------------- ------------------------------

spfile string +ARCH/dwrac/spfiledwrac.ora

 

6. ԭ�򼰽��

 

����Ϊʲô�أ�ʵ������RAC�����У����Ǹ���ʱ������srvctl������RAC��Դ����srvctl����Ϣ����ocr������spfile��λ����Ϣ�����Ǹղ���������Ȼ�޸��˲����ļ���λ�ã�����ocr����֪����������ԭ�����ļ��������ݿ⡣

���ǿ�����srvctl�鿴���ݿ��������Ϣ��ȷ�ϣ�

 

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

 

���Կ�����SPFILE��λ��ָ����+ARCH�����������ͨ��srvctl�޸�SPFILE��λ�á�

 

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

 

���Կ�������ʱOracle�����µ�spfile�����ġ�

 

7.�ܽ�

��RAC�������޸�spfile��

 

1. ��Ҫ�޸�$ORACLE_HOME/dbs�µ�����ļ���ָ�����ļ�

2. ��Ҫ��srvctl�޸�config��Ϣ��ָ�����ļ�

 

�ڶ�ƪ��Oracle ASM�洢Spfile����

����������̳��

��֮ǰ�����¡�Oracle Restart�������ݿ�ʵ������һ������http://space.itpub.net/17203031/viewspace-774622���У����߽����һ������ʹ��create pfilefrom spfile�����Restart�޷��������ݿ�ʵ���Ĺ��ϡ�

 

�ϸ��˵�����߲�û����ȫ����������Ҫ������Spfile��ʹ�úʹ���ϡ�

 

1���������

 

Oracle Database��װ��ASM�洢��ʱ��Ĭ�϶���ʹ��ASM����Spfile�����ļ��������ڵ�pfile�ļ���ͬ��Spfile�Ǿ��ж����Ƹ�ʽ���ܹ�֧�ֲ��ֲ����Ķ�̬������

 

���ԣ����ǳ��������ʱ�򣬷���Restart��������Ϣ�а�����ASM�е�Spfile�������ݡ�

 

 

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

 

 

����֮ǰ���޸����������ǽ�spfile�����ÿգ������ݿ�ʵ������ʹ��Ĭ��·��$ORACLE_HOME/dbs��spfile��pfile�������м�����

 

 

SQL> show parameter spfile

 

NAME                                TYPE        VALUE

------------------------------------ -----------------------------------------

spfile                              string     /u01/app/oracle/product/11.2.0

                                                /db_1/dbs/spfileora11g.ora

 

 

���Ǵ�ʱ��������ASM·�����Ǵ���spfile�ϵġ�

 

 

ASMCMD> pwd       

+DATA/ORA11G

 

ASMCMD> ls

CONTROLFILE/

DATAFILE/

ONLINELOG/

PARAMETERFILE/

TEMPFILE/

spfileora11g.ora

 

 

����������£����������ASMĿ¼��spfile������־������Restart�ᱨ��

 

 

[oracle@SimpleLinux ~]$ srvctl modify database -d ora11g-p +DATA/ora11g/spfileora11g.ora

[oracle@SimpleLinux ~]$ srvctl start database -d ora11g

PRCR-1079 : Failed to start resource ora.ora11g.db

CRS-5010: Update of configuration file "/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora"failed: details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

CRS-5017: The resource action "ora.ora11g.db start" encounteredthe following error:

CRS-5010: Update of configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in "/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

. For details refer to "(:CLSN00107:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log".

 

CRS-2674: Start of 'ora.ora11g.db' on 'simplelinux' failed

 

 

2��������˼��

 

һ���侲����~

 

Pfile��spfile�ǲ����ļ������������׶Ρ���umount�׶Σ�Oracle��ͨ������$ORACLE_HOME��$ORACLE_SID����Ŀ¼��λ����λ��$ORACLE_HOME/dbs����$ORACLE_HOME/database��������Ѱ���ƶ�����Ĳ����ļ���

 

Oracle���Ȼ�ȥѰ��Spfile��֮��Ż�ȥ��Pfile������ͨ��create spfile��create pfile����ʵ�����ߵ�ת����

 

һ���Ƚϳ��������ⰸ���ǣ�������ǰ����������Ĵ��ˣ����������ˣ���ô��ô�죿��׼��������ͨ��create pfilefrom spfile���õ�һ���ı���ʽ�Ĳ���pfile���������޸�����������������������ʱ��ʹ��startuppfile=xxxʹ�á�ָ����pfile���������ݿ�ʵ������ͨ��create spfile from pfile���仯�̻�������

 

Oracle Restart�ṩ�����ò���spfile��ʵ�Ǻܹ���ġ���ֱ���Ͽ�����������startup���ݿ�ʵ������������Լ�ȥָ�������ļ���������startupspfile=xxx�����á�����ʵ���ϣ�startup�ǲ�֧��spfile�����Ĳ����ġ�

 

����������������ָ������ô��Restart������ʱ�������Ѿ�������ȡ��spfileλ�ã�ָ��λ������Ҳ���ļ������Ǹ���û��Ч����Oracle����Ѱ�Ҳ����ļ���

 

��ô����ֻ��һ�ֿ����ԣ���ʹOracleʹ��Restart������Ҳ��������ָ����spfile�����ǰ���ԭ�еĹ������С�

 

��������һ�ַ�����˵�������������Ҫָ��һ��spfile�����ļ���ʱ��Ӧ����ô�������ǽ���һ���յ�pfile�ļ�������ֱ��ָ��SPFILE�������ļ�λ�á�

 

�ۺϼ���˼·�����ǿ������뵽Spfile������ASM���棬ͬʱ��Restart��sqlplus����ʱ����Է��ʵ�ASMSpfile�ķ�����

 

3������ASM��SPFILE����

 

�����Ǵ�����ASM�ϵ�spfile��ע�⣺����spfile��ʱ��һ���Ǵ�pfile������������Ҫת��һ�¡�

 

 

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

 

 

��ʱ��������ASM������Կ������ɵ�spfile�������ļ���

 

 

ASMCMD> ls -l

Type           Redund  Striped Time             Sys  Name

                                                Y    CONTROLFILE/

                                                Y    DATAFILE/

                                                Y    ONLINELOG/

                                                Y    PARAMETERFILE/

                                                Y    TEMPFILE/

                                                N   spfileora11g.ora => +DATA/ORA11G/PARAMETERFILE/spfile.267.829130539

 

 

�ڶ����Ǵ���ά��һ����ת���������ļ���

 

 

 

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

 

 

������Ҫ����������飬һ���ǽ�dbsĿ¼�����spfileɾ������Ϊ����Oracle������ԭ��������spfile��֮������pfile���ڶ������޸��ı������ļ�����Ϊת����

 

 

[oracle@SimpleLinux dbs]$ mv spfileora11g.ora spfileora11g.ora.bk

 

[oracle@SimpleLinux dbs]$ cat initora11g.ora

SPFILE='+DATA/ora11g/spfileora11g.ora�� �Cע�⣺���ܰ���*ǰ׺����SIDǰ׺

 

[oracle@SimpleLinux dbs]$ ls -l

total 28

-rw-rw---- 1 oracle asmadmin 1544 Sep 12 12:58 hc_ora11g.dat

-rw-r--r-- 1 oracle oinstall 2851 May 15 2009 init.ora

-rwxr-x--- 1 oracle oinstall   41Oct 18 10:07 initora11g.ora

-rwxrwx--- 1 oracle oinstall  887Sep 29 09:31 initora11g.ora.bk

-rw-r----- 1 oracle asmadmin   24Sep 12 12:58 lkORA11G

-rw-r----- 1 oracle oinstall 1536 Sep 12 13:11 orapwora11g

-rw-r----- 1 oracle asmadmin 2560 Oct 18 09:57 spfileora11g.ora.bk

 

 

ʹ��srvctl�رպ��������ݿ⡣

 

 

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

 

 

���ݿ��У�spfile����������ΪASM·����

 

 

SQL> show parameter spfile;

 

NAME                                 TYPE        VALUE

------------------------------------ -----------------------------------------

spfile                              string     +DATA/ora11g/spfileora11g.ora

 

 

���ϳ��׽����

 

4������

 

�ۺ������ʵ�飬���ǿ��Կ���ASM��Spfileʹ�õķ�����ASM�µ�Spfile����������ԭ�е��������򣬶��ǽ���ԭ�е�pfile������Ŀ��ת�ӡ�֮����߲鿴MOS�еĶ�Ӧ�������ٷ��Ƽ���Ҳ��������������

 

��������Ҫһ��ǰ�ᣬ����dbs����databaseĿ¼�в��ܰ���spfile����������ˣ�Oracle���õ�ת�ӻ��ƾͱ��滻���ˡ�

 

��һ������������һֱ�����Ĵ�����ʾ��Ϣ����ʾ�����ļ�initora11g.ora��ʽ����ʶ�𡣱��ߵ�����ǣ�ԭʼ���ļ��Ǳ���ʹ��create pfilefrom spfile���������ģ�Ĭ�ϵ�SPFILE=XXX�����ݱ����ǡ���Oracle Restart����ʶ�����ַ�ת�������ļ������Ա���

����ƪ��Oracle Restart�������ݿ�ʵ������һ��

��������

Oracle Restart��11gR2���Ƴ�����Ҫ�߿��ã�HighAvailability�����ԡ���Single Instance����£�Clusterware�γ�һ��������ά����ܣ�Oracle��������������ά���������Ͻ��й���

 

Oracle Restart��ְ���ϸ���������Ĺ��ܣ�һ����Oracle��������������Զ���������������临�ӵ�������ϵ��ʹ��Restart�Զ��Ľ�������˳������ǱȽϺõ�һ�ֲ��ԡ���һ�������Ǹ߿���֧�֣����ĳһ��������ⱻ��ֹ���У������쳣�жϣ�Oracle Restart�ǿ��Զ��ڵļ�顰���¡���������������һ����������ͻ�����Զ���������

 

Ŀǰ��ʵ��Oracleʹ��Oracle Restart֧�ֵ���������У�������Listener��Oracleʵ�������ݿ⡢ASMʵ����ASM�����顢���ݿ����Service��ONS��OracleNotification Service����

 

��ƪ��¼����������һ�����ϳ������������ӣ�����ҵ��ţ�Ǵ���������ȡ�Ȩ��˼·��¼��������Ҫ�����Ѳ�ʱ֮�衣

 

1��������ϳ���

 

��һ̨11gR2��Oracle�ϣ����߲����˵�ʵ��ASMʵ���ʹ�����ṹ�����������沿����SingleInstance Oracle�������ǲ���ʹ�ã�������������й�һЩ���Ժ�ʵ�飬��������������֮�󣬷������⡣

 

 

grid@SimpleLinux simplelinux]$ uptime

 13:58:13 up 2:24, 1 user, load average: 0.03, 0.02, 0.00

[grid@SimpleLinux simplelinux]$ ps -ef |grep pmon

grid      3212    1  0 11:35 ?        00:00:01 asm_pmon_+ASM

grid    27724 27685  0 13:58 pts/0    00:00:00 grep pmon

 

 

���ݱ�׼��Oracle Restart���ã�ASMʵ����ASM����������ݿ�ʵ��������Restart����Χ��Ӧ�������ŷ������������Զ����������Ǵ�ʵ���������ASMʵ���Ѿ��Զ����������ݿ�ʵ��û��������

 

ͬRAC�ṹһ����RestartҲ�ǽ������������������У���ohasdΪ�׵ĸ߿����ػ����̽��в�������������

 

��������£��鿴��־��Ϣ����õ�ѡ�񣬿����Ǹ����ڳ������⡣

 

 

[grid@SimpleLinux simplelinux]$ pwd

/u01/app/grid/product/11.2.0/grid/log/simplelinux

[grid@SimpleLinux simplelinux]$ ls -l |grep alert

-rw-rw---- 1 grid oinstall 14494Oct 17 11:35 alertsimplelinux.log

 

 

��grid��clusterware����־�����Ǳ�����$ORACLE_HOME/log�µ�Ŀ¼���С�Alert<sid>.log������־��Ҳ�Ǽ�����ʼ�㡣ͨ�������淢�ֵ����⣬���н�һ���ķ���������

 

 

[ohasd(2744)]CRS-2767:Resource staterecovery not attempted for 'ora.diskmon' as its target state is OFFLINE

2013-10-17 11:35:34.373

[cssd(3130)]CRS-1601:CSSD Reconfigurationcomplete. Active nodes are simplelinux .

2013-10-17 11:35:50.094

[/u01/app/grid/product/11.2.0/grid/bin/oraagent.bin(3072)]CRS-5010:Updateof configuration file "/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora"failed: details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

2013-10-17 11:35:55.645

[/u01/app/grid/product/11.2.0/grid/bin/oraagent.bin(3072)]CRS-5010:Updateof configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

2013-10-17 11:35:55.806

[ohasd(2744)]CRS-2807:Resource'ora.ora11g.db' failed to start automatically.

 

 

���Ƕ�λ��������Ƭ�Σ�������������ݿ���Clusterware������dismon����֮����ͼ�������ݿ⣬Ҳ����ora.ora11g.db���ڷ���һ�������ļ���ע����pfile�������У��������⡣

 

��һ�����ָ����oraagent_grid.log��־��Ҳû�й������Ϣ��ʾ��

 

 

2013-10-17 11:35:50.049:[ora.ora11g.db][3013430160] {0:0:2} [start] sclsnInstAgent::sUpdateOratab fileupdated with dbName ora11g value /u01/app/oracle/product/11.2.0/db_1:N

2013-10-17 11:35:50.049:[ora.ora11g.db][3013430160] {0:0:2} [start] sclsnInstAgent::sUpdateOratab CSSunlock

2013-10-17 11:35:50.090:[ora.ora11g.db][3013430160] {0:0:2} [start] (:CLSN00014:)Failed to open file/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora

2013-10-17 11:35:50.091: [   AGENT][3013430160] {0:0:2}UserErrorException: Locale is

2013-10-17 11:35:50.091:[ora.ora11g.db][3013430160] {0:0:2} [start] clsnUtils::error Exception type=2string=

CRS-5010: Update of configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in "/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

 

 

����Ϣ�Ͽ����Ƕ�pfileû���ܹ��򿪡�

 

2��һ�β��ɹ��ĳ���

 

����־��Ϣ�ϣ������ǲ��ܹ����ı����������ļ��������²����ļ�Ȩ��ԭ��������м�顣

 

 

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

 

 

Ȩ��������oracle�û���д�����û�������Ȩ���Ͽ���grid��oracle��ȡ���޸ĵ����ⲻ���ر����ء����ǻ��ǽ��в��Գ��ԡ�

 

 

[oracle@SimpleLinux dbs]$ chmod 770initora11g.ora

[oracle@SimpleLinux dbs]$ ls -l

total 20

-rw-rw---- 1 oracle asmadmin 1544 Sep 1212:58 hc_ora11g.dat

-rw-r--r-- 1 oracle oinstall 2851 May15  2009 init.ora

-rwxrwx--- 1 oracle oinstall  887 Sep 29 09:31 initora11g.ora

-rw-r----- 1 oracle asmadmin   24 Sep 12 12:58 lkORA11G

-rw-r----- 1 oracle oinstall 1536 Sep 1213:11 orapwora11g

 

 

�����������ݿ⡣

 

 

[grid@SimpleLinux ~]$ srvctl start database-d ora11g

PRCR-1079 : Failed to startresource ora.ora11g.db

CRS-5010: Update of configurationfile "/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

CRS-5017: The resource action"ora.ora11g.db start" encountered the following error:

CRS-5010: Update of configurationfile "/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

. For details refer to"(:CLSN00107:)" in "/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log".

 

CRS-2674: Start of'ora.ora11g.db' on 'simplelinux' failed

 

 

����ʧ�ܡ���ô������ʹ�ô�ͳsqlplus�����з�ʽ�����Ƿ���У�

 

 

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

 

 

�����ɹ���ʹ��sqlplus�����п�������������Oracle Restart�����ͻ�ʧ�ܡ���ô�������Ķ���

 

3��Spfile vs. Pfile

 

��ֱ���Ͽ���Oracle Restart������ʱ����ϣ�����ʵ������ļ�pfile����ֱ�۵ĸо��ϣ���������ܳ�ʱ���pfileΪʲô�ᱻ�ἰ�������Ѿ����������ݿ�ʵ������һ�µ�ǰʹ�õ���ʲô�����ļ���

 

 

SQL> show parameter spfile

 

NAME                                 TYPE        VALUE

----------------------------------------------- ------------------------------

spfile                               string

SQL>

 

 

��ǰ����������pfile�����ģ��ո����Ƕ�$ORACLE_HOME/dbs�ļ���Ҳû�п���spfile�ļ���Oracle���������У���Ĭ���ȸ��ݻ���������ƴ�ա���·������spfile��֮�����pfile��ϵͳspfile����Ϊ�գ�˵����ǰʹ�õ���pfile��

 

���ǣ���Ӧ��Oracle Restart�����������Ϣ���ƺ���Щ���

 

 

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

 

 

���Գ��ֲ�ͬ�����ʱ�򣬱�������֮ǰ���й�ʵ�飬��ASM�����½���spfile��pfile�����ɲ�������������������У�����Restart��ʵ����Ϣ�Ĳ�ƥ�䡣

 

����˵ڶ����޸����ԡ�

 

 

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

 

 

���ûָ����е�spfile��Ϊ���������ļ�����ͼ��Restart��ʵ����Ϣһ�¡�

 

 

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

 

 

ʵ��������������Ȼ��

 

 

[oracle@SimpleLinux tmp]$ srvctl startdatabase -d ora11g

PRCR-1079 : Failed to start resourceora.ora11g.db

CRS-5010: Update of configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora"failed: details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

CRS-5017: The resource action"ora.ora11g.db start" encountered the following error:

CRS-5010: Update of configuration file"/u01/app/oracle/product/11.2.0/db_1/dbs/initora11g.ora" failed:details at "(:CLSN00014:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log"

. For details refer to"(:CLSN00107:)" in"/u01/app/grid/product/11.2.0/grid/log/simplelinux/agent/ohasd/oraagent_grid/oraagent_grid.log".

 

CRS-2674: Start of 'ora.ora11g.db' on'simplelinux' failed

 

 

�ڶ����޸�������ʧ�ܸ��գ�Oracle Restart��ȻѰ���Ǹ�pfile�����Ǳ��߻���˷��򣬾���ϵͳ��������Restart�ж����ݿ����������ļ��Ĳ�һ�¡�

 

4��������

 

Oracle Restart��һ���ܸ��ӵ���ϵ����û�о�������ϵ�����£�����Ҳ����֤��˵��Oracle Bug֮��ġ�

 

һ��˼·���Խ��г��ԡ�����Oracle Restart�������������������ɲ�εġ�������Ҫ�����ǿ��Խ��ж�̬������ע����̡���֮ǰ������������ݿⱾ����û������ģ�Ӧ�þ������ù����еĹ��ϡ���ô��modify������������ġ��ɲ����Խ�database ora11g�޳���Restart��ϵ��֮������ӹ�����

 

Srvctl��add��remove������԰�������ʵ�ֹ��ܡ�������add�����У�ֻ��-o������ǿ�Ƶģ�����ORACLE_HOMEĿ¼��

 

 

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

 

 

SpfileΪ�ա���������������

 

 

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

 

 

�����ɹ�������Կ���rebootϵͳʱ���ܷ��Զ�������

 

 

--��������ϵͳ

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

 

 

��������

 

5�����ۺͷ�˼

 

��ֱ�۵ĸо�������Ӧ����Restart��ԭ������Э����һ�����ϡ�ԭ��create pfile֮��Restart�ƺ����ܹ�֧��pfile�������ˡ����⣬���޸������У�����ʼ�տ������ܶ�spfile�޸Ĳ�����Ч��Ҳ��һ���ɻ�㡣

 

�ܹ��϶����ǣ���������ݿ�ora11g��ʱ��û����ȷָ������spfile��λ�ã���ôӦ���ǽ������Զ�����Ŀ¼spfile-pfile�Ĺ��̡�����ϵͳ�õ��޸���