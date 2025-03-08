https://blog.csdn.net/qq_40687433/article/details/84990989?depth_1-utm_source=distribute.pc_relevant.none-task&utm_source=distribute.pc_relevant.none-task
#####关于字段类型转换的函数索引创建#####
原始SQL：
sql_id=1j0b7qbz77hwy

select *
  from BIZXFILES.fstax_zzsfpdk_fp fp
  left join BIZXFILES.FSTAX_ZZSFPDK_KZ_FP kz
    on fp.xlh = to_number(kz.xlh)
 where fp.xlh = '100205938739'
   and yxbz = 'Y';
   
##PS：
1、两个表的数据量都是500W，正常的是在BIZXFILES.fstax_zzsfpdk_fp根据条件，筛选出一条数据，然后在BIZXFILES.FSTAX_ZZSFPDK_KZ_FP表中，
走索引就可以了,并且xlh在两个表中都有相应的索引，且都为全局索引。
2、根据分析不存在数据分布不均，及为空的情况。
3、fp.xlh为number类型  kz.xlh为varchar2。 

##执行计划如下：
Plan hash value: 3182701912

----------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                     |       |       | 18212 (100)|          |
|   1 |  NESTED LOOPS OUTER          |                     |     1 |  1735 | 18212   (1)| 00:03:39 |
|*  2 |   TABLE ACCESS BY INDEX ROWID| FSTAX_ZZSFPDK_FP    |     1 |  1098 |     3   (0)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN         | FSTAX_ZZSFPDK_FP_PK |     1 |       |     2   (0)| 00:00:01 |
|*  4 |   TABLE ACCESS FULL          | FSTAX_ZZSFPDK_KZ_FP |     1 |   637 | 18209   (1)| 00:03:39 |
----------------------------------------------------------------------------------------------------

  - dynamic sampling used for this statement (level=2)
  
##处理方法如下：
1、根据动态采样的提示，给两个表都收集统计信息，但是执行计划未改变。
2、根据sql_tunning建立函数索引。
create index BIZXFILES.IDX_tonum_xlh on BIZXFILES.FSTAX_ZZSFPDK_KZ_FP(TO_NUMBER("XLH")) online nologging parallel 8;
3、建立函数索引后，在看执行计划，虽然执行计划改变了，但是cost很高。
Plan hash value: 3480197700

----------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                     |       |       | 18043 (100)|          |
|   1 |  NESTED LOOPS OUTER          |                     | 54943 |    61M| 18043   (1)| 00:03:37 |
|*  2 |   TABLE ACCESS BY INDEX ROWID| FSTAX_ZZSFPDK_FP    |     1 |  1102 |     3   (0)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN         | FSTAX_ZZSFPDK_FP_PK |     1 |       |     2   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID| FSTAX_ZZSFPDK_KZ_FP | 54943 |  4024K| 18040   (1)| 00:03:37 |
|*  5 |    INDEX RANGE SCAN          | IDX_TONUM_XLH       | 21977 |       |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------
   - dynamic sampling used for this statement (level=2)
   
4、但是提示了，动态采样，之后重新再收集统计信息，计划正常。
Plan hash value: 3480197700

----------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                     |       |       |     6 (100)|          |
|   1 |  NESTED LOOPS OUTER          |                     |     1 |  1185 |     6   (0)| 00:00:01 |
|*  2 |   TABLE ACCESS BY INDEX ROWID| FSTAX_ZZSFPDK_FP    |     1 |  1102 |     3   (0)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN         | FSTAX_ZZSFPDK_FP_PK |     1 |       |     2   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID| FSTAX_ZZSFPDK_KZ_FP |     1 |    83 |     3   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN          | IDX_TONUM_XLH       |     1 |       |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------

#####最终问题分析#####
SQL>  explain plan for select  * from  BIZXFILES.fstax_zzsfpdk_fp fp left join BIZXFILES.FSTAX_ZZSFPDK_KZ_FP kz on fp.xlh=kz.xlh where fp.xlh = '100205938739'    and yxbz = 'Y';

Explained.

Elapsed: 00:00:00.01
SQL> select * from table(dbms_xplan.display);

PLAN_TABLE_OUTPUT
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 3480197700

----------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                     |     1 |  1185 |     6   (0)| 00:00:01 |
|   1 |  NESTED LOOPS OUTER          |                     |     1 |  1185 |     6   (0)| 00:00:01 |
|*  2 |   TABLE ACCESS BY INDEX ROWID| FSTAX_ZZSFPDK_FP    |     1 |  1102 |     3   (0)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN         | FSTAX_ZZSFPDK_FP_PK |     1 |       |     2   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID| FSTAX_ZZSFPDK_KZ_FP |     1 |    83 |     3   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN          | IDX_TONUM_XLH       |     1 |       |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("FP"."YXBZ"='Y')
   3 - access("FP"."XLH"=100205938739)
   5 - access(TO_NUMBER("XLH"(+))=100205938739)
       filter("FP"."XLH"=TO_NUMBER("XLH"(+)))
       
通过把to_number在原语句中去掉，可以看出，关联的条件，确实进行了类型转换，所以一般的普通索引，根本用不上。所以即便在sql语句上去掉，装换条件，
经过oracle的转换后，依然需要用函数索引解决。
