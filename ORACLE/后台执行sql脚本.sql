--用oracle 用户执行
[oracle@BIGDATA ~]$ more insert_dzdz_table.sh 
#!/bin/bash
source /home/oracle/.bash_profile 
sqlplus dzdz/dzdz0715 <<EOF
insert into  DZDZ.DZDZ_FPXX_JDCFP select /*+parallel 10*/ * from  dzdz.DZDZ_FPXX_JDCFP_t nologging;      
commit;
insert into  dzdz.DZDZ_FPXX_JSFP  select /*+parallel 10*/ * from  dzdz.DZDZ_FPXX_JSFP_t nologging; 
commit;
insert into  dzdz.DZDZ_FPXX_RZDKL select /*+parallel 10*/ * from  dzdz.DZDZ_FPXX_RZDKL_t nologging;
commit;
insert into  dzdz.DZDZ_FPXX_YDK   select /*+parallel 10*/ * from  dzdz.DZDZ_FPXX_YDK_t nologging;  
commit;
insert into  dzdz.DZDZ_FPXX_ZF    select /*+parallel 10*/ * from  dzdz.DZDZ_FPXX_ZF_t nologging;   
commit;
insert into  dzdz.DZDZ_HWXX_JSFP  select /*+parallel 10*/ * from  dzdz.DZDZ_HWXX_JSFP_t nologging; 
commit;
insert into  dzdz.DZDZ_HWXX_PTFP  select /*+parallel 10*/ * from  dzdz.DZDZ_HWXX_PTFP_t nologging; 
commit;
insert into  dzdz.DZDZ_HWXX_DZFP  select /*+parallel 10*/ * from  dzdz.DZDZ_HWXX_DZFP_t nologging; 
commit;
exit;
EOF

--调取存储过程（存储过程的变量必须提前声明）
#!/bin/bash
source /home/oracle/.bash_profile 
sqlplus / a sysdba <<EOF                        
var sch_name1 VARCHAR2(50)
var sch_name1 VARCHAR2(100)
var tab_name1 VARCHAR2
var acv_recode VARCHAR2
var acv_remsg  VARCHAR2
begin
  -- Call the procedure
  ogg.p_deal_colchange_zl(sch_name1 => :sch_name1,
                          tab_name1 => :tab_name1,
                          acv_recode => :acv_recode,
                          acv_remsg => :acv_remsg);
end;
/
exit;
EOF
     