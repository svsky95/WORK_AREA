##mongodb 4.22分片及副本集搭建##
下载：https://www.mongodb.com/try/download/community
--服务器包
Version: 5.09
platform: centos7.0 
Package:tgz
mongodb-linux-x86_64-rhel70-5.0.9.tgz
--数据库工具包 mongodb database tools
https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel80-x86_64-100.6.0.tgz
里面包含了mongo、mongodump等工具
--mongosh （5.0版本前的mongo客户端）
Mongodb Shell

当数据节点为偶数时候需要增加仲裁节点，故障时候仲裁新的主，当数据节点为奇数时候无需仲裁节点，根据id优先级选举新的主。仲裁节点本身不存储数据，如果配置仲裁节点使用虚拟机即可。

--规划
mongos1: 192.168.2.118
shard1:27018
shard2:27019
shard3:27020
config:20000
mongos:27017

mongos2: 192.168.2.119
shard1:27018
shard2:27019
shard3:27020
config:20000
mongos:27017

mongos3: 192.168.2.120
shard1:27018
shard2:27019
shard3:27020
config:20000
mongos:27017

##修改主机名
[root@localhost ~]# vim /etc/hostname
dzswj_mysql_db3

systemctl restart systemd-hostnamed

##参考centos7.x优化
##参考mongodb搭建及管理

##配置host文件
vim /etc/hosts
192.168.2.118  mongodb01
192.168.2.119  mongodb02
192.168.2.120  mongodb03

1、账户创建及目录分配
##Root用户操作
1.1 mongod创建用户账号
groupadd -g 400001363 mongod
useradd -u 200000173 -g mongod mongod
passwd mongod
密码：123456

1.2 程序包目录
mkdir -p  /usr/local/mongodb509
chown -R mongod:mongod /usr/local/mongodb509

1.3 目录分配
mkdir -p  /usr/local/mongodb
chown -R mongod:mongod /usr/local/mongodb


2、解压软件包及环境变量配置
##mongod用户操作
2.1 把软件包放在此目录下进行解压
[mongod@mongodb01 mongodb509]$ /usr/local/mongodb509/mongodb-linux-x86_64-rhel70-5.0.9.tgz
[mongod@mongodb01 mongodb509]$ tar xvf mongodb-linux-x86_64-rhel70-5.0.9.tgz

--安装数据库工具包
https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel80-x86_64-100.6.0.tgz

--安装mongosh(mongo)
#root执行
cd /usr/local/mongodb602/mongodb-linux-x86_64-rhel80-6.0.2/bin
1、进入yum的repos目录

2、修改所有的CentOS文件内容
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

3、更新yum源为阿里镜像
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
yum clean all
yum makecache

4、运行 python3.6 install_compass

2.2 配置环境变量
[mongod@mongodb01 bin]$ vim ~/.bash_profile
PATH=$PATH:$HOME/.local/bin:$HOME/bin:/usr/local/mongodb509/mongodb-linux-x86_64-rhel70-5.0.9/bin
export PATH


2.3 创建目录数据目录
mkdir -p /usr/local/mongodb/shard1/db 
mkdir -p /usr/local/mongodb/shard1/log
mkdir -p /usr/local/mongodb/shard1/config
mkdir -p /usr/local/mongodb/shard2/db 
mkdir -p /usr/local/mongodb/shard2/log 
mkdir -p /usr/local/mongodb/shard2/config
mkdir -p /usr/local/mongodb/shard3/db 
mkdir -p /usr/local/mongodb/shard3/log 
mkdir -p /usr/local/mongodb/shard3/config
mkdir -p /usr/local/mongodb/configsvr/db
mkdir -p /usr/local/mongodb/configsvr/log
mkdir -p /usr/local/mongodb/configsvr/config
mkdir -p /usr/local/mongodb/mongos/log
mkdir -p /usr/local/mongodb/mongos/config


chown -R mongod:mongod /usr/local/mongodb/shard1/db
chown -R mongod:mongod /usr/local/mongodb/shard1/log
chown -R mongod:mongod /usr/local/mongodb/configsvr/log
chown -R mongod:mongod /usr/local/mongodb/mongos

chmod 750 /usr/local/mongodb
chmod 750 /usr/local/mongodb/shard1/db    
chmod 750 /usr/local/mongodb/shard1/log   
chmod 750 /usr/local/mongodb/configsvr/log
chmod 750 /usr/local/mongodb/mongos       

###分片集群创建###
--以下3、4、5、6步骤分别在118、119、120上分别配置，并启动服务，配置文件中修改IP，其余不变
3、配置并启动shard1
vim /usr/local/mongodb/shard1/config/mongod.conf 
:set paste
#shard1 mongod.conf
systemLog:
   destination: file
   path: "/usr/local/mongodb/shard1/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/shard1/db"
   ##调整缓存大小
 # wiredTiger:
 #    engineConfig:
 #       cacheSizeGB: 1
processManagement:
   fork: true
   pidFilePath: /usr/local/mongodb/shard1/pid
net:
   bindIp: 192.168.2.118  ##绑定本机的物理网卡IP
   port: 27018
setParameter:
   enableLocalhostAuthBypass: false
replication:
   replSetName: "shard1"
sharding:
   clusterRole: shardsvr

4、配置并启动shard2
vim /usr/local/mongodb/shard2/config/mongod.conf 

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
   bindIp: 192.168.2.118
   port: 27019
setParameter:
   enableLocalhostAuthBypass: false
replication:
   replSetName: "shard2"
   ##enableMajorityReadConcern: true   ##保证复制集中，读取的数据已经在大多数节点上已提交，用来提高数据的一致性，但是若从节点有延迟，就会导致等待。(可选)
sharding:
   clusterRole: shardsvr

5、配置并启动shard3
vim /usr/local/mongodb/shard3/config/mongod.conf 

#shard3 mongod.conf
systemLog:
   destination: file
   path: "/usr/local/mongodb/shard3/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/shard3/db"
