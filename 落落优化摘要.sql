�������䣺692162374@qq.com
--�����Ӳ�ѯ
����select��������һ��select�Ӿ�
1����򵥵ı����Ӳ�ѯ
table :a(a1,a2),b(a1,b2)
select a2,(select b2 from b where b.a1 = a.a1) from a
2���Ӳ�ѯ���ܷ��ض��е��޶��Ӳ�ѯ
table :a(a1,a2),b(a1,b2)
select a2,(select b2 from b where b.a1 = a.a1 and rownum = 1) from a
3���Ӳ�ѯ���оۼ�����
table :a(a1,a2),b(a1,b2)
select a2,(select sum(b2) from b where b.a1 = a.a1) from a
4��һ����ѯ����ͬʱ�кü��������Ӳ�ѯ��ÿ�������Ӳ�ѯ�Ĺ����������������ܶ�����ͬ
table :a(a1,a2),b(a1,b2),c(a1,b2,c2)
select a2,(select c2 from b,c where b.a1 = a.a1 and b.b2=c.b2 and rownum = 1),(select b2 from b where b.a1 = a.a1 and rownum = 1), (select c2 from c where c.a1 = a.a1 and rownum = 1) from a
select a2,(select sum(c2) from b,c where b.a1 = a.a1 and b.b2=c.b2),(select sum(b2) from b where b.a1 = a.a1), (select sum(c2) from c where c.a1 = a.a1) from a

--��д���
1��select a2,b2  from a,b where a.a1=b.a1(+);

2��select a2,bb.b2 
from a,(select b2,a1,ROW_NUMBER() OVER (PARTITION BY b.a1 order by null) rn from b where b.rn = 1) bb 
where a.a1 = bb.a1(+)

3��select  a.a2,bb.sum_b2
from a,(select a1,sum(b2) sum_b2 from b group by a1) bb
where a.a1=bb.a1(+);

4.1��SELECT a.a1,bb.b2,cc.c2,cc1.c2
FROM a,(SELECT max(b2) b2,a1 FROM b GROUP BY a1) bb,
(SELECT max(c2) c2,a1 FROM c GROUP BY a1) cc,
(SELECT max(c2) c2,a1 FROM c  WHERE EXISTS(SELECT 1 FROM b WHERE b.b2=c.b2) GROUP BY a1) cc1
WHERE a.a1=bb.a1(+) AND a.a1=cc.a1(+) AND a.a1=cc1.a1(+);

4.2��SELECT a.a1,bb.b2,cc.c2,cc1.c2
FROM a,(SELECT sum(b2) b2,a1 FROM b GROUP BY a1) bb,
(SELECT sum(c2) c2,a1 FROM c GROUP BY a1) cc,
(SELECT sum(c2) c2,a1 FROM c  WHERE EXISTS(SELECT 1 FROM b WHERE b.b2=c.b2) GROUP BY a1) cc1
WHERE a.a1=bb.a1(+) AND a.a1=cc.a1(+) AND a.a1=cc1.a1(+);


--������ͼ 
������ͼ������from����д��һ��select��ѯ��䣬��Ϊselect��ѯ������һ�����ϣ�Ҳ���൱��һ�ű������ͼ��
��������from���汻����һ���������ͼ�ã����Խ���������ͼ
--�Ӳ�ѯ
where SID IN��select SID from emp��   
�Ӳ�ѯչ�� unnest      ��չ��   /*+ no_unnest*/ ,��ʱ����չ��������ִ���ٶȸ���

--û�н��������������·����ü�����ɸ���϶������
sELECT   /*+INDEX(TMS,IDX1_TB_EVT_DLV_W)*/
TMS.MAIL_NUM,
		TMS.DLV_BUREAU_ORG_CODE AS DLVORGCODE,
		RO.ORG_SNAME AS DLVORGNAME,
		TMS.DLV_PSEG_CODE AS DLVSECTIONCODE,
		TMS.DLV_PSEG_NAME AS DLVSECTIONNAME,
		TO_CHAR(TMS.DLV_DATE,'YYYY-MM-DD HH24:MI:SS') AS RECTIME,
		TMS.DLV_STAFF_CODE AS HANDOVERUSERCODE,
		TU2.REALNAME AS  HANDOVERUSERNAME,
		DECODE( TMS.DLV_STS_CODE ,'I','��Ͷ','H','δ��Ͷ', TMS.DLV_STS_CODE) AS  DLV_STS_CODE,
     CASE WHEN  TMS.MAIL_NUM LIKE 'EC%' THEN '����'
            WHEN TMS.MAIL_NUM LIKE 'ED%CW' THEN '����'
            WHEN  TMS.MAIL_NUM LIKE 'FJ%' THEN '����'
            WHEN  TMS.MAIL_NUM LIKE 'GC%' THEN '����'
               ELSE
                           '�Ǵ���'
                        END MAIL_NUM_TYPE 
		FROM TB_EVT_DLV_W TMS
		LEFT JOIN RES_ORG RO ON TMS.DLV_BUREAU_ORG_CODE=RO.ORG_CODE
    LEFT JOIN TB_USER TU2 ON TU2.DELVORGCODE=TMS.DLV_BUREAU_ORG_CODE AND TU2.USERNAME=TMS.DLV_STAFF_CODE
		WHERE NOT EXISTS (SELECT  /*+INDEX(TDW,IDX1_TB_MAIL_SECTION_STORE)*/ MAIL_NUM FROM TB_MAIL_SECTION_STORE TDW WHERE
			 	 TDW.MAIL_NUM = TMS.MAIL_NUM
              AND TDW.DLVORGCODE = TMS.DLV_BUREAU_ORG_CODE
              and  TDW.DLVORGCODE='35000133'
                AND TDW.RECTIME >= TO_DATE('2012-11-01 00:00','YYYY-MM-DD HH24:MI:SS')
                AND TO_DATE('2012-11-08 15:15','YYYY-MM-DD HH24:MI:SS') >= TDW.RECTIME  and rownum=1   )
                AND 
               TMS.DLV_BUREAU_ORG_CODE = '35000133'
                AND TMS.DLV_DATE >=     TO_DATE('2012-11-01 00:00','YYYY-MM-DD HH24:MI:SS')
                AND TO_DATE('2012-11-08 15:15','YYYY-MM-DD HH24:MI:SS') >= TMS.DLV_DATE
                AND ('' IS NULL OR TMS.DLV_STAFF_CODE ='')
                AND ('' IS NULL OR TU2.REALNAME  LIKE '%%')
                AND TMS.REC_AVAIL_FLAG = '1' 



