3��getfacl��setfacl����
a.�ڽڵ�2�ϻ�ȡ�ļ���Ŀ¼��Ȩ��:
     # getfacl -pR /oracle > backup.txt
b.���� backup.txt ���ڵ�1
c.�滻backup.txt�е�rac2Ϊrac1��ASM2ΪASM1��orcl2Ϊorcl1
--ASM= ASM2 -> ASM1     :%s/ASM1/ASM2/g 
--ʵ�� = crsdb2  -> crsdb1    :%s/crsdb2/crsdb1/g 
--������ racnode2 -> racnode1   :%s/racnode2/racnode1/g 
     vi bakcup.txt
     :1,$s/rac2/rac1/g  �س� (:n,$s/ rac2/ rac1/g �滻�� n �п�ʼ�����һ����ÿһ������rac2Ϊrac1) 
d.�ڽڵ�1�ϻָ�Ȩ�ޣ��е�backup.txtĿ¼�£�
     # setfacl --restore=backup.txt
e. crsctl start crs
f.srvctl start instance -d orcl -i orcl1
g.�����֤��

��Ȼ�������ַ�ʽ���������������ݣ����ܶ�/oracle ����chown �CR ���� chmod �CR ������ֻҪ���ڵ��������Ϳ��ԴӶ��ڵ��Ǳߡ���������ȷȨ�ޡ