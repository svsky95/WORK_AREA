--����ɾ���û�����ռ估�����ļ�
SELECT * FROM dba_users t WHERE t.username LIKE 'NF%';
SELECT  * FROM dba_tablespaces t WHERE t.TABLESPACE_NAME LIKE 'DZDZ%';
DROP USER NF_FDM_T CASCADE;
DROP TABLESPACE  DZDZ_DATA including Contents AND DATAFILES CASCADE constraints;

--�������
ERROR at line 1:
ORA-00604: error occurred at recursive SQL level 1
ORA-38301: can not perform DDL/DML over objects in Recycle Bin
 1. ���recycle bin�еı�ռ䣺
purge tablespace tablespace_name;
2. ���ĳ����ռ��ڵ�ĳ���û��Ķ���
pruge tablespace tablespace_name user user_name
3. �����ǰ�û��Ķ���
purge recyclebin
4. ��������û��Ķ���
purge dba_recyclebin
5. sysdbaȨ��
drop table table_name purge ����ɾ��
6. ɾ������Ĺ���������
purge index index_name 
3������ִ��ɾ�����


--����
SELECT 'DROP TABLESPACE ' || t.tablespace_name ||
       ' including Contents AND DATAFILES CASCADE constraints;'
  FROM DBA_TABLESPACES T
 WHERE T.TABLESPACE_NAME LIKE 'dzdz%';
 
--�鿴ɾ���Ľ���
lsof| grep deleted
oracle      714    oracle  266u      REG              252,4 34359730176  194249016 /ora_data/sjyydb/data/NF_FDM_H_12.DBF (deleted)
oracle      714    oracle  267u      REG              252,4 34359730176  194249015 /ora_data/sjyydb/data/NF_FDM_H_11.DBF (deleted)

--˵���ļ��Ѿ�ɾ�������Ǿ�����ڣ����ǿ��Եȴ�����Լ30�����ڣ����ͷſռ�
--�������ͷſռ�
kill -9 714   

##��ռ�ɾ��30�������Ϸǳ�������Ҫ���ֵ����з���
SQL>  exec dbms_stats.gather_fixed_objects_stats;
SQL> exec dbms_stats.gather_dictionary_stats;
SQL> execute dbms_stats.gather_schema_stats('sys');


###����Ψһ�����޷�ɾ��
SELECT 'ALTER TABLE '||t.owner||'.'||t.table_name||' DROP CONSTRAINT '||t.index_name||' cascade;' FROM Dba_Indexes t WHERE t.TABLESPACE_NAME='TS_HX_SB_DATA';



--Լ��ԭ����ɾ��ʧ��
����1��ɾ����ռ��ڼ��������� ORA-29857

ɾ����ռ���䣺DROP TABLESPACE SAC INCLUDING CONTENTS AND DATAFILES;
����MOS�ĵ���
How To Resolve ORA-29857 During a Drop Tablespace although No Domain Index exists in This Tablespace (�ĵ� ID 1610456.1)
����ORA-29857��������ĵ�˵�ĺ������
����

ɾ����ռ�ʱ����������ORA-29857�����磺
SQL> drop tablespace SAC including contents and datafiles

drop tablespace SAC including contents and datafiles
*
ERROR at line 1:
ORA-29857: domain indexes and/or secondary objects exist in the tablespace

Ȼ�����㲢δ�������ռ��з�����������

SQL> SELECT OWNER,INDEX_NAME, TABLE_OWNER, TABLE_NAME
 FROM DBA_INDEXES WHERE INDEX_TYPE='DOMAIN'
 AND TABLESPACE_NAME ='SAC';

no rows selected

ԭ��

    The table which is in the tablespace to be dropped has a domain index which needs to be dropped before dropping the tablespace.
    Domain indexes cannot be created in a specific tablespace and the TABLESPACE_NAME column in DBA_INDEXES is always null for domain indexes.

Ҫɾ���ı�ռ��еı���һ���������������������ɾ����ռ�ǰ��Ҫ��ɾ������
���������ܱ�������ָ���ı�ռ䣬������������DBA_INDEXES�е�TABLESPACE_NAME��ֵ���ǿ�ֵ��
���������

