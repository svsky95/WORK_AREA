生产库由 原来的 AMM (Automatic memory management ) 调整为 ASMM （Automatic Shared Memory Management）后， 原来每天跑的逻辑备份由 30分钟变成了 4个半小时。
expdp 进程在 v$session 显示的等待为：
Streams AQ: enqueue blocked on low memory
wait for unread message on broadcast channel
经分析，采用了以下 设置：
ALTER SYSTEM SET STREAMS_POOL_SIZE=2G  SCOPE=spfile;
ALTER SYSTEM SET shared_pool_size=6G SCOPE=spfile;
ALTER SYSTEM SET "_shared_io_pool_size"=512M SCOPE=spfile;
重启数据库：shutdown immeidate
如果启动很慢，可以用startup force

但还是没有效果，查询到的相关资料如下：
https://community.oracle.com/thread/3600240?start=15&tstart=0
https://oraculix.com/2014/12/05/data-pump-aq-tm-processes/
http://srinivasoguri.blogspot.co.uk/2016/02/streams-aq-enqueue-blocked-on-low-memory.html

至此，采用了其中一帖的 重启方法，果然奏效。
现在 压缩后20G的dump 文件只需要 23分钟