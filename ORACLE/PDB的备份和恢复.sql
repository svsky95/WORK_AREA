备份流程

1 、主库归档

2 、物理备库应用日志

3 、物理备库 ：RMAN 备份CDB 数据库或者PDB 级别备份

 

恢复流程

1 、PDB 不完全恢复：备份环境禁止PDB 恢复

2 、主库环境PDB 恢复

3 、备份恢复PDB

4 、备库启动应用日志

 

 

一、CDB 备份

RMAN> backup database plus archivelog delete input;

 

二、PDB 备份

RMAN> backup pluggable database frankpdb plus archivelog delete input;

 

三、完全恢复PDB

RMAN> list backup of pluggable database frankpdb;

 

RMAN> RUN

{

RESTORE PLUGGABLE DATABASE frankpdb;

RECOVER PLUGGABLE DATABASE frankpdb;

}

 

RMAN> ALTER PLUGGABLE DATABASE frankpdb OPEN;

 

四、不完全恢复PDB

主库查看备份

RMAN> list backup of pluggable database frankpdb;

 

备库环境禁止故障 PDB 恢复应用，减少对其他 PDB 的影响

RMAN> alter pluggable database frankpdb close immediate instances=all;

 

DGMGRL> edit database frankdbdg set state='apply-off'

 

RMAN> alter session set container=frankpdb;

RMAN> alter pluggable database disable recovery;

 

DGMGRL> edit database frankdbdg set state='apply-on';

 

主库恢复 pdb

RMAN> run

{

SET UNTIL SCN 34506;

RESTORE PLUGGABLE DATABASE frankpdb;

RECOVER PLUGGABLE DATABASE frankpdb;

}

 

RMAN> ALTER PLUGGABLE DATABASE frankpdb OPEN RESETLOGS;

 

备份库恢复 pdb

RMAN> restore pluggable database frankpdb from frankdb;  

 

DGMGRL> edit database frankdbdg set state='apply-off'

 

SQL> alter pluggable database frankpdb close immediate instances=all;

SQL> alter session set container=frankpdb;

SQL> alter pluggable database enable recovery

 

DGMGRL> edit database frankdbdg set state='apply-on';