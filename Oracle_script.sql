SELECT a.snap_id,
       c.tablespace_name ts_name,
       to_char(to_date(a.rtime,'mm/dd/yyyy hh24:mi:ss'),'yyyy-mm-dd hh24:mi') rtime,
       round(a.tablespace_size * c.block_size /1024/1024,2) ts_size_mb,
       round(a.tablespace_usedsize * c.block_size /1024/1024,2) ts_used_mb,
       round((a.tablespace_size - a.tablespace_usedsize)* c.block_size /1024/1024,
2) ts_free_mb,
       round(a.tablespace_usedsize / a.tablespace_size *100,2) pct_used
  FROM dba_hist_tbspc_space_usage a,
(SELECT tablespace_id,
               substr(rtime,1,10) rtime,
               max(snap_id) snap_id
          FROM dba_hist_tbspc_space_usage nb
         group by tablespace_id, substr(rtime,1,10)) b,
         dba_tablespaces c,
         v$tablespace d
where a.snap_id = b.snap_id
   and a.tablespace_id = b.tablespace_id
   and a.tablespace_id=d.TS#
   and d.NAME=c.tablespace_name  
     and  to_date(a.rtime,'mm/dd/yyyy hh24:mi:ss')>=sysdate-30
   order by a.tablespace_id,to_date(a.rtime,'mm/dd/yyyy hh24:mi:ss') desc;