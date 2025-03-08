#####数据库并行进程异常
##问题描述
突发主机出现ora_p进程突然增多，导致process满，导致sqlplus无法登录

ERROR:
ORA-00020: maximum number of processes (2000) exceeded

##查看进程：
--外来连接：
ps -ef|grep LOCAL=NO|grep -v grep|wc -l 

--本地连接
ps -ef|grep ora|grep -v grep|wc -l 
2026
ps -ef|grep ora_p|grep -v grep|wc -l 
PS：ora_p148_sngsnfdb1

##排查日志
Fri Mar 20 15:14:12 2020
ORA-00020: maximum number of processes (2000) exceeded
 ORA-20 errors will not be written to the alert log for
 the next minute. Please look at trace files to see all
 the ORA-20 errors.
Process PA47 submission failed with error = 20  

##为什么ora进程会这么多，原因在于ora_p这种并发进程有2000多个。
基本定位问题，是由于sql采用了并行导致的

>>>解决方法：
1、由于sqlplus已经登录不上了，所以要杀掉进程，先登录进去看看
由于是并行导致，非连接数过大，所以可以不用关闭监听。
为了防止杀掉数据库自身进程（ora_pmon等），需要筛选杀掉进程，
ps -ef|grep ora_p1|grep -v grep|awk '{print $2}'|xargs kill -9

2、待process降下来后，登录sqlplus，找到问题SQL
   INST_ID USERNAME        OSUSER          MACHINE                        MODULE                              SQL_ID                 CNT
---------- --------------- --------------- ------------------------------ ----------------------------------- --------------- ----------
         1 NF_NFZC         Administrator   WorkGroup\ECW42E3712K11RR      PL/SQL Developer                    9y8pxh9ax0nyz          687
         
3、查看执行计划后，确定是并行导致
4、若果想马上想恢复正常，那就杀掉这个sql的会话
SELECT a."INST_ID",a."SQL_ID",'kill -9 '||b."SPID" pid_kill,'alter system kill session ''' || A.SID || ',' || A.SERIAL# ||''';' sid_kill  FROM  gv$session a,gv$process b WHERE a."PADDR"=b."ADDR" AND a.sql_id='&SQL_ID';
5、跟踪源头原因，查看监听日志，定位源头
由于是并行，所以在连接上看，只有一条或两条，可以按时间，也可以按主机名，定位主机IP
vim /u01/app/grid/diag/tnslsnr/dzswjnfdb1/listener/alert/log.xml
搜索：ECW42E3712K11RR

 <txt>20-MAR-2020 15:11:12 * (CONNECT_DATA=(SERVICE_NAME=sngsnfdb)(CID=(PROGRAM=C:\Program?Files??x86?\PLSQL?Developer\plsqldev.exe)(HOST=ECW42E3712K11RR)
(USER=Administrator))) * (ADDRESS=(PROTOCOL=tcp)(HOST=10.10.85.178)(PORT=63350)) * establish * sngsnfdb * 0
 </txt>
</msg>
<msg time='2020-03-20T15:11:12.174+08:00' org_id='oracle' comp_id='tnslsnr'
 type='UNKNOWN' level='16' host_id='cztestdb1'
 host_addr='10.10.79.13'>
 <txt>20-MAR-2020 15:11:12 * (CONNECT_DATA=(SERVICE_NAME=sngsnfdb)(CID=(PROGRAM=C:\Program?Files??x86?\PLSQL?Developer\plsqldev.exe)(HOST=ECW42E3712K11RR)
(USER=Administrator))) * (ADDRESS=(PROTOCOL=tcp)(HOST=10.10.85.178)(PORT=63351)) * establish * sngsnfdb * 0