processManagement:
   fork: true
   pidFilePath: /usr/local/mongodb/shard3/pid
net:
   bindIp: 192.168.2.118
   port: 27020
setParameter:
   enableLocalhostAuthBypass: false
replication:
   replSetName: "shard3"
sharding:
   clusterRole: shardsvr

6、启动并配置configsvr
vim /usr/local/mongodb/configsvr/config/cfg.conf
#configsvr cfg.conf
storage:
    dbPath: /usr/local/mongodb/configsvr/db
    journal:
        enabled: true
systemLog:
    destination: file
    logAppend: true
    path: /usr/local/mongodb/configsvr/log/mongod.log
net:
    port: 20000
    bindIp: 192.168.2.118
processManagement:
    fork: true
    pidFilePath: /usr/local/mongodb/configsvr/pid
replication:
    replSetName: cfg
sharding:
    clusterRole: configsvr


7、配置文件拷贝到其它节点
scp /usr/local/mongodb/shard1/config/mongod.conf 192.168.2.119:/usr/local/mongodb/shard1/config/mongod.conf
scp /usr/local/mongodb/shard2/config/mongod.conf 192.168.2.119:/usr/local/mongodb/shard2/config/mongod.conf
scp /usr/local/mongodb/shard3/config/mongod.conf 192.168.2.119:/usr/local/mongodb/shard3/config/mongod.conf
scp /usr/local/mongodb/configsvr/config/cfg.conf 192.168.2.119:/usr/local/mongodb/configsvr/config/cfg.conf

##登录到119上执行
sed -i 's:192.168.2.118:192.168.2.119:g' /usr/local/mongodb/shard1/config/mongod.conf
sed -i 's:192.168.2.118:192.168.2.119:g' /usr/local/mongodb/shard2/config/mongod.conf
sed -i 's:192.168.2.118:192.168.2.119:g' /usr/local/mongodb/shard3/config/mongod.conf
sed -i 's:192.168.2.118:192.168.2.119:g' /usr/local/mongodb/configsvr/config/cfg.conf


scp /usr/local/mongodb/shard1/config/mongod.conf 192.168.2.120:/usr/local/mongodb/shard1/config/mongod.conf
scp /usr/local/mongodb/shard2/config/mongod.conf 192.168.2.120:/usr/local/mongodb/shard2/config/mongod.conf
scp /usr/local/mongodb/shard3/config/mongod.conf 192.168.2.120:/usr/local/mongodb/shard3/config/mongod.conf
scp /usr/local/mongodb/configsvr/config/cfg.conf 192.168.2.120:/usr/local/mongodb/configsvr/config/cfg.conf

##登录到120上执行
sed -i 's:192.168.2.118:192.168.2.120:g' /usr/local/mongodb/shard1/config/mongod.conf
sed -i 's:192.168.2.118:192.168.2.120:g' /usr/local/mongodb/shard2/config/mongod.conf
sed -i 's:192.168.2.118:192.168.2.120:g' /usr/local/mongodb/shard3/config/mongod.conf
sed -i 's:192.168.2.118:192.168.2.120:g' /usr/local/mongodb/configsvr/config/cfg.conf

##三台机器上执行
启动shard1：
mongod --config /usr/local/mongodb/shard1/config/mongod.conf
启动shard2：
mongod --config /usr/local/mongodb/shard2/config/mongod.conf
启动shard3：
mongod --config /usr/local/mongodb/shard3/config/mongod.conf
启动config：
mongod --config /usr/local/mongodb/configsvr/config/cfg.conf

##检查进程
[root@12cnod01 bin]# ps -ef | grep mongo
root     21311     1  0 09:30 ?        00:00:04 ./mongod --config /usr/local/mongodb/shard1/mongod.conf
root     21927     1  0 09:35 ?        00:00:03 ./mongod --config /usr/local/mongodb/shard2/mongod.conf
root     22523     1  0 09:38 ?        00:00:02 ./mongod --config /usr/local/mongodb/shard3/mongod.conf
root     24303     1  1 09:50 ?        00:00:01 ./mongod --config /usr/local/mongodb/configsvr/cfg.conf

8、初始化分片副本集
把每一个分片的主库，均匀的分布在三台机器上
--192.168.2.118
mongo 192.168.2.118:27018    // mongosh 192.168.2.118:27018 (mongodb6.0+)
config = {
   _id : "shard1",
    members : [
        {_id : 0, host : "192.168.2.118:27018" },
        {_id : 1, host : "192.168.2.119:27018" ,arbiterOnly: true},
        {_id : 2, host : "192.168.2.120:27018" }
    ]
}

rs.initiate(config);

--192.168.2.119
mongo 192.168.2.119:27019 
config = {
   _id : "shard2",
    members : [
        {_id : 0, host : "192.168.2.118:27019" },
        {_id : 1, host : "192.168.2.119:27019" },
        {_id : 2, host : "192.168.2.120:27019" ,arbiterOnly: true}
    ]
}

rs.initiate(config);

--192.168.2.120
mongo 192.168.2.120:27020
config = {
   _id : "shard3",
    members : [
        {_id : 0, host : "192.168.2.118:27020" ,arbiterOnly: true},
        {_id : 1, host : "192.168.2.119:27020" },
        {_id : 2, host : "192.168.2.120:27020" }
    ]
}

rs.initiate(config);

9、初始化config副本集
--192.168.2.118
mongo 192.168.2.118:20000
config = {
   _id : "cfg",
    members : [
        {_id : 0, host : "192.168.2.118:20000" },
        {_id : 1, host : "192.168.2.119:20000" },
        {_id : 2, host : "192.168.2.120:20000" }
    ]
}

rs.initiate(config);

10、配置路由服务器
三台服务器上分别配置，除修改IP，其余不变
vim /usr/local/mongodb/mongos/config/mongos.conf

#mongos mongos.conf
systemLog:
    destination: file
    logAppend: true
    path: /usr/local/mongodb/mongos/log/mongos.log
