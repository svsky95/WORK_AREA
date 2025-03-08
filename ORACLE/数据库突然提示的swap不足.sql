数据库报错日志：
Process startup failed, error stack:
Errors in file /u01/app/oracle/diag/rdbms/bigdata/bigdata/trace/bigdata_psp0_4926.trc:
ORA-27300: OS system dependent operation:fork failed with status: 12
ORA-27301: OS failure message: Cannot allocate memory
ORA-27302: failure occurred at: skgpspawn3
Process W000 died, see its trace file

解决方式：
扩大swap