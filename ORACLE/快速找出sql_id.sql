#####快速找出sql_id的方法
1、在sql上添加如下：
select /*+sample*/ nvl(n.shxydm, n.nsrsbh) shxydm ******
2、查找sql_id
SELECT * FROM v$sqlarea t WHERE t."SQL_TEXT" like 'select /*+sample*/% ';