--oracle���̸���
ע�ⲻҪ��oradugȥ����oracle��smon,pmon�ȼ������̣������������ܻ�ɱ���⼸����̨��������崿⡣
1��ͨ��ps -ef| grep oracle ����ȡSPID 
2������ oradebug help ��ȡ����
oradebug setospid 26611;   --SPID
oradebug unlimit;          --����Ը����ļ���С������
oradebug event 10046 trace name context forever,level 8;  --�Խ��̽����¼���
--ִ�и�������
oradebug event 10046 trace name context off;              --�رո���
oradebug tracefile_name;                                  --��ӡ�����ļ�·��