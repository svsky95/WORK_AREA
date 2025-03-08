--ASMCMD 
1、参看磁盘组的大小及剩余
ASMCMD> lsdg -g
Inst_ID  State    Type    Rebal  Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
      1  MOUNTED  EXTERN  N         512   4096  1048576      4000     3648                0            3648              0             N  FRA_DATA/
      2  MOUNTED  EXTERN  N         512   4096  1048576      4000     3648                0            3648              0             N  FRA_DATA/
      1  MOUNTED  EXTERN  N         512   4096  1048576      1000      604                0             604              0             Y  OCR_DATA/
      2  MOUNTED  EXTERN  N         512   4096  1048576      1000      604                0             604              0             Y  OCR_DATA/
      1  MOUNTED  EXTERN  N         512   4096  1048576      7000     2177                0            2177              0             N  ORACL_DATA/
      2  MOUNTED  EXTERN  N         512   4096  1048576      7000     2177                0            2177              0             N  ORACL_DATA/
2、查看磁盘
ASMCMD> lsdsk -p -G FRA_DATA
Group_Num  Disk_Num      Incarn  Mount_Stat  Header_Stat  Mode_Stat  State   Path
        3         0  3915917149  CACHED      MEMBER       ONLINE     NORMAL  /ora_data/disk23
        3         1  3915917147  CACHED      MEMBER       ONLINE     NORMAL  /ora_data/disk24
        3         2  3915917146  CACHED      MEMBER       ONLINE     NORMAL  /ora_data/disk25
        3         3  3915917148  CACHED      MEMBER       ONLINE     NORMAL  /ora_data/disk26
        
  
2、查找find
ASMCMD [+] > find +data undo*
+data/ORCL/DATAFILE/UNDOTBS1.258.691577151

ASMCMD [+] >  find --type CONTROLFILE +data/orcl *
+data/orcl/CONTROLFILE/Current.260.691577263