----------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                 | Name                       | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
----------------------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                          |                            |       |       |   322K(100)|          |       |       |
|*  1 |  FILTER                                   |                            |       |       |            |          |       |       |
|   2 |   NESTED LOOPS OUTER                      |                            |   131 | 13493 |   928   (1)| 00:00:12 |       |       |
|*  3 |    HASH JOIN RIGHT OUTER                  |                            |   129 | 10191 |   670   (1)| 00:00:09 |       |       |
|*  4 |     TABLE ACCESS BY INDEX ROWID           | EMS_USER                   |     6 |   120 |     8   (0)| 00:00:01 |       |       |
|*  5 |      INDEX RANGE SCAN                     | EMS_USER_NEW_INX_ORG       |     7 |       |     3   (0)| 00:00:01 |       |       |
|*  6 |     TABLE ACCESS BY GLOBAL INDEX ROWID    | TB_EVT_DLV_W               |   129 |  7611 |   661   (0)| 00:00:08 | ROWID | ROWID |
|*  7 |      INDEX RANGE SCAN                     | IDX1_TB_EVT_DLV_W          |   586 |       |    86   (0)| 00:00:02 |       |       |
|*  8 |       COUNT STOPKEY                       |                            |       |       |            |          |       |       |
|*  9 |        FILTER                             |                            |       |       |            |          |       |       |
|  10 |         PARTITION RANGE ITERATOR          |                            |     1 |    31 |   246   (0)| 00:00:03 |   KEY |   KEY |
|* 11 |          TABLE ACCESS BY LOCAL INDEX ROWID| TB_MAIL_SECTION_STORE      |     1 |    31 |   246   (0)| 00:00:03 |   KEY |   KEY |
|* 12 |           INDEX RANGE SCAN                | IDX1_TB_MAIL_SECTION_STORE |     1 |       |   245   (0)| 00:00:03 |   KEY |   KEY |
|  13 |    TABLE ACCESS BY INDEX ROWID            | RES_ORG                    |     1 |    24 |     2   (0)| 00:00:01 |       |       |
|* 14 |     INDEX RANGE SCAN                      | IDX_RES_ORG                |     1 |       |     1   (0)| 00:00:01 |       |       |
----------------------------------------------------------------------------------------------------------------------------------------

  1 - filter(TO_DATE('2012-11-01 00:00','YYYY-MM-DD HH24:MI:SS')<=TO_DATE('2012-11-08 15:15','YYYY-MM-DD HH24:MI:SS'))
   3 - access("EU"."USERNAME"="TMS"."DLV_STAFF_CODE" AND "EU"."DELVORGCODE"="TMS"."DLV_BUREAU_ORG_CODE")
   4 - filter("EU"."POSTMANKIND"<>5)
   5 - access("EU"."DELVORGCODE"='35000133')
   6 - filter(("TMS"."DLV_DATE">=TO_DATE('2012-11-01 00:00','YYYY-MM-DD HH24:MI:SS') AND "TMS"."REC_AVAIL_FLAG"='1' AND 
              "TMS"."DLV_DATE"<=TO_DATE('2012-11-08 15:15','YYYY-MM-DD HH24:MI:SS')))
   7 - access("TMS"."DLV_BUREAU_ORG_CODE"='35000133')
       filter( IS NULL)
   8 - filter(ROWNUM=1)
   9 - filter((TO_DATE('2012-11-01 00:00','YYYY-MM-DD HH24:MI:SS')<=TO_DATE('2012-11-08 15:15','YYYY-MM-DD HH24:MI:SS') AND 
              :B1='35000133'))
  11 - filter(("TDW"."RECTIME">=TO_DATE('2012-11-01 00:00','YYYY-MM-DD HH24:MI:SS') AND "TDW"."RECTIME"<=TO_DATE('2012-11-08 
              15:15','YYYY-MM-DD HH24:MI:SS')))
  12 - access("TDW"."DLVORGCODE"=:B1 AND "TDW"."MAIL_NUM"=:B2)
  14 - access("TMS"."DLV_BUREAU_ORG_CODE"="RO"."ORG_CODE")
  

===============================================================================
����(2016/04/14)���ݿ�汾11.2.0.4 ����һ�����ⰸ������Ȼ֮ǰҲ�������ǳ������ⰸ����
�������ڵ�ʱ�������޷��ռ�������˭�������̵����У�֤ȯ�����Ų�����й�ܰ������ý���������������ó�������

�����������ģ��������SQLҪ�ܼ�ʮ����

select count(distinct a.user_name), count(distinct a.invest_id)
  from base_data_login_info@agent a
 where a.str_day <= '20160304'
   and a.str_day >= '20160301'
   and a.channel_id in (select channel_rlat
                          from tb_user_channel a, tb_channel_info b
                         where a.channel_id = b.channel_id
                           and a.user_id = 5002)
   and a.platform = a.platform;
 

Plan hash value: 2367445948
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation            | Name                 | Rows  | Bytes | Cost (%CPU)| Time     | Inst   |IN-OUT|
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |                      |     1 |   130 |   754   (2)| 00:00:10 |        |      |
|   1 |  SORT GROUP BY       |                      |     1 |   130 |            |          |        |      |
|*  2 |   HASH JOIN          |                      |  4067K|   504M|   754   (2)| 00:00:10 |        |      |
|*  3 |    HASH JOIN         |                      | 11535 |   360K|   258   (1)| 00:00:04 |        |      |
|*  4 |     TABLE ACCESS FULL| TB_USER_CHANNEL      | 11535 |   157K|    19   (0)| 00:00:01 |        |      |
|   5 |     TABLE ACCESS FULL| TB_CHANNEL_INFO      | 11767 |   206K|   238   (0)| 00:00:03 |        |      |
|   6 |    REMOTE            | BASE_DATA_LOGIN_INFO |   190K|    17M|   486   (1)| 00:00:06 |  AGENT | R->S |
-------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("A"."CHANNEL_ID"="CHANNEL_RLAT")
   3 - access("A"."CHANNEL_ID"="B"."CHANNEL_ID")
   4 - filter("A"."USER_ID"=5002)
 
Remote SQL Information (identified by operation id):
----------------------------------------------------
 
   6 - SELECT "USER_NAME","INVEST_ID","STR_DAY","CHANNEL_ID","PLATFORM" FROM "BASE_DATA_LOGIN_INFO" 
       "A" WHERE "STR_DAY"<='20160304' AND "STR_DAY">='20160301' AND "PLATFORM" IS NOT NULL (accessing 
       'AGENT' ) 

������һ��ִ�мƻ�������һ��ִ�мƻ���������Ȼ��Ͻ�����dblink�ı��ж�� in ���� a, b �ֱ��ж��
tb_user_channel  1W
tb_channel_info  1W
base_data_login_info 19W ����ʣ��4w

��Щ���������һ����19w�У���ôҲ�������ܼ�ʮ���Ӱ���Ȼ���ҿ�ʼ�����ǲ���dblink�ı�������������⡣
Ϊ���ų�dblink�ı�����������⣬���ø����ڱ��ش���һ��һģһ���ı�������������ٶȸ���û��һ����ı䡣


�������ø������������SQL

select count(*)
  from base_data_login_info@agent a
 where a.str_day <= '20160304'
   and a.str_day >= '20160301'
   and a.channel_id in (select channel_rlat
                          from tb_user_channel a, tb_channel_info b
                         where a.channel_id = b.channel_id
                           and a.user_id = 5002)
   and a.platform = a.platform;

��ɱ��û��������ɱ ��ү�� ����ˣ���SQL��Ȼ��ɱ�ˡ� Ȼ�������ø������������SQL 

select count(a.user_name)
  from base_data_login_info@agent a
 where a.str_day <= '20160304'
   and a.str_day >= '20160301'
   and a.channel_id in (select channel_rlat
                          from tb_user_channel a, tb_channel_info b
                         where a.channel_id = b.channel_id
                           and a.user_id = 5002)
   and a.platform = a.platform;

��ɱ���������ø���������SQL

select count(a.user_name), count(a.invest_id)
  from base_data_login_info@agent a
 where a.str_day <= '20160304'
   and a.str_day >= '20160301'
   and a.channel_id in (select channel_rlat
                          from tb_user_channel a, tb_channel_info b
                         where a.channel_id = b.channel_id
                           and a.user_id = 5002)
   and a.platform = a.platform;

��ɱ�����ү�ģ�����һ���������SQL

select count(distinct a.user_name), count(a.invest_id)
  from base_data_login_info@agent a
 where a.str_day <= '20160304'
   and a.str_day >= '20160301'
   and a.channel_id in (select channel_rlat
                          from tb_user_channel a, tb_channel_info b
                         where a.channel_id = b.channel_id
                           and a.user_id = 5002)
   and a.platform = a.platform;

����ɱ�ˣ��Բۣ��Ҹо�Ů���������ǰ�ˣ����ټ�һ��distinct�������ܲ�����ɱ

select count(distinct a.user_name), count(distinct a.invest_id)
  from base_data_login_info@agent a
 where a.str_day <= '20160304'
   and a.str_day >= '20160301'
   and a.channel_id in (select channel_rlat
                          from tb_user_channel a, tb_channel_info b
                         where a.channel_id = b.channel_id
                           and a.user_id = 5002)
   and a.platform = a.platform;

������ˣ�SQL�ܲ����ˣ�̫���������ˣ������µ��ֵ��ǣ����Ǿ����ǲ��Ǻ����⡣˵����ô�࣬�������������������ô����أ�

����Ҫ������Ⱑ�����������SQL�ܵ������㲻�����⣬�Ǹ�Ҳ���û��ˣ���ɭҲ���ÿ��ˣ����յ��ˡ�

��������ҳ��������⣬��ֹ��һ������ͬ�����⣬˳��Ҳ�����ѿ�����д�İ�������λ���Ѿ͵���ɫС˵�������ˡ�


�������������⣬�����ֵ��������SQL

with t1 as 
(select /*+ materialize */
 a.user_name, a.invest_id
         from base_data_login_info@agent a
         where a.str_day <= '20160304' and a.str_day >= '20160301'
 and a.channel_id in (select channel_rlat from tb_user_channel a, tb_channel_info b where a.channel_id = b.channel_id and a.user_id = 5002)
 and a.platform = a.platform)
select count(distinct user_name) ,count(distinct invest_id) from t1;

Plan hash value: 901326807
 
-----------------------------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name                     | Rows  | Bytes | Cost (%CPU)| Time     | Inst   |IN-OUT|
-----------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |                          |     1 |    54 |  1621   (1)| 00:00:20 |        |      |
|   1 |  TEMP TABLE TRANSFORMATION |                          |       |       |            |          |        |      |
|   2 |   LOAD AS SELECT           | SYS_TEMP_0FD9D6720_EB8EA |       |       |            |          |        |      |
|*  3 |    HASH JOIN RIGHT SEMI    |                          |   190K|    22M|   744   (1)| 00:00:09 |        |      |
|   4 |     VIEW                   | VW_NSO_1                 | 11535 |   304K|   258   (1)| 00:00:04 |        |      |
|*  5 |      HASH JOIN             |                          | 11535 |   360K|   258   (1)| 00:00:04 |        |      |
|*  6 |       TABLE ACCESS FULL    | TB_USER_CHANNEL          | 11535 |   157K|    19   (0)| 00:00:01 |        |      |
|   7 |       TABLE ACCESS FULL    | TB_CHANNEL_INFO          | 11767 |   206K|   238   (0)| 00:00:03 |        |      |
|   8 |     REMOTE                 | BASE_DATA_LOGIN_INFO     |   190K|    17M|   486   (1)| 00:00:06 |  AGENT | R->S |
|   9 |   SORT GROUP BY            |                          |     1 |    54 |            |          |        |      |
|  10 |    VIEW                    |                          |   190K|     9M|   878   (1)| 00:00:11 |        |      |
|  11 |     TABLE ACCESS FULL      | SYS_TEMP_0FD9D6720_EB8EA |   190K|     9M|   878   (1)| 00:00:11 |        |      |
-----------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("A"."CHANNEL_ID"="CHANNEL_RLAT")
   5 - access("A"."CHANNEL_ID"="B"."CHANNEL_ID")
   6 - filter("A"."USER_ID"=5002)
 
Remote SQL Information (identified by operation id):
----------------------------------------------------
 
   8 - SELECT "USER_NAME","INVEST_ID","STR_DAY","CHANNEL_ID","PLATFORM" FROM "BASE_DATA_LOGIN_INFO" "A" WHERE 
       "STR_DAY"<='20160304' AND "STR_DAY">='20160301' AND "PLATFORM" IS NOT NULL (accessing 'AGENT' )
 
SQL��ɱ�ˡ� with as /*+ materialize */  ������� ��ɭ���˶�֪����

�����㿴�Ҳ���ȥ��(�ٶ� csdn �����ר��)���ҹ��ƹ����˶������ ���ݿ�Ȧ����ȫ��֪���ˡ�

�������⣬�ǲ��а��������ҳ��������ԭ�򰡣������ź�װ��װ����װ��ʦ�

���ȴ�ִ�мƻ��Ϸ���

�ܵÿ��SQL�Լ�ִ�мƻ� 

select count(a.user_name), count(distinct a.invest_id)
  from base_data_login_info@agent a
 where a.str_day <= '20160304'
   and a.str_day >= '20160301'
   and a.channel_id in (select channel_rlat
                          from tb_user_channel a, tb_channel_info b
                         where a.channel_id = b.channel_id
                           and a.user_id = 5002)
   and a.platform = a.platform


Plan hash value: 4282421321
 
------------------------------------------------------------------------------------------------------------------------
| Id  | Operation               | Name                 | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     | Inst   |IN-OUT|
------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |                      |     1 |    40 |       |  2982   (1)| 00:00:36 |        |      |
|   1 |  SORT AGGREGATE         |                      |     1 |    40 |       |            |          |        |      |
|   2 |   VIEW                  | VW_DAG_0             | 41456 |  1619K|       |  2982   (1)| 00:00:36 |        |      |
|   3 |    HASH GROUP BY        |                      | 41456 |  4250K|    20M|  2982   (1)| 00:00:36 |        |      |
|*  4 |     HASH JOIN RIGHT SEMI|                      |   190K|    19M|       |   744   (1)| 00:00:09 |        |      |
|   5 |      VIEW               | VW_NSO_1             | 11535 | 80745 |       |   258   (1)| 00:00:04 |        |      |
|*  6 |       HASH JOIN         |                      | 11535 |   360K|       |   258   (1)| 00:00:04 |        |      |
|*  7 |        TABLE ACCESS FULL| TB_USER_CHANNEL      | 11535 |   157K|       |    19   (0)| 00:00:01 |        |      |
|   8 |        TABLE ACCESS FULL| TB_CHANNEL_INFO      | 11767 |   206K|       |   238   (0)| 00:00:03 |        |      |
|   9 |      REMOTE             | BASE_DATA_LOGIN_INFO |   190K|    17M|       |   486   (1)| 00:00:06 |  AGENT | R->S |
------------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("A"."CHANNEL_ID"="CHANNEL_RLAT")
   6 - access("A"."CHANNEL_ID"="B"."CHANNEL_ID")
   7 - filter("A"."USER_ID"=5002)
 
Remote SQL Information (identified by operation id):
----------------------------------------------------
 
   9 - SELECT "USER_NAME","INVEST_ID","STR_DAY","CHANNEL_ID","PLATFORM" FROM "BASE_DATA_LOGIN_INFO" "A" WHERE 
       "STR_DAY"<='20160304' AND "STR_DAY">='20160301' AND "PLATFORM" IS NOT NULL (accessing 'AGENT' )
 
�ܵ�����SQL�Լ�ִ�мƻ�


select count(distinct a.user_name), count(distinct a.invest_id)
  from base_data_login_info@agent a
 where a.str_day <= '20160304'
   and a.str_day >= '20160301'
   and a.channel_id in (select channel_rlat
                          from tb_user_channel a, tb_channel_info b
                         where a.channel_id = b.channel_id
                           and a.user_id = 5002)
   and a.platform = a.platform
 

Plan hash value: 2367445948
 
-------------------------------------------------------------------------------------------------------------
| Id  | Operation            | Name                 | Rows  | Bytes | Cost (%CPU)| Time     | Inst   |IN-OUT|
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |                      |     1 |   130 |   754   (2)| 00:00:10 |        |      |
|   1 |  SORT GROUP BY       |                      |     1 |   130 |            |          |        |      |
|*  2 |   HASH JOIN          |                      |  4067K|   504M|   754   (2)| 00:00:10 |        |      |
|*  3 |    HASH JOIN         |                      | 11535 |   360K|   258   (1)| 00:00:04 |        |      |
|*  4 |     TABLE ACCESS FULL| TB_USER_CHANNEL      | 11535 |   157K|    19   (0)| 00:00:01 |        |      |
|   5 |     TABLE ACCESS FULL| TB_CHANNEL_INFO      | 11767 |   206K|   238   (0)| 00:00:03 |        |      |
|   6 |    REMOTE            | BASE_DATA_LOGIN_INFO |   190K|    17M|   486   (1)| 00:00:06 |  AGENT | R->S |
-------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("A"."CHANNEL_ID"="CHANNEL_RLAT")
   3 - access("A"."CHANNEL_ID"="B"."CHANNEL_ID")
   4 - filter("A"."USER_ID"=5002)
 
Remote SQL Information (identified by operation id):
----------------------------------------------------
 
   6 - SELECT "USER_NAME","INVEST_ID","STR_DAY","CHANNEL_ID","PLATFORM" FROM "BASE_DATA_LOGIN_INFO" 
       "A" WHERE "STR_DAY"<='20160304' AND "STR_DAY">='20160301' AND "PLATFORM" IS NOT NULL (accessing 
       'AGENT' )       

���û���Ż�����ǧ�����SQL���������������۽𾦣�ע�⿴�ܵ�����SQL��HASH JOIN���ܵÿ��SQL�� HASH JOIN RIGHT SEMI

Ҳ����˵�ܵ�����SQL�� HASH JOIN(inner join)���ܵÿ�� SQL �� HASH SEMI JOIN (semi join) 

˵�˻������ܵ�����SQL����������ˣ��ܵÿ��SQL�ǰ�����(in/exists)��

����SQL�ǰ����Ӱ���զ������������أ����漰���Ż����ڲ�ԭ��ʹ�ѧ�γ�����Ĺ�ϵ����������Ͳ�װ���ˣ���õ�ʱ��һ���������������ҷ����ˡ�

���������ˣ��ͼ����ʮ����Ľ���HASH JOIN Ӧ�úܿ찡������ܵ�����ֻ��һ�����ͣ�2����Ĺ��������ݷֲ����ǳ������� 

19W ��������

SQL> select channel_id,count(*) from base_data_login_info group by channel_id order by 2;

CHANNEL_ID               COUNT(*)
-------------------------------------------------- ----------
011a1                 2
003a1                 3
021a1                 3
006a1                12
024h2                16
013a1                19
007a1                24
012a1                25
005a1                27
EPT01                36
028h2               109
008a1               139
029a1               841
009a1               921
014a1              1583
000a1              1975
a0001              2724
004a1              5482
001a1             16329
026h2             160162

in����Ĺ��������ݷֲ�

select channel_rlat, count(*)
  from tb_user_channel a, tb_channel_info b
 where a.channel_id = b.channel_id
   and a.user_id = 5002
 group by channel_rlat
 order by 2 desc

channel_rlat  count(*)
026h2         10984
024h2         7
002h2         6
023a2         2
007s001022001 1
007s001022002 1
007s001024007 1
007s001024009 1
007s001022009 1
001s001006    1
001s001008    1
001s001001001 1
001s001001003 1
001s001001007 1
001s001001014 1
007s001018003 1
007s001018007 1
007s001019005 1
007s001019008 1
001s001002011 1
007s001011003 1
007s001034    1
007s001023005 1

��Ȼ���������������ϣ��������������ӵ� HASH JOIN �����˲Ź� 
026h2             160162 �� 026h2         10984 ���й�����ȫ����һ���ѿ�����

10046 trace �ļ��Ѿ� �����˴� HASH JOIN ���� 410996039  �����������һ��С�͵ѿ�������  

Rows (1st) Rows (avg) Rows (max)  Row Source Operation
---------- ---------- ----------  ---------------------------------------------------
         1          1          1  SORT GROUP BY (cr=3643 pr=0 pw=0 time=1236559678 us)
 410996039  410996039  410996039   HASH JOIN  (cr=3643 pr=0 pw=0 time=406365130 us cost=1006 size=66968010 card=458685)
     11535      11535      11535    HASH JOIN  (cr=945 pr=0 pw=0 time=199182 us cost=258 size=369120 card=11535)
     11535      11535      11535     TABLE ACCESS FULL TB_USER_CHANNEL (cr=67 pr=0 pw=0 time=21452 us cost=19 size=161490 card=11535)
     11771      11771      11771     TABLE ACCESS FULL TB_CHANNEL_INFO (cr=878 pr=0 pw=0 time=30291 us cost=238 size=211806 card=11767)
     45122      45122      45122    TABLE ACCESS FULL BASE_DATA_LOGIN_INFO (cr=2698 pr=0 pw=0 time=218144 us cost=747 size=2447922 card=21473)

���������˿�������ʵ��

create table a as select * from dba_objects;

create table b as select * from dba_objects;

Ȼ����ȥ�������SQL�������Ƚ����

select count(distinct owner), count(distinct object_name)
  from a
 where owner in (select owner from b);

Ȼ������������ЩSQL��������ɱ

select count(owner), count(distinct object_name)
  from a
 where owner in (select owner from b);

select count(distinct owner), count(distinct object_name)
  from a
 where object_id in (select object_id from b);

��ô��ô���ܵ�����SQL���еȼ۸�д�أ�

select count(distinct owner), count(distinct object_name)
  from a
 where owner in (select owner from b);

�����£�

select count(distinct owner), count(distinct object_name)
  from (select owner, object_name
          from a
         where owner in (select owner from b)
           and rownum > 0);
           ˼��Ϊɶ11g CBO�� ��дΪ inner join �أ� select xxx from 1�ı�  where owner in (select owner from n �ı�) ��дΪ inner join ǰ�治��Ҫ�� distinctselect xxx from n�ı�  where owner in (select owner from 1�ı�) ��дΪ inner join ǰ��Ҫ�� distinct ���ǵ�SQL �� select count(distinct ),count(distinct) ���� CBO ֱ�Ӹ�дΪ select count(dist
           inct a.owner),count(distinct object_name) from a,b where a.owner=b.owner;
           
============================================================================
�����������������
20����20�ڱ�����Ż�����(��������볬�����join�Ż�����) .
��ǩ�� �Ż�ORACLE��������SQL���� 2016-02-27 21:57 6928���Ķ� ����(21) �ղ� �ٱ� .����������¼�ڣ� 
 ���ࣺ SQL TUNING��67��   
����ͬ������X.��Ȩ����������Ϊ����ԭ�����£�δ������������ת�ء�
�ǵ�5��ǰ����һ��SQL������һ���򵥵����������SQL���˲��һ��һҹ�����������ǳ��޴�ÿ�����м�ʮ��G��������ÿ������20���ڣ�����ֶ�Ҳ�ر�ࡣ

���Ŵ��Ҳ֪��SQL���������ˣ��������̵�PGA �Ǿ��ԷŲ��¼�ʮ��G�����ݣ���ͻᵼ�����Ĵ���temp tablespace��SQL����������temp������������...�Ķ�д���ݡ�  

�������ֳ�������볬�������ô�Ż��أ���ƪ���½�������𰸡�




���ȴ���2�����Ա� t1,t2 ��������dba_objects

create table t1 as select * from dba_objects;

create table t2 as select * from dba_objects;

���Ǽ��� t1 �� t2 ���� ����������� Ҫ���е� SQL��   select * from t1,t2 where t1.object_id=t2.object_id;

����t1 t2 ���Ǽ�ʮ��GB ���߸��� ��ô�㶮�ģ������SQL���������ܲ�������ġ� 

��Щ�����룬�������в��͵��ˣ��ò��� hash hash �㷨��SQL����ʵ�ǲ����Եģ�ԭ�򲻶�˵�ˡ�

���ǿ�������MPP���ݿ�ܹ�(Greenplum/Teradata/vertica)˼�룬����������HADOOP��˼�����������SQL�����Ż���

 MPP�ܹ�/HADOOP�ܹ��ĺ���Ҫ��˼����ǰ������и�Ѵ�������и�Ϊ�ܶ��С�����ݣ�Ȼ���ٶ�С�Ľ��й��������ٶ���Ȼ�Ϳ��ˡ�




��Oracle������ô�Ѵ������г�С�����أ��������취��һ���Ƿ���������һ���Ƿֱ�������ѡ����Ƿ�������Ȼ�˿�����ƪ������Ҳ���Էֱ�

����һ����P1����T1�ı�ṹ�����϶��һ���ֶ�HASH_VALUE�����Ҹ���HASH_VALUE����LIST����


CREATE TABLE P1(
HASH_VALUE NUMBER,
OWNER VARCHAR2(30),
OBJECT_NAME VARCHAR2(128),
SUBOBJECT_NAME VARCHAR2(30), 
OBJECT_ID NUMBER,
DATA_OBJECT_ID NUMBER,
OBJECT_TYPE VARCHAR2(19),
CREATED DATE,
LAST_DDL_TIME DATE,
TIMESTAMP VARCHAR2(19),
STATUS VARCHAR2(7),
TEMPORARY VARCHAR2(1),
GENERATED VARCHAR2(1),
SECONDARY VARCHAR2(1),
NAMESPACE NUMBER,
EDITION_NAME VARCHAR2(30)
)   
   PARTITION BY  list(HASH_VALUE)
(
partition p0 values (0),
partition p1 values (1),
partition p2 values (2),
partition p3 values (3),
partition p4 values (4)
)




ͬ���ģ���T2�ı�ṹ�����϶��һ���ֶ�HASH_VALUE�����Ҹ���HASH_VALUE����LIST����

CREATE TABLE P2(
HASH_VALUE NUMBER,
OWNER VARCHAR2(30),
OBJECT_NAME VARCHAR2(128),
SUBOBJECT_NAME VARCHAR2(30), 
OBJECT_ID NUMBER,
DATA_OBJECT_ID NUMBER,
OBJECT_TYPE VARCHAR2(19),
CREATED DATE,
LAST_DDL_TIME DATE,
TIMESTAMP VARCHAR2(19),
STATUS VARCHAR2(7),
TEMPORARY VARCHAR2(1),
GENERATED VARCHAR2(1),
SECONDARY VARCHAR2(1),
NAMESPACE NUMBER,
EDITION_NAME VARCHAR2(30)
)   
   PARTITION BY  list(HASH_VALUE)
(
partition p0 values (0),
partition p1 values (1),
partition p2 values (2),
partition p3 values (3),
partition p4 values (4)
)

ע�⣺P1��P2��ķ�������һģһ�� 




delete t1 where object_id is null;

commit;

delete t1 where object_id is null;

commit;

insert into p1
select ora_hash(object_id,4), a.*  from t1 a;  ---��������append parallel���в���

commit;

insert into p2
select ora_hash(object_id,4), a.*  from t2 a;  ---��������append parallel���в���

commit;




�����Ͱ� T1 �� T2�ı������ת�Ƶ� P1 �� P2 ������




��ô֮ǰ���е� select * from t1,t2 where t1.object_id=t2.object_id  ��ʵ�͵ȼ�������5��SQL��

select * from p1,p2 where p1.object_id=p2.object_id and p1.hash_value=0 and p2.hash_value=0;
select * from p1,p2 where p1.object_id=p2.object_id and p1.hash_value=1 and p2.hash_value=1;
select * from p1,p2 where p1.object_id=p2.object_id and p1.hash_value=2 and p2.hash_value=2;
select * from p1,p2 where p1.object_id=p2.object_id and p1.hash_value=3 and p2.hash_value=3;
select * from p1,p2 where p1.object_id=p2.object_id and p1.hash_value=4 and p2.hash_value=4;




�����У������Ϊ���ٸ����������Լ��жϡ�����һ����Ҫע��ľ���ORA_HASH����

oracle�е�hash�����������õ�ora_hash����

partition by hash(object_id) �ȼ��� ora_hash(object_id,4294967295)

ora_hash(��,hashͰ) hashͰĬ����4294967295 ��������0��4294967295

ora_hash(object_id,4) ���object_id��ֵ����hash���㣬Ȼ��ŵ� 0,1,2,3,4 ��ЩͰ���棬Ҳ����˵ ora_hash(object_id,4) ֻ����� 0 1 2 3 4 




����Ȥ��ͬѧ�����Լ�ȥ�����ٶȡ���������������Ż�������֮ǰ��Ҫ��һ��һҹ��SQL����1Сʱ����ɡ�

Ϊ�˼�㣬����ʹ��PLSQL��д�洢���̷�װ���������

��Ȼ�ˣ����ʹ��hadoop ���� greenplum ��������Ż���������Ͳ��������ˡ�

====================================================================
--�����е����Ͳ�һ��
create table t1(id number,name nvarchar2(200));
create table t2(id number,name varchar2(200));

insert into t1 select rownum,table_name from dba_tables;
insert into t2 select rownum,object_name from dba_objects;
commit;

 1 - filter(ROWNUM<=10)
 2 - access("T1"."NAME"=SYS_OP_C2C("T2"."NAME"))   --SYS_OP_C2C  
 
--�޸��е�����
alter table tt1 modify ( name varchar2(200))
�������ʱ�򣬻��Զ��ļ��� SYS_OP_C2C ��������ҪT2 join�����������ø�� �������� create index idx_t2 on t2(sys_op_c2c(name));

ע�⣺����Ƶ�ʱ�������2��������������� Ҫôȫ����NVARCHAR2��Ҫôȫ����VARCHAR2������һ��һ��

====================================================================================
--V$SESSION SQL_ID Ϊ�գ��Ҳ���SQL_ID 
�ֵܣ��ǲ�����������ѯ V$SESSION.SQL_ID ������ SQL_ID �ǿգ�Ȼ���Ҳ���SQL�����������̫��������������ˡ�

����������Ҳû�ٶ�/GOOGLE���õĽ���취������ͷ���һ���������̴��ץSQL(����������ORACLE11G��10G ��ϴϴ˯��)��

��������������ʵ�飺

SQL> select sid from v$mystat where rownum=1;
 
       SID
----------
      1150
 
SQL> update test set owner='BIGSB' where object_id<100;
 
98 rows updated

��1150���SESSION����ִ��һ��UPDATE����Ҫ�ύ��

SQL> select sid from v$mystat where rownum=1;
 
       SID
----------
      1338
 
SQL>  update test set owner='SB' where object_id<10;

��1338����������һ��UPDATE����Ϊ1150û�ύ��1138���������ȴ���

���ʱ��ͨ�����½ű�ȥ��ѯ���ݿ⣺


SQL> select inst_id,
  2         sid,
  3         sql_id,
  4         event,
  5         blocking_session,
  6         blocking_instance
  7    from gv$session a
  8   where blocking_session is not null;
 
   INST_ID        SID SQL_ID        EVENT                                   BLOCKING_SESSION BLOCKING_INSTANCE
---------- ---------- ------------- --------------------------------------- ---------------- ----------------
         1       1338 852mvmth18w37 enq: TX - row lock contention           1150                 1
         
SQL> select sql_id from gv$session where inst_id=1 and sid=1150;
 
SQL_ID
-------------





ȷʵ��SQL_ID�ǿյģ�Ҳ�����˻�˵������ȥ��ѯPREV_SQL_ID������ȥ��һ�԰ɣ��Ǹ�SQL_ID�������SQL_ID��������UPDATE��SQL_ID

SQL>  select prev_sql_id from gv$session where inst_id=1 and sid=1150;
 
PREV_SQL_ID
-------------
9m7787camwh4m
 
SQL> select sql_text from gv$sql where sql_id='9m7787camwh4m';
 
SQL_TEXT
--------------------------------------------------------------------------------
begin :id := sys.dbms_transaction.local_transaction_id; end;
���Ժܶ������ʱ��͵����ˣ���֪��զ�졣���ڽ̴������һ�ַ���


SQL> select PREV_EXEC_START,USERNAME,MODULE,ACTION FROM GV$SESSION WHERE INST_ID=1 AND SID=1150;
 
PREV_EXEC_START     USERNAME    MODULE               ACTION
---------------     ------------------------------ -----------------------
2015-04-10 18:01:44 SCOTT       PL/SQL Developer    Command Window - New

SQL> SELECT SQL_ID,SQL_TEXT,LAST_ACTIVE_TIME,MODULE,ACTION FROM GV$SQL WHERE INST_ID=1 AND LAST_ACTIVE_TIME=TO_DATE('2015-04-10 18:01:44','YYYY-MM-DD HH24:MI:SS');
 
SQL_ID        SQL_TEXT                                                                         LAST_ACTIVE_TIME MODULE              ACTION
------------- -------------------------------------------------------------------------------- ---------------- ---------------------------------------------------------------- ----------------------------------------------------------------
2syvqzbxp4k9z select u.name, o.name, a.interface_version#, o.obj#      from association$ a, us 2015/4/10 18:01:                                                                  
6c9wx6z8w9qpu select a.default_selectivity                             from association$ a     2015/4/10 18:01:                    
2xyb5d6xg9srh select a.default_cpu_cost, a.default_io_cost             from association$ a     2015/4/10 18:01:                                                                  
d1s917pgj7650  update test set owner='BIGSB' where object_id<100                               2015/4/10 18:01: PL/SQL Developer    Command Window - New
 




���ھͿ��԰�SQL ץ����

��ע�⣺

1.�ڸ߲���������£����ܻ���ֶ������SQL

2.UPDATEִ�й����ּ���ִ���µ�SQL���ͱ����ˣ����ʱ��Ҫ�Լ�������SQLץ����������ʱ��������CHECK




�������ṩ��һ��˼·�������ʱ�����Լ��жϣ��Դ���Ҫ̫����





select a.inst_id, a.sid, a.sql_id, b.sql_id, b.sql_text
  from gv$session a, gv$sql b
 where a.inst_id = b.inst_id
   and a.PREV_EXEC_START = b.LAST_ACTIVE_TIME
   and a.USERNAME = b.PARSING_SCHEMA_NAME
   and a.MODULE = b.MODULE
   --and a.ACTION_HASH = b.ACTION_HASH
   
   
select a.inst_id,
       a.sid,
       a.event,
       a.sql_id,
       b.sql_text          running_sql,
       c.sql_in_session,
       c.sql_id_in_v$sql,
       c.sql_text          blocking_sql,
       a.blocking_session,
       a.blocking_instance
  from gv$session a,
       (select sql_id, sql_text
          from (select sql_id,
                       sql_text,
                       row_number() over(partition by sql_id order by sql_id) as rn
                  from gv$sql)
         where rn = 1) b,
       (select a.inst_id,
               a.sid,
               a.sql_id   sql_in_session,
               b.sql_id   sql_id_in_v$sql,
               b.sql_text
          from gv$session a, gv$sql b
         where a.inst_id = b.inst_id
           and a.PREV_EXEC_START =b.LAST_ACTIVE_TIME
           and a.USERNAME = b.PARSING_SCHEMA_NAME
           and a.MODULE = b.MODULE
        ) c
 where a.sql_id = b.sql_id
   and a.blocking_session is not null
   and a.BLOCKING_SESSION = c.sid
   and a.BLOCKING_INSTANCE = c.inst_id;

--SQL ����淶 

1. ����Ա����������������������Щ��


���� select owner,object_id,name from a,b where a.id=b.id; 

������Ա�ȡ����������ô֪������ʵ������ĸ���ġ����SQL�����У����SQL������ܶ࣬ȥ���ɡ�



2. ���ݿ���� ����


��             ǰ׺/��׺ T_XXX

��ͼ         ǰ׺/��׺  V_XXX

�ﻯ��ͼ  ǰ׺/��׺ MV_XXX

����         IDX_����




����� 

���ݲֿ� ��ʵ��  _FACT 

���ݲֿ� ά�ȱ�  _DIM

ҵ���м��  _TMP

��־��      _LOG  


�������������淶�����㲻��Ϥҵ���DBA��������Ա���������


3. �Ͻ������Ӳ�ѯ(��ҳ����д)


select (select ... from a where a.id=b.id) from b;  ---���־ͽб����Ӳ�ѯ


���� b ����100w ��ô a���ܱ�ɨ�� 100w�� Ȼ���㶮�� ����

�����Ӳ�ѯ ȫ����дΪ select ... from a left join b .....

4. �Ͻ�sql���Զ��庯���������洢���̵���� �����Ӳ�ѯһ��


5. �Ͻ���ͼ��select����ROWNUM create or replace view ....select rownum Ӱ��ν������+��ͼ�ϲ�



6. �Ͻ���ͼ ������ order by����ִ�мƻ�



7. �Ͻ���ͼ���ó���2�� ����Ϊ���������ͼ���˿���Ӱ��������� ���ھ� �����


������������ͼ�����⣬��ô���������ͼ��SQLȫ�����⣬��д���붼������


8. in exists ��not in not exists ��дΪ with as (�Ӳ�ѯ)

�����˵����������

9. ��ҳ������ distinct, group by ,union /union all��order by ֻ��һ����

�������ɣ���˵Ϊɶ����


10. �������£���дΪmerge ���߸�дΪ���� rowid����



11. ��ֹ��join���ú��� ���� where trunc(ʱ��)=b.ʱ��

12.ע����ʽת��

13. ʡ��....�����ɵ�

==================================================================================
--�ȴ�ʱ���ѯ�з��ֵ�����
--��ѯ�쳣�ĵȴ�ʱ��
SELECT a.USERNAME,
       a.BLOCKING_INSTANCE,
       a.BLOCKING_INSTANCE ,
       a.PROGRAM,
       a.SID,
       a.SERIAL#,
       a.EVENT,
       a.p1,
       a.p2,
       a.p3,
       a.SQL_ID,
       a.SQL_CHILD_NUMBER ,
       b.SQL_TEXT
  FROM gv$session a, v$sql b
 WHERE a.SQL_ADDRESS = b.ADDRESS
   and a.SQL_HASH_VALUE = b.HASH_VALUE
   and a.SQL_CHILD_NUMBER = b.CHILD_NUMBER;


һ�����Ǹ��Ҵ�绰����˵ϵͳ��һֱ���ֵȴ��¼� read by other session �����Ҹõȴ�����ͬһ��sql����ģ��ȽϽ��������Ұ�æԶ�̿�����

Զ�̹�ȥ֮���ýű��� �ȴ��¼���ץ����

��ͼ�п��� read by other session ��������ͬһ��SQL , sql_id ��  1svyhsn0g56qd

���ǲ鿴ִ�мƻ�

��SQL�ߵ��� ILMCU ����е�����������������4���У�����ֻ����һ���е�������

�ȱ��ִ�мƻ���������һ�µȴ��¼� read by other session �����Ǳ���Щ������������Щ����������ʲôSQL

����֣� ����ͬһ��SQL�� Ȼ����ϸ����һ��ҵ��ԭ����ϵͳ��һ�� ɳ������ ERP ϵͳ��

ǰ̨���û����ĳ����ť�����˰���û��Ӧ��Ȼ���һֱ�㣬һֱ�� �͵������ SQL һֱ�ظ������У�

�����أ����SQL �ܲ�����������ԾͲ��������� read by other session

�����أ������Ż����SQL�Ϳ��Խ�������⣬�ܵ�SQL ���£�
[html] view plain copy
print?��CODE�ϲ鿴����Ƭ�������ҵĴ���Ƭ

    SELECT *  FROM PRODDTA.F4111 WHERE ((ILDCT = :1   AND ILFRTO = :2   AND ILMCU = :3   AND ILDOC = :4  )) ORDER BY ILUKID ASC  

�ߵ������� ILMCU ����е����������ȿ�һ�������һ���ж�����

һ����250w�У����������ʵ���󰡣���������ݲֿ⣬һ����û�м�ʮ�������ǻ��治�����������һ�� ILMCU ��������ݷֲ�

ͬ־����һ�� Ϊɶ��Ҫ�� full ���hint? ��Ϊ���� �� n ������ ���� �ղŵ� SQL�����Ҿ��� ILMCU ����е�����

 Ҫ�����ʱ���Ҳ��� full hint , ��һ������ ILMCU ����е� �������ǲ��ǻ��Ͻ�����

���� �����һ���� 250w�����ݣ���ȫ��Ҳûɶ�ģ������Ҳ�����Ҫ����������ݷֲ�����Ҫ������3���У��Ǳ�����ȫ����


���շ��� ILMCU ����зֲ� ̫���費�����ˣ� ����һ�� �Ǹ��ǣ����ڵ�ҵ���ǲ������� SF10 �����ش�˵�ǵ� ��

��250w����ȥѡ142w ,�������� �Բۣ��ǿ϶����������� ���϶����������� db file sequen read �ȴ� ��

˵���ˣ� ��ͳ����Ϣ�����⣬û�ռ�ֱ��ͼ���������ù�ͳ����Ϣ�ˣ������㶨��˵

�����������鿴ʣ�µĹ����е����ݷֲ�

Ȼ����һ�����ĵ����ݿ�汾��11gR2 ������ IBM С�������� �� ��Ϊ�� 11g ���� online ���� ������ ����� 10g ���� online ���� (10g �Ǽٵ�online )


create index idx_F4111_docdctilmcufrto on F4111(ILDOC,ILDCT,ILMCU,ILFRTO) online nologging;
   
===============================================================================
--��һ��ǿ����ORACLE������������ 

����������ǳ�ʶ�������μǡ���������д���ּ򵥰������������������ü�������������������������⣬���Ի���дһ�¡�


һ���ֵ����� delete from Sa_Sales_Comm_Detail s where s.sales_commission_id=24240;  ---ɾ��105�����ݷǳ�����Ҫ�ܼ�ʮ�뵽�ϰ���

����������ݲ�35���У�sales_commission_id ����������ִ�мƻ�Ҳȷʵ������������ ����������105 �����ݣ��������ܼ�ʮ�����ϰ���ġ�


֮�������� select * from Sa_Sales_Comm_Detail s where s.sales_commission_id=24240;   ����ܵ��������ش� 0.06�롣


select * from Sa_Sales_Comm_Detail s where s.sales_commission_id=24240;  ---0.06��

delete from Sa_Sales_Comm_Detail s where s.sales_commission_id=24240;   ---��ʮ�뼸����


�������֣�ֱ����10046 trace�����ֵ�trace�ļ�����


[html] view plain copy
print?

    =====================  
    PARSING IN CURSOR #4 len=111 dep=1 uid=0 oct=3 lid=0 tim=1374414810328412 hv=4234506700 ad='99cc8678'  
     select /*+ all_rows */ count(1) from "CMM"."SA_SALES_PER_SPLIT_DETAIL" where "SALES_COMMISSION_DETAIL_ID" = :1  
    END OF STMT  
    PARSE #4:c=4000,e=4619,p=0,cr=0,cu=2,mis=1,r=0,dep=1,og=1,tim=1374414810328406  
    EXEC #4:c=999,e=1841,p=0,cr=0,cu=0,mis=1,r=0,dep=1,og=1,tim=1374414810330416  
    FETCH #4:c=226965,e=221384,p=0,cr=6867,cu=0,mis=0,r=1,dep=1,og=1,tim=1374414810551844  
    =====================  
    PARSING IN CURSOR #2 len=106 dep=1 uid=0 oct=3 lid=0 tim=1374414810557316 hv=1936840180 ad='8ae35660'  
     select /*+ all_rows */ count(1) from "CMM"."SA_SALES_COMM_REPROT" where "SALES_COMMISSION_DETAIL_ID" = :1  
    END OF STMT  
    PARSE #2:c=5000,e=5152,p=0,cr=0,cu=2,mis=1,r=0,dep=1,og=1,tim=1374414810557310  
    EXEC #2:c=3000,e=2081,p=0,cr=0,cu=0,mis=1,r=0,dep=1,og=1,tim=1374414810559571  
    WAIT #2: nam='db file scattered read' ela= 384 file#=5 block#=83604 blocks=5 obj#=104150 tim=1374414810560401  
    WAIT #2: nam='db file scattered read' ela= 154 file#=5 block#=87785 blocks=8 obj#=104150 tim=1374414810561125  
    WAIT #2: nam='db file scattered read' ela= 141 file#=5 block#=87802 blocks=7 obj#=104150 tim=1374414810561384  
    WAIT #2: nam='db file scattered read' ela= 204 file#=5 block#=94633 blocks=8 obj#=104150 tim=1374414810561704  
    WAIT #2: nam='db file scattered read' ela= 160 file#=5 block#=94642 blocks=7 obj#=104150 tim=1374414810562029  
    WAIT #2: nam='db file scattered read' ela= 167 file#=5 block#=94649 blocks=8 obj#=104150 tim=1374414810562309  
    WAIT #2: nam='db file scattered read' ela= 184 file#=5 block#=94674 blocks=7 obj#=104150 tim=1374414810562602  
    WAIT #2: nam='db file scattered read' ela= 172 file#=5 block#=94705 blocks=8 obj#=104150 tim=1374414810562882  
    WAIT #2: nam='db file scattered read' ela= 135 file#=5 block#=94714 blocks=7 obj#=104150 tim=1374414810563132  
    WAIT #2: nam='db file scattered read' ela= 162 file#=5 block#=97529 blocks=8 obj#=104150 tim=1374414810563412  
    WAIT #2: nam='db file scattered read' ela= 234 file#=5 block#=98314 blocks=7 obj#=104150 tim=1374414810563758  
    WAIT #2: nam='db file scattered read' ela= 154 file#=5 block#=99513 blocks=8 obj#=104150 tim=1374414810564008  
    WAIT #2: nam='db file scattered read' ela= 143 file#=5 block#=101666 blocks=7 obj#=104150 tim=1374414810564260  
    WAIT #2: nam='db file scattered read' ela= 166 file#=5 block#=101681 blocks=8 obj#=104150 tim=1374414810564533  
    WAIT #2: nam='db file scattered read' ela= 157 file#=5 block#=101690 blocks=7 obj#=104150 tim=1374414810564797  
    WAIT #2: nam='db file scattered read' ela= 128 file#=5 block#=101697 blocks=8 obj#=104150 tim=1374414810565025  
    WAIT #2: nam='db file scattered read' ela= 335 file#=5 block#=102027 blocks=16 obj#=104150 tim=1374414810565576  
    WAIT #2: nam='db file scattered read' ela= 355 file#=5 block#=102043 blocks=16 obj#=104150 tim=1374414810566148  
    WAIT #2: nam='db file scattered read' ela= 302 file#=5 block#=102059 blocks=16 obj#=104150 tim=1374414810566690  
    WAIT #2: nam='db file scattered read' ela= 323 file#=5 block#=102075 blocks=16 obj#=104150 tim=1374414810567221  
    WAIT #2: nam='db file scattered read' ela= 310 file#=5 block#=102091 blocks=16 obj#=104150 tim=1374414810567720  
    WAIT #2: nam='db file scattered read' ela= 270 file#=5 block#=102107 blocks=16 obj#=104150 tim=1374414810568243  
    WAIT #2: nam='db file scattered read' ela= 378 file#=5 block#=102123 blocks=16 obj#=104150 tim=1374414810568814  
    WAIT #2: nam='db file scattered read' ela= 253 file#=5 block#=102139 blocks=14 obj#=104150 tim=1374414810569252  
    WAIT #2: nam='db file scattered read' ela= 527 file#=5 block#=108043 blocks=16 obj#=104150 tim=1374414810570016  
    WAIT #2: nam='db file scattered read' ela= 309 file#=5 block#=108059 blocks=16 obj#=104150 tim=1374414810570543  
    WAIT #2: nam='db file scattered read' ela= 281 file#=5 block#=108075 blocks=16 obj#=104150 tim=1374414810571075  
    WAIT #2: nam='db file scattered read' ela= 356 file#=5 block#=108091 blocks=16 obj#=104150 tim=1374414810571658  
    WAIT #2: nam='db file scattered read' ela= 273 file#=5 block#=108107 blocks=16 obj#=104150 tim=1374414810572138  
    WAIT #2: nam='db file scattered read' ela= 381 file#=5 block#=108123 blocks=16 obj#=104150 tim=1374414810572715  
    WAIT #2: nam='db file scattered read' ela= 318 file#=5 block#=108139 blocks=16 obj#=104150 tim=1374414810573241  
    WAIT #2: nam='db file scattered read' ela= 302 file#=5 block#=108155 blocks=14 obj#=104150 tim=1374414810573745  
    WAIT #2: nam='db file scattered read' ela= 280 file#=5 block#=109195 blocks=16 obj#=104150 tim=1374414810574226  
    WAIT #2: nam='db file scattered read' ela= 362 file#=5 block#=109211 blocks=16 obj#=104150 tim=1374414810574795  
    WAIT #2: nam='db file scattered read' ela= 333 file#=5 block#=109227 blocks=16 obj#=104150 tim=1374414810575357  
    WAIT #2: nam='db file scattered read' ela= 331 file#=5 block#=109243 blocks=16 obj#=104150 tim=1374414810575904  
    WAIT #2: nam='db file scattered read' ela= 377 file#=5 block#=109259 blocks=16 obj#=104150 tim=1374414810576483  
    WAIT #2: nam='db file scattered read' ela= 349 file#=5 block#=109275 blocks=16 obj#=104150 tim=1374414810577059  
    WAIT #2: nam='db file scattered read' ela= 344 file#=5 block#=109291 blocks=16 obj#=104150 tim=1374414810577601  
    WAIT #2: nam='db file scattered read' ela= 320 file#=5 block#=109307 blocks=14 obj#=104150 tim=1374414810578133  
    WAIT #2: nam='db file scattered read' ela= 385 file#=7 block#=2699 blocks=16 obj#=104150 tim=1374414810578830  


��trace�ļ����濴����ִ��delete��ʱ�������ĵ�����

 select /*+ all_rows */ count(1) from "CMM"."SA_SALES_COMM_REPROT" where "SALES_COMMISSION_DETAIL_ID" = :1

���sql ������ db file scattered read(����) ��Ҳ����˵ �����sql û������������ȫ��ɨ�� ������������ SALES_COMMISSION_DETAIL_ID �����潨������

��������֮��deleteֻ��Ҫ0.���뼴�ɡ�


������ס���������Ҫ����������

--����rowid�ķ�ʽɾ���ϴ�ı� ��ɾ��������ݽϴ�����ù�����������ȫ��ɨ��
delete from i_br_all_user_real where rowid in (
select a.rowid from i_br_all_user_real a,i_br_card_return b
where a.imsi_no = b.imsi_no
and a.oper_date<=to_date(b.return_date,'YYYYMMDDHH24MISS'))

--����ͼ��д
select rownum, adn, zdn, 'cable'
    from (select distinct connect_by_root(t.tdl_a_dn) adn, t.tdl_z_dn zdn
            from AGGR_1 t
           where t.tdl_operation <> 2
             and exists (select 1
                    from CABLE_1 a
                   where a.tdl_operation <> 2
                     and a.tdl_dn = t.tdl_z_dn)
           start with exists (select 1
                         from RESOURCE_FACING_SERVICE1_1 b
                        where b.tdl_operation <> 2
                          and t.tdl_a_dn = b.tdl_dn)
          connect by nocycle prior t.tdl_z_dn = t.tdl_a_dn)
          
-----------------------------------------------------------------------------------------------------------------------------------  
| Id  | Operation                                    | Name                       | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |  
-----------------------------------------------------------------------------------------------------------------------------------  
|   0 | SELECT STATEMENT                             |                            | 31125 |    59M|       | 36356   (1)| 00:07:17 |  
|   1 |  COUNT                                       |                            |       |       |       |            |          |  
|   2 |   VIEW                                       |                            | 31125 |    59M|       | 36356   (1)| 00:07:17 |  
|   3 |    HASH UNIQUE                               |                            | 31125 |    59M|   334M| 36356   (1)| 00:07:17 |  
|*  4 |     FILTER                                   |                            |       |       |       |            |          |  
|*  5 |      CONNECT BY NO FILTERING WITH SW (UNIQUE)|                            |       |       |       |            |          |  
|   6 |       TABLE ACCESS FULL                      | AGGR_1                     |   171K|  4353K|       |  2468   (1)| 00:00:30 |  
|*  7 |       TABLE ACCESS FULL                      | RESOURCE_FACING_SERVICE1_1 |     1 |    18 |       |   137   (1)| 00:00:02 |  
|*  8 |      TABLE ACCESS FULL                       | CABLE_1                    |     1 |    14 |       |   205   (1)| 00:00:03 |  
-----------------------------------------------------------------------------------------------------------------------------------  
  
Predicate Information (identified by operation id):  
---------------------------------------------------  
  
   4 - filter("T"."TDL_OPERATION"<>2 AND  EXISTS (SELECT 0 FROM "CABLE_1" "A" WHERE "A"."TDL_DN"=:B1 AND  
              "A"."TDL_OPERATION"<>2))  
   5 - access("T"."TDL_A_DN"=PRIOR "T"."TDL_Z_DN")  
       filter( EXISTS (SELECT 0 FROM "RESOURCE_FACING_SERVICE1_1" "B" WHERE "B"."TDL_DN"=:B1 AND "B"."TDL_OPERATION"<>2))  
   7 - filter("B"."TDL_DN"=:B1 AND "B"."TDL_OPERATION"<>2)  
   8 - filter("A"."TDL_DN"=:B1 AND "A"."TDL_OPERATION"<>2)  
   
with a as (select /*+ materialize */ tdl_dn from CABLE_1 a where a.tdl_operation <> 2 ),
     b as (select /*+ materialize */ tdl_dn from  RESOURCE_FACING_SERVICE1_1 b where b.tdl_operation <> 2),
     t as (select /*+ materialize */ tdl_a_dn, tdl_z_dn,tdl_operation from AGGR_1 t )                       
 select rownum, adn, zdn, 'cable'
    from (select distinct connect_by_root(t.tdl_a_dn) adn, t.tdl_z_dn zdn
            from  t
           where t.tdl_operation <> 2
             and exists (select 1
                    from  a
                   where a.tdl_dn = t.tdl_z_dn)
           start with exists (select 1
                         from  b
                        where  t.tdl_a_dn = b.tdl_dn)
          connect by nocycle prior t.tdl_z_dn = t.tdl_a_dn)
          
------------------------------------------------------------------------------------------------------------------------------  
| Id  | Operation                               | Name                       | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |  
------------------------------------------------------------------------------------------------------------------------------  
|   0 | SELECT STATEMENT                        |                            | 31125 |    59M|       | 32045   (1)| 00:06:25 |  
|   1 |  TEMP TABLE TRANSFORMATION              |                            |       |       |       |            |          |  
|   2 |   LOAD AS SELECT                        | SYS_TEMP_0FD9D6664_D65E0   |       |       |       |            |          |  
|*  3 |    TABLE ACCESS FULL                    | CABLE_1                    | 12616 |   172K|       |   205   (1)| 00:00:03 |  
|   4 |   LOAD AS SELECT                        | SYS_TEMP_0FD9D6665_D65E0   |       |       |       |            |          |  
|*  5 |    TABLE ACCESS FULL                    | RESOURCE_FACING_SERVICE1_1 | 10511 |   184K|       |   137   (1)| 00:00:02 |  
|   6 |   LOAD AS SELECT                        | SYS_TEMP_0FD9D6666_D65E0   |       |       |       |            |          |  
|   7 |    TABLE ACCESS FULL                    | AGGR_1                     |   171K|  4353K|       |  2468   (1)| 00:00:30 |  
|   8 |   COUNT                                 |                            |       |       |       |            |          |  
|   9 |    VIEW                                 |                            | 31125 |    59M|       | 29236   (1)| 00:05:51 |  
|  10 |     HASH UNIQUE                         |                            | 31125 |    59M|   140M| 29236   (1)| 00:05:51 |  
|* 11 |      FILTER                             |                            |       |       |       |            |          |  
|* 12 |       CONNECT BY WITH FILTERING (UNIQUE)|                            |       |       |       |            |          |  
|* 13 |        HASH JOIN RIGHT SEMI             |                            | 22778 |    22M|       |   179   (3)| 00:00:03 |  
|  14 |         VIEW                            |                            | 10511 |   164K|       |     9   (0)| 00:00:01 |  
|  15 |          TABLE ACCESS FULL              | SYS_TEMP_0FD9D6665_D65E0   | 10511 |   164K|       |     9   (0)| 00:00:01 |  
|  16 |         VIEW                            |                            |   171K|   168M|       |   168   (2)| 00:00:03 |  
|  17 |          TABLE ACCESS FULL              | SYS_TEMP_0FD9D6666_D65E0   |   171K|  4353K|       |   168   (2)| 00:00:03 |  
|* 18 |        HASH JOIN                        |                            | 49360 |    95M|    22M|  9874   (1)| 00:01:59 |  
|  19 |         CONNECT BY PUMP                 |                            |       |       |       |            |          |  
|  20 |         VIEW                            |                            |   171K|   168M|       |   168   (2)| 00:00:03 |  
|  21 |          TABLE ACCESS FULL              | SYS_TEMP_0FD9D6666_D65E0   |   171K|  4353K|       |   168   (2)| 00:00:03 |  
|* 22 |       VIEW                              |                            |     1 |  1002 |       |     1   (0)| 00:00:01 |  
|  23 |        TABLE ACCESS FULL                | SYS_TEMP_0FD9D6664_D65E0   | 12616 |   147K|       |     8   (0)| 00:00:01 |  
------------------------------------------------------------------------------------------------------------------------------  
  
Predicate Information (identified by operation id):  
---------------------------------------------------  
  
   3 - filter("A"."TDL_OPERATION"<>2)  
   5 - filter("B"."TDL_OPERATION"<>2)  
  11 - filter("T"."TDL_OPERATION"<>2 AND  EXISTS (SELECT 0 FROM  (SELECT /*+ CACHE_TEMP_TABLE ("T1") */ "C0" "TDL_DN"  
              FROM "SYS"."SYS_TEMP_0FD9D6664_D65E0" "T1") "A" WHERE "A"."TDL_DN"=:B1))  
  12 - access("T"."TDL_A_DN"=PRIOR "T"."TDL_Z_DN")  
  13 - access("T"."TDL_A_DN"="B"."TDL_DN")  
  18 - access("connect$_by$_pump$_011"."prior t.tdl_z_dn "="T"."TDL_A_DN")  
  22 - filter("A"."TDL_DN"=:B1)  
  
42 rows selected.  

--SQL�������ӵ�ʱ��ע���������λ�� 
    select *  
      from (select u.NAME UniversityName,  
                   u.id UniversityId,  
                   count(a.SIGNUPNUMBER) playercnt  
              from T_B_UNIVERSITY u  
              left join T_D_EDUCATION e  
                on e.UNIVERSITY_ID = u.id  
              left join T_D_VIDEO_PLAYER a  
                on a.USER_ID = e.user_id  
               and e.ISDEFAULT = 1  
               and e.ISVALID = 1  
               and a.AUDITSTATUS = 1  
               and a.ISVALID = 1  
              left join T_D_USER c  
                on a.USER_ID = c.id  
               and c.ISVALID = 1  
             where u.REGION_CODE like '43%'  
             group by u.NAME, u.id)  
     order by playercnt desc;  

Plan hash value: 3938743742  
  
--------------------------------------------------------------------------------------------  
| Id  | Operation               | Name             | Rows  | Bytes | Cost (%CPU)| Time     |  
--------------------------------------------------------------------------------------------  
|   0 | SELECT STATEMENT        |                  |   142 | 10366 |   170   (3)| 00:00:03 |  
|   1 |  SORT ORDER BY          |                  |   142 | 10366 |   170   (3)| 00:00:03 |  
|   2 |   HASH GROUP BY         |                  |   142 | 10366 |   170   (3)| 00:00:03 |  
|*  3 |    HASH JOIN RIGHT OUTER|                  |   672 | 49056 |   168   (2)| 00:00:03 |  
|*  4 |     TABLE ACCESS FULL   | T_D_USER         |   690 |  5520 |     5   (0)| 00:00:01 |  
|   5 |     NESTED LOOPS OUTER  |                  |   672 | 43680 |   162   (1)| 00:00:02 |  
|*  6 |      HASH JOIN OUTER    |                  |   672 | 37632 |    14   (8)| 00:00:01 |  
|*  7 |       TABLE ACCESS FULL | T_B_UNIVERSITY   |    50 |  2050 |     8   (0)| 00:00:01 |  
|   8 |       TABLE ACCESS FULL | T_D_EDUCATION    |   672 | 10080 |     5   (0)| 00:00:01 |  
|   9 |      VIEW               |                  |     1 |     9 |     0   (0)| 00:00:01 |  
|* 10 |       FILTER            |                  |       |       |            |          |  
|* 11 |        TABLE ACCESS FULL| T_D_VIDEO_PLAYER |     1 |    15 |     3   (0)| 00:00:01 |  
--------------------------------------------------------------------------------------------  
  
Predicate Information (identified by operation id):  
---------------------------------------------------  
  
   3 - access("A"."USER_ID"="C"."ID"(+))  
   4 - filter("C"."ISVALID"(+)=1)  
   6 - access("E"."UNIVERSITY_ID"(+)="U"."ID")  
   7 - filter("U"."REGION_CODE" LIKE '43%')  
  10 - filter("E"."ISVALID"=1 AND "E"."ISDEFAULT"=1)  
  11 - filter("A"."USER_ID"="E"."USER_ID" AND "A"."AUDITSTATUS"=1 AND  
              "A"."ISVALID"=1)  
              
    select *  
      from (select u.NAME UniversityName,  
                   u.id UniversityId,  
                   count(a.SIGNUPNUMBER) playercnt  
              from T_B_UNIVERSITY u  
              left join T_D_EDUCATION e  
                on e.UNIVERSITY_ID = u.id  
               and e.ISDEFAULT = 1  
               and e.ISVALID = 1  
              left join T_D_VIDEO_PLAYER a  
                on a.USER_ID = e.user_id      
               and a.AUDITSTATUS = 1  
               and a.ISVALID = 1  
              left join T_D_USER c  
                on a.USER_ID = c.id  
               and c.ISVALID = 1  
             where u.REGION_CODE like '43%'  
             group by u.NAME, u.id)  
     order by playercnt desc;   

--�����in/exists �Ӳ�ѯ(������)��Ϊ������    
select  rowid rid  
   from its_car_pass7 v  
  where 1 = 1  
    and pass_datetime >=  
        to_date('2013-07-06 :17:46:04', 'yyyy-mm-dd hh24:mi:ss')  
    and pass_datetime <=  
        to_date('2013-07-06 :18:46:06', 'yyyy-mm-dd hh24:mi:ss')  
    and v.pass_device_unid in  
        (select unid  
           from its_base_device  
          where dev_bay_unid in ('01685EFE4658C19D59C4DDAAEDD37393')  
            and dev_type = '1'  
            and dev_chk_flag = '1'  
            and dev_delete_flag = 'N')  
  order by v.pass_datetime asc;


Execution Plan  
----------------------------------------------------------  
Plan hash value: 3634433140  
  
--------------------------------------------------------------------------------------------------------------------  
| Id  | Operation                     | Name               | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |  
--------------------------------------------------------------------------------------------------------------------  
|   0 | SELECT STATEMENT              |                    |     1 |   111 |     2  (50)| 00:00:01 |       |       |  
|   1 |  SORT ORDER BY                |                    |     1 |   111 |     2  (50)| 00:00:01 |       |       |  
|   2 |   NESTED LOOPS                |                    |       |       |            |          |       |       |  
|   3 |    NESTED LOOPS               |                    |     1 |   111 |     1   (0)| 00:00:01 |       |       |  
|   4 |     PARTITION RANGE SINGLE    |                    |     1 |    39 |     1   (0)| 00:00:01 |  1284 |  1284 |  
|*  5 |      INDEX SKIP SCAN          | IDX_VT7_DEVICEID   |     1 |    39 |     1   (0)| 00:00:01 |  1284 |  1284 |  
|*  6 |     INDEX UNIQUE SCAN         | PK_ITS_BASE_DEVICE |     1 |       |     0   (0)| 00:00:01 |       |       |  
|*  7 |    TABLE ACCESS BY INDEX ROWID| ITS_BASE_DEVICE    |     1 |    72 |     0   (0)| 00:00:01 |       |       |  
--------------------------------------------------------------------------------------------------------------------  

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'ADVANCED -PROJECTION'));  
  
-----------------------------------------------------------  
Plan hash value: 2191740724  
---------------------------------------------------------------------------------------------------------------------------  
| Id  | Operation                            | Name               | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |  
---------------------------------------------------------------------------------------------------------------------------  
|   0 | SELECT STATEMENT                     |                    |     1 |   111 |  2092K  (1)| 06:58:26 |       |       |  
|   1 |  NESTED LOOPS                        |                    |       |       |            |          |       |       |  
|   2 |   NESTED LOOPS                       |                    |     1 |   111 |  2092K  (1)| 06:58:26 |       |       |  
|   3 |    PARTITION RANGE SINGLE            |                    |     1 |    39 |  2092K  (1)| 06:58:26 |  1284 |  1284 |  
|   4 |     TABLE ACCESS BY LOCAL INDEX ROWID| ITS_CAR_PASS7      |     1 |    39 |  2092K  (1)| 06:58:26 |  1284 |  1284 |  
|*  5 |      INDEX RANGE SCAN                | IDX_VT7_DATETIME   |     1 |       |  6029   (1)| 00:01:13 |  1284 |  1284 |  
|*  6 |    INDEX UNIQUE SCAN                 | PK_ITS_BASE_DEVICE |     1 |       |     0   (0)| 00:00:01 |       |       |  
|*  7 |   TABLE ACCESS BY INDEX ROWID        | ITS_BASE_DEVICE    |     1 |    72 |     0   (0)| 00:00:01 |       |       |  
---------------------------------------------------------------------------------------------------------------------------  
   
Query Block Name / Object Alias (identified by operation id):  
-------------------------------------------------------------  
   
   1 - SEL$5DA710D3  
   4 - SEL$5DA710D3 / V@SEL$1  
   5 - SEL$5DA710D3 / V@SEL$1  
   6 - SEL$5DA710D3 / ITS_BASE_DEVICE@SEL$2  
   7 - SEL$5DA710D3 / ITS_BASE_DEVICE@SEL$2   --��ȡ�˱���
   
select /*+ leading(ITS_BASE_DEVICE@SEL$2) */ rowid rid  
   from its_car_pass7 v  
  where 1 = 1  
    and pass_datetime >=  
        to_date('2013-07-06 :17:46:04', 'yyyy-mm-dd hh24:mi:ss')  
    and pass_datetime <=  
        to_date('2013-07-06 :18:46:06', 'yyyy-mm-dd hh24:mi:ss')  
    and v.pass_device_unid in  
        (select unid  
           from its_base_device  
          where dev_bay_unid in ('01685EFE4658C19D59C4DDAAEDD37393')  
            and dev_type = '1'  
            and dev_chk_flag = '1'  
            and dev_delete_flag = 'N')  
  order by v.pass_datetime asc;

--no_expand�Ż�����  
select a.*,b.dn from temp_allcrmuser a, phs_smc_user b
 where a.USERNUMBER=b.dn
 and (a.ACTFLAG<>b.ACT_FLG
 or a.ENABLEFLAG<>b.ENABLE_FLG);
 
-------------------------------------------------------------------------------------------------
| Id  | Operation                     | Name            | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |                 |     2 |   112 |    12  (17)| 00:00:01 |
|   1 |  CONCATENATION                |                 |       |       |            |          |
|   2 |   MERGE JOIN                  |                 |     1 |    56 |     6  (17)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| PHS_SMC_USER    |    22 |   396 |     3   (0)| 00:00:01 |
|   4 |     INDEX FULL SCAN           | IND_SMC_USER_DN |    22 |       |     1   (0)| 00:00:01 |
|*  5 |    FILTER                     |                 |       |       |            |          |
|*  6 |     SORT JOIN                 |                 |    82 |  3116 |     3  (34)| 00:00:01 |
|   7 |      TABLE ACCESS FULL        | TEMP_ALLCRMUSER |    82 |  3116 |     2   (0)| 00:00:01 |
|   8 |   MERGE JOIN                  |                 |     1 |    56 |     6  (17)| 00:00:01 |
|   9 |    TABLE ACCESS BY INDEX ROWID| PHS_SMC_USER    |    22 |   396 |     3   (0)| 00:00:01 |
|  10 |     INDEX FULL SCAN           | IND_SMC_USER_DN |    22 |       |     1   (0)| 00:00:01 |
|* 11 |    FILTER                     |                 |       |       |            |          |
|* 12 |     SORT JOIN                 |                 |    82 |  3116 |     3  (34)| 00:00:01 |
|  13 |      TABLE ACCESS FULL        | TEMP_ALLCRMUSER |    82 |  3116 |     2   (0)| 00:00:01 |

 5 - filter("A"."ENABLEFLAG"<>"B"."ENABLE_FLG")
   6 - access("A"."USERNUMBER"="B"."DN")
       filter("A"."USERNUMBER"="B"."DN")
  11 - filter("A"."ACTFLAG"<>"B"."ACT_FLG" AND LNNVL("A"."ENABLEFLAG"<>"B"."ENABLE_FLG"))
  12 - access("A"."USERNUMBER"="B"."DN")
       filter("A"."USERNUMBER"="B"."DN")
       
SELECT  DISTINCT b.organ_id,
                        c.company_name as organ_name,
                        a.distri_date,
                        a.distri_type,
                        d.TYPE_NAME Capital_name,
                        b.policy_code,
                        b.apply_code send_code,
                        i.ATTRIBUTE10 total_code,
                        f.pay_mode,
                        j.type_name as policy_type_name,
                        e.Internal_Id AS product_code,
                        round(a.distri_amount, 2) AS fee_amount,
                        decode(a.posted,
                               'Y',
                               to_char(i.transaction_date, 'yyyy-mm-dd'),
                               to_char(a.distri_date, 'yyyy-mm-dd')) As finish_time,
                        F.DR_SEG1,
                        F.DR_SEG2,
                        F.DR_SEG3,
                        F.DR_SEG4,
                        F.DR_SEG5,
                        F.DR_SEG6,
                        f.dr_seg7,
                        f.dr_seg8,
                        f.dr_seg9,
                        f.dr_seg10,
                        f.cr_seg1,
                        f.cr_seg2,
                        f.cr_seg3,
                        f.cr_seg4,
                        f.cr_seg5,
                        f.cr_seg6,
                        f.cr_seg7,
                        f.cr_seg8,
                        f.cr_seg9,
                        f.cr_seg10,
                        f.je_posting_id as cred_id
          FROM T_CAPITAL_DISTRIBUTE a,
               t_contract_master b,
               t_channel_type j,
               t_company_organ c,
               t_capital_distri_type d,
               t_product_life e,
               t_contract_product f,
               (select * from T_BIZ_ACCOUNTING_INFO where DATA_TABLE = '7') F,
               T_GL_BIZ_INTERFACE i,
               (select  organ_id
                  from t_company_organ
                 start with organ_id = '101'
                connect by parent_id = prior organ_id) o
         WHERE a.policy_id = b.policy_id
           and a.item_id = f.item_id(+)
           AND b.organ_id = c.Organ_Id
           AND a.distri_type = d.distri_type
           AND a.product_id = e.product_id
           and b.policy_type = j.INDIVIDUAL_GROUP
           AND A.capital_id = F.FEE_ID(+)
           AND A.cred_id = i.posting_id(+)
           and a.organ_id = i.segment1(+)
           and nvl(a.posted, 'N') = 'Y'
           and a.cred_id = 493997
           and i.transaction_date >= to_date('2011-11-01', 'yyyy-MM-dd')
           and i.transaction_date < to_date('2011-11-30', 'yyyy-MM-dd') + 1
           and a.distri_type = i.reference3(+)
           and i.segment1 = o.organ_id(+);
�Ƕ�˵���SQL�߼�����2ǧ����300s������9000�����ݣ�SQL ִ�мƻ����£�

SQL> select * from table(dbms_xplan.display);

PLAN_TABLE_OUTPUT
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------
| Id  | Operation                             |  Name                          | Rows  | Bytes | Cost (%CPU)|
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                                |     1 |   356 |    27   (0)|
|   1 |  SORT UNIQUE                          |                                |     1 |   356 |    27   (0)|
|*  2 |   HASH JOIN OUTER                     |                                |     1 |   356 |    12   (9)|
|   3 |    NESTED LOOPS                       |                                |     1 |   350 |    10  (10)|
|   4 |     NESTED LOOPS                      |                                |     1 |   338 |     9  (12)|
|   5 |      NESTED LOOPS OUTER               |                                |     1 |   302 |     8  (13)|
|   6 |       NESTED LOOPS                    |                                |     1 |   171 |     7  (15)|
|   7 |        NESTED LOOPS                   |                                |     1 |   125 |     6  (17)|
|   8 |         NESTED LOOPS                  |                                |     1 |   100 |     5  (20)|
|   9 |          NESTED LOOPS OUTER           |                                |     1 |    86 |     4  (25)|
|  10 |           NESTED LOOPS                |                                |     1 |    76 |     3  (34)|
|  11 |            TABLE ACCESS BY INDEX ROWID| T_GL_BIZ_INTERFACE             |     1 |    24 |     2  (50)|
|* 12 |             INDEX SKIP SCAN           | IDX10                          |     1 |       |     3   (0)|
|* 13 |            TABLE ACCESS BY INDEX ROWID| T_CAPITAL_DISTRIBUTE           |     1 |    52 |     2  (50)|
|* 14 |             INDEX RANGE SCAN          | IDX_CAPITAL_DISTR__CRED_ORGAN  |    15 |       |     2   (0)|
|  15 |           TABLE ACCESS BY INDEX ROWID | T_CONTRACT_PRODUCT             |     1 |    10 |     2  (50)|
|* 16 |            INDEX UNIQUE SCAN          | PK_T_CONTRACT_PRODUCT          |     1 |       |     1   (0)|
|  17 |          TABLE ACCESS BY INDEX ROWID  | T_PRODUCT_LIFE                 |     1 |    14 |     2  (50)|
|* 18 |           INDEX UNIQUE SCAN           | PK_T_PRODUCT_LIFE              |     1 |       |            |
|  19 |         TABLE ACCESS BY INDEX ROWID   | T_CAPITAL_DISTRI_TYPE          |     1 |    25 |     2  (50)|
|* 20 |          INDEX UNIQUE SCAN            | PK_T_CAPITAL_DISTRI_TYPE       |     1 |       |            |
|  21 |        TABLE ACCESS BY INDEX ROWID    | T_CONTRACT_MASTER              |     1 |    46 |     2  (50)|
|* 22 |         INDEX UNIQUE SCAN             | PK_T_CONTRACT_MASTER           |     1 |       |     1   (0)|
|  23 |       TABLE ACCESS BY INDEX ROWID     | T_BIZ_ACCOUNTING_INFO          |     1 |   131 |     2  (50)|
|* 24 |        INDEX RANGE SCAN               | IDX_BIZ_ACCOUNTING_INFO__FEE_  |     1 |       |     2   (0)|
|  25 |      TABLE ACCESS BY INDEX ROWID      | T_COMPANY_ORGAN                |     1 |    36 |     2  (50)|
|* 26 |       INDEX UNIQUE SCAN               | PK_T_COMPANY_ORGAN             |     1 |       |            |
|  27 |     TABLE ACCESS BY INDEX ROWID       | T_CHANNEL_TYPE                 |     1 |    12 |     2  (50)|
|* 28 |      INDEX UNIQUE SCAN                | PK_T_CHANNEL_TYPE              |     1 |       |            |
|  29 |    VIEW                               |                                |     7 |    42 |            |
|* 30 |     CONNECT BY WITH FILTERING         |                                |       |       |            |
|  31 |      NESTED LOOPS                     |                                |       |       |            |
|* 32 |       INDEX UNIQUE SCAN               | PK_T_COMPANY_ORGAN             |     1 |     6 |            |
|  33 |       TABLE ACCESS BY USER ROWID      | T_COMPANY_ORGAN                |       |       |            |
|  34 |      NESTED LOOPS                     |                                |       |       |            |
|  35 |       BUFFER SORT                     |                                |     7 |    70 |            |
|  36 |        CONNECT BY PUMP                |                                |       |       |            |
|* 37 |       INDEX RANGE SCAN                | T_COMPANY_ORGAN_IDX_002        |     7 |    70 |     1   (0)|
-------------------------------------------------------------------------------------------------------------

   2 - access("I"."SEGMENT1"="O"."ORGAN_ID"(+))
  12 - access("I"."TRANSACTION_DATE">=TO_DATE('2011-11-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss') AND
              "I"."POSTING_ID"=493997 AND "I"."TRANSACTION_DATE"<TO_DATE('2011-12-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss'))
       filter("I"."POSTING_ID"=493997)
  13 - filter("A"."DISTRI_TYPE"="I"."REFERENCE3")
  14 - access("A"."CRED_ID"=493997 AND "A"."ORGAN_ID"="I"."SEGMENT1")
       filter(NVL("A"."POSTED",'N')='Y')
  16 - access("A"."ITEM_ID"="F"."ITEM_ID"(+))
  18 - access("A"."PRODUCT_ID"="E"."PRODUCT_ID")
  20 - access("A"."DISTRI_TYPE"="D"."DISTRI_TYPE")
  22 - access("A"."POLICY_ID"="B"."POLICY_ID")
  24 - access("A"."CAPITAL_ID"="T_BIZ_ACCOUNTING_INFO"."FEE_ID"(+) AND
              "T_BIZ_ACCOUNTING_INFO"."DATA_TABLE"(+)=7)
  26 - access("B"."ORGAN_ID"="C"."ORGAN_ID")
  28 - access("B"."POLICY_TYPE"="J"."INDIVIDUAL_GROUP")
  30 - filter("T_COMPANY_ORGAN"."ORGAN_ID"='101')
  32 - access("T_COMPANY_ORGAN"."ORGAN_ID"='101')
  37 - access("T_COMPANY_ORGAN"."PARENT_ID"=NULL)

65 rows selected.

--�����Ӳ�ѯ��д
create table tb_data(id number,code1 number,code2 number);
insert into tb_data 
SELECT 1,1,2 FROM dual;
insert into tb_data 
SELECT 2,2,1 FROM dual;
insert into tb_data 
SELECT 3,2,3 FROM dual;
insert into tb_data 
SELECT 4,3,1 FROM dual;
insert into tb_data 
SELECT 5,4,2 FROM dual;
insert into tb_data 
SELECT 6,5,3 FROM dual;

create table tb_code(code number,DESCRIPTION varchar2(2));                               
insert into tb_code 
SELECT 1,'a' FROM dual;
insert into tb_code 
SELECT 2,'b' FROM dual;
insert into tb_code 
SELECT 3,'c' FROM dual;
insert into tb_code 
SELECT 4,'d' FROM dual;
insert into tb_code 
SELECT 5,'e' FROM dual;

SELECT * FROM tb_data;
SELECT * FROM tb_code;
--�ﻯ��ͼ
with T1 as (
SELECT a.id,a.code1,b.description FROM tb_data a ,tb_code b WHERE a.code1=b.code) ,
 T2 as (
SELECT a.id,a.code2,b.description FROM tb_data a ,tb_code b WHERE a.code2=b.code)
SELECT T1.id,T1.DESCRIPTION,T2.DESCRIPTION FROM  T1,T2 WHERE T1.id=T2.id order by T1.id;
--�����Ӳ�ѯ
SELECT a.id,
       (SELECT b.description FROM tb_code b WHERE a.code1 = b.code),
       (SELECT b.description FROM tb_code b WHERE a.code2 = b.code)
  FROM tb_data a;
--�����Ӳ�ѯ��д
SELECT a.id,b.description,e.description FROM tb_data a 
left join tb_code b  on (a.code1 = b.code) 
left join tb_code e  on (a.code2=e.code) order by a.id;

SELECT a.partition_id_region, a.current_month, b.last_month
  from (SELECT t.partition_id_region, count(*) as current_month
          FROM yswork_jtwg.CZ_REPART_OFFER_INSTANCE_T t
         group by t.partition_id_region ) a
  full outer join (SELECT t.partition_id_region, count(*) as last_month
               FROM  ysuser_sid.repart_offer_instance_t t
              group by t.partition_id_region ) b
 on ( a.partition_id_region = b.partition_id_region)
 order by 1 ;


       
with a as
(SELECT t.partition_id_region, count(*) as current_month
          FROM yswork_jtwg.CZ_REPART_OFFER_INSTANCE_T t
         group by t.partition_id_region ),
b as 
(SELECT t.partition_id_region, count(*) as last_month
               FROM  ysuser_sid.repart_offer_instance_t t
              group by t.partition_id_region )
select a.partition_id_region,a.current_month,b.last_month from a,b WHERE a.partition_id_region=b.partition_id_region order by 1;

--rebulid �ؽ��������������ӷ�������
����Ҫ��һ������rebuild һ�������� ��������������11�������ݵı��ϡ�


���ڷ���Ϸ�����������Ҫrebuild ÿ������(partition),����ֱ��rebuild����������


������Ϸ�����������Ҫrebuildÿ���ӷ�����subpartition��,����ֱ��rebuild����������Ҳ����ֱ��rebuild ����(partition)


������Ҫrebuild�������ܴ���100���������928���ӷ�������������ֹ�дrebuild������Ȼ�����ʣ�Ҫд928������ �ޡ�����������������һ�½ű����Ժ����á�


�����������ǲֿ⻷����������û��дrebuild online.������ע�⣬sunpartition ������ rebuild ��ʱ���� ���� nologging, pctfree ...��storage������ֻ������ tablespace ...parallel ���� �������£�

ORA-14189: this physical attribute may not be specified for an index subpartition




����Ϸ�������

SET ECHO OFF
set termout off  
set feedback off
set heading off
set linesize 200
set pagesize 10000

spool c:/partition.sql

select 'alter index ' || index_owner || '.' ||index_name ||' rebuild partition ' || PARTITION_NAME || ' nologging parallel ;' --����Ӳ��ж�
from dba_ind_partitions where index_owner='&index_owner' and index_name=&index_name;

spool off

 

������Ϸ�������


SET ECHO OFF
set termout off  
set feedback off
set heading off
set linesize 200
set pagesize 10000

spool c:/subpartition.sql
select 'alter index ' || index_owner || '.' ||index_name ||' rebuild subpartition ' || subpartition_name || '  parallel ;' --����Ӳ��ж�
from dba_ind_subpartitions where index_owner='&index_owner' and index_name='&index_name';
spool off

���������ôӦ����ôѡȡ�����У� .
��ǩ�� sqlaccessjoinfilterdiskcomments 2011-08-05 16:14 4878���Ķ� ����(5) �ղ� �ٱ� .����������¼�ڣ� 
 ���ࣺ SQL TUNING��67��   
����ͬ������X.��Ȩ����������Ϊ����ԭ�����£�δ������������ת�ء�
 
������һ��SQL
select count(*) from t1,t2 where t1.id=t2.id and t1.owner='SCOTT';
id��ѡ���Ժܸߣ�ownerѡ���Ժܵ�
Ҫ�Ż����ܼ򵥣�ֻ��Ҫ��t1���Ͻ���һ���������(owner,id)����t2���Ͻ���һ������(id)
����Ҫ���۵�������Ӧ����ô���������������һ��(owner,id)Ӧ�÷�����ǰ�棿

����������ʵ��

SQL> desc t1
Name        Type          Nullable Default Comments 
----------- ------------- -------- ------- -------- 
ID          NUMBER        Y                         
OBJECT_NAME VARCHAR2(128) Y                         
OWNER       VARCHAR2(30)  Y                         

SQL> desc t2
Name      Type        Nullable Default Comments 
--------- ----------- -------- ------- -------- 
ID        NUMBER      Y                         
STATUS    VARCHAR2(7) Y                         
TEMPORARY VARCHAR2(1) Y    


SQL> create index inx_id on t2(id);

Index created.

SQL> create index inx_id_owner on t1(id,owner);

Index created.

SQL> select count(*) from t1,t2 where t1.id=t2.id and t1.owner='SCOTT';

Elapsed: 00:00:00.02

Execution Plan
----------------------------------------------------------
Plan hash value: 2432674005

---------------------------------------------------------------------------------------
| Id  | Operation              | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |              |     1 |    16 |    88   (2)| 00:00:02 |
|   1 |  SORT AGGREGATE        |              |     1 |    16 |            |          |
|*  2 |   HASH JOIN            |              |  2416 | 38656 |    88   (2)| 00:00:02 |
|*  3 |    INDEX FAST FULL SCAN| INX_ID_OWNER |  2416 | 26576 |    50   (0)| 00:00:01 |
|   4 |    INDEX FAST FULL SCAN| INX_ID       | 72475 |   353K|    37   (0)| 00:00:01 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."ID"="T2"."ID")
   3 - filter("T1"."OWNER"='SCOTT')


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        392  consistent gets
          0  physical reads
          0  redo size
        422  bytes sent via SQL*Net to client
        420  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
                      
