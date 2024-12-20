--采用删除条件的方式，取出rowid，然后每5000行删除后提交一次。
DECLARE
  CURSOR MYCURSOR IS
    SELECT /*+parallel 10*/ ROWID
      FROM HX_ZS.ZS_JKS_BAK2
     WHERE (SPUUID) IN (SELECT SPUUID
                          FROM HX_ZS.ZS_JKS_BAK2
                         GROUP BY SPUUID
                        HAVING COUNT(SPUUID) > 1)
       AND ROWID NOT IN (SELECT MIN(ROWID)
                           FROM HX_ZS.ZS_JKS_BAK2
                          GROUP BY SPUUID
                         HAVING COUNT(*) > 1);
  TYPE ROWID_TABLE_TYPE IS TABLE OF ROWID INDEX BY PLS_INTEGER;
  V_ROWID ROWID_TABLE_TYPE;
  P_ROWS       NUMBER;
BEGIN
  OPEN MYCURSOR;
  LOOP
    FETCH MYCURSOR BULK COLLECT
      INTO V_ROWID LIMIT 5000;
    EXIT WHEN V_ROWID.COUNT = 0;
    FORALL I IN V_ROWID.FIRST .. V_ROWID.LAST
      DELETE FROM HX_ZS.ZS_JKS_BAK2 WHERE ROWID = V_ROWID(I); 
          P_ROWS := SQL%ROWCOUNT;
      DBMS_OUTPUT.PUT_LINE(P_ROWS); 
    COMMIT;
  END LOOP;
  CLOSE MYCURSOR;
END;
