--数据库自动启动
vim db_autostart.sh
#!/bin/bash
su - oracle <<EOF
source /home/oracle/.bash_profile
sqlplus / as sysdba 
startup
exit;


$ORACLE_HOME/bin/lsnrctl stop
sleep 10
$ORACLE_HOME/bin/lsnrctl start 
EOF

chmod a+x db_autostart.sh

--vim /etc/rc.local

exec 1>/tmp/rc.local.log 2>&1
set -x 
touch /var/lock/subsys/local
source /root/.bash_profile
source /etc/profile
sh /root/db_autostart.sh



--96双实例
#!/bin/bash
su - oracle <<EOF
source /home/oracle/.bash_profile
#sqlplus / as sysdba 
#startup
#exit;


/u01/app/oracle/product/11.2.0/dbhome_1/bin/lsnrctl stop LISTENER_2
sleep 10
/u01/app/oracle/product/11.2.0/dbhome_1/bin/lsnrctl start LISTENER_2 

export ORACLE_SID=nfzcdb
sqlplus / as sysdba 
startup
exit;

/u01/app/oracle/product/11.2.0/dbhome_1/bin/lsnrctl stop LISTENER_1
sleep 10
/u01/app/oracle/product/11.2.0/dbhome_1/bin/lsnrctl start LISTENER_1

EOF


--实际脚本--
vim db_autostart.sh

#!/bin/bash
su - oracle <<EOF
source /home/oracle/.bash_profile
sqlplus / as sysdba
startup
exit;
EOF

su - oracle <<EOF
source /home/oracle/.bash_profile
export ORACLE_SID=nfzcdb
sqlplus / as sysdba
startup
exit;
EOF

su - oracle <<EOF
source /home/oracle/.bash_profile

/u01/app/oracle/product/11.2.0/dbhome_1/bin/lsnrctl stop LISTENER_2
sleep 10
/u01/app/oracle/product/11.2.0/dbhome_1/bin/lsnrctl start LISTENER_2
exit;
EOF

su - oracle <<EOF
source /home/oracle/.bash_profile
/u01/app/oracle/product/11.2.0/dbhome_1/bin/lsnrctl stop LISTENER_1
sleep 10
/u01/app/oracle/product/11.2.0/dbhome_1/bin/lsnrctl start LISTENER_1
exit;
EOF

--vim /etc/rc.local
source /root/.bash_profile
source /etc/profile
sh /root/db_autostart.sh

