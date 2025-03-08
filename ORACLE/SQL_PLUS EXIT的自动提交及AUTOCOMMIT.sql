SQL*PLUS EXIT的自动提交及AUTOCOMMIT
这个功能点一般很少注意，具体是在主机上用SQL*PLUS登录的时候，进行操作，会有两个选项：

SQL> show autocommit                    --自动提交
autocommit OFF
SQL> show exitcommit                     --退出时自动提交
exitcommit ON
--修改
set exitcommit off  

当你在SQL*PLUS执行了DML语句时，若没有执行commit或者rollback，而是直接退出，那么就会导致自动提交。
1）
AUTOCOMMIT  EXITCOMMIT  EXIT(退出前动作)  Exit Behavior（执行退出）
OFF         ON          -                    COMMIT
OFF         ON          COMMIT               COMMIT
OFF         ON          ROLLBACK             ROLLBACK

2）AUTOCOMMIT保持默认“OFF”不变，将EXITCOMMIT修改为“OFF”的三种情况：重点放在第一条上
AUTOCOMMIT  EXITCOMMIT  EXIT      Exit Behavior
OFF         OFF         -         ROLLBACK
OFF         OFF         COMMIT    COMMIT
OFF         OFF         ROLLBACK  ROLLBACK

3）剩下的AUTOCOMMIT为“ON”的情形，结论统统是“提交”
AUTOCOMMIT  EXITCOMMIT  EXIT      Exit Behavior
ON          ON          -         COMMIT
ON          OFF         -         COMMIT
ON          ON          COMMIT    COMMIT
ON          ON          ROLLBACK  COMMIT
ON          OFF         COMMIT    COMMIT
ON          OFF         ROLLBACK  COMMIT