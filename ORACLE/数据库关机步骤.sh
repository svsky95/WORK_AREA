##���ݿ������ػ�����
1���ر�OGG
stop *
stop mgr 

2��ͣ���������򣬷�ֹ�µ����ӽ���
su - grid
lsnrctl stop 
lsnrctl status 

3��ɱ�����ݿ�Ự
su - oracle

SELECT 'alter system kill session  ''' || T.SID || ',' || t."SERIAL#" ||''';' kill_command  FROM GV$SESSION T WHERE T.SQL_ID IN (SELECT t."SQL_ID" FROM gv$session t WHERE t."STATUS"='ACTIVE');

4��ɱ����������
--linux 
ps -ef | grep LOCAL=NO | awk -F " " '{ print "kill -9 "$2 }'|sh
--solars
ps -ef|grep LOCAL=NO|grep -v grep|awk '{print $2}'|xargs kill -9

5���ص����ݿ�
su - oracle
sqlplus / as sysdba
shutdown immediate

6���ر�crs 
su - root
/u01/app/11.2.0/grid/bin
crsctl stop crs 

##���ݿ�������������
1��Ĭ������������crs���Լ�����������־�۲����
tail -f /u01/app/11.2.0/grid/log/racnode01/alertracnode01.log

2�����ݿⲻ���Լ���������Ҫ�ֶ�����
su - oracle
sqlplus / as sysdba
startup

3��ȷ����Ⱥ״̬
crsctl stat res -t

4������OGG
start mgr 
start *