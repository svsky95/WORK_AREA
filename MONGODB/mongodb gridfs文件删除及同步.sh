#####mongodb gridfs文件删除及同步#####
一、以shard2为例，其中有三个成员：
10.10.8.51:27019 PRIMARY
10.10.8.50:27019 secondary
10.10.8.55:27019 ARBITER

二、断掉生产的所有业务，关闭分片的复制集，为了保证数据的安全，让secondary从复制集中脱离
1、关闭所有节点上mongos
[root@12cnod01 ~]# ps -ef | grep mongodb
root       939     1  0 May20 ?        00:04:05 ./mongos --config /usr/local/mongodb/mongos/mongos.conf
kill -2 939

2、关闭PRIMARY、secondary实例
mongod --shutdown --dbpath /usr/local/mongodb/shard2/db

3、编辑文件，让primary脱离复制集，这样才能做删除
[root@12cnod02 shard2]# vim mongod.conf 
#shard2 mongod.conf
systemLog:
   destination: file
   path: "/usr/local/mongodb/shard2/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/shard2/db"
processManagement:
   fork: true
   pidFilePath: /usr/local/mongodb/shard2/pid
net:
   bindIp: 10.10.8.51
   port: 27019
setParameter:
   enableLocalhostAuthBypass: false
--注释掉以下
#replication:
#   replSetName: "shard2"
#sharding:
#   clusterRole: shardsvr
#security:
#    authorization: enabled
#    keyFile: /usr/local/mongodb/key/mongdb-keyfile

3、启动PRIMARY mongod，让之就变成了单实例
mongod --config /usr/local/mongodb/shard2/mongod.conf

三、在PRIMARY删除相关文件
参考  《gridfs文件删除》
1、mongofiles --host 10.10.8.51 --port 27019 -d records delete file_20200521

四、确定物理空间都释放后，让PRIMARY的单实例重新加入复制集
1、编辑配置文件，打开集群的配置
replication:
   replSetName: "shard2"
sharding:
   clusterRole: shardsvr
security:
    authorization: enabled
    keyFile: /usr/local/mongodb/key/mongdb-keyfile 

2、启动实例
mongod --shutdown --dbpath /usr/local/mongodb/shard2/db
mongod --config /usr/local/mongodb/shard2/mongod.conf

五、启动mongos，验证业务是否正确
mongos --config /usr/local/mongodb/mongos/mongos.conf

六、在主验证正常的情况下，开启 secondary节点，这是就会发现主从不一致
[root@12cnod01 shard2]# mongofiles --host 10.10.8.50 --port 27019 -d records list
2020-05-22T09:54:32.847+0800    connected to: mongodb://10.10.8.50:27019/   从 
jdk-8u171-linux-x64.tar.gz      190890122
CodeDataConfiguration_20180614.bson     12065
test    109
test_2  12762
test_3  12762
files_1 1073741824
files_2 1073741824
files_3 1073741824
files_4 1073741824
files_5 1073741824
files_6 1073741824
files_7 1073741824
files_8 1073741824
[root@12cnod01 shard2]# mongofiles --host 10.10.8.50 --port 27017 -d records list
2020-05-22T09:55:13.780+0800    connected to: mongodb://10.10.8.51:27019/   主
jdk-8u171-linux-x64.tar.gz      190890122
CodeDataConfiguration_20180614.bson     12065
test    109
test_2  12762
test_3  12762
files_1 1073741824
files_2 1073741824

--之后为了保证主从的同一，只能重新同步从服务器。
1、关闭从服务器
mongod --shutdown --dbpath /usr/local/mongodb/shard2/db

删除shard2的文件

2、开启从服务器后，开始复制集的自动同步

3、若没有初始化，登录主，查看权重值，根据权重值，重新初始化复制集
rs.status()

config = {
   _id : "shard2",
    members : [
        {_id : 0, host : "10.10.8.50:27019" ,priority : 1},
        {_id : 1, host : "10.10.8.51:27019" ,priority : 2},
        {_id : 2, host : "10.10.8.55:27019", arbiterOnly: true}
    ]
}

rs.initiate(config);



##操作日志
10.10.8.50 
[root@12cnod01 shard2]# du -sh *
1.9G    db
234M    log
4.0K    mongod.conf
4.0K    pid

10.10.8.51 
[root@12cnod02 shard2]# du -sh *
2.0G    db
1.4G    log
4.0K    mongod.conf
4.0K    pid

