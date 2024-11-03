--普通表改分区表
procedure p_rename_001 (p_tab in varchar2)
as
/*
功能：将原表重命名为_yyyymmdd格式的表名
完善点： 要考虑RENMAE的目标表已存在的情况，先做判断
*/
V_CNT_RE_TAB  NUMBER(9) :=0;
v_sql_p_rename         varchar2(4000);
begin
SELECT  COUNT(*)   INTO V_CNT_RE_TAB FROM user_objects where object_name=UPPER(P_ TAB||'_'||YYYYMMDD);
if V_CNT_RE_TAB=0 then
v_sql_p_rename:= 'rename '||P_TAB ||' to '||P_TAB||'_'||YYYYMMDD;
--   DBMS_OUTPUT.PUT_LINE(v_sql_p_rename);--调试使用
p_insert_log(p_tab,'P_RENAME',v_sql_p_rename,'完成原表的重命名，改为_YYYYMMDD形式',1);
execute immediate(v_sql_p_rename); --这里无须做判断，rename动作真实完成！如果后续只是为生成脚本而不是真实执行分区操作，最
后再把这个表RENAME回去！
ELSE
RAISE_APPLICATION_ERROR(-20066,'备份表'||P_TAB||'_'||YYYYMMDD||'已存在,请先删除或重命名该备份表后再继续执行！');
--  DBMS_OUTPUT.PUT_LINE('备份表'||P_TAB||'_'||YYYYMMDD||'已存在');
end if;
DBMS_OUTPUT.PUT_LINE('操作步骤1(备份原表)-------将'||p_tab ||' 表RENMAE成 '||p_tab||'_'||YYYYMMDD||'，并删除其约束索引等');
end p_rename_001;
脚本13-18　分区改造前的原表重命名 


--------------------------------------------------------------------------------------------


