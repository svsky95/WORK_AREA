WARNING: ASM communication error: op 18 state 0x40 (1017)
ERROR: slave communication error with ASM
NOTE: Deferred communication with ASM instance
Errors in file /u01/app/oracle/diag/rdbms/sngsnfdb/sngsnfdb2/trace/sngsnfdb2_pmon_740.trc:
ORA-01017: invalid username/password; logon denied


vim /etc/group 
dba::101:grid,oracle
asmdba::102:grid,oracle
asmadmin::103:grid
zabbix::1221:
oracle::1222:

