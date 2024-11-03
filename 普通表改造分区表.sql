--��ͨ��ķ�����
procedure p_rename_001 (p_tab in varchar2)
as
/*
���ܣ���ԭ��������Ϊ_yyyymmdd��ʽ�ı���
���Ƶ㣺 Ҫ����RENMAE��Ŀ����Ѵ��ڵ�����������ж�
*/
V_CNT_RE_TAB  NUMBER(9) :=0;
v_sql_p_rename         varchar2(4000);
begin
SELECT  COUNT(*)   INTO V_CNT_RE_TAB FROM user_objects where object_name=UPPER(P_ TAB||'_'||YYYYMMDD);
if V_CNT_RE_TAB=0 then
v_sql_p_rename:= 'rename '||P_TAB ||' to '||P_TAB||'_'||YYYYMMDD;
--   DBMS_OUTPUT.PUT_LINE(v_sql_p_rename);--����ʹ��
p_insert_log(p_tab,'P_RENAME',v_sql_p_rename,'���ԭ�������������Ϊ_YYYYMMDD��ʽ',1);
execute immediate(v_sql_p_rename); --�����������жϣ�rename������ʵ��ɣ��������ֻ��Ϊ���ɽű���������ʵִ�з�����������
���ٰ������RENAME��ȥ��
ELSE
RAISE_APPLICATION_ERROR(-20066,'���ݱ�'||P_TAB||'_'||YYYYMMDD||'�Ѵ���,����ɾ�����������ñ��ݱ���ټ���ִ�У�');
--  DBMS_OUTPUT.PUT_LINE('���ݱ�'||P_TAB||'_'||YYYYMMDD||'�Ѵ���');
end if;
DBMS_OUTPUT.PUT_LINE('��������1(����ԭ��)-------��'||p_tab ||' ��RENMAE�� '||p_tab||'_'||YYYYMMDD||'����ɾ����Լ��������');
end p_rename_001;
�ű�13-18����������ǰ��ԭ�������� 


--------------------------------------------------------------------------------------------


