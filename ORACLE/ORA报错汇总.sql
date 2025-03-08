##ORA报错汇总

--ORA-00600
报错信息中一般以 ORA-600 [ktsircinfo_num1] [a] [b] [c]形式显示，其中： 
参数[a]  为表空间编号 
参数[b]  为文件号 
参数[c]  为块号

[6] [800] [3950146]

1、查看表空间
SELECT t.FILE_ID,t.TABLESPACE_NAME,t.FILE_NAME FROM dba_data_files t WHERE t.FILE_ID=800;

2、查看块
SELECT t.tablespace_name,t.segment_type,t.owner,t.segment_name FROM dba_extents t WHERE t.FILE_ID=800 and 3950146 between t.BLOCK_ID and t.BLOCK_ID+t.BLOCKS-1;

--若是表及索引的问题，建议先备份表数据，后重建表及索引。