[root@12cnod01 shard2]# mongofiles --host 10.10.8.50 --port 27017 -d records list
2020-05-22T09:29:58.432+0800    connected to: mongodb://10.10.8.50:27017/
jdk-8u171-linux-x64.tar.gz      190890122
CodeDataConfiguration_20180614.bson     12065
test    109
test_2  12762
test_3  12762
files_1 1073741824
files_2 1073741824
files_3 1073741824
files_4 1073741824
files_5 1073741824
files_6 1073741824
files_7 1073741824
files_8 1073741824

mongos> show dbs;
admin    0.000GB
config   0.002GB
records  0.690GB
test_db  0.000GB

2020-05-22T09:36:47.450+0800    connected to: mongodb://10.10.8.51:27019/
jdk-8u171-linux-x64.tar.gz      190890122
CodeDataConfiguration_20180614.bson     12065
test    109
test_2  12762
test_3  12762
files_1 1073741824
files_2 1073741824
files_3 1073741824
files_4 1073741824
files_5 1073741824
files_6 1073741824
files_7 1073741824
files_8 1073741824

> db.fs.files.find()
{ "_id" : ObjectId("5ec4e3622c1ee85d199dbf31"), "length" : NumberLong(190890122), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-20T07:59:36.990Z"), "filename" : "jdk-8u171-linux-x64.tar.gz", "metadata" : {  } }
{ "_id" : ObjectId("5ec5dd2447d67f6906bad871"), "length" : NumberLong(12065), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T01:45:08.462Z"), "filename" : "CodeDataConfiguration_20180614.bson", "metadata" : {  } }
{ "_id" : ObjectId("5ec5dd2b8f5a80bcd86d5385"), "length" : NumberLong(109), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T01:45:15.962Z"), "filename" : "test", "metadata" : {  } }
{ "_id" : ObjectId("5ec5dd336524fdd4ced337fb"), "length" : NumberLong(12762), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T01:45:23.626Z"), "filename" : "test_2", "metadata" : {  } }
{ "_id" : ObjectId("5ec5dd36bed5d98c2af6648c"), "length" : NumberLong(12762), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T01:45:26.130Z"), "filename" : "test_3", "metadata" : {  } }
{ "_id" : ObjectId("5ec6510ea6767e3bef2a9eda"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T10:00:03.555Z"), "filename" : "files_1", "metadata" : {  } }
{ "_id" : ObjectId("5ec72828e7961bff3676a599"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:18:58.755Z"), "filename" : "files_2", "metadata" : {  } }
{ "_id" : ObjectId("5ec728b65d465a588988a543"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:21:08.641Z"), "filename" : "files_3", "metadata" : {  } }
{ "_id" : ObjectId("5ec729bb8ccb02abbd214888"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:25:32.351Z"), "filename" : "files_4", "metadata" : {  } }
{ "_id" : ObjectId("5ec72a1654eb62eea84928b7"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:26:07.943Z"), "filename" : "files_5", "metadata" : {  } }
{ "_id" : ObjectId("5ec72a384bd1c2bec1c64454"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:26:34.217Z"), "filename" : "files_6", "metadata" : {  } }
{ "_id" : ObjectId("5ec72aa2888c23977348efa9"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:28:21.463Z"), "filename" : "files_7", "metadata" : {  } }
{ "_id" : ObjectId("5ec72ab85059e2fe09f6f53d"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:28:42.514Z"), "filename" : "files_8", "metadata" : {  } }
> db.fs.files.update({"uploadDate": {
...         $gt: new Date("2020-05-22 09:20:14"),
...         $lt: new Date('2020-05-22 17:50:00')}},{$set:{"filename": "file_20200522"}},{multi:true})
WriteResult({ "nMatched" : 6, "nUpserted" : 0, "nModified" : 6 })
> db.fs.files.find()
{ "_id" : ObjectId("5ec4e3622c1ee85d199dbf31"), "length" : NumberLong(190890122), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-20T07:59:36.990Z"), "filename" : "jdk-8u171-linux-x64.tar.gz", "metadata" : {  } }
{ "_id" : ObjectId("5ec5dd2447d67f6906bad871"), "length" : NumberLong(12065), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T01:45:08.462Z"), "filename" : "CodeDataConfiguration_20180614.bson", "metadata" : {  } }
{ "_id" : ObjectId("5ec5dd2b8f5a80bcd86d5385"), "length" : NumberLong(109), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T01:45:15.962Z"), "filename" : "test", "metadata" : {  } }
{ "_id" : ObjectId("5ec5dd336524fdd4ced337fb"), "length" : NumberLong(12762), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T01:45:23.626Z"), "filename" : "test_2", "metadata" : {  } }
{ "_id" : ObjectId("5ec5dd36bed5d98c2af6648c"), "length" : NumberLong(12762), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T01:45:26.130Z"), "filename" : "test_3", "metadata" : {  } }
{ "_id" : ObjectId("5ec6510ea6767e3bef2a9eda"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-21T10:00:03.555Z"), "filename" : "files_1", "metadata" : {  } }
{ "_id" : ObjectId("5ec72828e7961bff3676a599"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:18:58.755Z"), "filename" : "files_2", "metadata" : {  } }
{ "_id" : ObjectId("5ec728b65d465a588988a543"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:21:08.641Z"), "filename" : "file_20200522", "metadata" : {  } }
{ "_id" : ObjectId("5ec729bb8ccb02abbd214888"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:25:32.351Z"), "filename" : "file_20200522", "metadata" : {  } }
{ "_id" : ObjectId("5ec72a1654eb62eea84928b7"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:26:07.943Z"), "filename" : "file_20200522", "metadata" : {  } }
{ "_id" : ObjectId("5ec72a384bd1c2bec1c64454"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:26:34.217Z"), "filename" : "file_20200522", "metadata" : {  } }
{ "_id" : ObjectId("5ec72aa2888c23977348efa9"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:28:21.463Z"), "filename" : "file_20200522", "metadata" : {  } }
{ "_id" : ObjectId("5ec72ab85059e2fe09f6f53d"), "length" : NumberLong(1073741824), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-22T01:28:42.514Z"), "filename" : "file_20200522", "metadata" : {  } }

[root@12cnod02 shard2]# mongofiles --host 10.10.8.51 --port 27019 -d records list 
2020-05-22T09:40:30.474+0800    connected to: mongodb://10.10.8.51:27019/
jdk-8u171-linux-x64.tar.gz      190890122
CodeDataConfiguration_20180614.bson     12065
test    109
test_2  12762
test_3  12762
files_1 1073741824
files_2 1073741824
file_20200522   1073741824
file_20200522   1073741824
file_20200522   1073741824
file_20200522   1073741824
file_20200522   1073741824
file_20200522   1073741824
[root@12cnod02 shard2]# mongofiles --host 10.10.8.51 --port 27019 -d records delete file_20200522
2020-05-22T09:40:40.490+0800    connected to: mongodb://10.10.8.51:27019/
2020-05-22T09:40:48.385+0800    successfully deleted all instances of 'file_20200522' from GridFS

[root@12cnod02 shard2]# mongofiles --host 10.10.8.51 --port 27019 -d records list 
2020-05-22T09:41:42.776+0800    connected to: mongodb://10.10.8.51:27019/
jdk-8u171-linux-x64.tar.gz      190890122
CodeDataConfiguration_20180614.bson     12065
test    109
test_2  12762
test_3  12762
files_1 1073741824
files_2 1073741824

[root@12cnod02 shard2]# du -sh *
1.5G    db
1.4G    log
4.0K    mongod.conf
4.0K    pid

> show dbs;
admin    0.000GB
config   0.000GB
local    0.464GB
records  0.690GB
> db.runCommand({ compact : 'fs.chunks' ,force:true});
{ "ok" : 1 }
> show dbs;
admin    0.000GB
config   0.000GB
local    0.464GB
records  0.307GB

[root@12cnod02 shard2]# du -sh *
1.1G    db
1.4G    log
4.0K    mongod.conf
4.0K    pid

2020-05-22T09:54:32.847+0800    connected to: mongodb://10.10.8.50:27019/
jdk-8u171-linux-x64.tar.gz      190890122
CodeDataConfiguration_20180614.bson     12065
test    109
test_2  12762
test_3  12762
files_1 1073741824
files_2 1073741824
files_3 1073741824
files_4 1073741824
files_5 1073741824
files_6 1073741824
files_7 1073741824
files_8 1073741824
[root@12cnod01 shard2]# mongofiles --host 10.10.8.50 --port 27017 -d records list
2020-05-22T09:55:13.780+0800    connected to: mongodb://10.10.8.50:27017/
jdk-8u171-linux-x64.tar.gz      190890122
CodeDataConfiguration_20180614.bson     12065
test    109
test_2  12762
test_3  12762
files_1 1073741824
files_2 1073741824