net:
    port: 27017
    bindIp: 192.168.2.118
    maxIncomingConnections: 65535 #5.09 这个参数改变了
processManagement:
    fork: true
    pidFilePath: /usr/local/mongodb/mongos/pid
sharding:
    configDB: cfg/192.168.2.118:20000,192.168.2.119:20000,192.168.2.120:20000

scp /usr/local/mongodb/mongos/config/mongos.conf 192.168.2.119:/usr/local/mongodb/mongos/config/mongos.conf
scp /usr/local/mongodb/mongos/config/mongos.conf 192.168.2.120:/usr/local/mongodb/mongos/config/mongos.conf

sed -i 's#bindIp: 192.168.2.118#bindIp: 192.168.2.119#g' /usr/local/mongodb/mongos/config/mongos.conf
sed -i 's#bindIp: 192.168.2.118#bindIp: 192.168.2.120#g' /usr/local/mongodb/mongos/config/mongos.conf
    
--启动mongos服务
mongos --config /usr/local/mongodb/mongos/config/mongos.conf

11、添加分片集群（登录mongos）
--192.168.2.118
mongo 192.168.2.118:27017
sh.addShard("shard1/192.168.2.118:27018,192.168.2.119:27018,192.168.2.120:27018")
sh.addShard("shard2/192.168.2.118:27019,192.168.2.119:27019,192.168.2.120:27019")
sh.addShard("shard3/192.168.2.118:27020,192.168.2.119:27020,192.168.2.120:27020")

--查看分片状态
mongos> sh.status()    --每片中少一台机器，是因为其中有一个仲裁盘，不存储数据。
  shards:
        {  "_id" : "shard1",  "host" : "shard1/192.168.2.118:27018,192.168.2.120:27018",  "state" : 1 }
        {  "_id" : "shard2",  "host" : "shard2/192.168.2.118:27019,192.168.2.119:27019",  "state" : 1 }
        {  "_id" : "shard3",  "host" : "shard3/192.168.2.119:27020,192.168.2.120:27020",  "state" : 1 }


#####启用keyfile集群认证#####
##由于启用了认证后，分片的管理会因为没有用户而失效，所以要先创建分片管理用户及集群管理用户
1、创建集群管理用户
登录mongos
mongo mongodb01:27017
mongos> use admin // 切换到admin
mongos> db.createUser( { user: 'mongo_admin', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })

2、创建分片管理用户，需要登录每个分片的primary,为了更方便的登录primary，可在添加复制集的时候指定权重
分别登录shard1、shard2、shard3进行管理用户的创建
mongo 192.168.2.118:27018
shard1:PRIMARY> use admin
switched to db admin
shard1:PRIMARY> db.createUser( { user: 'shard1_admin', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })
Successfully added user: {
        "user" : "shard1_admin",
        "roles" : [
                {
                        "role" : "root",
                        "db" : "admin"
                }
        ]
}

mongo 192.168.2.119:27019
shard2:PRIMARY> use admin
shard2:PRIMARY> db.createUser( { user: 'shard2_admin', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })

mongosh 192.168.2.120:27020
shard3:PRIMARY> use admin
shard3:PRIMARY> db.createUser( { user: 'shard3_admin', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })

#如果是后期修改，需要去掉shard、config、mongos的所有配置参数，重启服务后，才可操作。

3、将所有的服务先进行关闭，开启身份认证
--创建key存放的路径
在其中的一台主机上生成密码文件，之后拷贝到其他节点上。
#192.168.2.118
su - mongod
mkdir -p /usr/local/mongodb/key
--生成密码配置文件
openssl rand -base64 100 > /usr/local/mongodb/key/mongdb-keyfile
chmod 600 /usr/local/mongodb/key/mongdb-keyfile
--将密码文件复制到另外的两台机器上
scp /usr/local/mongodb/key/mongdb-keyfile 192.168.2.119:/usr/local/mongodb/key/mongdb-keyfile
scp /usr/local/mongodb/key/mongdb-keyfile 192.168.2.120:/usr/local/mongodb/key/mongdb-keyfile

--mongod、config配置添加如下：
echo "
security:
    authorization: enabled
    keyFile: /usr/local/mongodb/key/mongdb-keyfile" >> /usr/local/mongodb/shard1/config/mongod.conf
	
echo "
security:
    authorization: enabled
    keyFile: /usr/local/mongodb/key/mongdb-keyfile" >> /usr/local/mongodb/shard2/config/mongod.conf

echo "
security:
    authorization: enabled
    keyFile: /usr/local/mongodb/key/mongdb-keyfile" >> /usr/local/mongodb/shard3/config/mongod.conf

echo "
security:
    authorization: enabled
    keyFile: /usr/local/mongodb/key/mongdb-keyfile" >> /usr/local/mongodb/configsvr/config/cfg.conf
	
--mongos添加配置如下：
echo "
security:
    keyFile: /usr/local/mongodb/key/mongdb-keyfile" >> /usr/local/mongodb/mongos/config/mongos.conf
    
启动mongo集群，先启动配置服务器---->分片服务器（逐一启动分片）----> mongos服务器
启动config：
mongod --config /usr/local/mongodb/configsvr/config/cfg.conf
启动shard1：
mongod --config /usr/local/mongodb/shard1/config/mongod.conf
启动shard2：
mongod --config /usr/local/mongodb/shard2/config/mongod.conf
启动shard3：
mongod --config /usr/local/mongodb/shard3/config/mongod.conf
启动mongos:
mongos --config /usr/local/mongodb/mongos/config/mongos.conf

4、验证登录
--集群验证
mongo MGR1:27017 -u mongo_admin -p '123456'  --authenticationDatabase admin 

--分片验证
mongo MGR1:27018 -u shard1_admin -p '123456'  --authenticationDatabase admin 

mongo MGR1:27018
shard1:PRIMARY> use admin
shard1:PRIMARY> db.auth('shard1_admin','123456');

