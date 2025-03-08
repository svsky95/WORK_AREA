https://blog.csdn.net/qq_40687433/article/details/84990989?depth_1-utm_source=distribute.pc_relevant.none-task&utm_source=distribute.pc_relevant.none-task
#####�����ֶ�����ת���ĺ�����������#####
ԭʼSQL��
sql_id=1j0b7qbz77hwy

select *
  from BIZXFILES.fstax_zzsfpdk_fp fp
  left join BIZXFILES.FSTAX_ZZSFPDK_KZ_FP kz
    on fp.xlh = to_number(kz.xlh)
 where fp.xlh = '100205938739'
   and yxbz = 'Y';
   
##PS��
1�������������������500W������������BIZXFILES.fstax_zzsfpdk_fp����������ɸѡ��һ�����ݣ�Ȼ����BIZXFILES.FSTAX_ZZSFPDK_KZ_FP���У�
�������Ϳ�����,����xlh���������ж�����Ӧ���������Ҷ�Ϊȫ��������
2�����ݷ������������ݷֲ���������Ϊ�յ������
3��fp.xlhΪnumber����  kz.xlhΪvarchar2�� 

##ִ�мƻ����£�
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
  
##���������£�
1�����ݶ�̬��������ʾ�����������ռ�ͳ����Ϣ������ִ�мƻ�δ�ı䡣
2������sql_tunning��������������
create index BIZXFILES.IDX_tonum_xlh on BIZXFILES.FSTAX_ZZSFPDK_KZ_FP(TO_NUMBER("XLH")) online nologging parallel 8;
3�����������������ڿ�ִ�мƻ�����Ȼִ�мƻ��ı��ˣ�����cost�ܸߡ�
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
   
4��������ʾ�ˣ���̬������֮���������ռ�ͳ����Ϣ���ƻ�������
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

#####�����������#####
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
       
ͨ����to_number��ԭ�����ȥ�������Կ�����������������ȷʵ����������ת��������һ�����ͨ�����������ò��ϡ����Լ�����sql�����ȥ����װ��������
����oracle��ת������Ȼ��Ҫ�ú������������
