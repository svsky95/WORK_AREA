--�������ݿ������Ȩ�޵����޷�����
��ι��ϵĻ���������ASMʵ���������ǵ����ģ����Ծ�ô��CRS���̣�������ohasd���̡�
1����һ̨���ýӽ���ϵͳ����Ȩ��
(���ݵ�Ŀ¼ȡ�����������Ŀ¼��������� / �£�����Ҫ���� / ��������Ȩ��)
[root@12cnod01 ~]# getfacl -R /home >homesc.bak    
getfacl: Removing leading '/' from absolute path names

2����ԭȨ��
��Ŀ������ϣ�����Ŀ¼�Ƿ��Ӧ������ORACLE_BASE��ORACLE_HOME���ܾͺͱ��ݵĲ�һ������Ҫ�޸��ļ�����ִ�С�
setfacl --restore=homesc.bak  //����Ŀ¼ִ��

��֤����asm��oracleʵ���Ƿ�����

3���п���������asm����ʾȨ�޲��㣬���߲��ܷ��乲���ڴ�
[root@12cnod01 ~]# su - grid
[grid@12cnod01 ~]$ sqlplus / as sysasm

4���Ų鹲���ڴ�
�����ڴ���/dev/shm����ļ��йأ�ora_asm����grid.oinstallȨ��,���������Ļ���Ȩ�޽����޸ġ�   