#####集群状态监控#####
5.0版本后，需要下载：https://www.mongodb.com/try/download/database-tools
选择：Centos7.0 x86_64
cd /usr/local/mongodb509
wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel70-x86_64-100.5.3.tgz
tar zxvf mongodb-database-tools-rhel70-x86_64-100.5.3.tgz

每10秒输出一次
mongostat -h 192.168.2.118:27017 -u mongo_admin -p '123456' --authenticationDatabase=admin --humanReadable=true --discover --all 10 
mongostat -h 192.168.2.118:27018 -u shard1_admin -p '123456' --authenticationDatabase=admin --humanReadable=true --discover --all 10
为了监控分片的信息，-h 后登陆每个分片的ip+port，需要有每个分片的管理用户才可显示
-参数说明
inserts/s 每秒插入次数
query/s   每秒查询次数
update/s  每秒更新次数
delete/s  每秒删除次数
getmore/s 每秒执行getmore次数,每次获取的查询
command/s 每秒的命令数，比以上插入、查找、更新、删除的综合还多，还统计了别的命令
dirty     超过20%时阻塞新的请求
used      超过95%时阻塞新的请求
flushs/s  每秒执行fsync将数据写入硬盘的次数。
mapped/s  所有的被mmap的数据量，单位是MB，
vsize     虚拟内存使用量，单位MB
res       物理内存使用量，单位MB
faults/s  每秒访问失败数(只有Linux有)，数据被交换出物理内存，放到swap。不要超过100，否则就是机器内存太小，造成频繁swap写入。此时要升级内存或者扩展
locked %  被锁的时间百分比，尽量控制在50%以下吧
idx miss %  索引不命中所占百分比。如果太高的话就要考虑索引是不是少了
q t|r|w   当Mongodb接收到太多的命令而数据库被锁住无法执行完成，它会将命令加入队列。这一栏显示了总共、读、写3个队列的长度，都为0的话表示mongo毫无压力。高并发时，一般队列值会升高。
qrw       等待从MongoDB实例读取|写入数据的客户机队列的长度
arw       活动的执行读|写入的数量
conn      当前连接数
time      时间戳

--不能针对mongos,只能针对每一个分片
mongotop -h mongodb02:27018 -u shard1_admin -p '123456'  --authenticationDatabase admin
mongotop --locks 查看锁的情况

##集群启动命令--可以在三个机器上同时运行
mongod --config /usr/local/mongodb/configsvr/cfg.conf
mongod --config /usr/local/mongodb/shard1/mongod.conf
mongod --config /usr/local/mongodb/shard2/mongod.conf
mongod --config /usr/local/mongodb/shard3/mongod.conf
mongos --config /usr/local/mongodb/mongos/mongos.conf

关闭时，直接killall杀掉所有进程
pkill -9 mongod
pkill -9 mongos

##开启分片##
chunk默认大小64M，越小数据月均衡，但是会增大开销，所以不建议修改。
每个chunk不超过25W条数据，超过就分裂


1、给数据库（chj_db）开启分片
#mongos> sh.enableSharding("chj_db")  
{
        "ok" : 1,
        "operationTime" : Timestamp(1557546835, 3),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1557546835, 3),
                "signature" : {
                        "hash" : BinData(0,"bkrrr8Kxrr9j9udrDc/hURHld38="),
                        "keyId" : NumberLong("6689575940508352541")
                }
        }
}

-查看库的主片
{  "_id" : "chj_db",  "primary" : "shard3",  "partitioned" : true,  "version" : {  "uuid" : UUID("7a5563d6-3c9a-494f-a536-c19dad0b4380"),  "lastMod" : 1 } }
 
2、给片键创建索引
db.users.createIndex({name:1,age:1}, {background: true})

3、在chj_db数据库的users集合中创建了name和age为升序的片键
mongos> sh.shardCollection("chj_db.users",{name:1,age:1})  
{
        "collectionsharded" : "chj_db.users",
        "collectionUUID" : UUID("59c0b99f-efff-4132-b489-f6c7e3d98f42"),
        "ok" : 1,
        "operationTime" : Timestamp(1557546861, 12),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1557546861, 12),
                "signature" : {
                        "hash" : BinData(0,"UBB1A/YODnmXwG5eAhgNLcKVzug="),
                        "keyId" : NumberLong("6689575940508352541")
                }
        }
}

--查看分片状态，需要登录mongos查看
mongos>sh.status()

--查看复制集状态，需要登录分片查看
shard3:PRIMARY> rs.status()

--查看单表的分片情况
mongos> db.news.getShardDistribution()

Shard shard1 at shard1/10.10.8.50:27018,10.10.8.51:27018,10.10.8.61:27018
 data : 75B docs : 1 chunks : 1
 estimated data per chunk : 75B
 estimated docs per chunk : 1

Shard shard2 at shard2/10.10.8.50:27019,10.10.8.51:27019
 data : 34.53MiB docs : 503908 chunks : 1
 estimated data per chunk : 34.53MiB
 estimated docs per chunk : 503908

Shard shard3 at shard3/10.10.8.51:27020,10.10.8.61:27020
 data : 35.53MiB docs : 539999 chunks : 2
 estimated data per chunk : 17.76MiB
 estimated docs per chunk : 269999

Totals
 data : 70.06MiB docs : 1043908 chunks : 4
 Shard shard1 contains 0% data, 0% docs in cluster, avg obj size on shard : 75B
 Shard shard2 contains 49.28% data, 48.27% docs in cluster, avg obj size on shard : 71B
 Shard shard3 contains 50.71% data, 51.72% docs in cluster, avg obj size on shard : 69
 
--针对库的平衡
sh.startBalancer()
sh.stopBalancer()

sh.status()
 balancer:
        Currently enabled:  yes
        Currently running:  no        YES为运行状态
        
--针对表的数据平衡
sh.enableSharding("testdb.table_par")    //针对testdb库的table_par开启均衡
sh.disableSharding("testdb.table_par") 
-查看当前所在的库
mongos>  db
testdb

