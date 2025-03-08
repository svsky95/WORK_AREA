##mongodb执行计划##
【如何获取系统中TOP SQL】
通常在版本上线前、平时SQL优化以及遇到性能问题等情况下，我们会通过explain()命令并根据传入不同参数,来获取不同细节.如果想看对于已经执行过语句的执行计划:
1、通过setProfilingLevel来配置语句执行超过设置阈值会记录到mongo日志以及system.profile中，因为system.profile是固定大小集合，频繁被truncate也会影响性能,不建议Profiling设置太小且不建议开启2级别.
2、通过缓存的执行计划来查看相关查询的详细执行计划，但是Mongodb并没有缓存所有查询结构的执行计划，必须存在多种可能执行计划时，才会进行缓存.同时也会LRU算法来清理相关缓存.
     对于开启Profile的系统，通过mtools、pt等工具来分析mongo慢日志或直接查询system.profile来分析数据库执行慢的语句.
1、检查数据库是否开profile并开始1级别
level:0表示不开启不采集任何数据,1表示采集超过slowms,默认是100ms,2表采集所有操作
shard1:PRIMARY> db.getProfilingLevel();
0
shard1:PRIMARY> db.setProfilingLevel(1);
2、通过profile集合来查询慢查询
备注:不一定能查找，有可能被覆盖了,此时需要借助mongodb log来分析
db.system.profile.find( { ns : 'exp.sign_detail' } ).pretty()

3、mtools工具mloginfo中queries获取整体TOP SQL概览情况
备注: queries无法获取执行计划，只能知道是top sql,是否走索引以及什么样索引看不出来，是否有排序之类，只能看到大概pattern情况. 还需要去日志去查找此集合相关的语句来分析.日志有具体
mloginfo --queries shard1.log
QUERIES                                                                                          
namespace     operation    pattern     count     min (ms)    max (ms)    mean (ms)                 sum (ms)
exp.sign_detail   find  {"org": 1, "signStatus": 1, "signT": 1}   964         100       4474            316 304884
      4、mtools工具mlogfilter来结合分析
