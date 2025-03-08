--oracle审计
Oracle 11G以后，数据库默认是开启审计功能的，因此有时候我们忘记了关闭该功能导致SYSTEM表空间暴满，但由于关闭审计功能需要重启数据库，此类操作生产环境下是不允许的，因此我们需要找出哪类审计产生的较多，然后单独的进行关闭。

SQL> show parameter audit

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest                      string      /home/oracle/app/oracle/admin/
                                                 sjyydb/adump
audit_sys_operations                 boolean     FALSE
audit_syslog_level                   string
audit_trail                          string      DB

--如果你发现AUD$这个表比较大了，检查下是哪种审计占的空间：
select action_name,count(*) from dba_audit_trail group by action_name ORDER BY 2 DESC;

--关闭登录及登出
noaudit session whenever successful;

--一般来说，如果空间不是占的特别多，此类审计还是保留为好。可以取消对一些登录特别频繁的用户的审计，比如DBSNMP用户
noaudit session by dbsnmp;

--关闭审计后，对表sys.aud$进行清理
truncate table sys.aud$;

--审计级别
当开启审计功能后，可在三个级别对数据库进行审计：Statement(语句)、PRivilege（权限）、object（对象）。
--Statement：
按语句来审计，比如audit table 会审计数据库中所有的create table,drop table,truncate table语句，alter session by cmy会审计cmy用户所有的数据库连接。
--Privilege：
按权限来审计，当用户使用了该权限则被审计，如执行grant select any table to a，当执行了audit select any table语句后，当用户a 访问了用户b的表时（如select * from b.t）会用到select any table权限，故会被审计。注意用户是自己表的所有者，所以用户访问自己的表不会被审计。
--Object：
按对象审计，只审计on关键字指定对象的相关操作，如aduit alter,delete,drop,insert on cmy.t by scott; 这里会对cmy用户的t表进行审计，但同时使用了by子句，所以只会对scott用户发起的操作进行审计。注意Oracle没有提供对schema中所有对象的审计功能，只能一个一个对象审计，对于后面创建的对象，Oracle则提供on default子句来实现自动审计，比如执行audit drop on default by access;后， 对于随后创建的对象的drop操作都会审计。但这个default会对之后创建的所有数据库对象有效，似乎没办法指定只对某个用户创建的对象有效，想比trigger可以对schema的DDL进行“审计”，这个功能稍显不足。

--审计的一些其他选项
by access / by session：
by access 每一个被审计的操作都会生成一条audit trail。 
by session 一个会话里面同类型的操作只会生成一条audit trail，默认为by session。
whenever [not] successful：
whenever successful 操作成功(dba_audit_trail中returncode字段为0) 才审计,
whenever not successful 反之。省略该子句的话，不管操作成功与否都会审计。
--和审计相关的视图
dba_audit_trail：保存所有的audit trail，实际上它只是一个基于aud$的视图。其它的视图dba_audit_session,dba_audit_object,dba_audit_statement都只是dba_audit_trail的一个子集。
dba_stmt_audit_opts：可以用来查看statement审计级别的audit options，即数据库设置过哪些statement级别的审计。dba_obj_audit_opts,dba_priv_audit_opts视图功能与之类似
all_def_audit_opts：用来查看数据库用on default子句设置了哪些默认对象审计。
--取消审计
将对应审计语句的audit改为noaudit即可，如audit session whenever successful对应的取消审计语句为noaudit session whenever successful;

--审计写法举例
AUDIT DELETE ANY TABLE;    --审计删除表的操作
AUDIT DELETE ANY TABLE WHENEVER NOT SUCCESSFUL;    --只审计删除失败的情况
AUDIT DELETE ANY TABLE WHENEVER SUCCESSFUL;    --只审计删除成功的情况
AUDIT DELETE,UPDATE,INSERT ON user.table by test;    --审计test用户对表user.table的delete,update,insert操作