SQL> create index inx_owner_id on t1(owner,id);

Index created.

SQL> select count(*) from t1,t2 where t1.id=t2.id and t1.owner='SCOTT';

Elapsed: 00:00:00.03

Execution Plan
----------------------------------------------------------
Plan hash value: 277464349

---------------------------------------------------------------------------------------
| Id  | Operation              | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |              |     1 |    16 |    47   (3)| 00:00:01 |
|   1 |  SORT AGGREGATE        |              |     1 |    16 |            |          |
|*  2 |   HASH JOIN            |              |  2416 | 38656 |    47   (3)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN    | INX_OWNER_ID |  2416 | 26576 |     9   (0)| 00:00:01 |
|   4 |    INDEX FAST FULL SCAN| INX_ID       | 72475 |   353K|    37   (0)| 00:00:01 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."ID"="T2"."ID")
   3 - access("T1"."OWNER"='SCOTT')


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        169  consistent gets
          0  physical reads
          0  redo size
        422  bytes sent via SQL*Net to client
        420  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed

���OWNER��Ϊ�����У��߼�������ǰ��392������ڵ�169����������ǰ�� index fast full scan ���index range scan

���ǿ��ָ�������� inx_id_owner 
          
SQL>  select /*+ index(t1 inx_id_owner) */ count(*) from t1,t2 where t1.id=t2.id and t1.owner='SCOTT';

