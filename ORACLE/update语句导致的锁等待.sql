##����update��䵼�µ����ȴ����Ӷ����ݿ��ѹ���޴�������
����������ǰ��ҵ��ӳ������ϵͳ�޷�����ʹ�ã��鿴ϵͳ���£�
1���ȴ��¼��鿴
   INST_ID EVENT                                      COUNT(*)
---------- ---------------------------------------- ----------
         1 enq: TX - row lock contention                   523
         1 SGA: allocation forcing component growth          1
         1 asynch descriptor resize                          1
         1 latch: shared pool                                1
         1 direct path read temp                             1
         
##ϵͳ�л�ѹ��SQL
SQL> select tt."INST_ID",       tt."USERNAME",       tt."OSUSER",       tt."MACHINE",       tt.module,       tt.sql_id,       count(*) cnt  from (select t."INST_ID",               t."USERNAME",               t."OSUSER",               t."MACHINE",               module,               nvl(sql_id, prev_sql_id) sql_id          from gv$session t         WHERE t."STATUS" = 'ACTIVE'           and t.username is not null           and t."MODULE" is not null) tt group by tt."INST_ID",          tt."USERNAME",          tt."OSUSER",          tt."MACHINE",          tt.module,          sql_id order by 1, cnt desc;

   INST_ID USERNAME        OSUSER          MACHINE                        MODULE                              SQL_ID                 CNT
---------- --------------- --------------- ------------------------------ ----------------------------------- --------------- ----------
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    a0p96w76dx5fy          251
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    a0p96w76dx5fy          108
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    cg9u3vhj3upkb           91
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    cg9u3vhj3upkb           22
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    61rc6t31y90qf           12
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    2wcwb3shu14dd            6
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    61rc6t31y90qf            4
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    2wcwb3shu14dd            3
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    ggrgcb84481ya            2
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    dn3y51uj2ampy            1
         1 SYS             oracle          sx12366-db1                    sqlplus@sx12366-db1 (TNS V1-V3)     1u8v3v4dq2fmc            1
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    8fs5jnc155hr8            1
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    dq68jpthm16m3            1
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    dn3y51uj2ampy            1
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    3hjy3crkg6g56            1
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    85xqgumyd9x45            1
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    ggrgcb84481ya            1
         1 SZ12366         root            sx12366-web2.site              JDBC Thin Client                    apfu1r69a1429            1
         1 SZ12366         root            sx12366-web1.site              JDBC Thin Client                    933p8xtk2pwwk            1
         
         
�ص㼯���ڣ�a0p96w76dx5fy��cg9u3vhj3upkb��
#a0p96w76dx5fy��sql���Ϊ��
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') a from dual
���ղ�ѯϵͳ��˵����Ӧ�ô��ڵȴ�

#cg9u3vhj3upkb
update ywcl_lzmx set lzxmjsr=:1 ,lzxmjsrxm=:2 ,lzmxjsrjg=:3   where lzxmcasebh=:4  and lzmxsfsx=:5;
---------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name               | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT             |                    |       |       |    12 (100)|          |
|   1 |  UPDATE                      | YWCL_LZMX          |       |       |            |          |
|*  2 |   TABLE ACCESS BY INDEX ROWID| YWCL_LZMX          |     5 |   300 |    12   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | PK_YWCL_LZMXCASEBH |     9 |       |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------

