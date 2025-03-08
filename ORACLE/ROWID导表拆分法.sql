/*SUBOBJECT_NAME �Ǳ�ķ������������Ƿ��������ѷ��������еȷ�*/
SELECT ROWNUM group_id , ' rowid between ' || CHR(39) ||
       DBMS_ROWID.ROWID_CREATE(1, DOI, LO_FNO, LO_BLOCK, 0) || CHR(39) ||
       ' and  ' || CHR(39) ||
       DBMS_ROWID.ROWID_CREATE(1, DOI, HI_FNO, HI_BLOCK, 1000000) ||
       CHR(39) ROWID_GROUP,SUBOBJECT_NAME PARTITION_NAME
  FROM (SELECT DISTINCT DOI,
                        GRP,
                        FIRST_VALUE(RELATIVE_FNO) OVER(PARTITION BY DOI, GRP ORDER BY RELATIVE_FNO, BLOCK_ID ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LO_FNO,
                        FIRST_VALUE(BLOCK_ID) OVER(PARTITION BY DOI, GRP ORDER BY RELATIVE_FNO, BLOCK_ID ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) LO_BLOCK,
                        LAST_VALUE(RELATIVE_FNO) OVER(PARTITION BY DOI, GRP ORDER BY RELATIVE_FNO, BLOCK_ID ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) HI_FNO,
                        LAST_VALUE(BLOCK_ID + BLOCKS - 1) OVER(PARTITION BY DOI, GRP ORDER BY RELATIVE_FNO, BLOCK_ID ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) HI_BLOCK,
                        SUM(BLOCKS) OVER(PARTITION BY DOI, GRP) SUM_BLOCKS,
                        SUBOBJECT_NAME
          FROM (SELECT OBJ.OBJECT_ID,
                       OBJ.SUBOBJECT_NAME,
                       OBJ.DATA_OBJECT_ID AS DOI,
                       EXT.RELATIVE_FNO,
                       EXT.BLOCK_ID,
                       (SUM(BLOCKS) OVER()) SUM,
                       (SUM(BLOCKS)
                        OVER(ORDER BY DATA_OBJECT_ID, RELATIVE_FNO, BLOCK_ID) - 0.01) SUM_FNO,
                       TRUNC((SUM(BLOCKS) OVER(ORDER BY DATA_OBJECT_ID,
                                               RELATIVE_FNO,
                                               BLOCK_ID) - 0.01) /
                             (SUM(BLOCKS) OVER() / 5)) GRP,    /*��ּ���*/
                       EXT.BLOCKS
                  FROM DBA_EXTENTS EXT, DBA_OBJECTS OBJ
                 WHERE EXT.SEGMENT_NAME = UPPER('CONF_SJYY_ZK')  /*�������*/
                   AND EXT.OWNER = UPPER('SJYY')         /*�������û�*/
                   AND OBJ.OWNER = EXT.OWNER
                   AND OBJ.OBJECT_NAME = EXT.SEGMENT_NAME
                   AND OBJ.DATA_OBJECT_ID IS NOT NULL
                 ORDER BY DATA_OBJECT_ID, RELATIVE_FNO, BLOCK_ID)
         ORDER BY DOI, GRP);
         