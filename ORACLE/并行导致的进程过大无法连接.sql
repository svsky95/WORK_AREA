#####���ݿⲢ�н����쳣
##��������
ͻ����������ora_p����ͻȻ���࣬����process��������sqlplus�޷���¼

ERROR:
ORA-00020: maximum number of processes (2000) exceeded

##�鿴���̣�
--�������ӣ�
ps -ef|grep LOCAL=NO|grep -v grep|wc -l 

--��������
ps -ef|grep ora|grep -v grep|wc -l 
2026
ps -ef|grep ora_p|grep -v grep|wc -l 
PS��ora_p148_sngsnfdb1

##�Ų���־
Fri Mar 20 15:14:12 2020
ORA-00020: maximum number of processes (2000) exceeded
 ORA-20 errors will not be written to the alert log for
 the next minute. Please look at trace files to see all
 the ORA-20 errors.
Process PA47 submission failed with error = 20  

##Ϊʲôora���̻���ô�࣬ԭ������ora_p���ֲ���������2000�����
������λ���⣬������sql�����˲��е��µ�

>>>���������
1������sqlplus�Ѿ���¼�����ˣ�����Ҫɱ�����̣��ȵ�¼��ȥ����
�����ǲ��е��£����������������Կ��Բ��ùرռ�����
Ϊ�˷�ֹɱ�����ݿ�������̣�ora_pmon�ȣ�����Ҫɸѡɱ�����̣�
ps -ef|grep ora_p1|grep -v grep|awk '{print $2}'|xargs kill -9

2����process�������󣬵�¼sqlplus���ҵ�����SQL
   INST_ID USERNAME        OSUSER          MACHINE                        MODULE                              SQL_ID                 CNT
---------- --------------- --------------- ------------------------------ ----------------------------------- --------------- ----------
         1 NF_NFZC         Administrator   WorkGroup\ECW42E3712K11RR      PL/SQL Developer                    9y8pxh9ax0nyz          687
         
3���鿴ִ�мƻ���ȷ���ǲ��е���
4��������������ָ��������Ǿ�ɱ�����sql�ĻỰ
SELECT a."INST_ID",a."SQL_ID",'kill -9 '||b."SPID" pid_kill,'alter system kill session ''' || A.SID || ',' || A.SERIAL# ||''';' sid_kill  FROM  gv$session a,gv$process b WHERE a."PADDR"=b."ADDR" AND a.sql_id='&SQL_ID';
5������Դͷԭ�򣬲鿴������־����λԴͷ
�����ǲ��У������������Ͽ���ֻ��һ�������������԰�ʱ�䣬Ҳ���԰�����������λ����IP
vim /u01/app/grid/diag/tnslsnr/dzswjnfdb1/listener/alert/log.xml
������ECW42E3712K11RR

 <txt>20-MAR-2020 15:11:12 * (CONNECT_DATA=(SERVICE_NAME=sngsnfdb)(CID=(PROGRAM=C:\Program?Files??x86?\PLSQL?Developer\plsqldev.exe)(HOST=ECW42E3712K11RR)
(USER=Administrator))) * (ADDRESS=(PROTOCOL=tcp)(HOST=10.10.85.178)(PORT=63350)) * establish * sngsnfdb * 0
 </txt>
</msg>
<msg time='2020-03-20T15:11:12.174+08:00' org_id='oracle' comp_id='tnslsnr'
 type='UNKNOWN' level='16' host_id='cztestdb1'
 host_addr='10.10.79.13'>
 <txt>20-MAR-2020 15:11:12 * (CONNECT_DATA=(SERVICE_NAME=sngsnfdb)(CID=(PROGRAM=C:\Program?Files??x86?\PLSQL?Developer\plsqldev.exe)(HOST=ECW42E3712K11RR)
(USER=Administrator))) * (ADDRESS=(PROTOCOL=tcp)(HOST=10.10.85.178)(PORT=63351)) * establish * sngsnfdb * 0

