##电子税务局生产mongodb iowait过大的分析
--问题描述：
##从库
在当天的10:30分左右，发现iowait达到100%，在从节点慢日志看出，所有查询都是30s以上。
2021-07-07T10:28:50.679+0800 I COMMAND [conn2708816] command dzswjdb.ysxVO command: find { find: "ysxVO", filter: { ywbm: "XGMZZS", djxh: "10116103010000037738", yxbz: "Y", yzcbz: "Y", ssqq: new Date(1617206400000), ssqz: new Date(1624982400000), guideParam: "525542009", ywzt: "Y" }, projection: { $sortKey: { $meta: "sortKey" } }, sort: { xgrq: -1 }, limit: 1, shardVersion: [ Timestamp 0|0, ObjectId('000000000000000000000000') ] } planSummary: IXSCAN { djxh: 1, ywbm: 1, ssqq: 1, ssqz: 1 } keysExamined:0 docsExamined:0 hasSortStage:1 cursorExhausted:1 numYields:0 nreturned:0 reslen:200 locks:{ Global: { acquireCount: { r: 2 }, acquireWaitCount: { r: 1 }, timeAcquiringMicros: { r: 16291538 } }, Database: { acquireCount: { r: 1 } }, Collection: { acquireCount: { r: 1 } } } protocol:op_command 16383ms
##主库
2021-07-07T10:20:00.341+0800 I COMMAND  [conn3292666] command dzswjdb.xxzxMesSendVO command: find { find: "xxzxMesSendVO", filter: { $or: [ { $and: [ { receiverType: "djxh" }, { lrrq: { $gte: new Date(1622995200000), $lte: new Date(1625673599000) } }, { isDeliverOut: "Y" }, { yxbz: "Y" }, { receiver: "groupUsers" } ] }, { $and: [ { receiverType: "djxh" }, { lrrq: { $gte: new Date(1622995200000), $lte: new Date(1625673599000) } }, { isDeliverOut: "Y" }, { yxbz: "Y" }, { receiver: "10116101010000068285" }, { isRead: "N" } ] }, { $and: [ { receiverType: "djxh" }, { lrrq: { $gte: new Date(1622995200000), $lte: new Date(1625673599000) } }, { isDeliverOut: "Y" }, { yxbz: "Y" }, { multiUsers: "10116101010000068285" } ] } ] }, projection: { $sortKey: { $meta: "sortKey" } }, sort: { lrrq: -1 }, limit: 1000, shardVersion: [ Timestamp 0|0, ObjectId('000000000000000000000000') ] } planSummary: IXSCAN { receiver: 1, xgrq: -1, lrrq: -1 }, IXSCAN { receiver: 1, xgrq: -1, lrrq: -1 }, IXSCAN { multiUsers: 1, lrrq: -1 } keysExamined:67 docsExamined:7 hasSortStage:1 cursorExhausted:1 numYields:3 nreturned:1 reslen:615 locks:{ Global: { acquireCount: { r: 8 } }, Database: { acquireCount: { r: 4 } }, Collection: { acquireCount: { r: 4 } } } protocol:op_command 51676ms
可以看出在主库的读，是没有timeAcquiringMicros，但是hasSortStage:1，说明有排序了，需要再优化下索引。
--问题分析：
以上的这个语句，索引方面已经是最优了，但是需要注意：
1、timeAcquiringMicros: { r: 16291538 }，这个是从节点读的典型问题，在4.0之前从节点复制数据的时候会有一个全局锁，所有读操作都会被阻塞。
--处理方式：
当查询量很大时候，内存一定要大，想要查询性能好内存得够大，内存装不下的就变成IO压到磁盘上。
这个问题升级到4.0会有明显的改善
这是之前版本的设计上的问题，除了升级没有更好的办法
但是这个全局锁长时间占用的原因主要也是因为IO不足
升级库，简单重要的是，目前应用要支持4.0的驱动。
--升级顺序：
3.4->3.6->4.0  （不能跳版本）