--彻底删除用户、表空间及数据文件
SELECT * FROM dba_users t WHERE t.username LIKE 'NF%';
SELECT  * FROM dba_tablespaces t WHERE t.TABLESPACE_NAME LIKE 'DZDZ%';
DROP USER NF_FDM_T CASCADE;
DROP TABLESPACE  DZDZ_DATA including Contents AND DATAFILES CASCADE constraints;

--如果出错
ERROR at line 1:
ORA-00604: error occurred at recursive SQL level 1
ORA-38301: can not perform DDL/DML over objects in Recycle Bin
 1. 清空recycle bin中的表空间：
purge tablespace tablespace_name;
2. 清空某个表空间内的某个用户的对象：
pruge tablespace tablespace_name user user_name
3. 清除当前用户的对象：
purge recyclebin
4. 清除所有用户的对象：
purge dba_recyclebin
5. sysdba权限
drop table table_name purge 永久删除
6. 删除对象的关联索引：
purge index index_name 
3、重新执行删除语句


--批量
SELECT 'DROP TABLESPACE ' || t.tablespace_name ||
       ' including Contents AND DATAFILES CASCADE constraints;'
  FROM DBA_TABLESPACES T
 WHERE T.TABLESPACE_NAME LIKE 'dzdz%';
 
--查看删除的进程
lsof| grep deleted
oracle      714    oracle  266u      REG              252,4 34359730176  194249016 /ora_data/sjyydb/data/NF_FDM_H_12.DBF (deleted)
oracle      714    oracle  267u      REG              252,4 34359730176  194249015 /ora_data/sjyydb/data/NF_FDM_H_11.DBF (deleted)

--说明文件已经删除，但是句柄存在，这是可以等待，大约30分钟内，会释放空间
--可立即释放空间
kill -9 714   

##表空间删除30分钟以上非常慢，需要对字典表进行分析
SQL>  exec dbms_stats.gather_fixed_objects_stats;
SQL> exec dbms_stats.gather_dictionary_stats;
SQL> execute dbms_stats.gather_schema_stats('sys');


###存在唯一索引无法删除
SELECT 'ALTER TABLE '||t.owner||'.'||t.table_name||' DROP CONSTRAINT '||t.index_name||' cascade;' FROM Dba_Indexes t WHERE t.TABLESPACE_NAME='TS_HX_SB_DATA';



--约束原因导致删除失败
问题1：删除表空间期间遭遇报错 ORA-29857

删除表空间语句：DROP TABLESPACE SAC INCLUDING CONTENTS AND DATAFILES;
根据MOS文档：
How To Resolve ORA-29857 During a Drop Tablespace although No Domain Index exists in This Tablespace (文档 ID 1610456.1)
对于ORA-29857这个错误，文档说的很清楚：
现象：

删除表空间时，遇到报错ORA-29857，例如：
SQL> drop tablespace SAC including contents and datafiles

drop tablespace SAC including contents and datafiles
*
ERROR at line 1:
ORA-29857: domain indexes and/or secondary objects exist in the tablespace

然而，你并未在这个表空间中发现域索引：

SQL> SELECT OWNER,INDEX_NAME, TABLE_OWNER, TABLE_NAME
 FROM DBA_INDEXES WHERE INDEX_TYPE='DOMAIN'
 AND TABLESPACE_NAME ='SAC';

no rows selected

原因：

    The table which is in the tablespace to be dropped has a domain index which needs to be dropped before dropping the tablespace.
    Domain indexes cannot be created in a specific tablespace and the TABLESPACE_NAME column in DBA_INDEXES is always null for domain indexes.

要删除的表空间中的表有一个域索引，这个域索引在删除表空间前需要被删除掉。
域索引不能被创建在指定的表空间，对于域索引，DBA_INDEXES中的TABLESPACE_NAME列值总是空值。
解决方法：

You need to identify and drop the secondary objects:
你需要找出并删除二级对象：

