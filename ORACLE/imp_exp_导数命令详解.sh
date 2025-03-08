四、expdp关键字与命令

 （1）关键字　　　　　　　　　  　　说明 (默认)

 ATTACH　　　　　　　　　　　　　　　连接到现有作业, 例如 ATTACH [=作业名]。

 COMPRESSION　　　　  　　　　　　　减小转储文件内容的大小, 其中有效关键字  值为: ALL, (METADATA_ONLY), DATA_ONLY 和 NONE。

 CONTENT　　　　　　　　　 　　　　   指定要卸载的数据, 其中有效关键字  值为: (ALL), DATA_ONLY 和 METADATA_ONLY。

 DATA_OPTIONS　　　　　　  　　　　   数据层标记, 其中唯一有效的值为: 使用CLOB格式的 XML_CLOBS-write XML 数据类型。

 DIRECTORY　　　　　　　　 　　　　　供转储文件和日志文件使用的目录对象，即逻辑目录。

 DUMPFILE　　　　　　　　　　　　　　目标转储文件 (expdp.dmp) 的列表,例如 DUMPFILE=expdp1.dmp, expdp2.dmp。

 ENCRYPTION　　　　　　　　  　　　　加密部分或全部转储文件, 其中有效关键字值为: ALL, DATA_ONLY, METADATA_ONLY,ENCRYPTED_COLUMNS_ONLY 或 NONE。

 ENCRYPTION_ALGORITHM　　　　　　指定应如何完成加密, 其中有效关键字值为: (AES128), AES192 和 AES256。

 ENCRYPTION_MODE　　　　　　　　　生成加密密钥的方法, 其中有效关键字值为: DUAL, PASSWORD 和 (TRANSPARENT)。

 ENCRYPTION_PASSWORD　　　　　　用于创建加密列数据的口令关键字。

 ESTIMATE　　　　　　　　　　　　　　计算作业估计值, 其中有效关键字值为: (BLOCKS) 和 STATISTICS。

 ESTIMATE_ONLY　　　　　　　  　　　 在不执行导出的情况下计算作业估计值。

 EXCLUDE　　　　　　　　　　　　 　　排除特定的对象类型, 例如 EXCLUDE=TABLE:EMP。例：EXCLUDE=[object_type]:[name_clause],[object_type]:[name_clause] 。

 FILESIZE　　　　　　　　　　　　  　　以字节为单位指定每个转储文件的大小。

 FLASHBACK_SCN　　　　　　　　 　　用于将会话快照设置回以前状态的 SCN。 -- 指定导出特定SCN时刻的表数据。

 FLASHBACK_TIME　　　　　　　　　　用于获取最接近指定时间的 SCN 的时间。-- 定导出特定时间点的表数据，注意FLASHBACK_SCN和FLASHBACK_TIME不能同时使用。

 FULL　　　　　　　　　　　　　　  　　导出整个数据库 (N)。　　

 HELP　　　　　　　　　　　　　　 　　显示帮助消息 (N)。

 INCLUDE　　　　　　　　　　　　  　　包括特定的对象类型, 例如 INCLUDE=TABLE_DATA。

 JOB_NAME　　　　　　　　　　　  　　要创建的导出作业的名称。

 LOGFILE　　　　　　　　　　　　  　　日志文件名 (export.log)。

 NETWORK_LINK　　　　　　　　   　　链接到源系统的远程数据库的名称。

 NOLOGFILE　　　　　　　　　　　　　不写入日志文件 (N)。

 PARALLEL　　　　　　　　　　　   　　更改当前作业的活动 worker 的数目。

 PARFILE　　　　　　　　　　　　  　　指定参数文件。

 QUERY　　　　　　　　　　　　　 　　用于导出表的子集的谓词子句。--QUERY = [schema.][table_name:] query_clause。

 REMAP_DATA　　　　　　　　　   　　指定数据转换函数,例如 REMAP_DATA=EMP.EMPNO:REMAPPKG.EMPNO。

 REUSE_DUMPFILES　　　　　　　　　覆盖目标转储文件 (如果文件存在) (N)。

 SAMPLE　　　　　　　　　　　　  　　要导出的数据的百分比。

 SCHEMAS　　　　　　　　　　　  　　要导出的方案的列表 (登录方案)。　　

 STATUS　　　　　　　　　　　　  　　在默认值 (0) 将显示可用时的新状态的情况下,要监视的频率 (以秒计) 作业状态。　　

 TABLES　　　　　　　　　　　　  　　标识要导出的表的列表 - 只有一个方案。--[schema_name.]table_name[:partition_name][,…]

 TABLESPACES　　　　　　　　　 　　标识要导出的表空间的列表。

 TRANSPORTABLE　　　　　　　　　   指定是否可以使用可传输方法, 其中有效关键字值为: ALWAYS, (NEVER)。

 TRANSPORT_FULL_CHECK　　 　　　验证所有表的存储段 (N)。 

 TRANSPORT_TABLESPACES　　　　  要从中卸载元数据的表空间的列表。

 VERSION　　　　　　　　　　　　　　要导出的对象的版本, 其中有效关键字为:(COMPATIBLE), LATEST 或任何有效的数据库版本。

