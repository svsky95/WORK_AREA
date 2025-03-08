
#!/bin/bash
source /home/oracle/.bash_profile 
sqlplus / as sysdba <<EOF
create table HTJS.CB_FPCGL_MX_QDMX as 
SELECT t.*,utl_raw.cast_to_varchar2(t.wp_mc_A) wp_mc_B,utl_raw.cast_to_varchar2(t.wp_xh_A) wp_xh_B,utl_raw.cast_to_varchar2(t.wp_dw_A) wp_dw_B FROM sjcx.v_tab_CB_FPCGL_MX_QDMX@ogg_pwsk t;
exit;
EOF

--两个库字符集不同的倒数
1、在源端创建转换视图
create view v_tab_CB_FDKFPCGL_MX_QD as  SELECT t.*,utl_raw.cast_to_raw(t.wp_mc) wp_mc_A,utl_raw.cast_to_raw(t.wp_xh) wp_xh_A,utl_raw.cast_to_raw(t.wp_dw) wp_dw_A FROM HTJS.CB_FDKFPCGL_MX_QD t  WHERE to_char(t.czdate,'yyyymmdd')<='20150101';

2、在目标端用DBLink创建表
create table HTJS.CB_FDKFPCGL_MX_QDMX as 
SELECT t.*,utl_raw.cast_to_varchar2(t.wp_mc_A) wp_mc_B,utl_raw.cast_to_varchar2(t.wp_xh_A) wp_xh_B,utl_raw.cast_to_varchar2(t.wp_dw_A) wp_dw_B FROM sjcx.v_tab_CB_FDKFPCGL_MX_QDMX@ogg_pwsk t;

PS：注意在目标端创建完表后，会多出好几个字段，如果数量几千万，那么删除一列就会非常慢，如果是测试数据，建议把列重命名。
alter table HTJS.CB_FPCGL_MX rename column CZY_MC_B to CZY_MC;