--分片标签
1、给分片打上Tag
shard1、shard2为分片的名称
sh.addShardTag("shard1","Tag_sz")
sh.addShardTag("shard2","Tag_sh") 

sh.status()
shards:
        {  "_id" : "shard1",  "host" : "shard1/192.168.2.118:27018,192.168.2.119:27018,192.168.2.120:27018",  "state" : 1,  "topologyTime" : Timestamp(1656663225, 2),  "tags" : [ "Tag_sz" ] }
        {  "_id" : "shard2",  "host" : "shard2/192.168.2.118:27019,192.168.2.119:27019,192.168.2.120:27019",  "state" : 1,  "topologyTime" : Timestamp(1656406375, 1),  "tags" : [ "Tag_sh" ] }

2、创建空表		
db.createCollection("country_sms");
--创建索引
db.country_sms.createIndex({city:1,zipcode:1}, {background: true})
--开启分片
sh.shardCollection("chj_db.country_sms",{city:1,zipcode:1})  
--根据数据范围打标签
sh.addTagRange( "chj_db.country_sms",
                { city: "SZ", zipcode: MinKey },
                { city: "SZ", zipcode: MaxKey },
                "Tag_sz"
              )
也可以在zipcode上加具体的数值：
sh.addTagRange( "chj_db.country_sms",
                { city: "GZ", zipcode: 1000 },
                { city: "GZ", zipcode: 2000 },
                "Tag_gz"
              )
			  
sh.addTagRange( "chj_db.country_sms",                    
                { city: "SH", zipcode: MinKey },
                { city: "SH", zipcode: MaxKey },
                "Tag_sh"
              )
			  

db.country_sms.insertMany([
{name:1,city: "SH", zipcode: 01},
{name:2,city: "SH", zipcode: 02},
{name:3,city: "SZ", zipcode: 01},
{name:4,city: "SZ", zipcode: 02},
])

--可以看出数据分散到不同的分片上
mongos> db.country_sms.getShardDistribution()

Shard shard2 at shard2/192.168.2.118:27019,192.168.2.119:27019,192.168.2.120:27019
 data : 132B docs : 2 chunks : 1
 estimated data per chunk : 132B
 estimated docs per chunk : 2

Shard shard1 at shard1/192.168.2.118:27018,192.168.2.119:27018,192.168.2.120:27018
 data : 132B docs : 2 chunks : 4
 estimated data per chunk : 33B
 estimated docs per chunk : 0

Totals
 data : 264B docs : 4 chunks : 5
 Shard shard2 contains 50% data, 50% docs in cluster, avg obj size on shard : 66B
 Shard shard1 contains 50% data, 50% docs in cluster, avg obj size on shard : 66B
 
