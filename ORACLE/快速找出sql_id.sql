#####�����ҳ�sql_id�ķ���
1����sql��������£�
select /*+sample*/ nvl(n.shxydm, n.nsrsbh) shxydm ******
2������sql_id
SELECT * FROM v$sqlarea t WHERE t."SQL_TEXT" like 'select /*+sample*/% ';