����˼·2
procedure p_ctas_002 (p_tab in varchar2,
p_struct_only  in number,
p_deal_flag in number,
p_part_colum in varchar2,
p_parallel in number default 4,
p_tablespace IN VARCHAR2)
as
/*
���ܣ���CREATE TABLE AS SELECT �ķ�ʽ��RENAME��_yyyymmdd�����½���һ��ֻ��MAXVALUE�ĳ���������
���Ƶ㣺Ҫ���ǲ��У�nologging �����ٷ�ʽ��ҲҪ�������ս�NOLOGGING��PARALLEL�ָ�������״̬
*/
v_sql_p_ctas         varchar2(4000);
begin
v_sql_p_ctas:='create table '||p_tab
||' partition by range ( '||p_part_colum||' ) ('
|| ' partition P_MAX  values less than (maxvalue))'||
' nologging parallel 4  tablespace '||p_tablespace||
' as select /*+parallel(t,'||p_parallel||')*/ *'||
' from '|| P_TAB||'_'||YYYYMMDD ;
if p_struct_only=0 then
v_sql_p_ctas:=v_sql_p_ctas ||' where 1=2';
else
v_sql_p_ctas:=v_sql_p_ctas ||' where 1=1';
end if;
--DBMS_OUTPUT.PUT_LINE(v_sql_p_ctas);--����ʹ��
p_insert_log(p_tab,'p_ctas',v_sql_p_ctas,'���CTAS������������',2,1);
p_if_judge(v_sql_p_ctas,p_deal_flag);
v_sql_p_ctas:='alter table '|| p_tab ||' logging';
p_insert_log(p_tab,'p_ctas',v_sql_p_ctas,'���·������޸Ļ�LOGGING����',2,2);
p_if_judge(v_sql_p_ctas,p_deal_flag);
v_sql_p_ctas:='alter table '|| p_tab || ' noparallel';
p_insert_log(p_tab,'p_ctas',v_sql_p_ctas,'���·������޸Ļ�NOPARALLEL����',2,3);
p_if_judge(v_sql_p_ctas,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('��������2(��������)-------ͨ��CTAS�ķ�ʽ�� '||p_tab||'_'||YYYYMMDD|| ' ���½�'||p_tab ||'����ɳ���������
�칤��');
end p_ctas_002;
�ű�13-19����CTAS���һ�Ž���MAX�������±�


--------------------------------------------------------------------------------------------

����˼·3
procedure p_split_part_003 (p_tab in varchar2,
p_deal_flag in number,
p_part_nums in number default 24,
p_tab_tablespace IN VARCHAR2)
as
/*
���ܣ���CREATE TABLE AS SELECT �ķ�ʽ�½���һ��ֻ��MAXVALUE�ĳ������������SPLIT��
���·ݽ����з֣�Ĭ��p_part_nums����24������������2��ķ�������һ������Ϊ��ǰ�µ�
��һ����
*/
v_first_day   date;
v_next_day    date;
v_prev_day    date;
v_sql_p_split_part         varchar2(4000);
begin
select to_date(to_char(sysdate, 'yyyymm') || '01', 'yyyymmdd')
into v_first_day
from dual;
for i in 1 .. p_part_nums loop
select add_months(v_first_day, i) into v_next_day from dual;
select add_months(v_next_day, -1) into v_prev_day from dual;
v_sql_p_split_part := 'alter table '||p_tab||' split partition p_MAX at ' ||
'(to_date(''' || to_char(v_next_day, 'yyyymmdd') ||
''',''yyyymmdd''))' || 'into (partition PART_' ||
to_char(v_prev_day, 'yyyymm') || ' tablespace '|| p_tab_tablespace||', partition p_MAX)';
-- DBMS_OUTPUT.PUT_LINE(v_sql_p_split_part);--����ʹ��
p_insert_log(p_tab,'p_split_part',v_sql_p_split_part,'��������ɷ���SPLIT����',3,i);
p_if_judge(v_sql_p_split_part,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('��������3(��������)-------���½���'||p_tab ||'��������ɷ���SPLIT����');
end p_split_part_003;
�ű�13-20���ѷ����±�split�ɶ������


--------------------------------------------------------------------------------------------

����˼·4
procedure p_tab_comments_004  (p_tab in varchar2,p_deal_flag in number)
as
/*
���ܣ���_YYYYMMDD���ݱ��еõ�����ֶε�ע�ͣ�Ϊ�·�����ı������ֶ�����ע��
*/
v_sql_p_tab_comments         varchar2(4000);
v_cnt number;
begin
select count(*) into v_cnt from user_tab_comments where table_name=UPPER (P_TAB)||'_'||YYYYMMDD AND COMMENTS IS NOT NULL;
if v_cnt>0 then
for i in (select * from user_tab_comments where table_name=UPPER(P_TAB)|| '_'||YYYYMMDD AND COMMENTS IS NOT NULL) loop
v_sql_p_tab_comments:='comment on table '||p_tab||' is '|| ''''||i.COMMENTS||'''';
-- DBMS_OUTPUT.PUT_LINE(v_sql_p_deal_tab_comments);--����ʹ��
p_insert_log(p_tab,'p_deal_comments',v_sql_p_tab_comments,'���·�����ı��ע�ͼ���',4,1);
p_if_judge(v_sql_p_tab_comments,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('��������4(���ע��)-------��'||p_tab ||'�����ӱ�����ע������');
ELSE
DBMS_OUTPUT.PUT_LINE('��������4(���ע��)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'��û�б�ע��!');
END IF;
end p_tab_comments_004;
�ű�13-21�����������±��ע��


--------------------------------------------------------------------------------------------


�뿴����p_col_comments_005���õ��е�ע�ͣ�
procedure p_col_comments_005  (p_tab in varchar2,p_deal_flag in number)
as
/*
���ܣ���_YYYYMMDD���ݱ��еõ�����ֶε�ע�ͣ�Ϊ�·�����ı������ֶ�����ע��
*/
v_sql_p_col_comments         varchar2(4000);
v_cnt number;
begin
select count(*) into v_cnt from user_col_comments where table_name=UPPER (P_TAB)||'_'||YYYYMMDD AND COMMENTS IS NOT NULL;
if v_cnt>0 then
for i in (select * from user_col_comments where table_name=UPPER(P_TAB)||'_' ||YYYYMMDD AND COMMENTS IS NOT NULL) loop
v_sql_p_col_comments:='comment on column '||p_tab||'.'||i.COLUMN_NAME||' is '|| ''''||i.COMMENTS||'''';
p_insert_log(p_tab,'p_deal_col_comments',v_sql_p_col_comments,'���·�������е�ע�ͼ���',5,1);
p_if_judge(v_sql_p_col_comments,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('��������5(�е�ע��)-------��'||p_tab ||'�������������ֶε�ע������');
else
DBMS_OUTPUT.PUT_LINE('��������5(�е�ע��)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'��û����ע��!');
end if;
end p_col_comments_005;
�ű�13-22�����������±������е�ע��


--------------------------------------------------------------------------------------------

�뿴����p_defau_and_null_006���õ���������Ƿ�Ϊ�յ����ԣ�
procedure p_defau_and_null_006 (p_tab in varchar2,p_deal_flag in number)
as
/*
���ܣ���_YYYYMMDD���ݱ��еõ�ԭ���DEFAULTֵ��Ϊ�·�����ı������ֶ�����DEFAULTֵ
*/
v_sql_defau_and_null        varchar2(4000);
v_cnt  number;
begin
select count(*) into v_cnt  from user_tab_columns where table_name=UPPER(P_TAB)|| '_'||YYYYMMDD and data_default is not null;
if v_cnt>0 then
for i in (select * from user_tab_columns where table_name=UPPER(P_TAB)||'_' ||YYYYMMDD and data_default is not null) loop
v_sql_defau_and_null:='alter table '||p_tab||' modify '||i.COLUMN_NAME ||' default ' ||i.data_default;
p_insert_log(p_tab,'p_deal_default',v_sql_defau_and_null,'���·������Ĭ��ֵ����',6);
p_if_judge(v_sql_defau_and_null,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('��������6(�պ�Ĭ��)-------��'||p_tab ||'�����Ĭ��DEFAULTֵ������');
else
DBMS_OUTPUT.PUT_LINE('��������6(�պ�Ĭ��)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'��û��DEFAULT��NULLֵ!');
end if; 
end p_defau_and_null_006;
�ű�13-23�����������±������е�null����


--------------------------------------------------------------------------------------------


�뿴����p_check_007���õ��е�check���ԣ�
procedure p_check_007 (p_tab in varchar2,p_deal_flag in number)
as
/*
���ܣ���_YYYYMMDD���ݱ��еõ�ԭ���CHECKֵ��Ϊ�·���������CHECKֵ
��ע��
user_constraints�Ѿ������˷ǿյ��жϣ�������ȥ�������ƵĴ�user_tab_columns��ȡ�ǿ��жϵĴ����д���ж��Ƿ�
for i in (select * from user_tab_columns where table_name=UPPER(P_TAB)||'_' ||YYYYMMDD and nullable='N') loop
v_sql:='alter table '||p_tab||' modify '||i.COLUMN_NAME ||' not null';
*/
v_sql_p_check         varchar2(4000);
v_cnt number;
begin
select count(*) into v_cnt from user_constraints where table_name=UPPER(P_TAB)|| '_'||YYYYMMDD and constraint_type='C';
if v_cnt>0 then
for i in (select * from user_constraints where table_name=UPPER(P_TAB)||'_'|| YYYYMMDD and constraint_type='C') loop
v_sql_p_check :='alter table '||P_TAB||'_'||YYYYMMDD ||' drop constraint ' || I.CONSTRAINT_NAME;
p_insert_log(p_tab,'p_deal_check',v_sql_p_check ,'�����ݳ�����ԭ���CHECKɾ��',7,1);
p_if_judge(v_sql_p_check ,p_deal_flag);
v_sql_p_check :='alter table '||p_tab||' ADD CONSTRAINT '||I.CONSTRAINT_NAME||' CHECK ('||I.SEARCH_CONDITION ||')' ;
p_insert_log(p_tab,'p_deal_check',v_sql_p_check ,'���·������CHECK����',7,2);
p_if_judge(v_sql_p_check ,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('��������7(checkԼ��)-------��'||p_tab ||'���CHECK��Լ��');
else
DBMS_OUTPUT.PUT_LINE('��������7(checkԼ��)-----'||UPPER(P_TAB)||'_'||YYYYMMDD ||'��û��CHECK!');
end if;    
end p_check_007;
�ű�13-24�����������±������е�checkԼ��


--------------------------------------------------------------------------------------------

�뿴����p_index_008���õ����������
procedure p_index_008 (p_tab in varchar2,p_deal_flag in number,p_idx_tablespace IN VARCHAR2)
as
/*
���ܣ���_YYYYMMDD���ݱ��еõ�ԭ���������Ϣ��Ϊ�·�����������ͨ������Ψһ�ͷ�Ψһ���������������ݲ����ǣ�����ɾ���ɱ�����
�ѵ㣺��Ҫ�����������������
*/
v_sql_p_normal_idx         varchar2(4000);
v_cnt number;
begin
SELECT count(*) into v_cnt
from user_indexes
where table_name = UPPER(P_TAB)||'_'||YYYYMMDD
and index_type='NORMAL' AND INDEX_NAME NOT IN (SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS);
if v_cnt>0 then
for i in
(
WITH T AS
(
select C.*,I.UNIQUENESS
from user_ind_columns C
,(SELECT DISTINCT index_name,UNIQUENESS
from user_indexes
where table_name = UPPER(P_TAB)||'_'||YYYYMMDD
and index_type='NORMAL'
AND INDEX_NAME NOT IN
(SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS)
) i
where c.index_name = i.index_name
)
SELECT INDEX_NAME,TABLE_NAME,UNIQUENESS, MAX(substr(sys_connect_by_path(COLUMN_ NAME, ','), 2)) str ---����������������
FROM (SELECT column_name,INDEX_NAME,TABLE_NAME, row_number() over(PARTITION BY INDEX_NAME,TABLE_NAME ORDER BY COLUMN_NAME) rn
,UNIQUENESS
FROM T) t
START WITH rn = 1
CONNECT BY rn = PRIOR rn + 1
AND INDEX_NAME = PRIOR INDEX_NAME
GROUP BY INDEX_NAME,T.TABLE_NAME,UNIQUENESS
) loop
v_sql_p_normal_idx:= 'drop index '||i.index_name;
p_insert_log(p_tab,'p_deal_normal_idx',v_sql_p_normal_idx,'ɾ��ԭ������',8,1);
p_if_judge(v_sql_p_normal_idx,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('��������8(��������)-------��'||i.table_name ||'��'||i.str||'�е�����'||i.index_name||'ɾ�����');
if i.uniqueness='UNIQUE' then
v_sql_p_normal_idx:='CREATE UNIQUE INDEX ' || i.INDEX_NAME || ' ON '|| p_tab||'('||i.STR||')'||' tablespace '||
p_idx_tablespace ;
elsif i.uniqueness='NONUNIQUE' then
v_sql_p_normal_idx:='CREATE  INDEX ' || i.INDEX_NAME || ' ON '|| p_tab ||' ('||i.STR||')'||' LOCAL tablespace '||
p_idx_tablespace ;
end if;
p_insert_log(p_tab,'p_deal_normal_idx',v_sql_p_normal_idx,'���·��������������',8,2);
p_if_judge(v_sql_p_normal_idx,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('��������8(��������)-------��'||p_tab ||'�·�����'||i.STR||'����������'||i.index_name);
end loop;
else
DBMS_OUTPUT.PUT_LINE('��������8(��������)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'��û������(����ģ�鲢���������ж�)!');
end if;
end p_index_008;
�ű�13-25�����������±������


--------------------------------------------------------------------------------------------


�뿴����p_pk_009���õ����������
procedure p_pk_009 (p_tab in varchar2,p_deal_flag in number,p_idx_tablespace IN VARCHAR2)
as
/*
���ܣ���_YYYYMMDD���ݱ��еõ�ԭ���������Ϣ��Ϊ�·�������������ֵ����ɾ���ɱ�����
�ѵ㣺��Ҫ�����������������
*/
v_sql_p_pk         varchar2(4000);
v_cnt              number;

begin
SELECT count(*) into v_cnt
from USER_IND_COLUMNS
where index_name in (select index_name
from sys.user_constraints t
WHERE TABLE_NAME =UPPER(P_TAB)||'_'||YYYYMMDD
and constraint_type = 'P');
if v_cnt>0 then
for i in
(WITH T AS
(SELECT INDEX_NAME,TABLE_NAME,COLUMN_NAME
from USER_IND_COLUMNS
where index_name in (select index_name
from sys.user_constraints t
WHERE TABLE_NAME =UPPER(P_TAB)||'_'||YYYYMMDD
and constraint_type = 'P')
)
SELECT INDEX_NAME,TABLE_NAME, MAX(substr(sys_connect_by_path(COLUMN_NAME, ','), 2)) str
FROM (SELECT  column_name,INDEX_NAME,TABLE_NAME, row_number() over(PARTITION BY INDEX_NAME,TABLE_NAME ORDER BY COLUMN_NAME) rn
FROM T) t
START WITH rn = 1
CONNECT BY rn = PRIOR rn + 1
AND INDEX_NAME = PRIOR INDEX_NAME
GROUP BY INDEX_NAME,T.TABLE_NAME
) loop
v_sql_p_pk:= 'alter table '||i.table_name||' drop constraint '||i.index_name|| ' cascade';
p_insert_log(p_tab,'p_deal_pk',v_sql_p_pk,'�����ݳ�����ԭ�������ɾ��',9,1);
p_if_judge(v_sql_p_pk,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('��������9(��������)-------�����ݳ�����ԭ��'||i.table_name||'��'||i.str||'�е�����'||i.index_name||'ɾ����
�ϣ�'); ---����FORѭ����Ч��û���⣬��Ϊ����ֻ��һ����ֻ��ѭ��һ��
v_sql_p_pk:='ALTER TABLE '||p_tab||' ADD CONSTRAINT '||I.INDEX_NAME||' PRIMARY KEY ('||I.STR||')' ||' using index tablespace
'||p_idx_tablespace ;
p_insert_log(p_tab,'p_deal_pk',v_sql_p_pk,'���·��������������',9,2);
p_if_judge(v_sql_p_pk,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('��������9(��������)-------��'||p_tab ||'���'||i.str||'����������'||i.index_name); ---����FORѭ����Ч��û
���⣬��Ϊ����ֻ��һ����ֻ��ѭ��һ��
end loop;
else
DBMS_OUTPUT.PUT_LINE('��������9(��������)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'��û������!');
end if;
end p_pk_009;
�ű�13-26�����������±������


--------------------------------------------------------------------------------------------


�뿴����p_constraint_010���õ����
procedure p_constraint_010 (p_tab in varchar2,p_deal_flag in number)
as
/*
���ܣ���_YYYYMMDD���ݱ��еõ�ԭ���Լ����Ϊ�·���������Լ��ֵ����ɾ���ɱ�Լ��
�ѵ㣺��Ҫ�����������REFERENCE�����
*/
v_sql_p_constraint         varchar2(4000);
v_cnt  number;
begin
SELECT count(*) into v_cnt  FROM user_constraints where table_name=UPPER(P_TAB)|| '_'||YYYYMMDD AND CONSTRAINT_TYPE='R';
if v_cnt>0 then
for i in
(with t1 as (
SELECT  /*+no_merge */
POSITION
,t.owner,t.constraint_name as constraint_name1,t.table_name as table_name1
,t.column_name as column_name1  FROM user_cons_columns t where constraint_name in
(
SELECT CONSTRAINT_NAME FROM user_constraints where table_name=UPPER(P_TAB) ||'_'||YYYYMMDD AND CONSTRAINT_TYPE='R'
)
),
t2 as (
SELECT  /*+no_merge */
t.POSITION
,c.constraint_name constraint_name1
,t.constraint_name as constraint_name2,t.table_name as table_name2
,t.column_name as column_name2
,MAX(t.POSITION) OVER (PARTITION BY c.constraint_name) MAX_POSITION
FROM user_cons_columns t
,user_constraints c
WHERE c.table_name = UPPER(P_TAB)||'_'||YYYYMMDD
AND t.constraint_name = c.r_constraint_name
AND c.constraint_type='R'
),
t3 AS (
SELECT t1.*
,t2.constraint_name2
,t2.table_name2
,t2.column_name2
,t2.max_position
FROM t1,t2
WHERE t1.constraint_name1 = t2.constraint_name1 AND t1.position=t2.position)
select t3.*,SUBSTR(SYS_CONNECT_BY_PATH(column_name1,','),2) as FK,SUBSTR(SYS_ CONNECT_BY_PATH(column_name2,','),2) AS PK from t3
WHERE POSITION=MAX_POSITION
START WITH position=1
CONNECT BY constraint_name1 = PRIOR constraint_name1
AND position = PRIOR position+1) loop
v_sql_p_constraint:= 'alter table '||p_tab||'_'||YYYYMMDD  ||' drop constraint '||i.constraint_name1;
p_insert_log(p_tab,'p_deal_constraint',v_sql_p_constraint,'ɾ��ԭ��FK���' ,10,1);
p_if_judge(v_sql_p_constraint,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('��������10(�������)------�����ݳ�����'||i.table_name1||'���'||i.column_name1||'�е����'||
i.constraint_name1||'ɾ�����!');
v_sql_p_constraint:= 'alter table ' || p_tab ||' add constraint '||i.constraint_ name1 || ' foreign key ( '
||i.fk||') references '||i.table_name2|| ' ('||i.pk||' )';
p_insert_log(p_tab,'p_deal_constraint',v_sql_p_constraint,'���·�������������',10,2);
p_if_judge(v_sql_p_constraint,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('��������10(�������)------��'||p_tab ||'���'||i.column_ name1||'���������'||i.constraint_name1);
end loop;
else
DBMS_OUTPUT.PUT_LINE('��������10(�������)------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'��û�����!');
end if;
end p_constraint_010;
�ű�13-27�����������±������������Լ��
