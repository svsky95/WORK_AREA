11.2.04�汾֮ǰ��dblink��ͬ������Ŀ����SCN�ţ����ܻᵼ��SCNԽ�硣
select
  version,
  to_char(SYSDATE,'YYYY/MM/DD HH24:MI:SS') DATE_TIME,
  round((((
   ((to_number(to_char(sysdate,'YYYY'))-1988)*12*31*24*60*60) +
   ((to_number(to_char(sysdate,'MM'))-1)*31*24*60*60) +
   (((to_number(to_char(sysdate,'DD'))-1))*24*60*60) +
   (to_number(to_char(sysdate,'HH24'))*60*60) +
   (to_number(to_char(sysdate,'MI'))*60) +
   (to_number(to_char(sysdate,'SS')))
   ) * (16*1024)) - dbms_flashback.get_system_change_number)
  / (16*1024*60*60*24) ,3
  ) HeadROOM,
  dbms_flashback.get_system_change_number SCN    --day
from v$instance;