Elapsed: 00:00:00.03

Execution Plan
----------------------------------------------------------
Plan hash value: 3161475902

---------------------------------------------------------------------------------------
| Id  | Operation              | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |              |     1 |    16 |   259   (1)| 00:00:04 |
|   1 |  SORT AGGREGATE        |              |     1 |    16 |            |          |
|*  2 |   HASH JOIN            |              |  2416 | 38656 |   259   (1)| 00:00:04 |
|*  3 |    INDEX FULL SCAN     | INX_ID_OWNER |  2416 | 26576 |   221   (1)| 00:00:03 |
|   4 |    INDEX FAST FULL SCAN| INX_ID       | 72475 |   353K|    37   (0)| 00:00:01 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."ID"="T2"."ID")
   3 - access("T1"."OWNER"='SCOTT')
       filter("T1"."OWNER"='SCOTT')


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        387  consistent gets
          0  physical reads
          0  redo size
        422  bytes sent via SQL*Net to client
        420  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed

��ȻҪ387���߼�����

ΪʲôҪ��ownerΪ�����У���ΪID��join�У�����ID������û���������������ID����Ϊ�����У�����û��������
��ôCBOֻ���� index full scan,����index fast full scan����Ϊ������û�����������߲���index range scan,
�����index skip scan������index skip scan���۹��ߣ���Ϊindex skip scanҪ�� ������ѡ���Ժܵͣ�����ID����ѡ���Ժܸ�

SQL> select /*+ index_ss(t1 inx_id_owner) */ count(*) from t1,t2 where t1.id=t2.id and t1.owner='SYS';

Elapsed: 00:00:00.10

Execution Plan
----------------------------------------------------------
Plan hash value: 3493079762

---------------------------------------------------------------------------------------
| Id  | Operation              | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |              |     1 |    16 | 72529   (1)| 00:14:31 |
|   1 |  SORT AGGREGATE        |              |     1 |    16 |            |          |
|*  2 |   HASH JOIN            |              |  2416 | 38656 | 72529   (1)| 00:14:31 |
|*  3 |    INDEX SKIP SCAN     | INX_ID_OWNER |  2416 | 26576 | 72491   (1)| 00:14:30 |
|   4 |    INDEX FAST FULL SCAN| INX_ID       | 72475 |   353K|    37   (0)| 00:00:01 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."ID"="T2"."ID")
   3 - access("T1"."OWNER"='SYS')
       filter("T1"."OWNER"='SYS')


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
        387  consistent gets
          0  physical reads
          0  redo size
        424  bytes sent via SQL*Net to client
        420  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed

���owner����Ϊ�����У���ô�Ż����Ϳ���ѡ��index range scan,�������index full scan, index fast full scan
�϶�Ҫ��ɨ��ܶ�leaf block,�߼����ͻ���Խ��١�

��ʵ������Ƿ�����ܽ�һ�½������������ԭ���أ�
������Ҫѡ���������������Ϊ�����У����� where a.xxx='xxx' ���� a.xxx> ���� a.xxx<
�����е�ѡ����Խ��Խ�ã���Ϊѡ����Խ�ߣ�ɨ���leaf block��Խ�٣�Ч�ʾ�Խ��
������join�зŵ�������������

����ѡ����owner����Ϊ�����У�����ownerѡ���Ժܵͣ����Բ�������ѹ���������ܵ�����

SQL> analyze  index inx_owner_id validate structure;

Index analyzed.

SQL> select height,
  2         blocks,
  3         lf_blks,
  4         br_blks,
  5         OPT_CMPR_COUNT,
  6         OPT_CMPR_PCTSAVE
  7    from index_stats
  8   where name = 'INX_OWNER_ID';

    HEIGHT     BLOCKS    LF_BLKS    BR_BLKS OPT_CMPR_COUNT OPT_CMPR_PCTSAVE
---------- ---------- ---------- ---------- -------------- ----------------
         2        256        219          1              1               26
 
SQL> drop index inx_owner_id;

Index dropped

SQL> create index inx_owner_id on t1(owner,id) compress 1;

Index created

SQL> analyze  index inx_owner_id validate structure;