You need to identify and drop the secondary objects:
����Ҫ�ҳ���ɾ����������

1.The domain index associated with a table in the tablespace to be dropped can be identified from the following query:
Ҫɾ�������������ռ��еı���ص�����������ͨ������Ĳ�ѯ�ҳ�����

SQL> SELECT INDEX_NAME,I.TABLE_NAME FROM DBA_INDEXES I, DBA_TABLES T 
WHERE T.TABLE_NAME=I.TABLE_NAME 
AND T.OWNER=I.OWNER
AND I.INDEX_TYPE='DOMAIN'
and t.TABLESPACE_NAME='&TABLESPACE_NAME';

2.Secondary objects associated with domain indexes, can be identified from the following query:
����������صĶ������󣬿���ͨ������Ĳ�ѯ�ҳ�����

SQL> SELECT SECONDARY_OBJECT_OWNER,SECONDARY_OBJECT_NAME,SECONDARY_OBJDATA_TYPE FROM DBA_SECONDARY_OBJECTS WHERE INDEX_NAME='INDEX_NAME_From_Previous_Query';

Once you identify the secondary objects, you can drop those and then drop the tablespace.
һ�����ҳ���Щ����������Ϳ���ɾ������Ȼ����ɾ����ռ䡣

Please see the following example:
�뿴��������ӣ�

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

����2��ɾ����ռ��ڼ����� ORA-02429

����ORA-02429�������MOS�ĵ�������Ҳ�������
Drop Tablespace Failed with ORA-02429: cannot drop index used for enforcement of unique/primary key (�ĵ� ID 1918060.1)
����

ɾ����ռ�ʧ�ܣ���������Ĵ���

SQL> DROP TABLESPACE REP_DATA INCLUDING CONTENTS AND DATAFILES;
DROP TABLESPACE REP_DATA INCLUDING CONTENTS AND DATAFILES
*
ERROR at line 1:
ORA-00604: error occurred at recursive SQL level 1
ORA-02429: cannot drop index used for enforcement of unique/primary key

���������

Find the constraint name for the unique/primary key, disable the constraint and drop the tablespace again.
�ҵ���ЩΩһ/����Լ������������ЩԼ��Ȼ���ٴ�ɾ����ռ䡣

Steps:
=====
1) Execute below query to find the constraint name:
ִ������Ĳ�ѯ���ҵ�Լ������
SQL> select owner, constraint_name,table_name,index_owner,index_name
from dba_constraints
where (index_owner,index_name) in (select owner,index_name from dba_indexes
where tablespace_name='<tablespace_name>');
 
2) Disable the constraint:
����Լ����
SQL> ALTER TABLE <table_name> DISABLE CONSTRAINT <constraint_name>;
--��������Լ��
SELECT 'ALTER TABLE '||owner||'.'||table_name||' DISABLE CONSTRAINT '||constraint_name||';'
from dba_constraints
where (index_owner,index_name) in (select owner,index_name from dba_indexes
where tablespace_name='TS_HX_SB_IDX');

--����ɾ������
SELECT 'drop index '||t.owner||'.'||t.index_name||';' FROM dba_indexes t WHERE t.tablespace_name='TS_HX_SB_IDX';
 
3) Drop the tablespace:
ɾ����ռ䣺
SQL> DROP TABLESPACE <tablespace_name> INCLUDING CONTENTS AND DATAFILES;  

����3����ռ�ɾ����ϣ��������̿ռ䲻�ͷ�

����ȴ��ܳ�ʱ�䶼û���ͷţ���ô�ɲο���http://www.linuxidc.com/Linux/2016-04/130312.htm

    ����Ĳ����������£�
    1������һ��lsof���װ�ϣ�google�Ͽ����ѵ�
    2���ҵ������ñ�ɾ�ļ��Ľ���
    lsof | grep deleted
oracle    95890    oracle  257u      REG              252,4 34359730176  194248898 /ora_data/sjyydb/data/SJYYDB/datafile/o1_mf_ts_hx_sb_gcv1qxkz_.dbf (deleted)    
    3��kill -9 95890 ɱ����Ӧ�Ľ��̿ռ���ͷ���
