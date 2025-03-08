--session marked for kill（标记要终止的会话）解决方法
今天碰到一个问题，有一张表不能操作，很可能是被锁了，首先想到的是kill session，于是执行了下列的脚本找到是哪个session有问题：

select object_name, machine, s.sid,s.serial#

 from v$locked_object l, dba_objects o, v$session s

 where l.object_id = o.object_id

   and l.session_id =s.sid;

      发现有一个会话有锁sid 197,serial# 17，于是执行alter system kill session ‘197,17’;大概等了30s中，pl/sql developer报出一个错误:ora-00031:标记要终止的会话。

解决方法：查出session的spid

select spid, osuser, s.program

 from v$session s, v$process p

 where s.paddr = p.addr

   and s.sid =197;

1. 在linux上，  kill -9 12345

2. 在windows上，C:\Documents and Settings\gg>orakill orcl 12345

orcl：表示要杀死的进程属于的实例名

12345：是要杀掉的线程号