1.The domain index associated with a table in the tablespace to be dropped can be identified from the following query:
要删除的与在这个表空间中的表相关的域索引可以通过下面的查询找出来：

SQL> SELECT INDEX_NAME,I.TABLE_NAME FROM DBA_INDEXES I, DBA_TABLES T 
WHERE T.TABLE_NAME=I.TABLE_NAME 
AND T.OWNER=I.OWNER
AND I.INDEX_TYPE='DOMAIN'
and t.TABLESPACE_NAME='&TABLESPACE_NAME';

2.Secondary objects associated with domain indexes, can be identified from the following query:
与域索引相关的二级对象，可以通过下面的查询找出来：

SQL> SELECT SECONDARY_OBJECT_OWNER,SECONDARY_OBJECT_NAME,SECONDARY_OBJDATA_TYPE FROM DBA_SECONDARY_OBJECTS WHERE INDEX_NAME='INDEX_NAME_From_Previous_Query';

Once you identify the secondary objects, you can drop those and then drop the tablespace.
一旦你找出这些二级对象，你就可以删除它们然后再删除表空间。

Please see the following example:
请看下面的例子：

SQL> CREATE TABLESPACE SAC DATAFILE 'C:\SAC.DBF' SIZE 50M;

Tablespace created.

SQL> CREATE TABLE SAC TABLESPACE SAC AS SELECT * FROM ALL_OBJECTS;

Table created.

SQL> begin
 ctx_ddl.create_preference('SUBSTRING_PREF','BASIC_WORDLIST');
 ctx_ddl.set_attribute('SUBSTRING_PREF', 'SUBSTRING_INDEX','TRUE');
 end;
 /

PL/SQL procedure successfully completed.


-- Trying to create the domain index in specific tablespace fails with ORA-29850:

SQL> CREATE INDEX SAC_INDX ON SAC(OBJECT_TYPE) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('WORDLIST SUBSTRING_PREF MEMORY 50M') TABLESPACE SAC;
CREATE INDEX SAC_INDX ON SAC(OBJECT_TYPE) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('WORDLIST SUBSTRING_PREF MEMORY 50M') TABLESPACE SAC
*
ERROR at line 1:
ORA-29850: invalid option for creation of domain indexes

SQL> CREATE INDEX SAC_INDX ON SAC(OBJECT_TYPE) INDEXTYPE IS CTXSYS.CONTEXT PARAMETERS ('WORDLIST SUBSTRING_PREF MEMORY 50M');

Index created. 

SQL> drop tablespace sac including contents and datafiles;
drop tablespace sac including contents and datafiles
*
ERROR at line 1:
ORA-29857: domain indexes and/or secondary objects exist in the tablespace

-- Trying to find the domain index in this tablespace:

SQL> SELECT OWNER,INDEX_NAME, TABLE_OWNER, TABLE_NAME
 FROM DBA_INDEXES WHERE INDEX_TYPE='DOMAIN'
 AND TABLESPACE_NAME ='SAC';

no rows selected

--Trying to find segments created in this newly created tablespace:

SQL> SELECT SEGMENT_NAME,SEGMENT_TYPE FROM DBA_SEGMENTS WHERE TABLESPACE_NAME='SAC';

SEGMENT_NAME SEGMENT_TYPE
-------------------- ------------------
SAC TABLE

-- Trying to find the segment for index SAC_INDX :

SQL> SELECT TABLESPACE_NAME FROM DBA_SEGMENTS WHERE SEGMENT_NAME='SAC_INDX';

no rows selected

-- Trying to find the tablespace for index SAC_INDX from DBA_INDEXES :

SQL> set null null
SQL> select INDEX_TYPE,TABLE_TYPE,DOMIDX_STATUS,DOMIDX_OPSTATUS,SEGMENT_CREATED,TABLESPACE_NAME from DBA_INDEXES where INDEX_NAME='SAC_INDX';

