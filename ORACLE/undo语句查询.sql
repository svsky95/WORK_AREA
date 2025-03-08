--UNDO��ռ�鿴
SELECT * FROM Dba_Data_Files t WHERE t.TABLESPACE_NAME='UNDOTBS1';

select start_time,  --������ʼʱ��  
       username,    --�û���  
       s.MACHINE,   --��������  
       s.OSUSER,    --��¼��  
       r.name,      --�ع�������  
       ubafil,      --Undo block address (UBA) filenum  
       ubablk,      --UBA block number  
       t.status,    --�ػ�״̬  
       (used_ublk * p.value) / 1024 blk, --ʹ�õĻع��οռ�  
       used_urec,   --ʹ�õ�undo ��¼ ,  
       s1.SQL_ID,    --sql_id  
       s1.SQL_TEXT   --sql�ı�  
  from v$transaction t, v$rollname r, v$session s, v$parameter p,v$sql s1  
 where xidusn = usn  
   and s.saddr = t.ses_addr  
   and p.name = 'db_block_size'   
   and s.SADDR=s1.ADDRESS(+)  
 order by 1; 
 
 select BEGIN_TIME,  
       end_time,    
       round(maxquerylen / 60, 0) maxq,  --�sqlִ��ʱ��  
       maxquerysqlid,                    --�sqlִ��ʱ���sqlid  
       undotsn,                          --�����undo tablespace ���  
       undoblks,                         --���ĵ�undo block size  
       txncount,                         --ʱ���ڵ�ʳ������  
       unexpiredblks,                    --δ���ڵ�  
       expiredblks,                      --ʱ����δ���ڵ�undp block����   
       round(tuned_undoretention / 60, 0) Tuned  --auto undoundoretention tuned֮���undo_retention  
  from dba_hist_undostat   
 where end_time > sysdate - 1
 order by 1 ;
 
--�鿴�Ự��undo�е�ռ��
select s.sid,s.serial#,s.sql_id,v.usn,segment_name,r.status, v.rssize/1024/1024 mb
From dba_rollback_segs r, v$rollstat v,v$transaction t,v$session s
Where r.segment_id = v.usn and v.usn=t.xidusn and t.addr=s.taddr
  order by segment_name ;