ִ�мƻ���ʾ���͸�����ֻ����lzxmcasebh�������������˵���Ǻܸ�Ч�������߸���������һЩ��
create index SZ12366.idx_LZMX_bh_sx on SZ12366.YWCL_LZMX(lzxmcasebh,lzmxsfsx);
���ǵ���������ʱ����ʾnowait,������Ҫ��ɱ�����Ľ��̡�
SELECT t.OWNER,OBJECT_NAME,       MACHINE,       'alter system kill session  ''' || S.SID || ',' || s."SERIAL#" ||       ''';' KILL_COMMAND  FROM V$LOCKED_OBJECT L, DBA_OBJECTS t, V$SESSION S WHERE L.OBJECT_ID = t.OBJECT_ID   AND L.SESSION_ID = S.SID;
����ǰ�˻����Ѿ��°��ˣ��������ⲻ�ٸ��֡�

2���ڶ���鿴��������һ��SQL������
���Ȳ鿴�˵ȴ�ʱ�䣬������Ȼ����
   INST_ID EVENT                                      COUNT(*)
---------- ---------------------------------------- ----------
         1 enq: TX - row lock contention                    36
         1 asynch descriptor resize                          1
         1 db file scattered read                            1
         1 SGA: allocation forcing component growth          1

2.1�鿴���ȴ�
SQL> SELECT w."USERNAME" "waiting session",w."MACHINE",w."SID",w."SERIAL#", '|',b."USERNAME" "blocked session",w."MACHINE",b."SID",b."SERIAL#" FROM V$SESSION W JOIN V$SESSION B ON (w."BLOCKING_SESSION" = b."SID") ORDER BY b."SID", w."SID";
waiting session                MACHINE                               SID    SERIAL# ' blocked session                MACHINE                               SID    SERIAL#
------------------------------ ------------------------------ ---------- ---------- - ------------------------------ ------------------------------ ---------- ----------
SZ12366                        sx12366-web1.site                     411          4 | SZ12366                        sx12366-web1.site                      37         14
SZ12366                        sx12366-web1.site                     505      54874 | SZ12366                        sx12366-web1.site                      37         14
SZ12366                        sx12366-web2.site                      36        252 | SZ12366                        sx12366-web2.site                      64      23374
SZ12366                        sx12366-web2.site                    1833       1040 | SZ12366                        sx12366-web2.site                      64      23374
SZ12366                        sx12366-web2.site                    1869      30252 | SZ12366                        sx12366-web2.site                      64      23374
SZ12366                        sx12366-web1.site                     997        168 | SZ12366                        sx12366-web1.site                     131      19507
SZ12366                        sx12366-web1.site                    1153        342 | SZ12366                        sx12366-web1.site                     131      19507
SZ12366                        sx12366-web1.site                    1185      29122 | SZ12366                        sx12366-web1.site                     131      19507
SZ12366                        sx12366-web1.site                    1217         14 | SZ12366                        sx12366-web1.site                     131      19507
SZ12366                        sx12366-web1.site                    1333      20155 | SZ12366                        sx12366-web1.site                     131      19507
SZ12366                        sx12366-web1.site                    1558       1602 | SZ12366                        sx12366-web1.site                     131      19507
SZ12366                        sx12366-web1.site                    1961        394 | SZ12366                        sx12366-web1.site                     131      19507
SZ12366                        WIN-08LR2J1G49K                       131      19507 | SZ12366                        WIN-08LR2J1G49K                       505      54874
SZ12366                        sx12366-web1.site                     437       8864 | SZ12366                        sx12366-web1.site                     505      54874
SZ12366                        sx12366-web1.site                    1650       1469 | SZ12366                        sx12366-web1.site                     505      54874
SZ12366                        sx12366-web1.site                     442      26868 | SZ12366                        sx12366-web1.site                     515      56308
SZ12366                        sx12366-web1.site                     646         92 | SZ12366                        sx12366-web1.site                     515      56308
SZ12366                        sx12366-web1.site                    1073      32336 | SZ12366                        sx12366-web1.site                     515      56308
SZ12366                        sx12366-web1.site                    1405        100 | SZ12366                        sx12366-web1.site                     515      56308
SZ12366                        sx12366-web1.site                    1526        978 | SZ12366                        sx12366-web1.site                     515      56308
SZ12366                        sx12366-web1.site                    1527       3929 | SZ12366                        sx12366-web1.site                     515      56308
SZ12366                        sx12366-web1.site                    1583       1871 | SZ12366                        sx12366-web1.site                     515      56308
SZ12366                        sx12366-web1.site                    1678      51043 | SZ12366                        sx12366-web1.site                     515      56308
SZ12366                        sx12366-web1.site                    1744      40069 | SZ12366                        sx12366-web1.site                     515      56308
SYS                            sx12366-db1                           567      43330 |                                sx12366-db1                           559          1
SZ12366                        sx12366-web1.site                      37         14 | SZ12366                        sx12366-web1.site                    1630      61936
SZ12366                        sx12366-web2.site                      64      23374 | SZ12366                        sx12366-web2.site                    1630      61936
SZ12366                        sx12366-web2.site                     193      13796 | SZ12366                        sx12366-web2.site                    1630      61936
SZ12366                        sx12366-web1.site                     260       2821 | SZ12366                        sx12366-web1.site                    1630      61936
SZ12366                        sx12366-web1.site                     273       5033 | SZ12366                        sx12366-web1.site                    1630      61936
SZ12366                        sx12366-web1.site                     503      39789 | SZ12366                        sx12366-web1.site                    1630      61936
SZ12366                        sx12366-web1.site                     515      56308 | SZ12366                        sx12366-web1.site                    1630      61936
SZ12366                        sx12366-web1.site                    1003      64659 | SZ12366                        sx12366-web1.site                    1630      61936
SZ12366                        sx12366-web2.site                    1024        415 | SZ12366                        sx12366-web2.site                    1630      61936
SZ12366                        sx12366-web2.site                    1326      10482 | SZ12366                        sx12366-web2.site                    1630      61936
SZ12366                        sx12366-web1.site                    1556      32327 | SZ12366                        sx12366-web1.site                    1630      61936
SZ12366                        sx12366-web2.site                    1575      54740 | SZ12366                        sx12366-web2.site                    1630      61936

��������SQL������SIDΪ64��131��515��1630��
�ֱ��ѯ�󣬷�����һ��SQLִ�е�ʱ���ر�ĳ�
SQL_ID  c95gjf491jyaa, child number 0
-------------------------------------
UPDATE YWCL_CASE SET CASESFGL = '1' WHERE CASEDJRQ >=
ADD_MONTHS(SYSDATE, -3) AND CASEDJRQ <= SYSDATE AND CASESFGL IS NULL
AND (CASEBH IN (SELECT CASEBH FROM TX_RECORDLOG WHERE BEGRECTIME >=
ADD_MONTHS(SYSDATE, -3) AND BEGRECTIME <= SYSDATE GROUP BY CASEBH
HAVING COUNT(1) > 1) OR CASEBH IN (SELECT GLCASEBHA FROM YWCL_BHGL
WHERE SUBSTR(GLGLSJ, 0, 7) >= TO_CHAR(ADD_MONTHS(SYSDATE, -3),
'yyyy-mm') AND SUBSTR(GLGLSJ, 0, 10) <= TO_CHAR(SYSDATE, 'yyyy-mm-dd'))
OR CASEBH IN (SELECT GLCASEBHB FROM YWCL_BHGL WHERE SUBSTR(GLGLSJ, 0,
7) >= TO_CHAR(ADD_MONTHS(SYSDATE, -3), 'yyyy-mm') AND SUBSTR(GLGLSJ, 0,
10) <= TO_CHAR(SYSDATE, 'yyyy-mm-dd')))

Plan hash value: 599586253

---------------------------------------------------------------------------------------
| Id  | Operation              | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | UPDATE STATEMENT       |              |       |       | 20607 (100)|          |
|   1 |  UPDATE                | YWCL_CASE    |       |       |            |          |
|*  2 |   FILTER               |              |       |       |            |          |
|*  3 |    FILTER              |              |       |       |            |          |
|*  4 |     TABLE ACCESS FULL  | YWCL_CASE    | 12132 |   426K| 20607   (1)| 00:04:08 |
|*  5 |    FILTER              |              |       |       |            |          |
|   6 |     HASH GROUP BY      |              |     1 |    30 | 43333   (1)| 00:08:40 |
|*  7 |      FILTER            |              |       |       |            |          |
|*  8 |       TABLE ACCESS FULL| TX_RECORDLOG |   287K|  8411K| 43325   (1)| 00:08:40 |
|*  9 |    TABLE ACCESS FULL   | YWCL_BHGL    |     1 |    42 |   138   (0)| 00:00:02 |
|* 10 |    TABLE ACCESS FULL   | YWCL_BHGL    |     1 |    41 |   138   (0)| 00:00:02 |
---------------------------------------------------------------------------------------

ͨ���鿴���SQL����ִ��ʱ�䳬��
SELECT  t."SID",t."CTIME" seconds FROM v$lock t where t."LMODE">0 and t."TYPE"='TX' and t."BLOCK"=1 and t."SID"=&sid;

       SID    SECONDS
---------- ----------
      1522      30204
      
��������ͳ��������SQL�ϣ���ɱ�����SQL����ϵͳ�������ٿ��ȴ��¼��������Ѿ���ʧ�ˣ�ϵͳ������
##ԭʼSQL��
UPDATE SZ12366.YWCL_CASE_cz
   SET CASESFGL = '1'
 WHERE CASEDJRQ >= ADD_MONTHS(SYSDATE, -3)
   AND CASEDJRQ <= SYSDATE
   AND CASESFGL IS NULL
   AND (CASEBH IN (SELECT CASEBH
                     FROM SZ12366.TX_RECORDLOG
                    WHERE BEGRECTIME >= ADD_MONTHS(SYSDATE, -3)
                      AND BEGRECTIME <= SYSDATE
                    GROUP BY CASEBH
                   HAVING COUNT(1) > 1) OR
       CASEBH IN
       (SELECT GLCASEBHA
           FROM SZ12366.YWCL_BHGL
          WHERE SUBSTR(GLGLSJ, 0, 7) >=
                TO_CHAR(ADD_MONTHS(SYSDATE, -3), 'yyyy-mm')
            AND SUBSTR(GLGLSJ, 0, 10) <= TO_CHAR(SYSDATE, 'yyyy-mm-dd')) OR
       CASEBH IN
       (SELECT GLCASEBHB
           FROM SZ12366.YWCL_BHGL
          WHERE SUBSTR(GLGLSJ, 0, 7) >=
                TO_CHAR(ADD_MONTHS(SYSDATE, -3), 'yyyy-mm')
            AND SUBSTR(GLGLSJ, 0, 10) <= TO_CHAR(SYSDATE, 'yyyy-mm-dd')));


##��дSQL��
UPDATE SZ12366.YWCL_CASE_cz
   SET CASESFGL = '1'
 WHERE CASEDJRQ >= ADD_MONTHS(SYSDATE, -3)
   AND CASEDJRQ <= SYSDATE
   AND CASESFGL IS NULL
   AND CASEBH in
       (SELECT CASEBH
          FROM SZ12366.TX_RECORDLOG
         WHERE BEGRECTIME >= ADD_MONTHS(SYSDATE, -3)
           AND BEGRECTIME <= SYSDATE
         GROUP BY CASEBH
        HAVING COUNT(1) > 1
        union all
        SELECT GLCASEBHA as CASEBH
          FROM SZ12366.YWCL_BHGL
         WHERE SUBSTR(GLGLSJ, 0, 7) >=
               TO_CHAR(ADD_MONTHS(SYSDATE, -3), 'yyyy-mm')
           AND SUBSTR(GLGLSJ, 0, 10) <= TO_CHAR(SYSDATE, 'yyyy-mm-dd')
        union all
        SELECT GLCASEBHB as CASEBH
          FROM SZ12366.YWCL_BHGL
         WHERE SUBSTR(GLGLSJ, 0, 7) >=
               TO_CHAR(ADD_MONTHS(SYSDATE, -3), 'yyyy-mm')
           AND SUBSTR(GLGLSJ, 0, 10) <= TO_CHAR(SYSDATE, 'yyyy-mm-dd'));