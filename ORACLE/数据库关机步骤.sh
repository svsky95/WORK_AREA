##数据库主机关机步骤
1、关闭OGG
stop *
stop mgr 

2、停掉监听程序，防止新的连接进入
su - grid
lsnrctl stop 
lsnrctl status 

3、杀掉数据库会话
su - oracle

SELECT 'alter system kill session  ''' || T.SID || ',' || t."SERIAL#" ||''';' kill_command  FROM GV$SESSION T WHERE T.SQL_ID IN (SELECT t."SQL_ID" FROM gv$session t WHERE t."STATUS"='ACTIVE');

4、杀掉主机进程
--linux 
ps -ef | grep LOCAL=NO | awk -F " " '{ print "kill -9 "$2 }'|sh
--solars
ps -ef|grep LOCAL=NO|grep -v grep|awk '{print $2}'|xargs kill -9

5、关掉数据库
su - oracle
sqlplus / as sysdba
shutdown immediate

6、关闭crs 
su - root
/u01/app/11.2.0/grid/bin
crsctl stop crs 

##数据库主机开机步骤
1、默认主机启动后，crs会自己启动，看日志观察过程
tail -f /u01/app/11.2.0/grid/log/racnode01/alertracnode01.log

2、数据库不会自己启动，需要手动启动
su - oracle
sqlplus / as sysdba
startup

3、确定集群状态
crsctl stat res -t

4、启动OGG
start mgr 
start *