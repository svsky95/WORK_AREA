--mongodb查询慢的问题汇总
1、在查询单列索引的情况下，为何查询的时间还会是2s以上
2、即便是索引已经正确的创建了，所有的查询也保证不了在500ms以下

原因分析：
1、从慢日志中可以看出来，在同一时间同一张表大约并发在20以上，导致时间较长
2、为此，尽量创建合适的索引，来尽快的查出结果



#####索引效率的比较#####
##测试数据
{ "_id" : 1, "item" : "f1", type: "food", quantity: 500 }
{ "_id" : 2, "item" : "f2", type: "food", quantity: 100 }
{ "_id" : 3, "item" : "p1", type: "paper", quantity: 200 }
{ "_id" : 4, "item" : "p2", type: "paper", quantity: 150 }
{ "_id" : 5, "item" : "f3", type: "food", quantity: 300 }
{ "_id" : 6, "item" : "t1", type: "toys", quantity: 500 }
{ "_id" : 7, "item" : "a1", type: "apparel", quantity: 250 }
{ "_id" : 8, "item" : "a2", type: "apparel", quantity: 400 }
{ "_id" : 9, "item" : "t2", type: "toys", quantity: 50 }
{ "_id" : 10, "item" : "f4", type: "food", quantity: 75 }

db.inventory.find( { quantity: { $gte: 100, $lte: 300 }, type: "food" } )
--查询结果
{ "_id" : 2, "item" : "f2", "type" : "food", "quantity" : 100 }
{ "_id" : 5, "item" : "f3", "type" : "food", "quantity" : 300 }

db.inventory.createIndex( { quantity: 1, type: 1 } )
db.inventory.createIndex( { type: 1, quantity: 1 } )   //效率较高

--db.inventory.createIndex( { quantity: 1, type: 1 } )执行计划
db.inventory.find(
   { quantity: { $gte: 100, $lte: 300 }, type: "food" }
).hint({ quantity: 1, type: 1 }).explain("executionStats")

"executionStats" : {
      "executionSuccess" : true,
      "nReturned" : 2,
      "executionTimeMillis" : 0,
      "totalKeysExamined" : 5,      --索引扫描了5个文档
      "totalDocsExamined" : 2,
      "executionStages" : {
      	
--db.inventory.createIndex( { type: 1, quantity: 1 } )  执行计划
db.inventory.find(
   { quantity: { $gte: 100, $lte: 300 }, type: "food" }
).hint({ type: 1, quantity: 1 }).explain("executionStats")

 "executionStats" : {
      "executionSuccess" : true,
      "nReturned" : 2,
      "executionTimeMillis" : 0,
      "totalKeysExamined" : 2,      --索引扫描了2个文档
      "totalDocsExamined" : 2,
      "executionStages" : {