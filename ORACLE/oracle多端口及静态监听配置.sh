--¶à¶Ë¿ÚÅäÖÃ
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1522))
      (ADDRESS = (PROTOCOL = TCP)(HOST =10.10.8.12)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST =10.10.8.12)(PORT = 1522))
    )
  )

SID_LIST_LISTENER =                                   //¾²Ì¬×¢²á
(SID_LIST =
  (SID_DESC =
  (GLOBAL_DBNAME = sxfxdb)
  (SID_NAME = sxfxdb)
  (ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1)
  )
  (SID_DESC =
  (GLOBAL_DBNAME = sxfxdb01)
  (SID_NAME = sxfxdb01)
  (ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1)
  )
)


Service "bigdata" has 2 instance(s).
  Instance "bigdata", status UNKNOWN, has 1 handler(s) for this service...   //¾²Ì¬¼àÌý
  Instance "bigdata", status READY, has 1 handler(s) for this service...     //¶¯Ì¬¼àÌý
  	
  	
  	