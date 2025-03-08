1.进入到adrci命令行模式
ora11g@RHEL53 /home/oracle$ which adrci
/oracle/u01/app/oracle/product/1101/db/bin/adrci
ora11g@RHEL53 /home/oracle$ adrci -help
Syntax:
   adrci [-help] [script=script_filename]
         [exec = "one_command [;one_command;...]"]

Options      Description                     (Default)
------------------------------------------------------
script       script. file name               (None)
help         help on the command options     (None)
exec         exec a set of commands          (None)
------------------------------------------------------

ora11g@RHEL53 /home/oracle$ adrci

ADRCI: Release 11.1.0.6.0 - Beta on Fri Feb 27 15:23:52 2009

Copyright (c) 1982, 2007, Oracle.  All rights reserved.

ADR base = "/oracle/u01/app/oracle"
adrci>

2.使用 help show alert 命令查看帮助文档
adrci> help

 HELP [topic]
   Available Topics:
        CREATE REPORT
        ECHO
        EXIT
        HELP
        HOST
        IPS
        PURGE
        RUN
        SET BASE
        SET BROWSER
        SET CONTROL
        SET ECHO
        SET EDITOR
        SET HOMES | HOME | HOMEPATH
        SET TERMOUT
        SHOW ALERT
        SHOW BASE
        SHOW CONTROL
        SHOW HM_RUN
        SHOW HOMES | HOME | HOMEPATH
        SHOW INCDIR
        SHOW INCIDENT
        SHOW PROBLEM
        SHOW REPORT
        SHOW TRACEFILE
        SPOOL

 There are other commands intended to be used directly by Oracle, type
 "HELP EXTENDED" to see the list

adrci> help show alert

  Usage: SHOW ALERT [-p ]  [-term]
                    [ [-tail [num] [-f]] | [-file ] ]
  Purpose: Show alert messages.

  Options:
    [-p ]: The predicate string must be double quoted.
    The fields in the predicate are the fields:
        ORIGINATING_TIMESTAMP         timestamp
        NORMALIZED_TIMESTAMP          timestamp
        ORGANIZATION_ID               text(65)
        COMPONENT_ID                  text(65)
        HOST_ID                       text(65)
        HOST_ADDRESS                  text(17)
        MESSAGE_TYPE                  number
        MESSAGE_LEVEL                 number
        MESSAGE_ID                    text(65)
        MESSAGE_GROUP                 text(65)
        CLIENT_ID                     text(65)
        MODULE_ID                     text(65)
        PROCESS_ID                    text(33)
        THREAD_ID                     text(65)
        USER_ID                       text(65)
        INSTANCE_ID                   text(65)
        DETAILED_LOCATION             text(161)
        UPSTREAM_COMP_ID              text(101)
        DOWNSTREAM_COMP_ID            text(101)
        EXECUTION_CONTEXT_ID          text(101)
        EXECUTION_CONTEXT_SEQUENCE    number
        ERROR_INSTANCE_ID             number
        ERROR_INSTANCE_SEQUENCE       number
        MESSAGE_TEXT                  text(2049)
        MESSAGE_ARGUMENTS             text(129)
        SUPPLEMENTAL_ATTRIBUTES       text(129)
        SUPPLEMENTAL_DETAILS          text(129)
        PROBLEM_KEY                   text(65)

    [-tail [num] [-f]]: Output last part of the alert messages and
    output latest messages as the alert log grows. If num is not specified,
    the last 10 messages are displayed. If "-f" is specified, new data
    will append at the end as new alert messages are generated.

    [-term]: Direct results to terminal. If this option is not specified,
    the results will be open in an editor.
    By default, it will open in emacs, but "set editor" can be used
    to set other editors.

    [-file ]: Allow users to specify an alert file which
    may not be in ADR. must be specified with full path.
    Note that this option cannot be used with the -tail option

  Examples:
    show alert
    show alert -p "message_text like '%incident%'"
    show alert -tail 20

adrci>

3.使用 show alert 列出各个目录下的日志目录，输入编号4，系统会自动调用vi编辑器查看数据库的alert日志
adrci> show alert

Choose the alert log from the following homes to view:

1: diag/tnslsnr/RHEL53/listener
2: diag/clients/user_unknown/host_411310321_11
3: diag/clients/user_oracle/host_2175824367_11
4: diag/rdbms/ora11g/ora11g
Q: to quit

Please select option:4

4.另外一种查看方式是，指定具体的 homepath 然后使用“show alert -tail 15”查看对应日志文件的后15行
adrci> show homepath
ADR Homes:
diag/tnslsnr/RHEL53/listener
diag/clients/user_unknown/host_411310321_11
diag/clients/user_oracle/host_2175824367_11
diag/rdbms/ora11g/ora11g
adrci> set homepath diag/rdbms/ora11g/ora11g
adrci> show alert -tail 15
2009-02-27 14:25:05.036000 +08:00
Starting background process SMCO
SMCO started with pid=21, OS id=3855
Starting background process FBDA
FBDA started with pid=22, OS id=3857
replication_dependency_tracking turned off (no async multimaster replication found)
2009-02-27 14:25:07.246000 +08:00
Starting background process QMNC
QMNC started with pid=23, OS id=3859
2009-02-27 14:25:17.325000 +08:00
db_recovery_file_dest_size of 4096 MB is 0.00% used. This is a
user-specified limit on the amount of space that will be used by this
database for recovery-related files, and does not reflect the amount of
space available in the underlying filesystem or ASM diskgroup.
2009-02-27 14:25:33.727000 +08:00
Completed: ALTER DATABASE OPEN
2009-02-27 14:29:59.158000 +08:00
Starting background process CJQ0
CJQ0 started with pid=25, OS id=3892
adrci>

5.小结
  使用ADRCI命令可以很好的对各个目录中的日志文件进行集中查看，可以有效的提高工作效率，赞一个，在高度紧张的问题处理环境中这个工具可以有效的提高问题诊断的效率。