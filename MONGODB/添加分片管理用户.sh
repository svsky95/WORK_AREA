##mongodb添加分片管理用户
现象描述：
在已经有keyfile验证的情况下，需要添加分片管理用户，用来监控每个分片的性能状态

操作如下：
1、关闭mongos，为了防止数据写入导致的不一致
kill -2 mongos_pid

2、关闭config及shard的分片
mongod --shutdown --dbpath /usr/local/mongodb/shard1/db
mongod --shutdown --dbpath /usr/local/mongodb/shard2/db
mongod --shutdown --dbpath /usr/local/mongodb/shard3/db

mongod --shutdown --dbpath /usr/local/mongodb/configsvr/db
 
3、注销mongod及config的 keyfile选项。
#security:
   #authorization: enabled
   #keyFile: /usr/local/mongodb/key/mongdb-keyfile

4、每台主机，先启动config的分片，再启动shard的分片，逐个分片启动。
mongod --config /usr/local/mongodb/configsvr/cfg.conf
mongod --config /usr/local/mongodb/shard1/mongod.conf

4、在分片的primary分片上添加管理用户
use admin 
db.createUser( { user: 'shard_admin', pwd: 'shard_admin@!2020', roles: [ { role: 'root', db: 'admin' } ] })
5、验证mongostat是否正常
mongostat -h 92.12.76.13:27001 -u shard_admin -p 'shard_admin@!2020' --authenticationDatabase=admin --humanReadable=true --discover --all 2
6、当验证正常的情况下，再次关闭config及shard分片，打开keyfile参数
7、先启动config再启动shard，确定没有问题的情况下，开启mongos服务。




db.createUser( { user: 'admin_shard', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })
mongod --shutdown --dbpath /usr/local/mongodb/shard1/db
mongod --shutdown --dbpath /usr/local/mongodb/shard2/db
mongod --shutdown --dbpath /usr/local/mongodb/shard3/db

mongod --shutdown --dbpath /usr/local/mongodb/configsvr/db




从"stateStr" : "ARBITER" 转换为 "stateStr" : "SECONDARY" 需要先移除，在添加进来。
"New and old configurations differ in the setting of the arbiterOnly field for member 10.10.8.51:27018; to make this change, remove then re-add the member",

rs.remove('10.10.8.51:27018')
rs.add('10.10.8.51:27018')