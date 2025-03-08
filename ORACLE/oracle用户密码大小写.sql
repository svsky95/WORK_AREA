--oracle用户密码大小写问题
oracle 11g 默认区分大小写的
--参数控制
show aprameter sec_case_sensitive_logon
alter system set sec_case_sensitive_logon=false 设置改为不区分大小写

--修改密码 
#不带特殊字符的
alter user cz identified by Cz;
这是登录的用户是不区分大小写的，但是登录密码是区分，即是大写C，小写的z.

#带有特殊字符的
alter user cz identified by "Cz#!2017";
这时密码是：双引号的内容，并且区分大小写。


