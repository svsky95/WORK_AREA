--SQL查询数据库当前环境是否存在长会话操作
SELECT 'alter system kill session '''||t."SID"||'.'||t."SERIAL#"||''';' killcommond,t."SQL_ID",t."USERNAME" from v$session_longops t  where time_remaining>0;

--SQL查询数据库中此时是否存在大事物操作
SELECT 'alter system kill session '''||s."SID"||'.'||s."SERIAL#"||''';' killcommond,s."SQL_ID",s."OSUSER",s."MACHINE" FROM v$transaction t ,v$session s WHERE t."ADDR"=s."TADDR" ;

shutdown immediate
关闭数据库只需要在数据库中强制选择检查点并关闭文件，不需要等待当前事物处理结束，不需要等待当前会话结束，不允许新连接。

引发shutdown immediate slowly and hanging的原因

>>>>
processes still continue to beconnected to the database and do not terminate
>>>>
如果数据库在关闭的时候，有进程持续连接数据，并且不能被中断，就会造成shutdown immediate slowly或者hanging

>>>>
SMON is cleaning temp segments orperforming delayed block cleanouts
>>>>
Temp segment cleanup: 在数据库中如果有大量的sql做排序操作，pga中分配的sort_area_size太小，不能满足排序的需要时候，就会占用临时段进行排序，这些分配的临时段分区，一旦分配，直到数据库shutdown?的时候才会释放。所以当我在进行数据库关闭时，有大量的临时分区被分配需要立刻被释放，这会引起row cache?的资源竞争，从而导致数据库shutdownimmediate变慢或者hanging。

>>>>
Uncommitted transactions are beingrolled back
>>>>
当数据库需要以一致性关闭数据库时，如果此刻数据库中正好存在运行的大事物，这时候数据库需要对大事物进行回滚（请不要误解之前提到的知识点，之前提到shutdown immediate 不需要等待事物是指不要等待此事物提交结束，而是要对此刻所有未提交的事物进行回滚），因为大事物的回滚需要很长的时间，所以就会在执行shutdownimmediate时感觉solwly或者hanging。当然对于事物的回滚，我们可以通过设置隐藏参数来加快回滚，但是另外考虑到高速的回滚设置会引起资源竞争，这样可能会加剧shutdown immediate变慢（有的特殊情况除外）

>>>>
Oracle Bug
>>>>

Oracle BUG oracle的某些BUG也会导致shutdownimmedaite变慢

以下是我在mos上搜索的BUG证明BUG也会导致shutdown immediate
Bug 6512622 - SHUTDOWN IMMEDIATE hangs / OERI[3708] (文档 ID 6512622.8)
Bug 5057695: Shutdown Immediate Very Slow To CloseDatabase (文档 ID 428688.1)
Bug 23309880 - SHUTDOWN IMMEDIATE may hang on primarydatabase if DG broker is configured (文档 ID 23309880.8)

