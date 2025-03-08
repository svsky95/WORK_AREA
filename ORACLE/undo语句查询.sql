--UNDO表空间查看
SELECT * FROM Dba_Data_Files t WHERE t.TABLESPACE_NAME='UNDOTBS1';

select start_time,  --事务起始时间  
       username,    --用户名  
       s.MACHINE,   --机器名称  
       s.OSUSER,    --登录名  
       r.name,      --回滚段名称  
       ubafil,      --Undo block address (UBA) filenum  
       ubablk,      --UBA block number  
       t.status,    --回话状态  
       (used_ublk * p.value) / 1024 blk, --使用的回滚段空间  
       used_urec,   --使用的undo 记录 ,  
       s1.SQL_ID,    --sql_id  
       s1.SQL_TEXT   --sql文本  
  from v$transaction t, v$rollname r, v$session s, v$parameter p,v$sql s1  
 where xidusn = usn  
   and s.saddr = t.ses_addr  
   and p.name = 'db_block_size'   
   and s.SADDR=s1.ADDRESS(+)  
 order by 1; 
 
 select BEGIN_TIME,  
       end_time,    
       round(maxquerylen / 60, 0) maxq,  --最长sql执行时间  
       maxquerysqlid,                    --最长sql执行时间的sqlid  
       undotsn,                          --最后活动的undo tablespace 编号  
       undoblks,                         --消耗的undo block size  
       txncount,                         --时段内的食物数量  
       unexpiredblks,                    --未过期的  
       expiredblks,                      --时段内未过期的undp block总数   
       round(tuned_undoretention / 60, 0) Tuned  --auto undoundoretention tuned之后的undo_retention  
  from dba_hist_undostat   
 where end_time > sysdate - 1
 order by 1 ;
 
--查看会话在undo中的占用
select s.sid,s.serial#,s.sql_id,v.usn,segment_name,r.status, v.rssize/1024/1024 mb
From dba_rollback_segs r, v$rollstat v,v$transaction t,v$session s
Where r.segment_id = v.usn and v.usn=t.xidusn and t.addr=s.taddr
  order by segment_name ;