--查看执行计划
 db.country_sms.find({name:1,city: "SZ", zipcode: 01}).explain()
 { 
    "queryPlanner" : {
        "mongosPlannerVersion" : 1.0, 
        "winningPlan" : {
            "stage" : "SINGLE_SHARD", 
            "shards" : [
                {
                    "shardName" : "shard1", 
                    "connectionString" : "shard1/192.168.2.118:27018,192.168.2.119:27018,192.168.2.120:27018", 
                    "serverInfo" : {
                        "host" : "mongodb02", 
                        "port" : 27018.0, 
                        "version" : "5.0.9", 
                        "gitVersion" : "6f7dae919422dcd7f4892c10ff20cdc721ad00e6"
                    }, 
                    "namespace" : "chj_db.country_sms", 
                    "indexFilterSet" : false, 
                    "parsedQuery" : {
                        "$and" : [
                            {
                                "city" : {
                                    "$eq" : "SZ"
                                }
                            }, 
                            {
                                "name" : {
                                    "$eq" : 1.0
                                }
                            }, 
                            {
                                "zipcode" : {
                                    "$eq" : 1.0
                                }
                            }
                        ]
                    }, 
                    "queryHash" : "A319CEC3", 
                    "planCacheKey" : "0F881132", 
                    "maxIndexedOrSolutionsReached" : false, 
                    "maxIndexedAndSolutionsReached" : false, 
                    "maxScansToExplodeReached" : false, 
                    "winningPlan" : {
                        "stage" : "FETCH", 
                        "filter" : {
                            "name" : {
                                "$eq" : 1.0
                            }
                        }, 
                        "inputStage" : {
                            "stage" : "IXSCAN", 
                            "keyPattern" : {
                                "city" : 1.0, 
                                "zipcode" : 1.0
                            }, 
                            "indexName" : "city_1_zipcode_1", 
                            "isMultiKey" : false, 
                            "multiKeyPaths" : {
                                "city" : [

                                ], 
                                "zipcode" : [

                                ]
                            }, 
                            "isUnique" : false, 
                            "isSparse" : false, 
                            "isPartial" : false, 
                            "indexVersion" : 2.0, 
                            "direction" : "forward", 
                            "indexBounds" : {
                                "city" : [
                                    "[\"SZ\", \"SZ\"]"
                                ], 
                                "zipcode" : [
                                    "[1.0, 1.0]"
                                ]
                            }
                        }
                    }, 
                    "rejectedPlans" : [

                    ]
                }
            ]
        }
    }, 
 	

##chunk迁移##
1、chunk迁移后，立即删除原chunk。用户可以设置 waitForDelete 为 true（默认为 false ），让源 Shard 在 Chunk 迁移完后同步删除 Chunk
数据。
mongos>use config;
mongos>db.settings.update( {"_id":"balancer"}, { $set : { "_waitForDelete":true } }, { upsert:true } )

2、修改chunk大小
use config
db.settings.save ({id:"chunksize",value:10})    单位M

3、开启及关闭均衡器
是否找正在运行，0表示非活动状态，2表示正在均衡。均衡迁移数据的过程会增加系统的负载：目标分片必须查询源分片的所有文档，将文档插入目标分片中，再清除源分片的数据。可以关闭均衡器（不建议）：关闭会导致各分片数据分布不均衡，磁盘空间得不到有效的利用。 
查看状态：mongos> sh.getBalancerState()
关闭命令：mongos> sh.stopBalancer()
开启命令：mongos> sh.setBalancerState(true)


##GridFs进行分片
大多数情况下不需要对 files 集合进行分片,这个集合通常很小,只包含了一些元信息.集合中也没有合适的片键可以将数据均衡地分布在集群中.如果你 必须 对 files 进行分片,可以使用 _id 字段与应用相关的字段做复合片键.
不将``files`` 分片意味着所有文件的元信息都存储在一个分片上,在生产环境中, 必须 在存储了 files 的分片上使用复制集.

fs.chunks进行分片：
1、files_id作为片键
db.fs.chunks.createIndex( { files_id : 1} 
db.runCommand( { shardCollection : "test.fs.chunks" , key : {  files_id : 1 } } )

2、files_id : 1 , n : 1 复合片键
db.fs.chunks.createIndex( { files_id : 1 , n : 1 } )
db.runCommand( { shardCollection : "test.fs.chunks" , key : { files_id : 1 , n : 1 } } )




##故障问题汇总
1、由于非正常关机，导致分片启动不了

about to fork child process, waiting until server is ready for connections.
forked process: 5637
ERROR: child process failed, exited with error number 14
To see additional information in this output, start without the "--fork" option.

--进行db的修复
cd /usr/local/mongodb/shard1/db
rm -rf mongod.lock
mongod --repair --dbpath /usr/local/mongodb/shard1/db


##集群启动顺序
cd /usr/local/mongodb422/bin/
./mongod --config /usr/local/mongodb/configsvr/cfg.conf
./mongod --config /usr/local/mongodb/shard1/mongod.conf
./mongod --config /usr/local/mongodb/shard2/mongod.conf
./mongod --config /usr/local/mongodb/shard3/mongod.conf
./mongos --config /usr/local/mongodb/mongos/mongos.conf


##readconcern和writeconcern
--readConcern 
在每一个mongod的配置文件中配置，保证复制集中，读取的数据已经在大多数节点上已提交，用来提高数据的一致性，但是若从节点有延迟，就会导致等待。(可选)
"Local"：读操作直接读取本地最新提交的数据，返回的数据可能被回滚。
"Available"：含义和"Local"类似，但是用于 Sharding 场景可能会返回孤档。
"Majority"：读操作返回已经在多数节点确认应用完成的数据，返回的数据不会被回滚，但可能会读到历史数据。
"Linearizable"：读取最新的数据，且能够保证数据不会被回滚，是所谓的线性一致性，是最高的一致性级别。
"Snapshot"：只用于多文档事务中，和"Majority"语义类似，但额外提供真正的一致性快照语义。

--readPreference
主要控制客户端 Driver 从复制集的哪个节点读取数据，这个特性可方便的实现读写分离、就近读取等策略。
>primary 只从 primary 节点读数据，这个是默认设置
>primaryPreferred 优先从 primary 读取，primary 不可用时，从 secondary 读
>secondary 只从 scondary 节点读数据
>secondaryPreferred 优先从 secondary 读取，没有 secondary 成员时，从 primary 读取
>nearest 根据网络距离就近读取

--writeConcern
MongoDB支持客户端灵活配置写入策略（writeConcern），以满足不同场景的需求。
db.collection.insert({x: 1}, {writeConcern: {w: 1}})

--writeConcern选项
https://www.cnblogs.com/AK47Sonic/p/7560177.html
MongoDB支持的WriteConncern选项如下

w: <number>，数据写入到number个节点才向用客户端确认
w: <number>，数据写入到number个节点才向用客户端确认
w: <number>，数据写入到number个节点才向用客户端确认

{w: 0} 对客户端的写入不需要发送任何确认，适用于性能要求高，但不关注正确性的场景
{w: 1} 默认的writeConcern，数据写入到Primary就向客户端发送确认
{w: 2} 决定了数据必须复制最少到一个从节点上时才会返回确定信息给客户端
{w: "majority"} 数据写入到副本集大多数成员后向客户端发送确认，适用于对数据安全性要求比较高的场景，该选项会降低写入性能
j: <boolean> ，写入操作的journal持久化后才向客户端确认

默认为"{j: false}，如果要求Primary写入持久化了才向客户端确认，则指定该选项为true
wtimeout: <millseconds>，写入超时时间，仅w的值大于1时有效。
{w:n>1}时，数据需要写入n个节点，才算成功。如果客户端写入的时候发生故障，可能会导致条件不满足，客户端会一致处于等待状态。
那么当客户端写入超过wtimeout设置的时间时，将会向客户端写入失败的异常。

当指定{w: n}时，数据需要成功写入number个节点才算成功，如果写入过程中有节点故障，可能导致这个条件一直不能满足，从而一直不能向客户端发送确认结果，针对这种情况，客户端可设置wtimeout选项来指定超时时间，当写入过程持续超过该时间仍未结束，则认为写入失败。 "

--{w: "majority"}解析
{w: 1}、{j: true}等writeConcern选项很好理解，Primary等待条件满足发送确认；但{w: "majority"}则相对复杂些，需要确认数据成功写入到大多数节点才算成功，而MongoDB的复制是通过Secondary不断拉取oplog并重放来实现的，并不是Primary主动将写入同步给Secondary，那么Primary是如何确认数据已成功写入到大多数节点的？

Client向Primary发起请求，指定writeConcern为{w: "majority"}，Primary收到请求，本地写入并记录写请求到oplog，然后等待大多数节点都同步了这条/批oplog（Secondary应用完oplog会向主报告最新进度)。
Secondary拉取到Primary上新写入的oplog，本地重放并记录oplog。为了让Secondary能在第一时间内拉取到主上的oplog，find命令支持一个awaitData的选项，当find没有任何符合条件的文档时，并不立即返回，而是等待最多maxTimeMS(默认为2s)时间看是否有新的符合条件的数据，如果有就返回；所以当新写入oplog时，备立马能获取到新的oplog。
Secondary上有单独的线程，当oplog的最新时间戳发生更新时，就会向Primary发送replSetUpdatePosition命令更新自己的oplog时间戳。
当Primary发现有足够多的节点oplog时间戳已经满足条件了，向客户端发送确认。  

##写阻塞读
读写分离问题
4.0之前版本如果主库压力不大,不建议读写分离，因为写会阻塞读，除非对响应时间不是非常关注(备库可接受范围内)以及读取延迟数据（接受一定时间延迟),本次版本是3.6集群，我们是跑批业务且平时延迟很小，所以目前来看，读写可以接受。考虑明年升级到4.4版本。
备库延迟问题
做好主从延迟监控告警，及时发现潜在的性能问题，比如磁盘、主库性能等问题
如果开启级联复制(默认开启)，级联数据源压力比较大，那么也会导致拉取日志失败从而造成延迟，根据实际情况是否调整级联复制.
升级到4.4版本，开始支持stream replication，变成主动推oplog，那么复制效率会提升。
< 4.0, 不推荐从节点，因为写阻塞读
< 4.4, 从节点读，推荐设置为nearst或者指定tag
= 4.4 , 从节点读，推荐设置hedged read  

##直接在复制集中进行配置
https://www.mongodb.com/docs/v4.4/reference/command/setDefaultRWConcern/#mongodb-dbcommand-dbcmd.setDefaultRWConcern
登录分片的primary节点
cfg = rs.conf()
cfg.settings.getLastErrorDefaults = { w: "majority", wtimeout: 5000 }     //5000ms = 5s
rs.reconfig(cfg)

mongodb://db0.example.com,db1.example.com,db2.example.com/?replicaSet=myRepl&w=majority&wtimeoutMS=5000


##Journal和oplog
--Journal日志，是MongoDB的预写日志WAL(类似Mysql的Redo log)。
所以建议「一定要开启journal」，开启 journal 后，每次写入会记录一条操作日志（通过journal可以重新构造出写入的数据）。这样即使出现宕机，启动时 Wiredtiger 会先将数据恢复到最近的一次checkpoint的点，然后重放后续的 journal 操作日志来恢复数据。

journal文件是以“j._”开头命名的，且是append only的，如果1个journal文件满了1G大小，mongodb就会新创建一个journal文件来使用，一旦某个journal文件所记载的写操作都被使用过了，mongodb就会把这个journal文件删除。通常在journal文件所在的文件夹下，只会存在2~3个journal文件，除非你使用mongodb每秒都写入大量的数据。而使用 smallfiles 这个运行时选项可以将journal文件大小减至128M大小。

MongoDB 里的 journal 行为 主要由2个参数控制:
storage.journal.enabled 决定是否开启
journal，storage.journal.commitInternalMs 决定 journal 刷盘的间隔，默认为100ms，
用户也可以通过写入时指定 writeConcern 为 {j: ture} 来每次写入时都确保 journal 刷盘。

--oplog
MongoDB 主从复制层面的一个概念，通过 oplog 来实现复制集节点间数据同步，客户端将数据写入到 Primary，Primary 写入数据后会记录一条 oplog，Secondary 从 Primary（或其他 Secondary ）拉取 oplog 并重放，来确保复制集里每个节点存储相同的数据。

MongoDB 的一次写入：

MongoDB 复制集里写入一个文档时，需要修改如下数据：

1）将文档数据写入对应的集合；

2）更新集合的所有索引信息；

3）写入一条oplog用于同步。

上面3个修改操作，需要确保要么都成功，要么都失败，不能出现部分成功的情况，否则：

1）如果数据写入成功，但索引写入失败，那么会出现某个数据，通过全表扫描能读取到，但通过索引就无法读取；

2）如果数据、索引都写入成功，但 oplog 写入不成功，那么写入操作就不能正常的同步到备节点，出现主备数据不一致的情况。

MongoDB 在写入数据时，会将上述3个操作放到一个 wiredtiger 的事务里，确保「原子性」。

--oplog 与 journal 谁先写入的问题：

1）oplog 与 journal 是 MongoDB 里不同层次的概念，放在一起比先后本身是不合理的。

2）oplog 在 MongoDB 里是一个普通的集合，所以 oplog 的写入与普通集合的写入并无区别。

3）一次写入，会对应数据、索引，oplog的修改，而这3个修改，会对应一条journal操作日志。

##复制模式
https://developer.aliyun.com/ask/316083?spm=a2c6h.13066369.0.0.6c1121d4zH2Zs1&groupCode=aliyundb

##主从切换
1、自动故障转移
当主节点超过配置的electionTimeoutMillis 时间（默认为 10 秒）未与集合的其他成员通信时，符合条件的辅助节点将要求进行选举以将自己提名为新的主节点。集群尝试完成新主节点的选举并恢复正常操作。

#####MongoDB配置SSL安全连接#####
1、Create a key by using the openssl utility.
openssl req -new -x509 -days 365 -nodes -out <replica set name>.crt -keyout <replica set name>.key
2、Create the .p12 file from the generated .key and .crt files.
openssl pkcs12 -export -in <replica set name>.crt -inkey <replica set name>.key -certfile <replica set name>.crt -out <replica set name>.p12
3、Generate the .jks files by using Java keytool (from %JAVA_HOME%\bin).
Note: Do not override the certificate. Use alias as hostname from the second replica set member onwards.
keytool -importkeystore -srckeystore <replica set name>.p12 -srcstoretype pkcs12 -destkeystore myJksFile.jks -deststoretype JKS
4、Copy the myJksFile.jks file to the PATROL Agent host in the Patrol3 directory and use this file path in the TrustStore file field.
5、Create the .pem file for the MongoDB server by using the key and certificate files.
cat <replica set name>.key <replica set name>.crt > <replica set name>.pem
6、Copy the .pem (like <replica set name>.pem) file to the replica set member host. 