INDEX_TYPE TABLE_TYPE DOMIDX_STATU DOMIDX SEG TABLESPACE_NAME
--------------------------- ----------- ------------ ------ --- ------------------------------
DOMAIN TABLE VALID VALID YES null

--To find the indexes that are causing ORA-29857 , please use the following query :

SQL> col TABLE_NAME for a30
SQL> col INDEX_NAME for a30

SQL> SELECT INDEX_NAME,I.TABLE_NAME FROM DBA_INDEXES I, DBA_TABLES T

 WHERE T.TABLE_NAME=I.TABLE_NAME
 AND T.OWNER=I.OWNER
 AND I.INDEX_TYPE='DOMAIN'
 and t.TABLESPACE_NAME='SAC';

INDEX_NAME TABLE_NAME
------------------------------ ------------------------------
SAC_INDX SAC

SQL> DROP INDEX SAC_INDX;

Index dropped.

--confirm that no secondary objects associated with domain index still exist:

SQL> SELECT SECONDARY_OBJECT_OWNER,SECONDARY_OBJECT_NAME,SECONDARY_OBJDATA_TYPE FROM DBA_SECONDARY_OBJECTS WHERE INDEX_NAME='SAC_INDX';

no rows selected

SQL> DROP TABLESPACE SAC INCLUDING CONTENTS AND DATAFILES;

Tablespace dropped.

问题2：删除表空间期间遭遇 ORA-02429

对于ORA-02429这个错误，MOS文档的描述也很清楚：
Drop Tablespace Failed with ORA-02429: cannot drop index used for enforcement of unique/primary key (文档 ID 1918060.1)
现象：

删除表空间失败，伴随下面的错误：

SQL> DROP TABLESPACE REP_DATA INCLUDING CONTENTS AND DATAFILES;
DROP TABLESPACE REP_DATA INCLUDING CONTENTS AND DATAFILES
*
ERROR at line 1:
ORA-00604: error occurred at recursive SQL level 1
ORA-02429: cannot drop index used for enforcement of unique/primary key

解决方法：

Find the constraint name for the unique/primary key, disable the constraint and drop the tablespace again.
找到那些惟一/主键约束名，禁用这些约束然后再次删除表空间。

Steps:
=====
1) Execute below query to find the constraint name:
执行下面的查询来找到约束名：
SQL> select owner, constraint_name,table_name,index_owner,index_name
from dba_constraints
where (index_owner,index_name) in (select owner,index_name from dba_indexes
where tablespace_name='<tablespace_name>');
 
2) Disable the constraint:
禁用约束：
SQL> ALTER TABLE <table_name> DISABLE CONSTRAINT <constraint_name>;
--批量禁用约束
SELECT 'ALTER TABLE '||owner||'.'||table_name||' DISABLE CONSTRAINT '||constraint_name||';'
from dba_constraints
where (index_owner,index_name) in (select owner,index_name from dba_indexes
where tablespace_name='TS_HX_SB_IDX');

--批量删除索引
SELECT 'drop index '||t.owner||'.'||t.index_name||';' FROM dba_indexes t WHERE t.tablespace_name='TS_HX_SB_IDX';
 
3) Drop the tablespace:
删除表空间：
SQL> DROP TABLESPACE <tablespace_name> INCLUDING CONTENTS AND DATAFILES;  

问题3：表空间删除完毕，主机磁盘空间不释放

如果等待很长时间都没有释放，那么可参考：http://www.linuxidc.com/Linux/2016-04/130312.htm

    建议的操作方法如下：
    1、下载一个lsof软件装上，google上可以搜到
    2、找到正在用被删文件的进程
    lsof | grep deleted
oracle    95890    oracle  257u      REG              252,4 34359730176  194248898 /ora_data/sjyydb/data/SJYYDB/datafile/o1_mf_ts_hx_sb_gcv1qxkz_.dbf (deleted)    
    3、kill -9 95890 杀掉相应的进程空间就释放了
