##ORA�������

--ORA-00600
������Ϣ��һ���� ORA-600 [ktsircinfo_num1] [a] [b] [c]��ʽ��ʾ�����У� 
����[a]  Ϊ��ռ��� 
����[b]  Ϊ�ļ��� 
����[c]  Ϊ���

[6] [800] [3950146]

1���鿴��ռ�
SELECT t.FILE_ID,t.TABLESPACE_NAME,t.FILE_NAME FROM dba_data_files t WHERE t.FILE_ID=800;

2���鿴��
SELECT t.tablespace_name,t.segment_type,t.owner,t.segment_name FROM dba_extents t WHERE t.FILE_ID=800 and 3950146 between t.BLOCK_ID and t.BLOCK_ID+t.BLOCKS-1;

--���Ǳ����������⣬�����ȱ��ݱ����ݣ����ؽ���������


