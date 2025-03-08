Oracle SQL和PL/SQL中字符串单引号的处理
请看以下查询，最外层的两个单引号作为引号操作符，第二个作为转义符号，随意第三个单引号是真实的数据输出，所以，以下查询输出的是第三个单引号：

SQL> select '''' from dual;

'
-
'
进一步的，如果我们希望在字符串中也留有单引号，那么会是这一个样子的：

SQL> select '''YUNHE''ENMO' from dual;

'''YUNHE''E
-----------
'YUNHE'ENMO

SQL> select '''YUNHE''''ENMO' from dual;

'''YUNHE''''
------------
'YUNHE''ENMO

SQL> select '''YUNHE''''ENMO''' from dual;

'''YUNHE''''E
-------------
'YUNHE''ENMO'