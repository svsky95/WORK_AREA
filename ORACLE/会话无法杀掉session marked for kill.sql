--session marked for kill�����Ҫ��ֹ�ĻỰ���������
��������һ�����⣬��һ�ű��ܲ������ܿ����Ǳ����ˣ������뵽����kill session������ִ�������еĽű��ҵ����ĸ�session�����⣺

select object_name, machine, s.sid,s.serial#

 from v$locked_object l, dba_objects o, v$session s

 where l.object_id = o.object_id

   and l.session_id =s.sid;

      ������һ���Ự����sid 197,serial# 17������ִ��alter system kill session ��197,17��;��ŵ���30s�У�pl/sql developer����һ������:ora-00031:���Ҫ��ֹ�ĻỰ��

������������session��spid

select spid, osuser, s.program

 from v$session s, v$process p

 where s.paddr = p.addr

   and s.sid =197;

1. ��linux�ϣ�  kill -9 12345

2. ��windows�ϣ�C:\Documents and Settings\gg>orakill orcl 12345

orcl����ʾҪɱ���Ľ������ڵ�ʵ����

12345����Ҫɱ�����̺߳