--Prod
su - mongod
mkdir -p /usr/local/mongodb/key
1、Create a key by using the openssl utility.
openssl req -new -x509 -days 3650 -nodes -out rep_mongo_prod.crt -keyout rep_mongo_prod.key
一路回车，信息不填写

2、Create the .p12 file from the generated .key and .crt files.
openssl pkcs12 -export -in rep_mongo_prod.crt -inkey rep_mongo_prod.key -certfile rep_mongo_prod.crt -out rep_mongo_prod.p12
Enter Export Password: rep_mongo_prod_123

3、Generate the .jks files by using Java keytool (from %JAVA_HOME%\bin).
Note: Do not override the certificate. Use alias as hostname from the second replica set member onwards.
keytool -importkeystore -srckeystore rep_mongo_prod.p12 -srcstoretype pkcs12 -destkeystore rep_mongo_prod.jks -deststoretype JKS
Enter destination keystore password:rep_mongo_prod_123
Re-enter new password: 
Enter source keystore password:  
Entry for alias 1 successfully imported.
Import command completed:  1 entries successfully imported, 0 entries failed or cancelled

4、Copy the rep_mongo_prod.jks file to the PATROL Agent host in the Patrol3 directory and use this file path in the TrustStore file field.

5、Create the .pem file for the MongoDB server by using the key and certificate files.
cat rep_mongo_prod.key rep_mongo_prod.crt > rep_mongo_prod.pem
[mongod@mongodb01 key]$ ll
total 24
-rw------- 1 mongod mongod  139 Jun 30 11:04 mongdb-keyfile
-rw-rw-r-- 1 mongod mongod 1220 Aug 23 14:57 rep_mongo_prod.crt
-rw-rw-r-- 1 mongod mongod 2206 Aug 23 15:00 rep_mongo_prod.jks
-rw-rw-r-- 1 mongod mongod 1704 Aug 23 14:57 rep_mongo_prod.key
-rw-rw-r-- 1 mongod mongod 3365 Aug 23 14:58 rep_mongo_prod.p12
-rw-rw-r-- 1 mongod mongod 2924 Aug 23 15:01 rep_mongo_prod.pem

6、Copy the rep_mongo_prod.pem (like <replica set name>.pem) file to the replica set member host. 

https://blog.51cto.com/u_15127539/2660017
https://docs.bmc.com/docs/PATROL4MongoDB/11/configuring-a-mongodb-environment-738292490.html
https://www.cnblogs.com/wts-home/p/15399204.html
https://www.codenong.com/cs106709978/

配置文件编写（mongod、mongs、config都需要添加如下配置）：
--4.0 版本  
（mode: requireSSL 配置完成后，就不能直接用用户名和密码访问了，必须用pem文件，才能连接数据库 ）
（mode: preferTLS 兼容模式，在集群之间用SSL通信的同时，依然可以用用户名和密码的方式的进行访问 ）
net:
   ssl:
      mode: requireSSL
      PEMKeyFile: /usr/local/mongodb/key/rep_mongo_prod.pem
	  allowConnectionsWithoutCertificates: true

--5.0 版本
net:
   tls:
      mode: requireTLS
      certificateKeyFile: /usr/local/mongodb/key/rep_mongo_prod.pem
      allowConnectionsWithoutCertificates: true


--分片链接
-requireSSL
mongo --host mongodb01:27018  -u shard1_admin -p '123456'  --authenticationDatabase admin --tls --tlsAllowInvalidCertificates
-preferTLS
mongo --host mongodb01:27018  -u shard1_admin -p '123456'  --authenticationDatabase admin

##Mvware虚拟机
[mongod@mongodb01 ~]$     ps -ef |grep mongod
avahi       536      1  0 08:39 ?        00:00:03 avahi-daemon: registering [mongodb01-294.local]
mongod     2260      1  2 08:48 ?        00:01:47 mongos --config /usr/local/mongodb/mongos/config/mongos.conf
mongod     8249      1  1 09:44 ?        00:00:18 mongod --config /usr/local/mongodb/shard1/config/mongod.conf
mongod     8385      1  1 09:44 ?        00:00:15 mongod --config /usr/local/mongodb/shard2/config/mongod.conf


[mongod@mongodb02 ~]$ ps -ef |grep mongod
avahi       558      1  0 08:39 ?        00:00:03 avahi-daemon: registering [mongodb02-252.local]
mongod     1678      1  1 08:47 ?        00:01:26 mongod --config /usr/local/mongodb/configsvr/config/cfg.conf
mongod     1815      1  1 08:48 ?        00:01:05 mongod --config /usr/local/mongodb/shard2/config/mongod.conf
mongod     1933      1  1 08:48 ?        00:01:03 mongod --config /usr/local/mongodb/shard3/config/mongod.conf


[mongod@mongodb03 ~]$     ps -ef | grep mongod
avahi       567      1  0 08:41 ?        00:00:03 avahi-daemon: running [mongodb03-128.local]
mongod     2054      1  1 08:47 ?        00:01:18 mongod --config /usr/local/mongodb/configsvr/config/cfg.conf
mongod     2196      1  7 08:48 ?        00:05:55 mongod --config /usr/local/mongodb/shard1/config/mongod.conf
mongod     2305      1  1 08:48 ?        00:00:58 mongod --config /usr/local/mongodb/shard3/config/mongod.conf


--mongod，config配置添加如下：
security:
    authorization: enabled
    keyFile: /usr/local/mongodb/key/mongdb-keyfile
    
--mongos添加配置如下：
security:
    keyFile: /usr/local/mongodb/key/mongdb-keyfile

启动config：
mongod --config /usr/local/mongodb/configsvr/config/cfg.conf
启动shard1：
mongod --config /usr/local/mongodb/shard1/config/mongod.conf
启动shard2：
mongod --config /usr/local/mongodb/shard2/config/mongod.conf
启动shard3：
mongod --config /usr/local/mongodb/shard3/config/mongod.conf

mongos --config /usr/local/mongodb/mongos/config/mongos.conf