（2）命令　　　　　　　　　　　　说明

 ADD_FILE　　　　　　　　　　　　　向转储文件集中添加转储文件。

 CONTINUE_CLIENT　　　　　　　 　返回到记录模式。如果处于空闲状态, 将重新启动作业。

 EXIT_CLIENT　　　　　　　　　　 　退出客户机会话并使作业处于运行状态。

 FILESIZE　　　　　　　　　　　　 　后续 ADD_FILE 命令的默认文件大小 (字节)。

 HELP　　　　　　　　　　　　　　　总结交互命令。

 KILL_JOB　　　　　　　　　　　　　分离和删除作业。

 PARALLEL　　　　　　　　　　　  　 更改当前作业的活动 worker 的数目。PARALLEL=<worker 的数目>。

 _DUMPFILES　　　　　　　　　　 　 覆盖目标转储文件 (如果文件存在) (N)。

 START_JOB　　　　　　　　　　   　启动/恢复当前作业。

 STATUS　　　　　　　　　　　　  　 在默认值 (0) 将显示可用时的新状态的情况下,要监视的频率 (以秒计) 作业状态。STATUS[=interval]。

 STOP_JOB　　　　　　　　　　　 　 顺序关闭执行的作业并退出客户机。STOP_JOB=IMMEDIATE 将立即关闭数据泵作业。

 

五、impdp关键字与命令

（1）关键字　　　　　　　　　　　　说明 (默认)

ATTACH　　　　　　　　　　　　　　　连接到现有作业, 例如 ATTACH [=作业名]。

CONTENT　　　　　　　　　 　　　　   指定要卸载的数据, 其中有效关键字  值为: (ALL), DATA_ONLY 和 METADATA_ONLY。

DATA_OPTIONS　　　　　　  　　　　   数据层标记,其中唯一有效的值为:SKIP_CONSTRAINT_ERRORS-约束条件错误不严重。

DIRECTORY　　　　　　　　　　　　　供转储文件,日志文件和sql文件使用的目录对象，即逻辑目录。

DUMPFILE　　　　　　　　　　　　　　要从(expdp.dmp)中导入的转储文件的列表,例如 DUMPFILE=expdp1.dmp, expdp2.dmp。

 ENCRYPTION_PASSWORD　　　　　　用于访问加密列数据的口令关键字。此参数对网络导入作业无效。

 ESTIMATE　　　　　　　　　　　　　　计算作业估计值, 其中有效关键字为:(BLOCKS)和STATISTICS。

 EXCLUDE　　　　　　　　　　　　　　排除特定的对象类型, 例如 EXCLUDE=TABLE:EMP。

 FLASHBACK_SCN　　　　　　　　　　用于将会话快照设置回以前状态的 SCN。

 FLASHBACK_TIME　　　　　　　　　　用于获取最接近指定时间的 SCN 的时间。

 FULL　　　　　　　　　　　　　　　　 从源导入全部对象(Y)。

 HELP　　　　　　　　　　　　　　　　 显示帮助消息(N)。

 INCLUDE　　　　　　　　　　　　　　 包括特定的对象类型, 例如 INCLUDE=TABLE_DATA。

 JOB_NAME　　　　　　　　　　　　　 要创建的导入作业的名称。

 LOGFILE　　　　　　　　　　　　　　  日志文件名(import.log)。

 NETWORK_LINK　　　　　　　　　　　链接到源系统的远程数据库的名称。

 NOLOGFILE　　　　　　　　　　　　　不写入日志文件。　　

 PARALLEL　　　　　　　　　　　　　   更改当前作业的活动worker的数目。

 PARFILE　　　　　　　　　　　　　　  指定参数文件。

 PARTITION_OPTIONS　　　　　　　　 指定应如何转换分区,其中有效关键字为:DEPARTITION,MERGE和(NONE)。

 QUERY　　　　　　　　　　　　　　　用于导入表的子集的谓词子句。

 REMAP_DATA　　　　　　　　　　　　指定数据转换函数,例如REMAP_DATA=EMP.EMPNO:REMAPPKG.EMPNO。

 REMAP_DATAFILE　　　　　　　　　　在所有DDL语句中重新定义数据文件引用。

 REMAP_SCHEMA　　　　　　　　　　 将一个方案中的对象加载到另一个方案。

 REMAP_TABLE　　　　　　　　　　　  表名重新映射到另一个表,例如 REMAP_TABLE=EMP.EMPNO:REMAPPKG.EMPNO。

 REMAP_TABLESPACE　　　　　　　　将表空间对象重新映射到另一个表空间。

 REUSE_DATAFILES　　　　　　　　　 如果表空间已存在, 则将其初始化 (N)。

 SCHEMAS　　　　　　　　　　　　　   要导入的方案的列表。

 SKIP_UNUSABLE_INDEXES　　　　　  跳过设置为无用索引状态的索引。

 SQLFILE　　　　　　　　　　　　　　  将所有的 SQL DDL 写入指定的文件。

 STATUS　　　　　　　　　　　　　　  在默认值(0)将显示可用时的新状态的情况下,要监视的频率(以秒计)作业状态。　　

 STREAMS_CONFIGURATION　　　　   启用流元数据的加载。

 TABLE_EXISTS_ACTION　　　　　　　导入对象已存在时执行的操作。有效关键字:(SKIP),APPEND,REPLACE和TRUNCATE。

 TABLES　　　　　　　　　　　　　　  标识要导入的表的列表。

 TABLESPACES　　　　　　　　　　　 标识要导入的表空间的列表。　

 TRANSFORM　　　　　　　　　　　　要应用于适用对象的元数据转换。有效转换关键字为:SEGMENT_ATTRIBUTES,STORAGE,OID和PCTSPACE。

 TRANSPORTABLE　　　　　　　　　  用于选择可传输数据移动的选项。有效关键字为: ALWAYS 和 (NEVER)。仅在 NETWORK_LINK 模式导入操作中有效。

 TRANSPORT_DATAFILES　　　　　　 按可传输模式导入的数据文件的列表。

 TRANSPORT_FULL_CHECK　　　　　验证所有表的存储段 (N)。

 TRANSPORT_TABLESPACES　　　　 要从中加载元数据的表空间的列表。仅在 NETWORK_LINK 模式导入操作中有效。
 metrics=y                     显示每一个步骤的消耗时间

  VERSION　　　　　　　　　　　　　  要导出的对象的版本, 其中有效关键字为:(COMPATIBLE), LATEST 或任何有效的数据库版本。仅对 NETWORK_LINK 和 SQLFILE 有效。

（2）命令　　　　　　　　　　　　说明

 CONTINUE_CLIENT　　　　　　　　　返回到记录模式。如果处于空闲状态, 将重新启动作业。

 EXIT_CLIENT　　　　　　　　　　　　退出客户机会话并使作业处于运行状态。

 HELP　　　　　　　　　　　　　　　   总结交互命令。

 KILL_JOB　　　　　　　　　　　　　   分离和删除作业。

 PARALLEL　　　　　　　　　　　　　 更改当前作业的活动 worker 的数目。PARALLEL=<worker 的数目>。

 START_JOB　　　　　　　　　　　　  启动/恢复当前作业。START_JOB=SKIP_CURRENT 在开始作业之前将跳过作业停止时执行的任意操作。

 STATUS　　　　　　　　　　　　　　 在默认值 (0) 将显示可用时的新状态的情况下,要监视的频率 (以秒计) 作业状态。STATUS[=interval]。

 STOP_JOB　　　　　　　　　　　　　顺序关闭执行的作业并退出客户机。STOP_JOB=IMMEDIATE 将立即关闭数据泵作业。