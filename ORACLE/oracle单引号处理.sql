Oracle SQL��PL/SQL���ַ��������ŵĴ���
�뿴���²�ѯ��������������������Ϊ���Ų��������ڶ�����Ϊת����ţ��������������������ʵ��������������ԣ����²�ѯ������ǵ����������ţ�

SQL> select '''' from dual;

'
-
'
��һ���ģ��������ϣ�����ַ�����Ҳ���е����ţ���ô������һ�����ӵģ�

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