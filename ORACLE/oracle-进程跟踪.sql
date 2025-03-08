--oracle进程跟踪
注意不要用oradug去跟踪oracle的smon,pmon等几个进程，操作不当可能会杀掉这几个后台进和引起宕库。
1、通过ps -ef| grep oracle 来获取SPID 
2、跟踪 oradebug help 获取帮助
oradebug setospid 26611;   --SPID
oradebug unlimit;          --解除对跟踪文件大小的限制
oradebug event 10046 trace name context forever,level 8;  --对进程进行事件绑定
--执行跟踪内容
oradebug event 10046 trace name context off;              --关闭跟踪
oradebug tracefile_name;                                  --打印跟踪文件路径