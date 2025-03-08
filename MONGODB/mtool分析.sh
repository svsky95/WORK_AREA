mloginfo C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard13.log   --queries --sort count > C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard13_slow.log 
mloginfo C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14.log   --queries --sort count > C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14_slow.log 
mlogfilter --namespace dzswjdb.ysqxxVO  --slow 1000  C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14.log > C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14_ysqxxVO_cn.log

mlogfilter --namespace dzswjdb.ysqxxVO  --slow 1000   C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14.log > C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14_ysqxxVO_cn.log

mloginfo C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14.log   --queries --sort sum > C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14_slow.log 
mloginfo C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14.log   --queries --sort sum > C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14_slow.log 
mloginfo C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14.log   --queries --sort count > C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14_slow.log 
mlogfilter --namespace dzswjdb.xxzxMesSendVO  --slow 2000   C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14.log > C:\Users\svsky95\Desktop\mongodb慢日志\2020-04-21\shard14_xxzxMesSendVO.log



  "key" : {
                        "pzxh" : 1,
                        "yxbz" : 1,
                        "lrrq" : -1
                },
                "name" : "pzxh_1_yxbz_1_lrrq_-1",
                
db.ysqxxVO.find({ $and: [ { yxbz: "Y" }, { pzxh: "10016120000016645517" } ] }).sort({ lrrq: -1 })
db.ysqxxVO.ensureIndex({"pzxh" : 1, "yxbz" : 1,"lrrq" : -1}, {background: true})               





mloginfo C:\Users\svsky95\Desktop\shard1.log   --queries --sort sum > C:\Users\svsky95\Desktop\shard14_slow_0519.log  
mloginfo C:\Users\svsky95\Desktop\shard1.log   --queries --sort sum > C:\Users\svsky95\Desktop\shard14_slow_0512_new.log  

mloginfo C:\Users\svsky95\Desktop\shard1.log   --queries --sort sum > C:\Users\svsky95\Desktop\shard14_slow_0513.log  
mloginfo C:\Users\svsky95\Desktop\shard1_0514.log   --queries --sort sum > C:\Users\svsky95\Desktop\shard14_slow_0514.log  
mloginfo C:\Users\svsky95\Desktop\shard1_0514.log   --queries --sort sum > C:\Users\svsky95\Desktop\shard14_slow_0514.log  

--dzswjdb.ysqTbsmVO
mlogfilter --namespace dzswjdb.ysqTbsmVO  --slow 1000   C:\Users\svsky95\Desktop\shard1_0514.log > C:\Users\svsky95\Desktop\shard1_0514_ysqTbsmVO.log
--dzswjdb.nf_sfjr_transeq
mlogfilter --namespace dzswjdb.nf_sfjr_transeq  --slow 1000   C:\Users\svsky95\Desktop\shard1_0514.log > C:\Users\svsky95\Desktop\shard1_0514_nf_sfjr_transeq.log
--dzswjdb.ysqxxVO
mlogfilter --namespace dzswjdb.ysqxxVO  --slow 1000   C:\Users\svsky95\Desktop\shard1_0514.log > C:\Users\svsky95\Desktop\shard1_0514_ysqxxVO.log

-- --connections
mloginfo C:\Users\svsky95\Desktop\shard1_0514.log   --connections --sort > C:\Users\svsky95\Desktop\shard14_conn_0514.log 

mloginfo C:\Users\svsky95\Desktop\shard1.log   --queries --sort sum > C:\Users\svsky95\Desktop\shard13_slow_0513.log  