设想思路2
procedure p_ctas_002 (p_tab in varchar2,
p_struct_only  in number,
p_deal_flag in number,
p_part_colum in varchar2,
p_parallel in number default 4,
p_tablespace IN VARCHAR2)
as
/*
功能：用CREATE TABLE AS SELECT 的方式从RENAME的_yyyymmdd表中新建出一个只有MAXVALUE的初步分区表
完善点：要考虑并行，nologging 的提速方式，也要考虑最终将NOLOGGING和PARALLEL恢复成正常状态
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
--DBMS_OUTPUT.PUT_LINE(v_sql_p_ctas);--调试使用
p_insert_log(p_tab,'p_ctas',v_sql_p_ctas,'完成CTAS建初步分区表',2,1);
p_if_judge(v_sql_p_ctas,p_deal_flag);
v_sql_p_ctas:='alter table '|| p_tab ||' logging';
p_insert_log(p_tab,'p_ctas',v_sql_p_ctas,'将新分区表修改回LOGGING属性',2,2);
p_if_judge(v_sql_p_ctas,p_deal_flag);
v_sql_p_ctas:='alter table '|| p_tab || ' noparallel';
p_insert_log(p_tab,'p_ctas',v_sql_p_ctas,'将新分区表修改回NOPARALLEL属性',2,3);
p_if_judge(v_sql_p_ctas,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('操作步骤2(建分区表)-------通过CTAS的方式从 '||p_tab||'_'||YYYYMMDD|| ' 中新建'||p_tab ||'表，完成初步分区改
造工作');
end p_ctas_002;
脚本13-19　用CTAS完成一张仅带MAX分区的新表


--------------------------------------------------------------------------------------------

设想思路3
procedure p_split_part_003 (p_tab in varchar2,
p_deal_flag in number,
p_part_nums in number default 24,
p_tab_tablespace IN VARCHAR2)
as
/*
功能：用CREATE TABLE AS SELECT 的方式新建出一个只有MAXVALUE的初步分区表进行SPLIT，
按月份进行切分，默认p_part_nums产生24个分区，构造2年的分区表，第一个分区为当前月的
上一个月
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
-- DBMS_OUTPUT.PUT_LINE(v_sql_p_split_part);--调试使用
p_insert_log(p_tab,'p_split_part',v_sql_p_split_part,'分区表完成分区SPLIT工作',3,i);
p_if_judge(v_sql_p_split_part,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('操作步骤3(分区操作)-------对新建的'||p_tab ||'分区表完成分区SPLIT工作');
end p_split_part_003;
脚本13-20　把分区新表split成多个分区


--------------------------------------------------------------------------------------------

设想思路4
procedure p_tab_comments_004  (p_tab in varchar2,p_deal_flag in number)
as
/*
功能：从_YYYYMMDD备份表中得到表和字段的注释，为新分区表的表名和字段增加注释
*/
v_sql_p_tab_comments         varchar2(4000);
v_cnt number;
begin
select count(*) into v_cnt from user_tab_comments where table_name=UPPER (P_TAB)||'_'||YYYYMMDD AND COMMENTS IS NOT NULL;
if v_cnt>0 then
for i in (select * from user_tab_comments where table_name=UPPER(P_TAB)|| '_'||YYYYMMDD AND COMMENTS IS NOT NULL) loop
v_sql_p_tab_comments:='comment on table '||p_tab||' is '|| ''''||i.COMMENTS||'''';
-- DBMS_OUTPUT.PUT_LINE(v_sql_p_deal_tab_comments);--调试使用
p_insert_log(p_tab,'p_deal_comments',v_sql_p_tab_comments,'将新分区表的表的注释加上',4,1);
p_if_judge(v_sql_p_tab_comments,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('操作步骤4(表的注释)-------对'||p_tab ||'表增加表名的注释内容');
ELSE
DBMS_OUTPUT.PUT_LINE('操作步骤4(表的注释)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'并没有表注释!');
END IF;
end p_tab_comments_004;
脚本13-21　补进分区新表的注释


--------------------------------------------------------------------------------------------


请看代码p_col_comments_005，得到列的注释：
procedure p_col_comments_005  (p_tab in varchar2,p_deal_flag in number)
as
/*
功能：从_YYYYMMDD备份表中得到表和字段的注释，为新分区表的表名和字段增加注释
*/
v_sql_p_col_comments         varchar2(4000);
v_cnt number;
begin
select count(*) into v_cnt from user_col_comments where table_name=UPPER (P_TAB)||'_'||YYYYMMDD AND COMMENTS IS NOT NULL;
if v_cnt>0 then
for i in (select * from user_col_comments where table_name=UPPER(P_TAB)||'_' ||YYYYMMDD AND COMMENTS IS NOT NULL) loop
v_sql_p_col_comments:='comment on column '||p_tab||'.'||i.COLUMN_NAME||' is '|| ''''||i.COMMENTS||'''';
p_insert_log(p_tab,'p_deal_col_comments',v_sql_p_col_comments,'将新分区表的列的注释加上',5,1);
p_if_judge(v_sql_p_col_comments,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('操作步骤5(列的注释)-------对'||p_tab ||'表增加列名及字段的注释内容');
else
DBMS_OUTPUT.PUT_LINE('操作步骤5(列的注释)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'并没有列注释!');
end if;
end p_col_comments_005;
脚本13-22　补进分区新表所有列的注释


--------------------------------------------------------------------------------------------

请看代码p_defau_and_null_006，得到表的列中是否为空的属性：
procedure p_defau_and_null_006 (p_tab in varchar2,p_deal_flag in number)
as
/*
功能：从_YYYYMMDD备份表中得到原表的DEFAULT值，为新分区表的表名和字段增加DEFAULT值
*/
v_sql_defau_and_null        varchar2(4000);
v_cnt  number;
begin
select count(*) into v_cnt  from user_tab_columns where table_name=UPPER(P_TAB)|| '_'||YYYYMMDD and data_default is not null;
if v_cnt>0 then
for i in (select * from user_tab_columns where table_name=UPPER(P_TAB)||'_' ||YYYYMMDD and data_default is not null) loop
v_sql_defau_and_null:='alter table '||p_tab||' modify '||i.COLUMN_NAME ||' default ' ||i.data_default;
p_insert_log(p_tab,'p_deal_default',v_sql_defau_and_null,'将新分区表的默认值加上',6);
p_if_judge(v_sql_defau_and_null,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('操作步骤6(空和默认)-------对'||p_tab ||'表完成默认DEFAULT值的增加');
else
DBMS_OUTPUT.PUT_LINE('操作步骤6(空和默认)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'并没有DEFAULT或NULL值!');
end if; 
end p_defau_and_null_006;
脚本13-23　补进分区新表所有列的null属性


--------------------------------------------------------------------------------------------


请看代码p_check_007，得到列的check属性：
procedure p_check_007 (p_tab in varchar2,p_deal_flag in number)
as
/*
功能：从_YYYYMMDD备份表中得到原表的CHECK值，为新分区表增加CHECK值
另注：
user_constraints已经进行了非空的判断，可以略去如下类似的从user_tab_columns获取非空判断的代码编写来判断是否
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
p_insert_log(p_tab,'p_deal_check',v_sql_p_check ,'将备份出来的原表的CHECK删除',7,1);
p_if_judge(v_sql_p_check ,p_deal_flag);
v_sql_p_check :='alter table '||p_tab||' ADD CONSTRAINT '||I.CONSTRAINT_NAME||' CHECK ('||I.SEARCH_CONDITION ||')' ;
p_insert_log(p_tab,'p_deal_check',v_sql_p_check ,'将新分区表的CHECK加上',7,2);
p_if_judge(v_sql_p_check ,p_deal_flag);
end loop;
DBMS_OUTPUT.PUT_LINE('操作步骤7(check约束)-------对'||p_tab ||'完成CHECK的约束');
else
DBMS_OUTPUT.PUT_LINE('操作步骤7(check约束)-----'||UPPER(P_TAB)||'_'||YYYYMMDD ||'并没有CHECK!');
end if;    
end p_check_007;
脚本13-24　补进分区新表所有列的check约束


--------------------------------------------------------------------------------------------

请看代码p_index_008，得到表的索引：
procedure p_index_008 (p_tab in varchar2,p_deal_flag in number,p_idx_tablespace IN VARCHAR2)
as
/*
功能：从_YYYYMMDD备份表中得到原表的索引信息，为新分区表增加普通索引（唯一和非唯一索引，函数索引暂不考虑），并删除旧表索引
难点：需要考虑联合索引的情况
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
SELECT INDEX_NAME,TABLE_NAME,UNIQUENESS, MAX(substr(sys_connect_by_path(COLUMN_ NAME, ','), 2)) str ---考虑组合索引的情况
FROM (SELECT column_name,INDEX_NAME,TABLE_NAME, row_number() over(PARTITION BY INDEX_NAME,TABLE_NAME ORDER BY COLUMN_NAME) rn
,UNIQUENESS
FROM T) t
START WITH rn = 1
CONNECT BY rn = PRIOR rn + 1
AND INDEX_NAME = PRIOR INDEX_NAME
GROUP BY INDEX_NAME,T.TABLE_NAME,UNIQUENESS
) loop
v_sql_p_normal_idx:= 'drop index '||i.index_name;
p_insert_log(p_tab,'p_deal_normal_idx',v_sql_p_normal_idx,'删除原表索引',8,1);
p_if_judge(v_sql_p_normal_idx,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('操作步骤8(处理索引)-------将'||i.table_name ||'的'||i.str||'列的索引'||i.index_name||'删除完毕');
if i.uniqueness='UNIQUE' then
v_sql_p_normal_idx:='CREATE UNIQUE INDEX ' || i.INDEX_NAME || ' ON '|| p_tab||'('||i.STR||')'||' tablespace '||
p_idx_tablespace ;
elsif i.uniqueness='NONUNIQUE' then
v_sql_p_normal_idx:='CREATE  INDEX ' || i.INDEX_NAME || ' ON '|| p_tab ||' ('||i.STR||')'||' LOCAL tablespace '||
p_idx_tablespace ;
end if;
p_insert_log(p_tab,'p_deal_normal_idx',v_sql_p_normal_idx,'将新分区表的索引加上',8,2);
p_if_judge(v_sql_p_normal_idx,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('操作步骤8(处理索引)-------对'||p_tab ||'新分区表'||i.STR||'列增加索引'||i.index_name);
end loop;
else
DBMS_OUTPUT.PUT_LINE('操作步骤8(处理索引)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'并没有索引(索引模块并不含主键判断)!');
end if;
end p_index_008;
脚本13-25　补进分区新表的索引


--------------------------------------------------------------------------------------------


请看代码p_pk_009，得到表的主键：
procedure p_pk_009 (p_tab in varchar2,p_deal_flag in number,p_idx_tablespace IN VARCHAR2)
as
/*
功能：从_YYYYMMDD备份表中得到原表的主键信息，为新分区表增加主键值，并删除旧表主键
难点：需要考虑联合主键的情况
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
p_insert_log(p_tab,'p_deal_pk',v_sql_p_pk,'将备份出来的原表的主键删除',9,1);
p_if_judge(v_sql_p_pk,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('操作步骤9(处理主键)-------将备份出来的原表'||i.table_name||'的'||i.str||'列的主键'||i.index_name||'删除完
毕！'); ---放在FOR循环中效率没问题，因为主键只有一个，只会循环一次
v_sql_p_pk:='ALTER TABLE '||p_tab||' ADD CONSTRAINT '||I.INDEX_NAME||' PRIMARY KEY ('||I.STR||')' ||' using index tablespace
'||p_idx_tablespace ;
p_insert_log(p_tab,'p_deal_pk',v_sql_p_pk,'将新分区表的主键加上',9,2);
p_if_judge(v_sql_p_pk,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('操作步骤9(处理主键)-------对'||p_tab ||'表的'||i.str||'列增加主键'||i.index_name); ---放在FOR循环中效率没
问题，因为主键只有一个，只会循环一次
end loop;
else
DBMS_OUTPUT.PUT_LINE('操作步骤9(处理主键)-------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'并没有主键!');
end if;
end p_pk_009;
脚本13-26　补进分区新表的主键


--------------------------------------------------------------------------------------------


请看代码p_constraint_010，得到表的
procedure p_constraint_010 (p_tab in varchar2,p_deal_flag in number)
as
/*
功能：从_YYYYMMDD备份表中得到原表的约束，为新分区表增加约束值，并删除旧表约束
难点：需要考虑联合外键REFERENCE的情况
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
p_insert_log(p_tab,'p_deal_constraint',v_sql_p_constraint,'删除原表FK外键' ,10,1);
p_if_judge(v_sql_p_constraint,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('操作步骤10(处理外键)------将备份出来的'||i.table_name1||'表的'||i.column_name1||'列的外键'||
i.constraint_name1||'删除完毕!');
v_sql_p_constraint:= 'alter table ' || p_tab ||' add constraint '||i.constraint_ name1 || ' foreign key ( '
||i.fk||') references '||i.table_name2|| ' ('||i.pk||' )';
p_insert_log(p_tab,'p_deal_constraint',v_sql_p_constraint,'将新分区表的外键加上',10,2);
p_if_judge(v_sql_p_constraint,p_deal_flag);
DBMS_OUTPUT.PUT_LINE('操作步骤10(处理外键)------对'||p_tab ||'表的'||i.column_ name1||'列增加外键'||i.constraint_name1);
end loop;
else
DBMS_OUTPUT.PUT_LINE('操作步骤10(处理外键)------'||UPPER(P_TAB)||'_'||YYYYMMDD ||'并没有外键!');
end if;
end p_constraint_010;
脚本13-27　补进分区新表的外键及主外键约束