备注:也可以通过vi中find命令来分析下,因为已经知道那个集合存在问题，tools工具比较复杂，只是简单介绍下常用的
mlogfilter shard1.log --namespace exp.jg_order--operation query
【如下慢日志--包括语句以及planSummary】
originatingCommand: {
aggregate:"jg_order",
pipeline: [{
     $match: {
          staBCode:"1000",
          staDate: newDate(1573315200000),
          isSta: {
              $in: [0,1]},
          isct: {
              $in: [0,1]}}
}, {
     $group: {
          _id: {
              staBCode:"$staBCode",
              staOCode:"$staOCode",
              staDate:"$staDate",
              isSta:"$isSta",
              isct:"$isct"
          },
          count: {
              $sum: {
                   $const:1
              }
          }
     }
}],

planSummary: IXSCAN {
staDate: 1,
staBCode: 1,
isSta: 1,
isct: 1,
staOCode: 1
}
cursorid: 5726654405175893822 keysExamined: 271092 docsExamined: 271091 cursorExhausted: 1 numYields: 2133 nreturned: 6 reslen: 1017 locks: {

【缓存执行计划】 
        Mongodb中生成执行计划并缓存执行计划(并不是所有执行计划都被缓存),如果存在多个执行计划，此时会缓存执行计划，如果只有一种执行计划，那么优化器不会缓存执行计划，因为只有一种可能.为什么存在多个可能的执行计划才会缓存?
        因为Mongo生成执行计划，是优化器对满足条件可能执行计划同时执行，而不是依赖统计信息来计算出来的，而是真正执行出来,谁先执行出来就是winningPlan,剩下都是rejectedPlans,此时缓存执行计划了,相当于一次解析，多次使用.因为生成执行计划代价比较高，所以存在多个可能的执行计划才会缓存.
         通过发生创建索引、删除索引、实例重启，此时会清空表缓存执行计划.当时也可以手动清理集合所有缓存执行计划也可以针对特定查询结构来清理.
【mongodb 4.2版本】
      为了标识慢查询具有相同查询结构，从Mongodb 4.2版本对于每一个sql通过hash函数生成十六进制的queryhash,每个queryhash可能有不同plancachekey.(如果了解oracle的，queryhash类似oracle sql_id,plancachekey类似oracle plan hash value),例如sql刚才走COLLSCAN后续走IXSCAN，那么sql的plancachekey则不一样.

【如何获取Mongodb执行计划】
         1、通过Mongodb慢查询或Profile集合来查看执行集合，必须超过slowms阈值才能查看到。如果没有超过阈值的则没有办法而且只能查看已经执行，所以说分析历史的SQL执行计划情况【属于历史执行计划】
         2、通过explain()来获取当前SQL的执行计划(也可能执行过，但是没有记录到慢日志中)，explain()支持三个参数{'queryPlanner','executionStats','allPlansExecution'},默不传参数即可查看queryPlanner, executionStats查看SQL具体执行情况，包括检查多少索引key、检索多少doc，返回多少记录，执行时间等，如果想看SQL具体执行情况以及资源消耗、索引是否高效，这个是最有效的方式之一,当然有经验dba或者熟悉优化的人员，通过语句结合索引就能判断索引是否高效.对write操作的查看explain，不会真正去修改数据库.使用executionStats之前先大概看下语句以及索引，如果忽略这个，大表没有索引的情况，使用executionStats真正去执行，那么有可能对workset造成影响。【按需执行计划】
      3、通过db.collection.getPlanCache().getPlansByQuery(query[, projection, sort, collation])获取已缓存的执行计划，只有存在语句存在多个执行计划时，才会缓存最高效执行计划，否则只有1个执行计划，那么不会缓存.【同一查询结构SQL缓存最佳执行计划】

【EXPLAIN来获取SQL执行计划】
        1、查看查询类执行计划
        PRIMARY> db.sign_detail.find({org:100}).explain();--参数按需
        2、查看聚合类执行计划
         PRIMARY> db.sign_detail.explain().aggregate({$match:{org:"100"}})
        3、查看修改类执行计划--不会修改实际值,也可以转换成查询语句
            db.members.explain().update(
            { "points": { $lte: 20 }, "status": "P" },
            { $set: { "misc1": "Need to activate" } },
             { multi: true, hint: { status: 1 } })

【如何查看与维护缓存执行计划】
1、通过db.collection.getPlanCache()命令可以查找缓存语句以及对应缓存执行计划
shard1:PRIMARY> db.sign_detail.getPlanCache().help();
PlanCache help
db.sign_detail.getPlanCache().help() - show PlanCache help
db.sign_detail.getPlanCache().listQueryShapes() - displays all query shapes in a collection
db.sign_detail.getPlanCache().clear() - drops all cached queries in a collection
db.sign_detail.getPlanCache().clearPlansByQuery(query[, projection, sort, collation]) - drops query shape from plan cache
db.sign_detail.getPlanCache().getPlansByQuery(query[, projection, sort, collation]) - displays the cached plans for a query shape
shard1:PRIMARY> 
备注:通过查询一个org:"1234"此时被缓存.
2、shard1:PRIMARY> db.sign_detail.getPlanCache().listQueryShapes();
db.sign_detail.getPlanCache().listQueryShapes();
[
{
"query" : {
"org" : "1234"
},
"sort" : {
},
"projection" : {
},
"queryHash" : "438F4C85"
}
]
3、查看query的缓存执行计划
备注:其中有一个score评分
db.sign_detail.getPlanCache().getPlansByQuery({"org" : "1234"},{},{});
{
"plans" : [
{
"details" : {
"solution" : "(index-tagged expression tree: tree=Leaf (org_1_staDate_1_no_1, ), pos: 0, can combine? 1\n)"
},
"reason" : {
"score" : 1.0002,
"stats" : {
"stage" : "FETCH",
"nReturned" : 0,
"executionTimeMillisEstimate" : 0,
"works" : 1,
"advanced" : 0,
"needTime" : 0,
"needYield" : 0,
"saveState" : 0,
"restoreState" : 0,
"isEOF" : 1,
"docsExamined" : 0,
"alreadyHasObj" : 0,
"inputStage" : {
"stage" : "IXSCAN",
"nReturned" : 0,
"executionTimeMillisEstimate" : 0,
"works" : 1,
"advanced" : 0,
"needTime" : 0,
"needYield" : 0,
"saveState" : 0,
"restoreState" : 0,
"isEOF" : 1,
"keyPattern" : {
"org" : 1,
"staDate" : 1,
"no" : 1
},

4、如何手动清理集合的缓存的执行计划
db.sign_detail.getPlanCache().clear()--清理所有的缓存执行计划
PRIMARY> db.sign_detail.getPlanCache().clear()
PRIMARY> db.sign_detail.getPlanCache().listQueryShapes();
[ ]--此时缓存查询为空
清理单个执行计划缓存:
PRIMARY> db.sign_detail.getPlanCache().listQueryShapes();
[
{
"query" : {
"org" : "100"
},
"sort" : {
			
},
"projection" : {
			
},
"queryHash" : "438F4C85"
}
]
PRIMARY>db.sign_detail.getPlanCache().clearPlansByQuery({org:"101"});
备注：这里org后续value值无需相同，只要谓词保持一致就行.
PRIMARY> db.sign_detail.getPlanCache().listQueryShapes();
[ ]
[ ]--此时缓存查询为空

5、其他情况也会触发清理集合的所有缓存的最佳执行计划
      创建索引、删除索引、实例重启以及触发LRU机制.

【如何固定执行计划】
          可以通过hint指定索引或者集合扫描来测试性能与验证特定索引策略,可以指定索引名字或者索引列顺序.
          1、hint指定索引以及查看执行计划
PRIMARY> db.sign_detail.find({org:100}).hint("org_1_signT_1").explain();
          2、hint聚合类
PRIMARY>db.sign_detail.explain().aggregate([{$match:{CustomerCode: "12345", Seller: "1234",staDate: new Date(1594742400000) } },{ $group: { _id: { cus:"$CustomerCode", type: "$signStatus", Seller:"$Seller" }, count: { $sum: 1 } } }],{hint:{CustomerCode: 1,Seller: 1, signT: 1}})}
        3、hint指定扫描集合，不使用索引，强制集合索引
PRIMARY> db.sign_detail.find().hint( { $natural : 1 } )；--正向扫描 
PRIMARY> db.sign_detail.find().hint( { $natural : -1 } )；--反向扫描