Index analyzed

SQL> 
SQL> select height,
  2         blocks,
  3         lf_blks,
  4         br_blks,
  5         OPT_CMPR_COUNT,
  6         OPT_CMPR_PCTSAVE
  7    from index_stats
  8   where name = 'INX_OWNER_ID';

    HEIGHT     BLOCKS    LF_BLKS    BR_BLKS OPT_CMPR_COUNT OPT_CMPR_PCTSAVE
---------- ---------- ---------- ---------- -------------- ----------------
         2        256        161          1              1                0
         
����ѹ��֮��Leaf block ��ԭ����219���͵�161������Լ��58��block ����������һ��ִ�мƻ�+ͳ����Ϣ

SQL> select count(*) from t1,t2 where t1.id=t2.id and t1.owner='SCOTT';

Elapsed: 00:00:00.03

Execution Plan
----------------------------------------------------------
Plan hash value: 277464349

---------------------------------------------------------------------------------------
| Id  | Operation              | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |              |     1 |    16 |    45   (3)| 00:00:01 |
|   1 |  SORT AGGREGATE        |              |     1 |    16 |            |          |
|*  2 |   HASH JOIN            |              |  2416 | 38656 |    45   (3)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN    | INX_OWNER_ID |  2416 | 26576 |     7   (0)| 00:00:01 |
|   4 |    INDEX FAST FULL SCAN| INX_ID       | 72475 |   353K|    37   (0)| 00:00:01 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("T1"."ID"="T2"."ID")
   3 - access("T1"."OWNER"='SCOTT')


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
        169  consistent gets
          0  physical reads
          0  redo size
        422  bytes sent via SQL*Net to client
        420  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed

�ɴ˿ɼ�������ѹ��֮���߼�����û���½�������169������������leaf blcok���������ˣ����������˴洢�ռ䣬�ܽ�������IO      

--�������� left join 
SELECT *
  FROM my_order o
  LEFT JOIN my_userinfo u
    ON o.uid = u.uid
  LEFT JOIN my_productinfo p
    ON o.pid = p.pid
 WHERE (o.display = 0)
   AND (o.ostaus = 1)
 ORDER BY o.selltime DESC LIMIT 0, 15;

#��д��
SELECT *
  FROM (SELECT *
          FROM my_order o
         WHERE (o.display = 0)
           AND (o.ostaus = 1)
         ORDER BY o.selltime DESC LIMIT 0, 15) o
  LEFT JOIN my_userinfo u
    ON o.uid = u.uid
  LEFT JOIN my_productinfo p
    ON o.pid = p.pid
 ORDER BY o.selltime DESC limit 0, 15;
