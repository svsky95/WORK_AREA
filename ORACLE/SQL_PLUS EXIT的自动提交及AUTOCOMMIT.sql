SQL*PLUS EXIT���Զ��ύ��AUTOCOMMIT
������ܵ�һ�����ע�⣬����������������SQL*PLUS��¼��ʱ�򣬽��в�������������ѡ�

SQL> show autocommit                    --�Զ��ύ
autocommit OFF
SQL> show exitcommit                     --�˳�ʱ�Զ��ύ
exitcommit ON
--�޸�
set exitcommit off  

������SQL*PLUSִ����DML���ʱ����û��ִ��commit����rollback������ֱ���˳�����ô�ͻᵼ���Զ��ύ��
1��
AUTOCOMMIT  EXITCOMMIT  EXIT(�˳�ǰ����)  Exit Behavior��ִ���˳���
OFF         ON          -                    COMMIT
OFF         ON          COMMIT               COMMIT
OFF         ON          ROLLBACK             ROLLBACK

2��AUTOCOMMIT����Ĭ�ϡ�OFF�����䣬��EXITCOMMIT�޸�Ϊ��OFF��������������ص���ڵ�һ����
AUTOCOMMIT  EXITCOMMIT  EXIT      Exit Behavior
OFF         OFF         -         ROLLBACK
OFF         OFF         COMMIT    COMMIT
OFF         OFF         ROLLBACK  ROLLBACK

3��ʣ�µ�AUTOCOMMITΪ��ON�������Σ�����ͳͳ�ǡ��ύ��
AUTOCOMMIT  EXITCOMMIT  EXIT      Exit Behavior
ON          ON          -         COMMIT
ON          OFF         -         COMMIT
ON          ON          COMMIT    COMMIT
ON          ON          ROLLBACK  COMMIT
ON          OFF         COMMIT    COMMIT
ON          OFF         ROLLBACK  COMMIT