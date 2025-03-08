--oracle���
Oracle 11G�Ժ����ݿ�Ĭ���ǿ�����ƹ��ܵģ������ʱ�����������˹رոù��ܵ���SYSTEM��ռ䱩���������ڹر���ƹ�����Ҫ�������ݿ⣬������������������ǲ�����ģ����������Ҫ�ҳ�������Ʋ����Ľ϶࣬Ȼ�󵥶��Ľ��йرա�

SQL> show parameter audit

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest                      string      /home/oracle/app/oracle/admin/
                                                 sjyydb/adump
audit_sys_operations                 boolean     FALSE
audit_syslog_level                   string
audit_trail                          string      DB

--����㷢��AUD$�����Ƚϴ��ˣ���������������ռ�Ŀռ䣺
select action_name,count(*) from dba_audit_trail group by action_name ORDER BY 2 DESC;

--�رյ�¼���ǳ�
noaudit session whenever successful;

--һ����˵������ռ䲻��ռ���ر�࣬������ƻ��Ǳ���Ϊ�á�����ȡ����һЩ��¼�ر�Ƶ�����û�����ƣ�����DBSNMP�û�
noaudit session by dbsnmp;

--�ر���ƺ󣬶Ա�sys.aud$��������
truncate table sys.aud$;

--��Ƽ���
��������ƹ��ܺ󣬿���������������ݿ������ƣ�Statement(���)��PRivilege��Ȩ�ޣ���object�����󣩡�
--Statement��
���������ƣ�����audit table ��������ݿ������е�create table,drop table,truncate table��䣬alter session by cmy�����cmy�û����е����ݿ����ӡ�
--Privilege��
��Ȩ������ƣ����û�ʹ���˸�Ȩ������ƣ���ִ��grant select any table to a����ִ����audit select any table���󣬵��û�a �������û�b�ı�ʱ����select * from b.t�����õ�select any tableȨ�ޣ��ʻᱻ��ơ�ע���û����Լ���������ߣ������û������Լ��ı��ᱻ��ơ�
--Object��
��������ƣ�ֻ���on�ؼ���ָ���������ز�������aduit alter,delete,drop,insert on cmy.t by scott; ������cmy�û���t�������ƣ���ͬʱʹ����by�Ӿ䣬����ֻ���scott�û�����Ĳ���������ơ�ע��Oracleû���ṩ��schema�����ж������ƹ��ܣ�ֻ��һ��һ��������ƣ����ں��洴���Ķ���Oracle���ṩon default�Ӿ���ʵ���Զ���ƣ�����ִ��audit drop on default by access;�� ������󴴽��Ķ����drop����������ơ������default���֮�󴴽����������ݿ������Ч���ƺ�û�취ָ��ֻ��ĳ���û������Ķ�����Ч�����trigger���Զ�schema��DDL���С���ơ�������������Բ��㡣

--��Ƶ�һЩ����ѡ��
by access / by session��
by access ÿһ������ƵĲ�����������һ��audit trail�� 
by session һ���Ự����ͬ���͵Ĳ���ֻ������һ��audit trail��Ĭ��Ϊby session��
whenever [not] successful��
whenever successful �����ɹ�(dba_audit_trail��returncode�ֶ�Ϊ0) �����,
whenever not successful ��֮��ʡ�Ը��Ӿ�Ļ������ܲ����ɹ���񶼻���ơ�
--�������ص���ͼ
dba_audit_trail���������е�audit trail��ʵ������ֻ��һ������aud$����ͼ����������ͼdba_audit_session,dba_audit_object,dba_audit_statement��ֻ��dba_audit_trail��һ���Ӽ���
dba_stmt_audit_opts�����������鿴statement��Ƽ����audit options�������ݿ����ù���Щstatement�������ơ�dba_obj_audit_opts,dba_priv_audit_opts��ͼ������֮����
all_def_audit_opts�������鿴���ݿ���on default�Ӿ���������ЩĬ�϶�����ơ�
--ȡ�����
����Ӧ�������audit��Ϊnoaudit���ɣ���audit session whenever successful��Ӧ��ȡ��������Ϊnoaudit session whenever successful;

--���д������
AUDIT DELETE ANY TABLE;    --���ɾ����Ĳ���
AUDIT DELETE ANY TABLE WHENEVER NOT SUCCESSFUL;    --ֻ���ɾ��ʧ�ܵ����
AUDIT DELETE ANY TABLE WHENEVER SUCCESSFUL;    --ֻ���ɾ���ɹ������
AUDIT DELETE,UPDATE,INSERT ON user.table by test;    --���test�û��Ա�user.table��delete,update,insert����