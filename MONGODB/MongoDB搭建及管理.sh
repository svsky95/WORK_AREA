##MongoDB搭建及管理
https://www.cnblogs.com/AK47Sonic/p/7560177.html
--帮助命令
db.commandHelp()  / db.commandHelp(find)
> help
> db.help() //库级别操作

--官方文档
https://docs.mongodb.com/v3.4/introduction/
--mongodb安装
下载地址：mongodb www.mongodb.org

##系统优化
--空间管理
单个主机的存储空间=总数据量+总数据量的三分之一（索引）

1、文件系统
最好采用XFS（centos7+）,ext4文件系统，单个文件上限14T，单个文件夹上限16T，如果用GridFs大于16T就加不上去了。

2、配置
vim /etc/sysctl.conf
net.ipv4.tcp_keepalive_time = 300          //5分钟
#关闭seliux
sed -i 's:SELINUX=enforcing:SELINUX=disabled:g' /etc/selinux/config
setenforce 0
echo "####################"
getenforce
echo "####################"

#清空及关闭iptables
iptables –F
iptables –L
service iptables stop
chkconfig iptables off
chkconfig iptables --list

##关闭防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl status firewalld.service

3、ulimit配置
vim /etc/profile
ulimit -n 102400
ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -m unlimited
ulimit -u 102400

-f (文件大小): unlimited
-t (cpu 时间): unlimited
-v (虚拟内存): unlimited [1]
-n (单个进程文件打开数): 102400           //ulimit -n 102400
-m (memory size): unlimited [1] [2]
-u (可打开的进程/线程): 102400 

4、关闭Transparent Huge Pages
https://mongoing.com/docs/tutorial/transparent-huge-pages.html
vim /etc/rc.d/rc.local
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
   echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
   echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi

vim /etc/init.d/disable-transparent-hugepages
#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case $1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > ${thp_path}/enabled
    echo 'never' > ${thp_path}/defrag

    re='^[0-1]+$'
    if [[ $(cat ${thp_path}/khugepaged/defrag) =~ $re ]]
    then
      # RHEL 7
      echo 0  > ${thp_path}/khugepaged/defrag
    else
      # RHEL 6
      echo 'no' > ${thp_path}/khugepaged/defrag
    fi

    unset re
    unset thp_path
    ;;
esac

--配置生效
/etc/init.d/disable-transparent-hugepages start
chmod 755 /etc/init.d/disable-transparent-hugepages
chkconfig --add disable-transparent-hugepages


--验证
more /sys/kernel/mm/transparent_hugepage/defrag
always madvise [never]
more /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]

5、关闭numa
echo 0 | sudo tee /proc/sys/vm/zone_reclaim_mode
sudo sysctl -w vm.zone_reclaim_mode=0

6、
[root@master ~]#vim  /etc/security/limits.conf
mongod soft nofile 64000
mongod hard nofile 64000
mongod soft nproc 64000
mongod hard nproc 64000

##修改主机名
[root@localhost ~]# vim /etc/hostname
dzswj_mysql_db3

systemctl restart systemd-hostnamed

##版本和安装包
mongodb-linux-x86_64-rhel70-3.4.21.tgz.gz
tar zxvf mongodb-linux-x86_64-rhel70-3.4.21.tgz.gz

-结构说明
/root/mongodb-linux-x86_64-rhel70-3.4.21/bin

bsondump        //导出bson结构
mongo           //客户端（相当于mysql.exe）
mongod          //服务器（相当于mysqld.exe）
mongodump       //整体数据库导出（二进制，相当于mysqldump）
mongoexport     //导出易识别的json或者csv文件
mongofiles
mongoimport
mongooplog
mongoperf
mongoreplay
mongorestore    //整体数据库导入
mongos          //路由器（分片时使用）
mongostat
mongotop

Mongodb单个文档限制为16MB
mongodb chunks默认为64MB



##单实例测试部署
-启动mongodb服务
[root@bogon ~]# mv mongodb-linux-x86_64-rhel70-3.4.21 mongodb3421
[root@bogon ~]# cd mongodb3421/
--创建数据库存放目录
[root@bogon mongodb3421]# mkdir mon_database 
[root@bogon mongodb3421]# mkdir mon_log
--无需创建日志文件，但需要指定具体的日志名字
[root@bogon mongodb3421]# ./bin/mongod --dbpath /root/mongodb3421/mon_database --logpath /root/mongodb3421/mon_log/mon.log --fork --port 27017
about to fork child process, waiting until server is ready for connections.
forked process: 20496
child process started successfully, parent exiting

参数解释:
--dbpath 数据存储目录
--logpath 日志存储目录
--port 运行端口(默认27017)
--fork 后台进程运行

##centos8.1安装mongodb
--可能报错：./mongod: error while loading shared libraries: libcrypto.so.10: cannot open shared object file: No such file or directory
进入linux镜像包：
/run/media/root/CentOS-8-1-1911-x86_64-dvd/AppStream/Packages
rpm -ivh compat-openssl10-1.0.2o-3.el8.x86_64.rpm --nodeps 

-连接mongodb
root@bogon mongodb3421]# cd bin/
[root@bogon bin]# ./mongo

-节点重启
节点降级，停机维护时，需要进行降级，primary让出去。
rs.stepDown()

-关闭非主节点
db.shutdownServer()

#####操作命令#####
show dbs  查看当前的数据库
use databaseName 选库
show tables/collections 查看当前库下的collection（相当于表名）

-创建库
Mongodb的库是隐式创建,你可以use 一个不存在的库
然后在该库下创建collection,即可创建库

>  use shop
switched to db shop
> db.createCollection('shop_tab1') 
{ "ok" : 1 }
> show tables;
shop_tab1

> show dbs;
admin  0.000GB
local  0.000GB
shop   0.000GB
test   0.000GB

-创建表、collection
db.createCollection('collectionName') 
//只创建test库，里面有没有字段
db.createCollection('test') 

-查看表状态
mongos> db.table1.stats() 
--格式化单位以GB显示：db.table1.stats(1024*1024*1024)

-查看数据库的数据及索引大小
use dzswjdb;
db.stats(1024*1024*1024)    //以G显示
"dataSize": NumberInt("157127")  //整个实例数据总量（压缩前）
"storageSize": NumberInt("47085")  //实际落盘的大小 (压缩后)

-collection允许隐式创建
use shop
show tables;
shop_tab1
shop_tab2

-插入数据
mongodb中并没有表结构的改变，就是各种不同的数据，都可以放在这个表下面
> db.shop_tab1.insert({name:'lisi',age:22})
WriteResult({ "nInserted" : 1 })

-多数据插入,要把插入的多个document，放在数组里面
db.shop_tab1.insert([ {time:'friday',study:'mongodb'}, {_id:10,gender:'male',name:'QQ'} ])

-查询数据
> db.shop_tab1.find()  //id列自动生成，为主键
{ "_id" : ObjectId("5d1490646eeb180c23ae4353"), "name" : "lisi", "age" : 22 }

-查询格式化
db.inventory.find({}).pretty()

-限制条数
db.mycol.find({"title" : "MongoDB Overview"}).limit(1)

-skip跳过固定的行数，一共显示两条，跳过第一条，显示第二条，尽量少使用，会导致性能低下。
db.mycol.find({"title" : "MongoDB Overview"}).limit(2).skip(1)

-查询总行数
db.inventory.count()

> db.shop_tab1.insert({_id:1,name:'lisi',age:22})  //指定Id

-mongodb中tables是可以隐式创建的，也就是说，可以在插入数据的时候，写一个新的表名，而不需要提前创建。
> show tables;
shop_tab1
shop_tab2
> db.shop_tab3.insert({_id:1,name:'lisia',age:22})
WriteResult({ "nInserted" : 1 })
> db.shop_tab3.find()
{ "_id" : 1, "name" : "lisia", "age" : 22 }
> show tables;
shop_tab1
shop_tab2
shop_tab3

-删除数据
-加条件
db.shop_tab1.remove({time:'friday'})
-删除查询出的第一条
db.col.remove({'title':'MongoDB 教程'},1)
-不加条件，则全表删除
db.shop_tab1.remove()
-db.collection.deleteMany() 从 users 集合中删除所有 status 字段等于 "A" 的文档
db.users.deleteMany({ status : "A" })

--更新操作
db.collection.update( criteria, objNew, upsert, multi )
--update()函数接受以下四个参数：
criteria : update的查询条件，类似sql update查询内where后面的。
objNew : update的对象和一些更新的操作符（如$,$inc...）等，也可以理解为sql update查询内set后面的
upsert : 这个参数的意思是，如果不存在update的记录，是否插入objNew,true为插入，默认是false，不插入。
multi : mongodb默认是false,只更新找到的第一条记录，如果这个参数为true,就把按条件查出来多条记录全部更新。
--语法描述
db.collection.update(
<query>,
<update>,
{
upsert: <boolean>,
multi: <boolean>,
writeConcern: <document>,
collation: <document>,
arrayFilters: [ <filterdocument1>, ... ],
hint: <document|string> // Available starting in MongoDB 4.2
}
)

-修改list中指定的元素值
db.prod_sms.insertMany([
{"product_name":"DE-1300","color":["Red","Orange"]}
])

db.prod_sms.find()
db.prod_sms.update(
{"product_name":"DE-1300"},
{$set:{"color.$[i]":"Blank"}},
{arrayFilters:[{"i":{$eq:"Red"}}]}
)


把表shop_tab1中的复合条件的"name" : "lisi" 改成 "name" : "wangwu" 但是会导致源表中的其它的字段丢失
db.shop_tab1.update({"name" : "lisi"},{"name" : "wangwu"},{upsert:true},{multi:true})
-修改某字段的更新，需要用set ,把lisi改为chenzhe
db.shop_tab1.update({"name" : "lisi"},{$set:{"name" : "chenzhe"}},{upsert:true},{multi:true})
-源数据：
{ "_id" : ObjectId("5d1492a06eeb180c23ae4354"), "id" : 1, "name" : "lisi", "age" : 22 }
-修改后数据：
{ "_id" : ObjectId("5d1492a06eeb180c23ae4354"), "id" : 1, "name" : "chenzhe", "age" : 22 }
#在有分区key的情况下，不能用upsert,因为无法获取分区key，不知道落在哪个分片里。

#不会导致字段丢失的更新方法
db.users.update(
   { "favorites.artist": "Pisanello" },
   {
     $set: { "favorites.food": "pizza", type: 0,  },
     $currentDate: { lastModified: true }
   },
   { multi: true }
)
-修改前
{ "_id" : 1, "name" : "sue", "age" : 19, "type" : 3, "status" : "P", "favorites" : { "artist" : "Picasso", "food" : "pie" }, "finished" : [ 17, 3 ], "badges" : [ "blue", "black" ], "points" : [ { "points" : 85, "bonus" : 20 }, { "points" : 85, "bonus" : 10 } ], "lastModified" : ISODate("2020-02-11T02:07:33.978Z") }
-修改后
{ "_id" : 1, "name" : "sue", "age" : 19, "type" : 0, "status" : "P", "favorites" : { "artist" : "Picasso", "food" : "pizza" }, "finished" : [ 17, 3 ], "badges" : [ "blue", "black" ], "points" : [ { "points" : 85, "bonus" : 20 }, { "points" : 85, "bonus" : 10 } ], "lastModified" : ISODate("2020-02-11T02:07:33.978Z") }

--添加字段
-在所有的数据行中的后面添加sex:"femal" 字段
db.users.update({},{$set:{sex:"femal"}},{multi:true})

-删除某列值-先查询出"name" : "abc" 的整行信息，之后再做条件
db.shop_tab2.update({"name" : "abc"},{$unset:{"age" : "9"}})

-重命名某列
db.shop_tab2.update({"name" : "abc"},{$rename:{"age" : "age_new"}})

-批量修改某列的值 --首先查询的是一个通用的类，可以查询出多行，然后把列为gender的值从"m"修改为"male",multi:true全表修改
db.user.update({"gender" : "m"},{$set:{"gender" : "male"}},{multi:true})

-复制表并重命名   goods表复制为goods_bak
db.goods.find().forEach(function(x){db.goods_bak.insert(x)})   

--按照条件移动表的数据到另一个库（备份表）
db.users.find({"username" : "user0"}).forEach(function(x){db.news_bak.insert(x)})

-并发
MongoDB 使用一个readers-writer [#multi-reader-lock-names]_ 锁，它允许并发多个读操作访问数据库，但是只提供唯一写操作访问。
当一个读操作锁存在时，许多读操作可以使用这个锁。然而，当一个写操作存在时，一个写操作会排他性的保持这个锁，并且不能有其他的读操作或者写操作可以共享这个锁。

-获取一行的数据的插入时间
ObjectId的时间转换
mongos> ObjectId("5ec6313c6a731f67183b8c07").getTimestamp()
ISODate("2020-05-21T07:43:56Z")

-按照objectid进行时间查询
如何查找命令(此日期[2015-1-12]至此日期[2015-1-15])：
db.collection.find({_id:{$gt: ObjectId(Math.floor((new Date('2015/1/12'))/1000).toString(16) + "0000000000000000"), $lt: ObjectId(Math.floor((new Date('2015/1/15'))/1000).toString(16) + "0000000000000000")}}).pretty()
计算命令(此日期[2015-1-12]至此日期[2015-1-15])：
db.collection.count({_id:{$gt: ObjectId(Math.floor((new Date('2015/1/12'))/1000).toString(16) + "0000000000000000"), $lt: ObjectId(Math.floor((new Date('2015/1/15'))/1000).toString(16) + "0000000000000000")}})
删除命令(此日期[2015-1-12]至此日期[2015-1-15])：
db.collection.remove({_id:{$gt: ObjectId(Math.floor((new Date('2015/1/12'))/1000).toString(16) + "0000000000000000"), $lt: ObjectId(Math.floor((new Date('2015/1/15'))/1000).toString(16) + "0000000000000000")}})


--获取时间
mongos> Date()
Wed May 27 2020 22:59:36 GMT+0800 (CST)
mongos> new Date()
ISODate("2020-05-27T14:59:50.559Z")
mongos> ISODate()
ISODate("2020-05-27T15:00:00.472Z")

-日期转换
mongos> Date("2020-05-27T15:00:00.472Z")
Wed May 27 2020 23:04:43 GMT+0800 (CST)

> ISODate("2016-01-24T12:52:33.341Z").toLocaleString()
Sun Jan 24 2016 20:52:33 GMT+0800 (CST)

-删除表
db.collectionName.drop()
> db.shop_tab3.drop()
删除collection
-删除所有文档
db.collection.remove()

-删除库
db.dropDatabase();
> show dbs;
admin  0.000GB
local  0.000GB
shop   0.000GB
test   0.000GB
> use test;
switched to db test
> db.dropDatabase()
{ "dropped" : "test", "ok" : 1 }
删除database

-修改表名 table_1修改为table_2
db.table_1.renameCollection("table_2")

-查询表达式
查: find, findOne
语法: db.collection.find(查询表达式,查询的列);
Db.collections.find(表达式,{列1:1,列2:1});

-表行数统计
db.collections.find().count()

#显示指定行数_分页
-显示前10行
db.collections.find().limit(10)
-显示11-20行
db.collections.find().skip(10).limit(10)
-显示21-30行
db.collections.find().skip(20).limit(10)

例1:db.stu.find()
查询所有文档 所有内容

--只显示gendre和age列
例2: db.stu.find({},{gendre:1,'age':1})
查询所有文档,的gender属性 (_id属性默认总是查出来)

例3: db.stu.find({},{gender:1, _id:0})  // 1展示此行 0 不展示
查询所有文档的gender属性,且不查询_id属性

例3: db.stu.find({gender:’male’},{name:1,_id:0});
查询所有gender属性值为male的文档中的name属性

三	查询知识
注:以下查询基于ecshop网站的商品表(ecs_goods)
在练习时可以只取部分列,方便查看.

1: 基础查询 where的练习:

查出满足以下条件的商品
1.1:主键为32的商品
 db.goods.find({goods_id:32});

1.2:不属第3栏目的所有商品($ne)并显示出goods_id、goods_name列
 db.goods.find({cat_id:{$ne:3}},{goods_id:1,cat_id:1,goods_name:1});

1.3:本店价格高于3000元的商品{$gt}
 db.goods.find({shop_price:{$gt:3000}},{goods_name:1,shop_price:1});

1.4:本店价格低于或等于100元的商品($lte)
 db.goods.find({shop_price:{$lte:100}},{goods_name:1,shop_price:1});

1.5:取出第4栏目或第11栏目的商品($in)
 db.goods.find({cat_id:{$in:[4,11]}},{goods_name:1,shop_price:1});

--取出不在第4栏目或第11栏目的商品($nin)
 db.goods.find({cat_id:{$nin:[4,11]}},{goods_name:1,shop_price:1});

1.6:取出100<=价格<=500的商品($and)
db.goods.find({$and:[{shop_price:{$gt:100}},{shop_price:{$lt:500}}]});

db.nssbYqsbNsrxxVo.find({$and:[{"djxh": "10116101000052143943"},{"tjssqq": "2018-01-01"},{"tjssqz": "2018-12-31"}]})

--$all 找出既有apple又有banana的文档
db.food.find(
{'fruit':{$all:['apple','banana']}}
)

--sort 
-1、升序 -1 降序
db.food.find().sort({username:1,age:-1})
-按照文档的插入顺序查看  $natural 
db.oplog.rs.find().sort( {$natural : -1} ).limit(1).pretty()

1.7:取出不属于第3栏目且不属于第11栏目的商品($and $nin和$nor分别实现)
 db.goods.find({$and:[{cat_id:{$ne:3}},{cat_id:{$ne:11}}]},{goods_name:1,cat_id:1})
 db.goods.find({cat_id:{$nin:[3,11]}},{goods_name:1,cat_id:1});
 db.goods.find({$nor:[{cat_id:3},{cat_id:11}]},{goods_name:1,cat_id:1});


1.8:取出价格大于100且小于300,或者大于4000且小于5000的商品()
db.goods.find({$or:[{$and:[{shop_price:{$gt:100}},{shop_price:{$lt:300}}]},{$and:[{shop_price:{$gt:4000}},{shop_price:{$lt:5000}}]}]},{goods_name:1,shop_price:1});


1.9:取出goods_id%5 == 1, 即,1,6,11,..这样的商品
db.goods.find({goods_id:{$mod:[5,1]}});


1.10:取出有age属性的文档
db.stu.find({age:{$exists:1}});
含有age属性的文档将会被查出

1.11 取出列中以诺基亚开头的所有行
db.goods.find({goods_name:{$regex:/^诺基亚.*/}})

--查看最后一次操作的更新信息
db.runCommand({getLastError:1})

--条件查询
$lt          <       (less    than )

$lte        <=    (less than    or equal to )

$gt       >        （greater    than ）

$gte       >=        (greater    than or       equal to)

   

$ne    != （not equal to）不等于    {'age': {'$ne': 20}}

$in    在范围内    {'age': {'$in': [20, 23]}}       注意用list

$nin    (not in)    不在范围内{'age': {'$nin': [20, 23]}}   注意用list

$regex (正则匹配） db.collection.find({'name': {'$regex':   '^M.*'}})    匹配以M开头的名字

$exists            属性是否存在               {'name': {'$exists': True}}           查找name属性存在

$type           类型判断                {'age': {'$type': 'int'}}               age的类型为int，string

--根据属性进行匹配查找
$elemMatch     用来匹配子文档同时满足两个条件         db.test.find({"members":{"$elemMatch":{"city":"Rome","city":"RUSA"}}});

--findAndModify 匹配查询条件就更新，没有就插入一条
https://www.mongodb.com/docs/v4.4/reference/method/db.collection.findAndModify/#mongodb-method-db.collection.findAndModify
{
  "_id" : ObjectId("50f1e2c99beb36a0f45c6453"),
  "name" : "Tom",
  "state" : "active",
  "rating" : 100,
  "score" : 5
}
--匹配就更新，并返回更改前的值
db.people.findAndModify({
    query: { name: "Gus", state: "active", rating: 100 },
    sort: { rating: 1 },
    update: { $inc: { score: 1 } },
    upsert: true
})
--不匹配就插入一条新的记录
db.people.findAndModify({
    query: { name: "CZ", state: "active", rating: 100 },
    sort: { rating: 1 },
    update: { $inc: { score: 1 } },
    upsert: true
})

##文本索引（支持不好）
一个集合只能拥有 ** 一个 ** 文本检索索引，但是这个索引可以覆盖多个字段。
--创建索引：
db.stores.createIndex( { name: "text", age: "text" } )   //name、age列名
-text类型的属性中包含java coffee shop字符串
--文本查询 
找到所有包含 “coffee”, “shop”, 以及 “java”的文档       
db.stores.find( { $text: { $search: "java coffee shop" } } )         
--精确检索
-找到所有包含”java” 或者 “coffee shop” 的文档，用空格隔开
db.stores.find( { $text: { $search: "java \"coffee shop\"" } } )
-词语排除
为了找到所有包含 “java” 或者 “shop” 但是不包含 “coffee” 的商店
db.stores.find( { $text: { $search: "java shop -coffee" } } )
--删除文本索引
db.stores1.dropIndex( "name_text_description_text" ) 
--重建索引（不建议使用）
该方法实际是将集合中的全部索引删除后，再依序重新创建索引，所以如果集合中有大量的索引，则不建议使用。
db.collection.reIndex()

$or    查找多种条件       ({'$or':[{'name':'chen'},{'name':'wang'}]})

组合使用方法如下：

db.user.find({"age":{"$gte":18,"$lte":25}})

   
对于日期查询方法：

1、db.getCollection('news').find({'pub_date':{'$gte':'2017-07-11    11:0:0'}})

db.test.find({time:{$gt: new Date('2015-05-08'), $lt: new Date('2020-05-20')}})
db.test.find({uploadDate:{$gt: ISODate("2018-02-08"), $lt: ISODate('2018-12-31')}}).count()
db.fs.files.find({uploadDate:{$gt: ISODate("2020-05-21 02:00:14"), $lt: ISODate('2020-05-21 02:50:00')}}).count()
db.fs.files.find({uploadDate:{$gt: new Date("2020-05-21 10:00:14"), $lt: ISODate('2020-05-21 10:50:00')}}).count()


2、start = new Date("01/01/2007")
   db.users.find({"register":{'$lt':start}})

   
2) 不等于 $ne

例子：

db.taobao.find( { age: { $ne : 10} } );

--查看当前库的线程，返回数据库实例上正在运行的操作信息的文档
需要先进入对应的数据库
db.currentOp(true)

-返回结果
{ "inprog" :   
        [   
            {  
"opid" : 3434473,//操作的id  
"active" : <boolean>,//是否处于活动状态  
"secs_running" : 0,//操作运行了多少秒  
"op" : "<operation>",//具体的操作行为,包括(insert/query/update/remove/getmore/command)  
"ns" : "<database>.<collection>",//操作的命名空间，如：数据库名.集合名  
"query" : {//具体的操作语句  
},  
"client" : "<host>:<outgoing>",//连接的客户端信息  
"desc" : "conn57683",//数据库连接描述  
"threadId" : "0x7f04a637b700",//线程id  
"connectionId" : 57683,//数据库连接id  
"locks" : {//锁的相关信息  
   "Global": "w",
   "Database": "w",
   "Collection": "w" 
},  
//锁定模式　　　　　　描述
R　　　　　　　　　　表示共享锁。
W　　　　　　　　　　表示排他(X)锁。
r　　　　　　　　　　表示共享的意图(IS)锁。
w　　　　　　　　　　表示意图独占(IX)锁。

"waitingForLock" : false,//是否在等待并获取锁，  
"msg": "<string>"  
"numYields" : 0,  
"progress" : {  
        "done" : <number>,  
        "total" : <number>  
}  
"lockStats" : {  
        "timeLockedMicros" : {//此操作获得以下锁后,把持的微秒时间  
                "R" : NumberLong(),//整个mongodb服务实例的全局读锁  
                "W" : NumberLong(),//整个mongodb服务实例的全局写锁  
                "r" : NumberLong(),//某个数据库实例的读锁  
                "w" : NumberLong() //某个数据库实例的写锁  
        },  
        "timeAcquiringMicros" : {//此操作为了获得以下的锁，而耗费等待的微秒时间  
                "R" : NumberLong(),//整个mongodb服务实例的全局读锁  
                "W" : NumberLong(),//整个mongodb服务实例的全局写锁  
                "r" : NumberLong(),//某个数据库实例的读锁  
                "w" : NumberLong()//某个数据库实例的写锁  
        }  
}  
                },   
              
        ]   
    } 
            
-杀掉线程
db.killOp(<opid>)
db.killOp("shard1:894099267")


-返回正在等待锁的所有写操作
db.currentOp(   
   {    
     "waitingForLock" : true,    
     $or: [    
        { "op" : { "$in" : [ "insert", "update", "remove" ] } },    
        { "query.findandmodify": { $exists: true } }    
    ]    
   }    
)
db.serverStatus()
查看锁的状态

-没有Yields的活动操作
db.currentOp(   
   {    
     "active" : true,    
     "numYields" : 0,    
     "waitingForLock" : false    
   }    
)

numYields： 主要是Mongodb进程需要访问的数据不在或者不完全在内存里面，此时需要等待过程，类似异步IO操作，等待同时让其他已准备就绪进程操作。说明这个值越大，则说明需要等待时间越久，那么SQL执行越慢。1、存在workset是否设置合理 2、SQL执行计划是索引或者集合

-对于特定数据库的活动操作，返回对于数据库db1运行时间大于3秒的所有活动操作
db.currentOp(   
   {    
     "active" : true,    
     "secs_running" : { "$gt" : 3 },    
     "ns" : /^db1\./    
   }    
)

-创建索引操作
db.currentOp(   
    {    
      $or: [    
        { op: "query", "query.createIndexes": { $exists: true } },    
        { op: "insert", ns: /\.system\.indexes\b/ }    
      ]    
    }    
)


#####索引#####
创建索引：
1、索引提高查询速度,降低写入速度,权衡常用的查询字段,不必在太多列上建索引
2、在mongodb中,索引可以按字段升序/降序来创建,便于排序
3、默认是用btree来组织索引文件,2.4版本以后,也允许建立hash索引
4、当在一个集合上创建索引时，存储了这个集合的数据库变成不可读不可写的状态直到索引建立完毕，任何需要所有数据库中读或者写锁的操作(例如 listDatabases )将会等待，直到后台索引创建完成。
5、若是有日期型的查询，可以创建倒序（-1）的索引，可以将最后几天的索引保存在内存中，从而减少内存的交换，查询速度回更快。
--分片索引
##SINGLE_SHARD  查询的语句正好落在一个分片上 
"stage" : "SHARDING_FILTER",   查询条件带上片键，然后对其它的字段添加索引。
#举例:
片键=shard key: { "month" : 1, "username" : 1 }  
查询条件： 
db.news.find({"createdate" : ISODate("2021-08-08T09:47:40.703Z"),"month" : 1,"username" : 0.0000656501847561275}).explain("executionStats")
只需要单独对createdate创建索引
db.news.ensureIndex({"createdate" : 1}, {background: true})

##SHARD_MERGE   跨不同分片查询后的汇总
db.getCollection("news").find({ "createdate": { $gte: ISODate("2021-08-08T09:40:28.166+0000"), $lte: ISODate("2021-08-08T09:47:40.703+0000") } }).explain("executionStats")


要在失败 的 索引构建后启动 mongod ，可 在启动时使用 storage.indexBuildRetry 或 --nolndexBuildRe町 跳过索引构建

索引策略
1、多列的复合索引
-{ x: 1, y: 1, z: 1 } 
走索引的情况，必须包含前导列,支持如下的索引：
{ x: 1 }
{ x: 1, y: 1 }
{ x: 1, y: 1,z:1 }
{ x: 1, z: 1 }

-{ x: 1, z: 1 }
db.collection.find( { x: 5 } ).sort( { z: 1} )
针对上面的查询
索引 { x: 1, z: 1 } 同时支持查询和排序操作，但是索引 { x: 1, y: 1, z: 1 } 只支持查询。

2、索引创建的排序
-如果一个递增或递减索引是单键索引，那么在该键上的排序操作可以是任意方向
-多键排序
您可以指定在索引的所有键或者部分键上排序。但是，排序键的顺序必须和它们在索引中的排列顺序 一致 。例如，索引 { a: 1, b: 1 } 可以支持排序 { a: 1, b: 1 } 但不支持 { b: 1, a: 1 } 排序。
此外，sort中指定的所有键的排序顺序(例如递增/递减）必须和索引中的对应键的排序顺序 完全相同, 或者 完全相反 。例如，索引 { a: 1, b: 1 } 可以支持排序 { a: 1, b: 1 } 和排序 { a: -1, b: -1 } ，但 不支持 排序 { a: -1, b: 1 } 

-索引前缀排序问题
索号 ｜ 键模式｛a : 1, b: -1 ｝可以支持｛ a: 1, b: - 1 ｝和 ｛a ： ” -1 , b: 1}上的排序，但不支持｛a: - 1. b: -1 ｝或｛a: 1, b: l ｝ 
-索引：{ a:1, b: 1, c: 1, d: 1 }
查询                                                        前缀（可用）
db.data.find().sort( { a: 1 } )	                            { a: 1 }
db.data.find().sort( { a: -1 } )	                          { a: 1 }
db.data.find().sort( { a: 1, b: 1 } )	                      { a: 1, b: 1 }
db.data.find().sort( { a: -1, b: -1 } )	                    { a: 1, b: 1 }
db.data.find().sort( { a: 1, b: 1, c: 1 } )	                { a: 1, b: 1, c: 1 }
db.data.find( { a: { $gt: 4 } } ).sort( { a: 1, b: 1 } )	  { a: 1, b: 1 }

-非索引前缀
db.data.find( { a: 5 } ).sort( { b: 1, c: 1 } )	            { a: 1 , b: 1, c: 1 }
db.data.find( { b: 3, a: 4 } ).sort( { c: 1 } )	            { a: 1, b: 1, c: 1 }
db.data.find( { a: 5, b: { $lt: 3} } ).sort( { b: 1 } )	    { a: 1, b: 1 }

-不可用索引
如果查询语句 没有 对排列在排序键前面或者与之有所重叠的前缀键指定相等匹配条件，那么操作将 不会 有效使用索引。例如，如下操作指定了排序 { c: 1 } ，但是查询语句并没有对前缀键 a 和 b 指定相等匹配:
db.data.find( { a: { $gt: 2 } } ).sort( { c: 1 } )
db.data.find( { c: 5 } ).sort( { c: 1 } )

-失效时间索引
如果文档中的索引字段不是日期 或保存日期值的数组，则文档不会过期，也不会自己删除。
1、db.tab_name.createIndex( { "createdAt": 1 }, { expireAfterSeconds: 3600 } )  单位为：秒
当某文档的 createdAt 字段的值 [1] 晚于 ``中指定的秒数时，MongoDB会自动从 ``tab_name 集合删除该文档。

2、添加字段，指定失效时间
Expire Documents at a Specific Clock Time
为了使文档在一个确定的时钟时间过期，首先在一个容纳BSON日期类型或BSON日期类型对象数组的值的字段上创建TTL索引 并 把 expireAfterSeconds 指定为 0。对于集合中的每个文档，设置其被索引的日期字段为与文档过期的时间一致的值。如果被索引字段包含了一个过去了的日期，MongoDB认为该文档过期。

例如，如下操作在 log_events 集合的 createdAt 字段创建了一个索引并指定 expireAfterSeconds 的值 0。

db.tab_events.createIndex( { "expireAt": 1 }, { expireAfterSeconds: 0 } ) 表中，需要添加expireAt字段
对于每个文档，设置 expireAt 的值与文档过期的时间一致。举例来说，如下的 insert() 操作添加了一个将在 2013年7月22号 14:00:00 过期的文档。

db.tab_events.insert( {
   "expireAt": new Date('July 22, 2013 14:00:00'),    --指定过期时间
   "logEvent": 2,
   "logMessage": "Success!"
} )
MongoDB will automatically delete documents from the log_events collection when the documents’ expireAt value is older than the number of seconds specified in expireAfterSeconds, i.e. 0 seconds older in this case. As such, the data expires at the specified expireAt value.

--稀疏索引
db.people.createIndex( { city: 1}, {background: true, sparse: true } )

--部分索引
https://mp.weixin.qq.com/s?__biz=MzU2MzMwNDE3Nw==&mid=2247484110&idx=1&sn=d634be74550ab7f2dcaf03d7ff8d9266&chksm=fc5d0150cb2a88465488c0f50216bd93c8d2d4361f456122dc2ab85b40a913d4b9b41359385e&scene=178&cur_album_id=1589521051305181186#rd
虽然创建的稀疏索引,这个组合索引并不是真正的稀疏索引,根据稀疏索引定义来讲,稀疏索引中不包括不存在字段的文档,但是这个是组合索引，但ut日期字段一直都在.所以此稀疏索引中还是索引key对应文档信息，只是缺少billSt字段而已,所以说此组合是伪稀疏索引.从mongo 3.2开始推荐使用部分索引,因为部分索引提供稀疏索引的超集功能.此处应该创建部分索引能够更好实现稀疏索引功能且只保存条件索引key，从而实现之前创建稀疏的目的，能够降低索引大小以及内存使用。
-只针对rating大于5的创建索引
db.restaurants.createIndex(
   { cuisine: 1, name: 1 },
   { partialFilterExpression: { rating: { $gt: 5 } } }
)
-查询条件必须要覆盖，查询的结果必须要是条件的子集
db.restaurants.find( { cuisine: "Italian", rating: { $gt: 5 } } )
db.restaurants.find( { cuisine: "Italian", rating: { $gt: 3 } } )

-不可使用索引
db.restaurants.find( { cuisine: "Italian", rating: { $lt: 8 } } )
db.restaurants.find( { cuisine: "Italian" } )

db.fee_detail.aggregate([{$match:{ut:
{ $gte: ISODate("2020-07-25T00:00:00.0000Z"),
$lt:ISODate("2020-07-25T01:00:00.000Z")}}},
{$group:{_id:{ut:"$ut"},count:{"$sum":1}}},{$count:"ut"}]);
--->>>   { "ut" : 792 }

db.fee_detail.createIndex(
   {billst:1,rpts:1,ut: 1},
   { partialFilterExpression: { billSt:1,rpts:1 } }
)

--隐藏索引
-创建
b.addresses.createIndex(
   { borough: 1 },
   { hidden: true }
);

-隐藏现有索引 4.4版本以上适用
db.restaurants.hideIndex( { borough: 1, ratings: 1 } ); // Specify the index key specification document
-取消
db.restaurants.unhideIndex( { borough: 1, city: 1 } );  // Specify the index key specification document
db.restaurants.unhideIndex( "borough_1_ratings_1" );    // Specify the index name

2.1 操作步骤：
#添加expireAt字段
db.users.update({},{$set:{expireAt:"0"}},{multi:true})
#添加索引
db.users.createIndex( { "expireAt": 1 }, { expireAfterSeconds: 0 } ) 
#按时间查找记录
db.users.find({create:{$gt: ISODate("2020-12-03T09:49:31.757+0000"), $lt: ISODate("2020-12-04T09:49:31.757+0000")}}).count()
#设置过期时间，过期时间expireAt就选择$lt的时间，就可以删除在小于条件$lt的所有数据
db.users.update({create:{$gt: ISODate("2020-12-03T09:49:31.757+0000"), $lt: ISODate("2020-12-04T09:49:31.757+0000")}},{$set:{"expireAt" : ISODate("2020-12-04T09:49:31.757+0000")}},{multi:true})

3、选择性
就如关系型数据库一样，选择性（distinct）越好，查询效率越高

4、复合索引创建规则

db.members.find({ gender: “F”， age: {$gte: 18}}).sort(“join_date:1”)

--组合索引的最佳方式：ESR原则
精确（Equal）匹配的字段放最前面
排序（Sort）条件放中间
范围（Range）匹配的字段放最后面

最佳索引：{ gender: 1, join_date:1, age: 1 }

--模糊索引
db.survey.createIndex({"attributes.$**":1}) 
將匹配以attributes字段作為開始的路径的任何一个字段。
db.goods.find({"attributes.color":"read"})
db.goods.find({"attributes.price":{$lt:120}})
##Mongodb多键索引
--嵌套文档:“telephone”:{"cellphone":"0211234567","mobilephone":13888888888}
创建方法：
db.survey.createIndex({"telephone”.cellphone":1})

--数组:“telephone”:["0211234567",13888888888]
创建方法：
1、数组索引位置从0开始，当对数组创建索引时，使用索引位置查询时，是无法使用多键索引,必须创建单独索引，例如第二个元素位置, db.survey.createIndex({"“telephone”.0":1}).其他位置以此内推方式创建索引.
2、创建数组索引还是按照数组索引位置创建索引，根据业务实际需求,做到创建索引能够提升效率，而不是创建低效或者无用索引。
3、查询单个元素，此时索引则不是多键索引，就是单个标量值,标量表示是字符串或者数字，而不是数组或者嵌套文档.

数组文档:“联系”:[“telephone”:{"cellphone":"0211234567","mobilephone":13888888888}]
db.survey.createIndex({"联系.0.cellphone":1})

{ "_id" : 3, "item" : { "name" : "ij", "code" : "456" }, "qty" : 25, "tags" : [ "A", "B" ] }
{ "_id" : 5, "item" : { "name" : "mn", "code" : "000" }, "qty" : 20, "tags" : [ [ "A", "B" ], "C" ] }
mongos> db.inventory.find({"tags.1" :"C"}) --查询数组第一个元素
{ "_id" : 5, "item" : { "name" : "mn", "code" : "000" }, "qty" : 20, "tags" : [ [ "A", "B" ], "C" ] }
mongos> db.inventory.find({"tags" :["A","B"]}) --查询数组元素包含["A","B"]的


1、db.survey.find({item:{name:"Katie","manufactured" : 16}})
db.survey.find({item:{name:"Katie"}})
--适用索引
db.survey.createIndex({item:1})  查询的匹配，需要按照上面的格式查询


2、db.survey.find({"item.name":"Katie","item.manufactured" : 16}})  
db.survey.createIndex({"item.name":1,"item:manufactured":1}) 可以独立的查询每一个条件


-查看语句的执行计划
db.find(query).explain();
db.goods.find({cat_id:11}).explain();

-查看索引状态
db.collection.getIndexes();    //PS:I大写
[
        {
                "v" : 2,
                "key" : {
                        "_id" : 1      //系统默认自带的列
                },
                "name" : "_id_",
                "ns" : "shop.goods"
        },
        {
                "v" : 2,
                "key" : {
                        "goods_id" : -1       //good_id 列的降序索引
                },
                "name" : "goods_id_-1",
                "ns" : "shop.goods"
        },
        {
                "v" : 2,
                "key" : {                    
                        "goods_name" : 1     //good_name 列的升序索引
                },
                "name" : "goods_name_1",
                "ns" : "shop.goods"
        }
]

--后台创建索引,不需要长时间占用写锁，在后台创建索引会比前台方式耗时更久，且会生成不够紧凑的索引结构。此外，后台创建索引可能会影响主节点的写性能。但是，在后台建立索引允许复制集在MongoDB建立索引期间持续写操作。
db.values.ensureIndex({open: 1, close: 1}, {background: true})

--指定索引的名字-最终这个索引的名字会是 inventory 
db.products.createIndex( { item: 1, quantity: -1 } , { name: "inventory" } )

-查看数据库中所有表的索引
use dzswjdb;
db.getCollectionNames().forEach(function(collection) {
   indexes = db[collection].getIndexes();             
   print("Indexes for " + collection + ":");          
   printjson(indexes);                                
});                                                   
      
-查询索引使用率
db.nssbYqsbNsrxxVo.aggregate( [ { $indexStats: { } } ] )
{
    "name": "djxh_1_tjssqq_1_tjssqz_1",     //索引名
    "key": {                                //索引涉及的字段
        "djxh": 1,
        "tjssqq": 1,
        "tjssqz": 1
    },
    "host": "dzswj_mongodb_db1:27001",     //索引所在mongod实例
    "accesses": {                          
        "ops": NumberLong("225752"),       //索引使用次数
        "since": ISODate("2019-09-30T07:20:54.736Z")    //收集统计信息的时间
    }
}
--前台创建索引，还会获取 db 的写锁，导致 db 上的读写都被阻塞
-创建索引
会阻塞所有对数据库的读写请求
>单列索引
> db.goods.ensureIndex({goods_id:-1})   1是升续  -1是降续
{
        "createdCollectionAutomatically" : false,
        "numIndexesBefore" : 1,
        "numIndexesAfter" : 2,
        "ok" : 1
}
>多列/复合索引
db.goods.ensureIndex({goods_id:-1,goods_name:1}) 
按照查询顺序进行索引的创建
对于排序，并不是很重要，mongodb可以在任意的方向对索引进行遍历
--$or 使用每个条件的索引
db.users.find({'$or':[{'username':'user999'},{'age':21}]}).explain()
使用了：
db.users.ensureIndex({'username':1})
db.users.ensureIndex({'age':1}) 
分别使用这两个索引，然后进行合并
>子文档索引(属性下面又包含属性)
db.goods.ensureIndex({spc.area_id:1});
>唯一索引
db.goods.ensureIndex({goods_id:1}, {unique:true});
>唯一复合索引，也可以创建复合的唯一索引。创建复合唯一索引时，单个键的值可以相同，但所有键的组合值必须是唯一的。
db.users.ensureIndex({"username":1, "age":1}, {"unique":true})
>去除重复，在已有的集合上创建惟一索引时可能会失败，因为集合中可能已经存在重复值，创建索引时使用”dropDups”选项，如果遇到重复的值，第一个会被保留，之后的重复文档都会被删除
db.people.ensureIndex({"username":1}, {"unique":true, "dropDups":true})

>创建哈希索引(2.4新增的)
哈希索引速度比普通索引快,但是,无能对范围查询进行优化.
适宜于---随机性强的散列
db.collection.ensureIndex({file:’hashed’});

--全文索引
-文档内容
{
   "post_text": "enjoy the mongodb articles on w3cschool.cn",
   "tags": [
      "mongodb",
      "w3cschool"
   ]
}
post_text 字段建立全文索引，这样我们可以搜索文章内的内容
db.posts.ensureIndex({post_text:"text"})
db.posts.find({$text:{$search:"w3cschool.cn"}})

-删除全文索引
db.posts.dropIndex("post_text_text")

-删除索引
>指定列的索引删除
db.ysqSxsqPzxx.dropIndex({"pzzgDm" : 1,"ndbc" : 1});   //key
>全部列的索引删除
db.goods.dropIndexes();

-重建索引
一个表经过很多次修改后,导致表的文件产生空洞,索引文件也如此.
可以通过索引的重建,减少索引文件碎片,并提高索引的效率.
类似mysql中的optimize table

db.collection.reIndex()

--hint
-强制索引
db.people.find(
   { name: "John Doe", zipcode: { $gt: "63000" } }
).hint( { zipcode: 1 } )

-强制不使用任何索引，走全表扫描（$natural）
db.nssbYqsbNsrxxVo.find({$and:[{"djxh": "10116101000052143943"},{"tjssqq": "2018-01-01"},{"tjssqz": "2018-12-31"}]}).hint( { $natural: 1 } ).explain()

-update强制走索引
db.members.updateMany(
   { "points": { $lte: 20 }, "status": "P" },
   { $set: { "misc1": "Need to activate" } },
   { hint: { status: 1 } }
)

##mongodb连接数
默认情况下，mongodb没有连接数的限制，是通过open files来限制的
[sxgs@dzswj_mongodb_db1 ~]$ ps -ef | grep mongos
root     20815     1 33  2019 ?        50-12:34:21 mongos -f /software/mongodb/conf/mongos.conf

[root@dzswj_mongodb_db1 ~]# more /proc/20815/limits | grep "Max open files"
Max open files            102400               102400               files 

-连接数最大计算，至于是 0.8 的原因是出于一种保护性的考虑，因为不可能把所有的 open file 句柄都拿来维
护连接数，还需要保持对磁盘上文件的访问。
102400*0.8 >  current+available

-当前数据库连接数
mongos> db.serverStatus().connections
{ "current" : 1255, "available" : 18745, "totalCreated" : 46988 }

current:当前的连接数
available:还可用的连接数
totalCreated:已经创建的总连接数

-查询某个文档的大小
mongos> var doc = db.students.find({"semester" : 1})
mongos> Object.bsonsize(doc)
79229  --字节


##MongoDB 聚合函数
>db.COLLECTION_NAME.aggregate(AGGREGATE_OPERATION)
db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$sum : 1}}}])
以上实例类似sql语句： select by_user, count(*) from mycol group by by_user

>多列group by 
多列group，根据name和status进行多列

db.collection.aggregate([

　　{$group:{_id:{name:"$name",st:"$status"},count:{$sum:1}}}

]);

--参考数据如下：
{
   _id: ObjectId(7df78ad8902c)
   title: 'MongoDB Overview', 
   description: 'MongoDB is no sql database',
   by_user: 'w3cschool.cn',
   url: 'http://www.w3cschool.cn',
   tags: ['mongodb', 'database', 'NoSQL'],
   likes: 100
},
{
   _id: ObjectId(7df78ad8902d)
   title: 'NoSQL Overview', 
   description: 'No sql database is very fast',
   by_user: 'w3cschool.cn',
   url: 'http://www.w3cschool.cn',
   tags: ['mongodb', 'database', 'NoSQL'],
   likes: 10
},
{
   _id: ObjectId(7df78ad8902e)
   title: 'Neo4j Overview', 
   description: 'Neo4j is no sql database',
   by_user: 'Neo4j',
   url: 'http://www.neo4j.com',
   tags: ['neo4j', 'database', 'NoSQL'],
   likes: 750
},

$sum	计算总和。	db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$sum : "$likes"}}}])
$avg	计算平均值	db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$avg : "$likes"}}}])
select by_user,avg(like) from mycol group by by_user;
$min	获取集合中所有文档对应值得最小值。	db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$min : "$likes"}}}])
$max	获取集合中所有文档对应值得最大值。	db.mycol.aggregate([{$group : {_id : "$by_user", num_tutorial : {$max : "$likes"}}}])
$push	在结果文档中插入值到一个数组中。	db.mycol.aggregate([{$group : {_id : "$by_user", url : {$push: "$url"}}}])
$addToSet	在结果文档中插入值到一个数组中，但不创建副本。	db.mycol.aggregate([{$group : {_id : "$by_user", url : {$addToSet : "$url"}}}])
$first	根据资源文档的排序获取第一个文档数据。	db.mycol.aggregate([{$group : {_id : "$by_user", first_url : {$first : "$url"}}}])
$last	根据资源文档的排序获取最后一个文档数据	db.mycol.aggregate([{$group : {_id : "$by_user", last_url : {$last : "$url"}}}])

--管道符
-先筛选出70<=likes<=90,之后把筛选的结果进行group by "by_user",算出likes的平均值
db.mycnt.aggregate( [
                        { $match : { likes: { $gte : 70, $lte : 90 } } },     
                        {$group : {_id : "$by_user", num_tutorial : {$avg : "$likes"}}}] );
                        
-筛选条件为title: "Neo4j Overview",group by "by_user",求和：likes        
db.mycnt.aggregate( [
                        { $match : { title: "Neo4j Overview" } },
                        {$group : {_id : "$by_user", num_tutorial : {$sum : "$likes"}}}] );

##那些操作会锁住数据库
-查询操作
读锁

-从一个 cursor 中获得更多数据
读锁

-插入数据
写锁

-删除数据
写锁

-更新数据
写锁

-Map-reduce	
读锁和写锁，除非被指定为非原子性操作。部分 map-reduce 的工作可以同时运行。

-创建一个索引
在前台创建一个索引，这是默认的，会长时间的锁定数据库。

db.eval()
3.0 版后已移除.
写锁， db.eval() 方法在评估JavaScript函数的时候使用了一个全局写锁，你可以使用 eval 命令，带上 nolock: true 。

eval
3.0 版后已移除.
写锁。默认的， eval 命令在评估JavaScript函数的时候使用一个全局写锁。如果使用参数 nolock: true ， eval 命令在评估JavaScript函数的时候不会使用全局写锁。然而，JavaScript函数可能为写操作接收一个写锁。
aggregate()	
读锁

--管理命令锁定数据库
下列的管理命令会在数据库上申请一个排他性的（比如：写操作）锁很长时间。
db.collection.ensureIndex() ，在不设置``background`` 为 ``true``时候。
reIndex,
compact,
db.repairDatabase(),
db.createCollection() ， 在创建一个非常大（比如：很多G）的capped collection ，（固定大小集合）
db.collection.validate(), and
db.copyDatabase() 。这个操作可能锁住所有的数据库。参见 MongoDB 操作是否会锁多个数据库?

--下列的管理操作会锁住数据库，但是只保持锁非常短的时间：
db.collection.dropIndex(),
db.getLastError(),
db.isMaster(),
rs.status() (i.e. replSetGetStatus),
db.serverStatus(),
db.auth(), and
db.addUser().

--下列操作锁定多个数据库
db.copyDatabase() 必须一次锁住整个 mongod 实例。
db.repairDatabase() 获得一个全局写锁，将阻止其他的操作，直到完成。
Journaling ，这是一个内部操作，在很短的时间内锁住所有的数据库，所有的数据库共享一个日志。
User authentication 请求一个读锁在 admin 数据库中， 部署使用 2.6 user credentials。 使用 2.4 模式来部署用户凭证，验证锁住 admin 数据库，以及用户访问数据库。
所有对复制集的写操作 primary 会锁住数据库接收写操作和 local 数据库很短的时间。local 数据库的锁允许 mongod 写入主节点的 oplog ，这占用整个操作总时间的很小的部分。

##锁库##
只能在mongod实例上的primary上执行
use admin;   //只能在admin库上运行
db.fsyncLock()
在db.currentOp()上显示为：
"info" : "use db.fsyncUnlock() to terminate the fsync write/snapshot lock",
db.fsyncUnlock()
解锁后会消失


#####数据导入导出#####
--在执行备份的时候，无论是MMAPv1 或 WiredTiger 存储引擎,使用db.fsyncLock()来保证正在进行的写操作落盘并锁定整个实例来阻止写入，以便在备份操作期间刷新所有写入并锁定
mongod 实例，保证数据文件不会更改，从而为创建备份提供一致性保障。
--备份完成后，使用db.fsyncUnlock()来释放。
##标准导入和导出 用于小数据量及异构数据库的数据交换 不包括索引
帮助：mongoexport --help
#导出 数据库为shop collection:goods 选定导出两列:goods_id,goods_name 输出路径：/root/goods_dmp.json
mongoexport -d shop -c goods -f "goods_id,goods_name" -o /root/goods_dmp.json
-导出为csv格式
mongoexport -d shop -c goods -f "goods_id,goods_name" --type=csv -k --limit=2 -o /root/goods_dmp.json 

-json导入
mongoimport -d shop -c goods_2 --file /root/goods_dmp.json 
-csv导入
mongoimport -d shop -c goods_1  --type=csv --headerline  --file /root/goods_dmp.json 


##二进制导入和导出 用于数据库备份及迁移 包括数据和索引
#导出mongodump命令使用的是游标，每次备份都会将数据加载到内存中，若备份数据过大，会持续占用内存资源，提高IO的负载。
--
-不加输出文件，默认在dump目录下
mongodump -d shop -c goods
--导出test库下的CodeDataConfiguration_20180614表
mongodump --host=10.10.8.50 --port=27017 -d test -c CodeDataConfiguration_20180614 --out=/root/mongo_dump --username=admin --password 123456 --authenticationDatabase=admin
--整库导出 默认在/root/mongo_dump/下生成对应的数据库文件夹
mongodump --host=10.10.8.50 --port=27017 -d testdb --out=/root/mongo_dump/ --username=admin --password 123456 --authenticationDatabase=admin
--整库导出包含索引 数据存放在 /mongodata/backup
mongodump --host=10.10.8.50 --port=27017 --username=admin --password=123456 --authenticationDatabase=admin  --gzip  --db testdb -v  -j 8  -o /mongodata/backup   //--gzip压缩 -j 并行
mongorestore --host=10.10.8.50 --port=27017 --username=admin --password=123456 --authenticationDatabase=admin --db test11 -v  --drop -j 8 --gzip --dir='/mongodata/backup/testdb'  //drop会删除库
--单表条件导出
mongodump -d=test -c=records -q='{ "a": { "$gte": 3 }, "date": { "$lt": { "$date": "2016-01-01T00:00:00.000Z" } } }' --username=admin --password 123456 --authenticationDatabase=admin
--查询条件导出
db.nfSsslJyrz.find({lrrq:{$gt:ISODate("2020-04-27T11:33:43.187Z"),$lt:ISODate("2020-05-01T08:00:00Z")}}).count()
mongodump --host=92.12.76.14 --port=27017 -d=dzswjdb -c=nfSsslJyrz -q='{lrrq:{$gt:ISODate("2020-04-27T11:33:43.187Z"),$lt:ISODate("2020-05-01T08:00:00Z")}}' --username=admin --password  'System@!2018' --authenticationDatabase=admin --out=/home/sxgs/nfSsslJyrz_t
--可选参数
--numParallelCollections=8    //添加并行
--gzip                        //压缩
--excludeCollection=          //去除掉某些表 ，如果需要有多张表需分开写 --excludeCollection=table1 --excludeCollection=table2 

##整个分片导入导出 
--oplog只能针对每个分片中的复制集做，就是为了备份截止某个时间点的数据，所以只能备份每个分片中整库的数据
因为是分片集群的存在，所以备份的过程中，可能存在分片之间均衡的情况，所以要在mongos里关闭均衡器，再进行每个分片的备份。
mongos> sh.getBalancerState() 
true
sh.stopBalancer()
sh.status()
  balancer:
        Currently enabled:  no
        Currently running:  no
mongos> sh.setBalancerState(true)
       
#备份
mongodump --host=10.10.8.50 --port=27018 --oplog --out=/root/mongo_dump/ --username=admin --password 123456 --authenticationDatabase=admin

#恢复
mongorestore --host=10.10.8.50 --port=27019 --oplogReplay   /root/mongo_dump --username=shard_admin --password 'shard_admin@!2020' --authenticationDatabase=admin
--oplogReplay 恢复完数据文件后再重放 oplog
--oplogFile: 指定需要重放的 oplog 文件位置
--oplogLimit: 重放 oplog 时截止到指定时间点
--drop: 先删除再导入，防止主键冲突

>查看文件输出路径
ps -ef| grep mongo
--dbpath /root/mongodb3421/mon_database
/root/mongodb3421/dump
goods.bson          //不可查看 数据文件
goods.metadata.json //可查看  索引文件


#导入 单个collection的导入需要执行到文件
mongorestore -d shop -c good_res /root/mongo_dump/shop/goods.bson

-导入一个库 shop_1不用提前创建
mongorestore -d shop_1 /root/mongo_dump/shop
-导入整库
mongorestore --host=10.10.8.50 --port=27017 -d test_1  --numParallelCollections=8 --username=admin --password 123456 --authenticationDatabase=admin /root/mongo_dump/test
--导入库中的一张表到另一个库 --collection后可以修改为其它表名
mongorestore --host=10.10.8.50 --port=27017 --drop -d test_1 --collection=table1 --numParallelCollections=8 --username=admin --password 123456 --authenticationDatabase=admin /root/mongo_dump/testdb/table1.bson
-添加并行
mongorestore -d shop_2 --numParallelCollections=8 /root/mongo_dump/shop/
-删除备份中的对象 再插入 在从转储的备份还原集合之前，从目标数据库中删除集合。--drop不会删除不在备份中的集合。
mongorestore -d shop_2 --numParallelCollections=8 --drop /root/mongo_dump/shop 
-压缩、并行、导入
mongorestore -d shop_3 --gzip --numParallelCollections=8 --drop /root/mongo_dump/shop
--不导入索引
--noIndexRestore



#####mongodb的主复制集#####
1、搭建过程与单节点相同，只是启动命令不同
##以下为一个三节点的高可用搭建
#启动3个实例,且声明实例属于某复制集
10.10.8.218: master
./bin/mongod --port 27017 --dbpath /root/mongodb3421/mon_database --replSet rsa --fork --logpath /root/mongodb3421/mon_log/mon.log
[root@bogon mongodb3421]# ps -ef | grep mongodb
root     31370     1  1 10:32 ?        00:00:01 ./bin/mongod --port 27017 --dbpath /root/mongodb3421/mon_database --replSet rsa --fork --logpath /root/mongodb3421/mon_log/mon.log

10.10.8.217: salve1 salve2
./bin/mongod --port 27017 --dbpath /root/mongodb_3421_slave/mon_database --replSet rsa --fork --logpath /root/mongodb_3421_slave/mon_log/mongo17.log
./bin/mongod --port 27018 --dbpath /root/mongodb_3421_slave/mon_database2 --replSet rsa --fork --logpath /root/mongodb_3421_slave/mon_log2/mongo18.log
[root@hasmbs01 mongodb_3421_slave]# ps -ef |grep mongodb
root     12674     1  0 10:33 ?        00:00:00 ./bin/mongod --port 27017 --dbpath /root/mongodb_3421_slave/mon_database --replSet rsa --fork --logpath /root/mongodb_3421_slave/mon_log/mongo17.log
root     12701     1  1 10:34 ?        00:00:00 ./bin/mongod --port 27018 --dbpath /root/mongodb_3421_slave/mon_database2 --replSet rsa --fork --logpath /root/mongodb_3421_slave/mon_log2/mongo18.log

#在主节点上进行配置
> use admin
switched to db admin
var rsconf = {
    _id:'rsa',
    members:
    [
        {_id:0,
        host:'10.10.8.218:27017'
        },
        {_id:1,
        host:'10.10.8.217:27017'
        },
        {_id:2,
        host:'10.10.8.217:27018 '
        }
    ]
}
> rs.initiate(rsconf)
{ "ok" : 1 }

#查看集群状态
rsa:PRIMARY> rs.status()
默认：id：0   PRIMARY
其它节点： SECONDARY

#添加节点
rsa:PRIMARY> rs.add('10.10.8.217:27018')  
-添加完节点后，数据会自动同步到一致

-在添加完集群后，只有PRIMARY可以连接，并做数据的操作，如果查看其它节点的数据同步情况，就必须在其它节点上行执行：
rsa:SECONDARY> rs.slaveOk();

#删除节点
rsa:PRIMARY>  rs.remove('10.10.8.217:27018')

#故障转移
当一个服务器由于异常关闭时，集群中id:1的服务器，自动升级为primary。
--关闭数据库：
rsa:PRIMARY> use admin
switched to db admin
rsa:PRIMARY> db.shutdownServer();

"_id" : 0,
                        "name" : "10.10.8.218:27017",
                        "health" : 0,               //0 为异常
                        "state" : 8,
                        "stateStr" : "(not reachable/healthy)",
                        
"_id" : 1,
                        "name" : "10.10.8.217:27017",
                        "health" : 1,
                        "state" : 1,
                        "stateStr" : "PRIMARY",
 
"_id" : 2,
                        "name" : "10.10.8.217:27018",
                        "health" : 1,
                        "state" : 2,
                        "stateStr" : "SECONDARY",      
                        
--也可以使用kill -2 PID 发出关闭命令，让mongodb可以把缓存中的数据写入到数据文件。不可使用kill -9  
--安全关闭集群方式
mongod --shutdown --dbpath /usr/local/mongodb/shard2/db           

-列出集群中的主备关系
db.isMaster()

-指定某个节点为primary，即使是重新启动，也会因为priority的权重大，而保持角色不变。
>查看配置
cfg = rs.conf()
>修改参数
cfg.members[0].priority = 1            id:0 的优先级为1 值越高，优先级越大     
cfg.members[1].priority = 0.5          id:1
cfg.members[2].priority = 0.5          id:2
>参数生效
rs.reconfig(cfg)
--若在secondary上可以加上force,	强制生效
rs.reconfig(cfg,{force:true})

-优先级为0的成员，成为备用的节点，同样可以同步主节点的数据，但是不参与选举，也就是不会升级为主节点
cfg.members[2].priority = 0    

-配置不投票节点
cfg = rs.conf()
cfg.members[3].votes = 0
cfg.members[4].votes = 0
cfg.members[5].votes = 0
rs.reconfig(cfg)

-配置隐藏节点，为了让客户端都不可见
cfg = rs.conf()
cfg.members[2].priority = 0
cfg.members[2].hidden = true
rs.reconfig(cfg)

-配置延时节点，为了防止主库误操作，从而可以从延迟节点恢复
cfg = rs.conf()
cfg.members[0].priority = 0
cfg.members[0].hidden = true
cfg.members[0].slaveDelay = 3600      //单位秒
rs.reconfig(cfg)

##复制集IP该为域名
cfg = rs.conf()
cfg.members[0].host = "cnl15034324.com.cn:5255"    <--为了防止错误，可以先看下修改的值cfg.members[0].host，是不是正确的。
rs.reconfig(cfg)

#####查看Oplog状态
#每个节点都有
默认的oplog大小是足够的，用来存储主节点的操作，以便于SECONDARY读取及应用
封顶表，固定大小，滚动覆盖写入。
#查看状态
rsa:PRIMARY> rs.printReplicationInfo()
configured oplog size:   1751.3427734375MB    //op_log的配置大小
log length start to end: 104346secs (28.99hrs)  <--预计窗口覆盖时间
oplog first event time:  Sun Jul 07 2019 10:42:57 GMT+0800 (CST)
oplog last event time:   Mon Jul 08 2019 15:42:03 GMT+0800 (CST)
now:                     Mon Jul 08 2019 15:42:05 GMT+0800 (CST)

#查看使用的oplog大小
shard1:PRIMARY> show dbs;
shard1:PRIMARY> use local;
shard1:PRIMARY> db.oplog.rs.stats()

#以主节点的视角返回复制的状态报告
rs.printReplicationInfo()
#查看SECONDARY的延迟
rsa:SECONDARY> rs.printSlaveReplicationInfo()
source: 10.10.8.217:27017
        syncedTo: Mon Jul 08 2019 15:44:13 GMT+0800 (CST)
        0 secs (0 hrs) behind the primary 
source: 10.10.8.217:27018
        syncedTo: Mon Jul 08 2019 15:44:13 GMT+0800 (CST)
        0 secs (0 hrs) behind the primary
        
##oplog过大，会导致mongodump --oplog耗时较长
rs11:SECONDARY> rs.printReplicationInfo()
configured oplog size:   92160MB
log length start to end: 24826899secs (6896.36hrs)
oplog first event time:  Mon May 29 2017 13:39:32 GMT+0800 (CST)
oplog last event time:   Mon Mar 12 2018 22:01:11 GMT+0800 (CST)
now:                     Mon Mar 12 2018 22:01:11 GMT+0800 (CST)

通过上面数据我们就分析出io以及高负载的原因：
原因：日志保留居然到达了287 天， oplog 明显太大，到时读取oplog的使用大量的io
解决办法： 缩小oplog 的 大小，我们生产环境一般保留48小时左右的数据，这个我们设置2GB 的大小
修改完以后，再次备份， 每次备份时间不用10分钟， 备份数据的性能大大提升
至于 修改oplog 的 大小的方法，后面有空就会写出来


#修改Oplog大小
PS : 请确保我们从复制集的从节点开始维护，并最后维护主节点。
--oplogSize=4096 单位：M
默认大小：当前分区的的可用空间的5%，体积不超过50G，建议生产设置为50G。
而oplog的大小将影响：
1、按记录条数的封顶
2、文件体积封顶    40G     50G    
 
1、关闭SECONDARY节点。 
> use admin
> db.shutdownServer()
2、以不带复制参数的命令启动mongodb
./mongod --port 27018 --dbpath /root/mongodb_3421_slave/mon_database2 --fork --logpath /root/mongodb_3421_slave/mon_log2/mongo18.log

> use local
switched to db local
> db = db.getSiblingDB('local')
local
> db.temp.drop()
false
> db.temp.find()   //此处的temp用来存放plog.rs中的数据，可以重新命名
> db.temp.save( db.oplog.rs.find( { }, { ts: 1, h: 1 } ).sort( {$natural : -1} ).limit(1).next() )
WriteResult({ "nInserted" : 1 })
> db.temp.find()
{ "_id" : ObjectId("5d2300bcfbfb84c373ac5c8d"), "ts" : Timestamp(1562574682, 1), "h" : NumberLong("650003381888214003") }
> db = db.getSiblingDB('local')
local
> db.oplog.rs.drop()
true
> db.runCommand( { create: "oplog.rs", capped: true, size: (2 * 1024 * 1024 * 1024) } )  //2G的oplog
{ "ok" : 1 }
> db.oplog.rs.save( db.temp.findOne() )
▽riteResult({
        "nMatched" : 0,
        "nUpserted" : 1,
        "nModified" : 0,
        "_id" : ObjectId("5d2300bcfbfb84c373ac5c8d")
})
> db.oplog.rs.find()
{ "_id" : ObjectId("5d2300bcfbfb84c373ac5c8d"), "ts" : Timestamp(1562574682, 1), "h" : NumberLong("650003381888214003") }
> use admin;
switched to db admin
> db.shutdownServer();

3、用带复制集的参数启动
./bin/mongod --port 27018 --dbpath /root/mongodb_3421_slave/mon_database2 --replSet rsa --fork --logpath /root/mongodb_3421_slave/mon_log2/mongo18.log

4、修改主节点
-降级
rsa:PRIMARY> use admin
rsa:PRIMARY> rs.stepDown()
-在特定的秒数，是其节点不成为主节点
rsa:PRIMARY> rs.freeze()    
-根据以上修改Oplog大小
-带参数启动

##Journaling and the WiredTiger Storage Engine
当journaling开启后，MongoDB在定义好的 dbPath 路径下创建一个journal子目录，dbPath默认路径为 /data/db 。journal目录用来存放journal文件，该文件用来记录write-ahead redo日志。该目录下还包含一个用来保存最近队列数的文件。一次正常的shutdown会删除journal目录下的所有文件，而非正常的shutdown（比如崩溃）则不会删除文件。当mongod进程重启时，这些文件用来自动恢复数据库保证数据的一致性。

Journal文件是只追加文件，文件名以 j._ 开头。当journal文件达到1G数据时，MongoDB会创建一个新的journal文件。一旦某个journal文件的所有写操作都被刷新到数据库数据文件之后，MongoDB将删除掉这个文件，因为以后都不会再用该文件来进行数据恢复了。除非你每秒进行大量数据的写入，否则journal目录里应该只会有两三个文件

cd /software/mongodb/shard1/data/journal
101M    WiredTigerLog.0000148770
100M    WiredTigerPreplog.0000000391
100M    WiredTigerPreplog.0000000405

##复制集成员的重新同步
1、自动同步，步骤简单，数据同步耗时很长
mongod --shutdown 安全关闭
清除dbPath 中的内容，让mongodb重新进行初始化。
2、拷贝数据文件
为了让数据同步时间缩短，可以先关闭primary节点，之后再拷贝dbpath中的数据，然后再启动实例。

#####管理链式复制
当 secondary 从其他从节点上进行复制而不是 primary 的时候，就发生了链式复制，MongoDB默认是允许链式复制的。
链式复制可以减低主节点的load。但是链式复制也可能造成复制的滞后，这取决于网络情况。
--关闭链式复制
cfg = rs.config()
cfg.settings.chainingAllowed = false
rs.reconfig(cfg)

--开启链式复制
cfg = rs.config()
cfg.settings.chainingAllowed = true
rs.reconfig(cfg)

--查看配置
cfg.settings.chainingAllowed.valueOf() 或者 rs.config().settings;

#####主从切换
分片登录： mongo 92.12.76.13:27001 -u shard_admin -p 'shard_admin@!2020' --authenticationDatabase=admin
1、登录复制集
shard1:PRIMARY> use admin
shard1:PRIMARY> db.auth('shard1_admin','123456');

2、查看状态及配置
shard1:PRIMARY> rs.status()
"ip" : "10.10.8.50","stateStr" : "PRIMARY",
"ip" : "10.10.8.51","stateStr" : "ARBITER",
"ip" : "10.10.8.56","stateStr" : "SECONDARY",
shard1:PRIMARY> rs.config() //查看权重值

3、登录SECONDARY节点，查看是否有延迟
shard1:SECONDARY> rs.printSlaveReplicationInfo()
source: 10.10.8.56:27018
        syncedTo: Wed Mar 04 2020 09:36:15 GMT+0800 (CST)
        0 secs (0 hrs) behind the primary
        
4、确定无延迟，开始转换，配置生效，转换成功
--方法1 降级
PRIMARY> rs.stepDown()       //rs.stepDown(30)   单位：S
这个命令会让primary降级为Secondary节点，并维持60s，如果这段时间内没有新的primary被选举出来，这个节点可以要求重新进行选举。

--方法2 调整权重值（由于某些原因，导致节点被移除后，虽然id变了，但是当更改的时候，还是需要从头开始顺序数）
提升SECONDARY的权重值大于PRIMARY，数值越大，优先级越高
目前三台机器的权重都为： "priority" : 1
--必须在PRIMARY节点上执行
PRIMARY> config=rs.config()                //查看当前配置，存入config变量中。
PRIMARY> config.members[2].priority = 3  //修改config变量，第三组成员的优先级为3.   [id]值
PRIMARY> rs.reconfig(config)             //配置生效   
--config.members[1].votes=0              //可以选配此节点不参与选举            

-操作完成后
"ip" : "10.10.8.50","stateStr" : "SECONDARY",
"ip" : "10.10.8.51","stateStr" : "ARBITER",
"ip" : "10.10.8.56","stateStr" : "PRIMARY ",

--强制把唯一的secondary变成primary （当前的secondary节点是members[0]）
不论其它节点当前是什么状态，都需要把priority和votes置为0，来保证，可以正常切主。
强制把config.members[2]节点提升为主节点
xiaoxu:SECONDARY> config=rs.config();
xiaoxu:SECONDARY> config.members[0].priority=0
xiaoxu:SECONDARY> config.members[0].votes=0
xiaoxu:SECONDARY> config.members[1].priority=0
xiaoxu:SECONDARY> config.members[1].votes=0
xiaoxu:SECONDARY> config.members[2].priority=10
xiaoxu:SECONDARY> config.members[2].votes=0
 rs.reconfig(config,{force:true});
5、SECONDARY关机，只会关闭当前分片的从节点，不影响其它分片。
--登录shard1:SECONDARY> 节点
shard1:SECONDARY> use admin;
shard1:SECONDARY> db.shutdownServer();
执行完成后，对应节点的shard1的进程会消失
在此时主节点会出现：--请耐心等待
2020-11-11T09:41:58.811+0800 I REPL     [ReplicationExecutor] Error in heartbeat request to 92.12.76.13:27001; InterruptedAtShutdown: interrupted at shutdown


#####复制集节点添加及删除
##添加节点
1、复制配置到新的主机上以及keyfile文件，并清空分片的数据、日志、pid等信息
2、修改配置
cd /usr/local/mongodb/shard1
vim mongod.conf
net:
   bindIp: 10.10.8.55
   port: 27018
   
3、启动shard1进程
cd /usr/local/mongodb422/bin/
./mongod --config /usr/local/mongodb/shard1/mongod.conf

4、shard1的PRIMARY上进行操作  注意：利用rs.add和rs.remove是不用rs.reconfig来使用配置生效的
shard1:PRIMARY> rs.add("10.10.8.55:27018");     //rs.add({_id: 1, host: "mongodb3.example.net:27017", priority: 0, hidden: true})
rs.status()
状态会从："stateStr" : "STARTUP2",  转换为："stateStr" : "SECONDARY"  说明主节点的数据，已经复制到新的SECONDARY节点上
--查看新加入节点的延迟情况。
rs.printSlaveReplicationInfo() 
5、复制节点删除
rs.remove("10.10.8.50:27018");

##节点状态转换
由从"stateStr" : "ARBITER" 转换为 "stateStr" : "SECONDARY" 
"New and old configurations differ in the setting of the arbiterOnly field for member 10.10.8.51:27018; to make this change, remove then re-add the member",
1、找到ARBITER所在的节点。
2、登录所在复制集的primary节点，先移除，再加入。
rs.remove('10.10.8.51:27018')
rs.add('10.10.8.51:27018')
3、停掉10.10.8.51所对应的进程。
删除data目录，以便重新加入节点的初始化。
4、启动10.10.8.51所在的进程，之后复制集进行初始化。
5、查看新加入节点的延迟情况。
shard1:PRIMARY> rs.printSlaveReplicationInfo()
source: 10.10.8.61:27018
        syncedTo: Sat Aug 14 2021 16:31:33 GMT+0800 (CST)
        0 secs (0 hrs) behind the primary 
source: 10.10.8.51:27018     //新加入的节点
        syncedTo: Sat Aug 14 2021 16:22:44 GMT+0800 (CST)
        529 secs (0.15 hrs) behind the primary 
6、检查
rs.status()
rs.config()

#####分片节点增加
1、在新的主机上部署mongod软件，配置文件以及keyfile文件等
2、修改原始的分片文件夹，并清空分片的数据、日志、pid等信息
3、修改配置,修改新的分片名
4、从其它分片上拷贝keyfile文件到新的分片上
[root@data_guard01 shard4]# vim mongod.conf 
#shard4 mongod.conf
systemLog:
   destination: file
   path: "/usr/local/mongodb/shard4/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/shard4/db"
processManagement:
   fork: true
   pidFilePath: /usr/local/mongodb/shard4/pid
net:
   bindIp: 10.10.8.55    
   port: 27021
setParameter:
   enableLocalhostAuthBypass: false
replication:
   replSetName: "shard4"
sharding:
   clusterRole: shardsvr
security:
    authorization: enabled
    keyFile: /usr/local/mongodb/key/mongdb-keyfile

4、启动新的分片
--由于之前的配置中，启用了keyFile，所以当shard4启动后，会由于需要认证启动不成功，需要先注释掉，再启动进程
#security:
#    authorization: enabled
#    keyFile: /usr/local/mongodb/key/mongdb-keyfile
[root@data_guard01 shard4]# cd /usr/local/mongodb422/bin/
[root@data_guard01 bin]# ./mongod --config /usr/local/mongodb/shard4/mongod.conf

5、连接分片
mongo 10.10.8.55:27021
config = {
   _id : "shard4",
    members : [
        {_id : 0, host : "10.10.8.55:27021" }
    ]
}

rs.initiate(config);

-由于shard4只有一个复制集成员，所以10.10.8.55就是PRIMARY

--创建分片管理用户
shard4:PRIMARY> use admin
switched to db admin
shard4:PRIMARY> db.createUser( { user: 'shard4_admin', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })

6、杀掉shard4进程，开启keyFile，重启shard4进程

7、连接mongos，添加成员
mongo 10.10.8.50:27017
sh.addShard("shard4/10.10.8.55:27021")

8、查看分片状态
  shards:
        {  "_id" : "shard1",  "host" : "shard1/10.10.8.50:27018,10.10.8.55:27018,10.10.8.56:27018",  "state" : 1 }
        {  "_id" : "shard2",  "host" : "shard2/10.10.8.50:27019,10.10.8.51:27019",  "state" : 1 }
        {  "_id" : "shard3",  "host" : "shard3/10.10.8.51:27020,10.10.8.56:27020",  "state" : 1 }
        {  "_id" : "shard4",  "host" : "shard4/10.10.8.55:27021",  "state" : 1 }
        
balancer:
        Currently enabled:  yes
        Currently running:  yes    //平衡进程启动，各个分片表，开始把数据均匀平衡到4个分片上
        
#####分片删除
为了使得数据迁移能够成功, balancer 必须 是开启的.在 mongo 终端中使用 sh.getBalancerState()        
mongos>  sh.getBalancerState()  
true

##注意：如果这个分片是一个或多个数据库的 primary shard ,上面会存储未设置分片的数据，所以当执行如下删除分片命令时，会有提示。
mongos> use admin
mongos> db.runCommand( { removeShard: "shard1" } )
{
        "msg" : "draining ongoing",
        "state" : "ongoing",
        "remaining" : {
                "chunks" : NumberLong(0),
                "dbs" : NumberLong(2),
                "jumboChunks" : NumberLong(0)
        },
        "note" : "you need to drop or movePrimary these databases",
        "dbsToMove" : [
                "test",           --未分片数据库
                "test_1"          --未分片数据库
        ],
        "ok" : 1,
        "operationTime" : Timestamp(1583308618, 1),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1583308618, 1),
                "signature" : {
                        "hash" : BinData(0,"MRjIXBbpAhQiMBSQMJ3zgBLZu5w="),
                        "keyId" : NumberLong("6781621887140102174")
                }
        }
}

此时平衡开始，数据开始迁移shard1的数据到其它分片上均衡。
Currently running:  no 均衡完成
以上操作只是把分片的库表做了均衡，但是未分片的数据库，依然需要迁移到其它分片，才算移除分片成功。
把这两个库迁移到shard4上。
db.runCommand( { movePrimary: "test", to: "shard4" })
db.runCommand( { movePrimary: "test_1", to: "shard4" })

迁移完成后，为了清除所有的元信息,并结束删除分片的过程,再次执行 removeShard。
mongos> use admin
mongos> db.runCommand( { removeShard: "shard1" } )
{
        "msg" : "removeshard completed successfully",    //出现此即为成功
        "state" : "completed",
        "shard" : "shard1",
        "ok" : 1,
        "operationTime" : Timestamp(1583308859, 2),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1583308859, 2),
                "signature" : {
                        "hash" : BinData(0,"rgdb2I28zvDqetrKuoEb3bq+X+0="),
                        "keyId" : NumberLong("6781621887140102174")
                }
        }
}

#查看状态,shard1的元数据被彻底清除
sh.status()
  shards:
        {  "_id" : "shard2",  "host" : "shard2/10.10.8.50:27019,10.10.8.51:27019",  "state" : 1,  "draining" : true }
        {  "_id" : "shard3",  "host" : "shard3/10.10.8.51:27020,10.10.8.56:27020",  "state" : 1 }
        {  "_id" : "shard4",  "host" : "shard4/10.10.8.55:27021",  "state" : 1 }

##库的分片迁移(这个库下的所有表，也会跟着移动)
对于未分片的库，可以进行分片的移动。
sh.status()        
{  "_id" : "testdb1",  "primary" : "shard1",  "partitioned" : false,  "version" : {  "uuid" : UUID("21dac042-0c53-46f1-bf39-1c253247306b"),  "lastMod" : 2 } }

use admin
db.runCommand( { movePrimary:"testdb1", to: "shard2" })   
//会有等待，并且肯定锁库，库的大小决定移动的时间。
{  "_id" : "testdb1",  "primary" : "shard2",  "partitioned" : false,  "version" : {  "uuid" : UUID("21dac042-0c53-46f1-bf39-1c253247306b"),  "lastMod" : 2 } }


#####用户管理
--创建超级管理员
mongos> use admin
switched to db admin
mongos> db.createUser({user:'admin',pwd:'123456', roles:[{role:'root', db:'admin'}]})

--指定库（test）创建读写权限
use admin   //把用户放在admin数据库中
db.createUser({user:'dzswjdb',pwd:'123456', roles:[{role:'readWrite', db:'test'}]})

--指定IP
db.createUser(
   {
     user: "test3",
     pwd: "test3",
     roles: [ {role:'readWrite', db:'test'}],
     authenticationRestrictions: [ {
        clientSource: ["10.10.8.50"],     //clientIP
        serverAddress: ["198.51.100.0"]   //mongod实例或者mongos提供的对外IP
     } ]
   }
)

--单用户多库权限设置(为了统一管理，建议把所有用户放在admin库中)
use admin;       
> db.createUser(
{
   user: "chenzhe",
   pwd: "123456",
   roles: [
      { role: "readWrite", db: "chj_db" },
      { role: "dbOwner", db: "chj_db" },
      { role: "readWrite", db: "dzswj_db" }
   ]
}
)


--查看用户创建是否成功
use admin;
db.system.users.find().pretty();

--删除用户
use admin
db.dropUser('YUNQU')

--用户密码修改
use admin
db.runCommand({ 
    "updateUser" : "admin_shard", 
    "pwd" : "45678", 
    "customData" : {

    }, 
    "roles" : [
        {
            "role" : "root", 
            "db" : "admin"
        }
    ]
});


#建立只读账号(根据业务需求确认是否需要)
> db.createUser(
{
user: "chj_db_r",
pwd: "123456",
roles: [ { role: "read", db: "chj_db" } ]
}
)

use admin // 切换到admin
db.createUser( { user: 'test', pwd: 'testpassword', roles: [ { role: 'root', db: 'admin' } ] })
db.auth('user','password'); //验证用户不要多次验证
多次验证登陆，会导致异常！关闭数据库重新验证

##创建role角色
--创建角色：sampleRole，具有sampledb.sample表的更新和读取
#actions 具体角色说明  https://docs.mongodb.com/v4.4/reference/privilege-actions/
db.createRole(
{
role: 'sampleRole',
privileges: [{
resource: {
db: 'sampledb', collection: 'sample'
},
actions: ["update"]      
}],
roles: [{
role: 'read',
db: 'sampledb'
}]
}
)

use admin
db.createRole(
   {
     role: "test_read",
     privileges: [
       { resource: { db: "test", collection: "" }, actions: [ "find", "update", "insert", "remove" ] },
       { resource: { db: "testdb", collection: "users" }, actions: [ "update", "insert"] },
     ],
     roles: [
       { role: "read", db: "admin" }
     ]
   },
   { w: "majority" , wtimeout: 5000 }
)

--给用户赋予角色
db.createUser(
{
user: 'sampleUser',
pwd: 'password',
roles: [{role: 'sampleRole', db: 'admin'}]
}
)
--删除角色
db.dropRole("myClusterwideAdmin")
 
数据库用户角色：read、readWrite;
数据库管理角色：dbAdmin、dbOwner、userAdmin；
集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager；
备份恢复角色：backup、restore；
所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
超级用户角色：root
内部角色：__system

##角色说明
read：允许用户读取指定数据库
readWrite：允许用户读写指定数据库
dbAdmin：允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
userAdmin：允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
clusterAdmin：只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
readAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读权限
readWriteAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的读写权限
userAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
dbAdminAnyDatabase：只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
root：只在admin数据库中可用。超级账号，超级权限
dbOwner: readWrite + dbAdmin + dbAdmin


--验证登录
访问哪个数据，都需要先进库
use test
db.auth('dzswjdb','123456')

use admin
db.auth('admin','123456')

##设置慢查询
--针对库设置慢查询，对于慢查询是基于每个分片的，所以需要登录每个分片进行设置，mongos里面配置是不行的，会提示 "errmsg" : "profile may only be run against the admin database.",
1.查看mongodb慢日志是否开起
mongo 92.12.76.13:27001 -u shard_admin -p 'shard_admin@!2020' --authenticationDatabase=admin 
use BJ_Rack;
db.getProfilingStatus();

2.开启慢日志，设置超过100毫秒的操作为慢操作
Level	Description
0	The profiler is off and does not collect any data. This is the default profiler level.
1	The profiler collects data for operations that take longer than the value of slowms. --筛选出大于slowms阈值的语句
2	The profiler collects data for all operations.   --筛选出所有语句

--查看级别
shard1:PRIMARY> db.getProfilingLevel();

--指定数据库，并指定阈值慢查询 ，超过20毫秒的查询被记录,sampleRate 值默认为1，表示都采集，0.42 表示采集42%的内容
use testdb
db.setProfilingLevel(1, { slowms: 200 })
db.setProfilingLevel(1, { sampleRate: 1 })

--也可以在shard1.conf上用参数控制，事例为500ms，参数文件中的静态值得优先级高于系统设置的数值
profile=1
slowms = 500

3.查看慢日志内容

db.system.profile.find().sort({$natural:-1})

--查看时间大于500ms的语句
> db.system.profile.find({millis:{$gt:500}}).sort({$natural:-1})
{ "ts" : ISODate("2011-07-23T02:50:13.941Z"), "info" : "query order.order reslen:11022 nscanned:672230  \nquery: { status: 1.0 } nreturned:101 bytes:11006 640ms", "millis" : 640 }
{ "ts" : ISODate("2011-07-23T02:51:00.096Z"), "info" : "query order.order reslen:11146 nscanned:672302  \nquery: { status: 1.0, user.uid: { $gt: 1663199.0 } }  nreturned:101 bytes:11130 647ms", "millis" : 647 }
 

##这里值的含义是
ts：命令执行时间
info：命令的内容
query：代表查询
order.order： 代表查询的库与集合
reslen：返回的结果集大小，byte数
nscanned：扫描记录数量
nquery：后面是查询条件
nreturned：返回记录数及用时
millis：所花时间

--慢查询分析
1. 如果发现 millis 值比较大，那么就需要作优化。
2. 如果docsExamined数很大，或者接近记录总数（文档数），那么可能没有用到索引查询，而是全表扫描。
3. 如果keysExamined数为0，也可能是没用索引。
4. 结合 planSummary 中的显示，上例中是  "COLLSCAN, COLLSCAN" 确认是全表扫描
5. 如果 keysExamined 值高于 nreturned 的值，说明数据库为了找到目标文档扫描了很多文档。这时可以考虑创建索引来提高效率。
6. 索引的键值选择可以根据 query 中的输出参考，上例中 filter:包含了 jzrq和jglxfldm 并且按照RsId排序，所以 我们的索引
   索引可以这么建: db.f10_2_8_3_jgcc.ensureindex({jzrq:1,jglxfldm:1,RsId:1})

db.system.profile.find({millis:{$gt:500}},{ns:1,op:1,query:1,planSummary:1,ts:1,millis:1}).sort({$natural:1})

--查询当天的慢SQL汇总
select ns,count(*)  from [system.profile]  where millis>=500 and ts between ISODate("2020-10-09T00:00:08.000+0000") and ISODate("2020-10-09T10:00:08.000+0000") group by ns having count(*) >=20 order by count(*)

--显示明细
select *  from [system.profile]  where ns="dzswjdb.ysqxxVO" and ts between ISODate("2020-10-09T00:00:08.000+0000") and ISODate("2020-10-09T10:00:08.000+0000");


#######执行计划详述#######
支持下列操作返回查询计划
aggregate(); count(); distinct(); find(); group(); remove(); update() 
cursor.explain(verbosity)   为一个游标返回其查询执行计划(Reports on the query execution plan for a cursor)
cursor.explain(verbosity) 最通常的行式为db.collection.find().explain()。其中verbosity说明返回信息的粒度。

1、查看查询类执行计划
        PRIMARY> db.sign_detail.find({org:100}).explain();--参数按需
2、查看聚合类执行计划
         PRIMARY> db.sign_detail.explain().aggregate({$match:{org:"100"}})
3、查看修改类执行计划--不会修改实际值,也可以转换成查询语句
            db.members.explain().update(
            { "points": { $lte: 20 }, "status": "P" },
            { $set: { "misc1": "Need to activate" } },
             { multi: true, hint: { status: 1 } })

db.collection.find().explain(verbose)
explain()输出一个以文档形式展现的执行计划，可以包括统计信息(可选)。

##参数说明：
    verbose：
            可选参数。缺省值为queryPlanner，用于查看指定执行计划的特定部分。即给定不同的参数则输出信息的详细程度不同
            常用的包括queryPlanner，executionStats，以及allPlansExecution

    queryPlanner模式
            这个是缺省模式。
            MongoDB运行查询优化器对当前的查询进行评估并选择一个最佳的查询计划

    executionStats模式        
            mongoDB运行查询优化器对当前的查询进行评估并选择一个最佳的查询计划进行执行
            在执行完毕后返回这个最佳执行计划执行完成时的相关统计信息
            对于写操作db.collection.explain()返回关于更新和删除操作的信息，但是并不将修改应用到数据库
            对于那些被拒绝的执行计划，不返回其统计信息

    allPlansExecution模式
            该模式是前2种模式的更细化，即会包括上述2种模式的所有信息
            即按照最佳的执行计划执行以及列出统计信息，而且还会列出一些候选的执行计划
            如果有多个查询计划   ，executionStats信息包括这些执行计划的部分统计信息

SQL术语/概念	MongoDB术语/概念	解释/说明
database	    database	数据库
table	        collection	数据库表/集合
row	          document	数据记录行/文档
column	      field	数据字段/域
index	        index	索引
table         joins	 	表连接,MongoDB不支持
primary key	primary key	主键,MongoDB自动将_id字段设置为主键


--执行计划中的TYPE类型（stage）
COLLSCAN         #全表扫描                                                避免
IXSCAN           #索引扫描                                                可以改进 选用更高效的索引
FETCH            #根据索引去检索指定document                               
SHARD_MERGE      #将各个分片返回数据进行merge                               尽可能避免跨分片查询
SORT             #表明在内存中进行了排序（与老版本的scanAndOrder:true一致）   排序要有index  
LIMIT            #使用limit限制返回数                                      要有限制 Limit+（Fetch+ixscan）最优
SKIP             #使用skip进行跳过                                         避免不合理的skip
IDHACK           #针对_id进行查询                                          推荐,_id 默认主键,查询速度快
SHARDING_FILTER  #通过mongos对分片数据进行查询                          SHARDING_FILTER+ixscan最优 
COUNT            #利用db.coll.explain().count()之类进行count运算             
COUNTSCAN        #count不使用Index进行count时的stage返回                    避免 这种情况建议加索引
COUNT_SCAN       #count使用了Index进行count时的stage返回                    推荐
SUBPLA           #未使用到索引的$or查询的stage返回                           避免
TEXT             #使用全文索引进行查询时候的stage返回  
PROJECTION       #限定返回字段时候stage的返回                                选择需要的数据, 推荐PROJECTION+ixscan
seeks            #寻址扫描次数   若是为1，即一次性寻址后就检索完索引       越小越好

--查看执行计划
db.inventory.find(
   { quantity: { $gte: 100, $lte: 200 } }
).explain("executionStats")

 "executionStats": {
        "nReturned": NumberInt("12322"),
        "executionTimeMillis": NumberInt("23"),
        "totalKeysExamined": NumberInt("12322"),
        "totalDocsExamined": NumberInt("12322"),


queryPlanner.winningPlan.stage        显示 COLLSCAN 表示集合扫描。
集合扫描表示mongod必须按照文档扫描整个文档集合来匹配结果。这通常是昂贵的操作，可能导致查询速度慢。
executionStats.nReturned              显示3表示查询匹配到并返回3个文档。
executionStats.totalKeysExamined      显示0表示这个查询没有使用索引。
executionStats.totalDocsExamined      显示10表示MongoDB扫描了10个文档，从中查询匹配到3个文档。
匹配文档的数量与检查文档的数量之间的差异可能意味着，查询可以使用索引提高的查询效率。

##update语句执行计划     
//https://blog.csdn.net/leshami/article/details/53521990

db.ysqRzVO.explain("executionStats").update()
explain中的选项，不会真正更新数据，可以放心查看执行计划。

##计划解释：
{
        "queryPlanner" : {
                "plannerVersion" : 1,              //查询计划版本
                "namespace" : "test.persons",      //被查询对象
                "indexFilterSet" : false,          //是否使用到了索引来过滤
                "parsedQuery" : {                  //解析查询，即过滤条件是什么
                        "age" : {                  //此处为age=26
                                "$eq" : 26
                        }
                },
                "winningPlan" : {                  //最佳的执行计划
                        "stage" : "COLLSCAN",      //COLLSCAN为集合扫描
                        "filter" : {               //过滤条件
                                "age" : {
                                        "$eq" : 26
                                }
                        },
                        "direction" : "forward"    //方向：forward
                },
                "rejectedPlans" : [ ]              //拒绝的执行计划，此处没有
        },
        "serverInfo" : {                           //服务器信息，包括主机名，端口，版本等。
                "host" : "node233.edq.com",
                "port" : 27017,
                "version" : "3.2.10",
                "gitVersion" : "79d9b3ab5ce20f51c272b4411202710a082d0317"
        },
        "ok" : 1
}

"executionStats" : {                   //执行计划相关统计信息
                "executionSuccess" : true,     //执行成功的状态
                "nReturned" : 1,               //返回结果集数目
                "executionTimeMillis" : 21896, //执行所需的时间,毫秒
                "totalKeysExamined" : 0,       //索引检查的时间
                "totalDocsExamined" : 5000000, //检查文档总数
                "executionStages" : {          
                        "stage" : "COLLSCAN",  //使用集合扫描方式
                        "filter" : {           //过滤条件
                                "id" : {
                                        "$eq" : 500
                                }
                        }
                      }
                    }

--hint指定索引
db.inventory.createIndex( { quantity: 1, type: 1 } )


db.inventory.find(
   { quantity: { $gte: 100, $lte: 300 }, type: "food" }
).hint({ quantity: 1, type: 1 }).explain("executionStats")



--慢查询常用参数
#返回最近的10条记录
db.system.profile.find().limit(10).sort({ts:-1}).pretty()
#返回所有的操作，除command类型的
db.system.profile.find({op: {$ne:'command'}}).pretty()
#返回特定集合
db.system.profile.find({ns:'mydb.test'}).pretty()
#返回大于5毫秒慢的操作
db.system.profile.find({millis:{$gt:5}}).pretty()
#从一个特定的时间范围内返回信息
db.system.profile.find(
                  {
                   ts : {
                         $gt : new ISODate("2015-10-18T03:00:00Z"),
                         $lt : new ISODate("2015-10-19T03:40:00Z")
                        }
                  }
                 ).pretty()
#特定时间，限制用户，按照消耗时间排序
db.system.profile.find(
                  {
                    ts : {
                          $gt : newISODate("2015-10-12T03:00:00Z") ,
                          $lt : newISODate("2015-10-12T03:40:00Z")
                         }
                  },
                  { user : 0 }
                 ).sort( { millis : -1 } )
#查看最新的 Profile  记录： 
db.system.profile.find().sort({$natural:-1}).limit(1)
# 显示5个最近的事件
show profile

##mongos启动报错
[root@bogon conf]# mongod -f /usr/local/mongodb/conf/mongos.conf
Error parsing INI config file: unrecognised option 'configdb'
稍微等待下，有可能是分片没有初始化完成
#####管理脚本#####
--查看collection的大小
function getReadableFileSizeString(fileSizeInBytes) {

    var i = -1;
    var byteUnits = [' kB', ' MB', ' GB', ' TB', 'PB', 'EB', 'ZB', 'YB'];
    do {
        fileSizeInBytes = fileSizeInBytes / 1024;
        i++;
    } while (fileSizeInBytes > 1024);

    return Math.max(fileSizeInBytes, 0.1).toFixed(1) + byteUnits[i];
};
var collectionNames = db.getCollectionNames(), stats = [];
collectionNames.forEach(function (n) { stats.push(db[n].stats()); });
stats = stats.sort(function(a, b) { return b['count'] - a['count']; });
for (var c in stats) { print(stats[c]['ns'] + " , " + stats[c]['count'] + " ," + getReadableFileSizeString(stats[c]['storageSize']) + ""); }

--批量生成测试数据
for (i=0;i<1000000;i++){
db.users.insert(
{"i":i,
"username":"user"+i,
"age":Math.floor(Math.random()*120),
"create":new Date()
});}


#####GridFS#####
用来存储超过16M的bson文件
1、同样可以在分片架构中进行分片操作
2、由两部分组成：在chunk中存储文件，在db中存储元数据
https://mongoing.com/docs/reference/program/mongofiles.html#bin.mongofiles
https://mongoing.com/docs/core/gridfs.html#gridfs-collections

--上传文件命令
向records库上传一个文件foo.txt
mongofiles --host 10.10.8.50 --port 27017 -d records put foo.txt

--下载文件
mongofiles --host 10.10.8.50 --port 27017 -d records get foo.txt

--查看命令
mongofiles --host 10.10.8.50 --port 27017 -d records list

--删除文档
mongofiles --host 10.10.8.50 --port 27017 -d records delete foo.txt
会同步删除fs.chunks、fs.files的元数据信息

--搜索文档 包含foo
mongofiles --host 10.10.8.50 --port 27017 -d records search foo

--通过ID查找
mongofiles --host 92.12.76.14 --port 27017 -u admin -p 'System@!2018'  --authenticationDatabase admin -d dzswjdb get_id 'ObjectId("5c2953e0770ea3e5018a2ad9")'

##实例内存分配
--存储引擎 Cache
MongoDB 3.2 及以后，默认使用 WiredTiger 存储引擎，可通过 cacheSizeGB 选项配置 WiredTiger 引擎使用内存的上限，一般建议配置在系统可用内存的60%左右（默认配置）
一个正常运行的 MongoDB 实例，cache used 一般会在 0.8 * cacheSizeGB 及以下，偶尔超出问题不大；如果出现 used>=95% 或者 dirty>=20%，并一直持续，说明内存淘汰压力很大，用户的请求线程会阻塞参与page淘汰，请求延时就会增加，这时可以考虑「扩大内存」或者 「换更快的磁盘提升IO能力」
>>合理配置 WiredTiger cacheSizeGB
如果一个机器上只部署 Mongod，mongod 可以使用所有可用内存，则是用默认配置即可。
如果机器上多个mongod混部，或者mongod跟其他的一些进程一起部署，则需要根据分给mongod的内存配额来配置 cacheSizeGB，按配额的60%左右配置即可。
>>内存配置方法
storage:
   wiredTiger:
      engineConfig:
         cacheSizeGB: 100     //100G 
https://docs.mongodb.com/manual/reference/configuration-options/
配置后，重启mongodb进程      
>>硬盘写入忽高忽低
硬盘出现，一会100%，一会是0% ，很不稳定，是由于内存刷脏页到硬盘导致。
cache调小目的：  cachesize调整优化(120G->50G)
1. 减少checkpoint刷脏数据时的数据量，减少磁盘IO跟不上客户端写入速度引起的持续性IO跌0问题。
2. 预留部分内存给内核pageCache，尽量避免内存不足引起的应用阻塞。
>>并发配置
MongoDB driver 在连接 mongod 时，会维护一个连接池（通常默认100），当有大量的客户端同时访问同一个mongod时，就需要考虑减小每个客户端连接池的大小。mongod 可以通过配置 net.maxIncomingConnections 配置项来限制最大的并发连接数量，防止数据库压力过载。


##元数据查看
mongos> use records;
mongos> show tables;
fs.chunks  //实际文件存储，二进制存放
fs.files  //元数据表
其中：fs.files中的_id = fs.chunks中的files_id
db.fs.chunks.find({"files_id": ObjectId("5ec4e3622c1ee85d199dbf31")})
db.fs.files.find({"_id":ObjectId("5ec4e3622c1ee85d199dbf31")})

mongos> db.fs.files.find()   
{ "_id" : ObjectId("5ec4df9dc0764266049f5759"), "length" : NumberLong(12)(单位:字节), "chunkSize" : 261120, "uploadDate" : ISODate("2020-05-20T07:43:25.504Z"), "filename" : "foo.txt", "metadata" : {  } }

##gridfs文件删除
1、为了方便删除，需要把文件名更新成一致的名字
db.fs.files.update({"uploadDate": {
        $gt: new Date("2020-05-21 14:00:14"),
        $lt: new Date('2020-05-21 17:50:00')}},{$set:{"filename": "file_20200521"}},{multi:true})
2、删除文件     	
mongofiles --host 10.10.8.50 --port 27017 -d records delete file_20200521
mongofiles --host 10.10.8.51 --port 27019 -d records list //确定文件已经删除

3、在分片的primary上进行空间释放
mongos> show dbs;
admin    0.000GB
config   0.001GB
records  0.494GB

shard2:PRIMARY> db.runCommand({ compact : 'fs.chunks' ,force:true});
--MongoDB4.4 的 Compact 指令并不会阻塞读写

mongos> show dbs;
admin    0.000GB
config   0.001GB
records  0.179GB

##空间回收##
1、表数据库按照条件remove后，需要db.runCommand({ compact : 'fs.chunks' ,force:true});进行空间的回收。
2、库下的表drop后，释放物理空间，需要进行整库的收缩，db.repairDatabase() 可以回收，但是会锁库。

#####主机更换IP迁移######
当由于主机需要维护，需更主机时，可以在不停机，不做任何操作的情况下完成迁移
1、如果要迁移的主机时mongod、conf及shard的分片的情况下，需要copy到新的主机上，包括keyfile，之后把源主机的关掉，把源IP修改到新的主机上，在新主机上启动所有服务，数据就开始同步了。
#源主机，shard分片中复制集的角色需降级为secondery
#新主机启动服务，若有必要按照分片的负载能力，指定复制集的primary

#####FAQ
--我可以在一个集合分片后更改片键吗
不可以
在MongoDB中，目前不自动支持集合分片后修改片键。这个事实凸显了选择一个好的 片键 的重要性。如果你 一定要 在集合分片后更改片键，最好的办法是：
从MongoDB中导出所有的数据到外部存储格式。
删除原始的分片集合。
使用更理想的片键配置分片。
预分裂 片键区间以确保初始均匀分布。
还原转储的数据到MongoDB。

--执行权重
config = {
   _id : "shard1",
    members : [
        {_id : 0, host : "10.10.8.50:27018" ,priority : 3},    //primary
        {_id : 1, host : "10.10.8.51:27018" ,arbiterOnly: true},
        {_id : 2, host : "10.10.8.56:27018" ,priority : 2},
        {_id : 3, host : "10.10.8.55:27018" ,priority : 2}
    ]
}

rs.initiate(config);

##关于查询和插入的实时性
同时打开两个shell，一个执行插入另一个执行查询，在同一shell中，插入后马上进行查找是没有问题的，但是在繁忙的服务器上，就有可能插入后，马上查询数据
是查不出结果的，但是随后，数据有突然冒出来了。
这是由于，python、java程序使用了连接池，为了提高效率，分在了不同的会话里。

## 除了mongodump/mongorestore之外还有一对组合是mongoexport/mongoimport 区别在哪里？
mongoexport/mongoimport导入/导出的是JSON格式，而mongodump/mongorestore导入/导出的是BSON格式。
JSON可读性强但体积较大，BSON则是二进制文件，体积小但对人类几乎没有可读性。
在一些mongodb版本之间，BSON格式可能会随版本不同而有所不同，所以不同版本之间用mongodump/mongorestore可能不会成功，具体要看版本之间的兼容性。当无法使用BSON进行跨版本的数据迁移的时候，使用JSON格式即mongoexport/mongoimport是一个可选项。跨版本的mongodump/mongorestore个人并不推荐，实在要做请先检查文档看两个版本是否兼容（大部分时候是的）。
JSON虽然具有较好的跨版本通用性，但其只保留了数据部分，不保留索引，账户等其他基础信息。使用时应该注意。
总之，这两套工具在实际使用中各有优势，应该根据应用场景选择使用（好像跟没说一样）。但严格地说，mongoexport/mongoimport的主要作用还是导入/导出数据时使用，并不是一个真正意义上的备份工具。所以这里也不展开介绍了。

                             
                             
                             
##### MongoDB shell 连接服务 连接串#####
mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]

mongodb:// 这是固定的格式，必须要指定。

username:password@ 可选项，如果设置，在连接数据库服务器之后，驱动都会尝试登陆这个数据库

host1 必须的指定至少一个host, host1 是这个URI唯一要填写的。它指定了要连接服务器的地址。如果要连接复制集，请指定多个主机地址。

portX 可选的指定端口，如果不填，默认为27017

/database 如果指定username:password@，连接并验证登陆指定数据库。若不指定，默认打开 test 数据库。

?options 是连接选项。如果不使用/database，则前面需要加上/。所有连接选项都是键值对name=value，键值对之间通过&或;（分号）隔开

options选项如下：
#replicaSet=name	验证replica set的名称。 Impliesconnect=replicaSet.
#slaveOk=true|false	//在程序或配置中心配置后，可保证读的操作，也可以发送到second节点。
true:在connect=direct模式下，驱动会连接第一台机器，即使这台服务器不是主。在connect=replicaSet模式下，驱动会发送所有的写请求到主并且把读取操作分布在其他从服务器。
false: 在 connect=direct模式下，驱动会自动找寻主服务器. 在connect=replicaSet 模式下，驱动仅仅连接主服务器，并且所有的读写命令都连接到主服务器。

#safe=true|false	
true: 在执行更新操作之后，驱动都会发送getLastError命令来确保更新成功。(还要参考 wtimeoutMS).
false: 在每次更新之后，驱动不会发送getLastError来确保更新成功。

#w=n	驱动添加 { w : n } 到getLastError命令. 应用于safe=true。

#wtimeoutMS=ms	驱动添加 { wtimeout : ms } 到 getlasterror 命令. 应用于 safe=true.
#fsync=true|false	
true: 驱动添加 { fsync : true } 到 getlasterror 命令.应用于 safe=true.
false: 驱动不会添加到getLastError命令中。

#journal=true|false	如果设置为 true, 同步到 journal (在提交到数据库前写入到实体中). 应用于 safe=true
#connectTimeoutMS=ms	可以打开连接的时间。
#socketTimeoutMS=ms	发送和接受sockets的时间。

#####数据库复制#####
##在同一个主机上从一个db的表复制到另一个db的表
use testdb;
db.DJ_NSRXX.find().forEach(function(d){
db.getSiblingDB('testdb_2')['DJ_NSRXX_bak'].insert(d);
})

##筛选字段的备份
db.getCollection("club").find({}).forEach(
function(d){
 db.getCollection("club_preload").insert({'club_id':d.id,'valid':NumberInt(1)});
});

##同主机、同db下复制表
use testdb;
db.t_sentiment_ids.find().forEach(function(x){
db.t_sentiment_ids22.insert(x);
})

##数据库的主机间复制
db.copyDatabase(fromdb,todb,fromhost,username,password,mechanism)
db.copyDatabase('test','test2','192.168.14.52:27017','test','test','SCRAM-SHA-1')

fromdbt: 源db；
todb: 目标db；
fromhost: 源db的主机地址，如果在同一个mongod实例内可以省略；
username: 如果开启了验证模式，需要源DB主机上的MongoDB实例的用户名；
password: 同上，需要对应用户的密码；
mechanism: fromhost验证username和password的机制，有：MONGODB-CR、SCRAM-SHA-1两种。

##聚合加工后输出
https://www.jianshu.com/p/27f602be63cc
db.news.aggregate( [
{ $group : { _id : "$author", books: { $push: "$title" } } },
{ $out : "news_1" }
] )

##create table as 
--全表拷贝
db.users.find().forEach(function(x){db.users_bak.insert(x)})
--带条件
db.clothes.aggregate(
  [
    { $match: { price: { $type: "long" }, priceDec: { $exists: 0 } } },
    {
      $addFields: {
        priceDec: {
          $multiply: [ "$price", NumberDecimal( "0.01" ) ]
        }
      }
    }
  ]
).forEach( ( function( doc ) {
  db.clothes_new.save( doc );
} ) )

##静默脚本执行
mongo mongo.dzswj.foresee:27017/dzswj -u admin -p 'Sys@!2018'  --authenticationDatabase admin  --quiet 1setZlpzxxVOYxbz.js > zlpzxxVO.bak
具体参考，mongodb电子税务局减肥脚本


#####帮助命令#####
-查看大于2S的查询
选择要查询的库
use testdb;
db.currentOp({"secs_running": {$gte: 2}});

-获取最后一次报错
db.getLastError()

--循环输出
var ops = db.currentOp().inprog;
for (i = 0; i < ops.length; i++){
var opid = ops[i].opid;
--db.killOp(opid)
print("Stopping op #"+opid) }

--统计库中所有表的大小及行数
var collectionNames= db.getCollectionNames();  
for (var i = 0; i < collectionNames.length; i++) {
  var coll = db.getCollection(collectionNames[i]);
  var stats = coll.stats(1024*1024*1024);
  print(stats.ns, stats.count, "            ",stats.storageSize+"GB");  
}

--行数大于100W的过滤
var collectionNames= db.getCollectionNames();  
for (var i = 0; i < collectionNames.length; i++) {
  var coll = db.getCollection(collectionNames[i]);
  var stats = coll.stats(1024*1024*1024);
  if(stats.count >= 1000000){
print(stats.ns, stats.count, "            ",stats.storageSize+"GB"); 
}
   }


--统计索引的大小
var collectionNames= db.getCollectionNames();  
for (var i = 0; i < collectionNames.length; i++) {
  var coll = db.getCollection(collectionNames[i]);
  var stats = coll.stats(1024*1024);
  print(stats.ns,stats.totalIndexSize+"MB");  
} 

--统计数据库的索引创建语句（只能在mongodb客户端执行，主机上执行会报错）
#统计单表索引的创建语句,指定要查询的库后
--var collectionList = ["nsrxx"]
#统计整库
var collectionList = db.getCollectionNames();
for(var index in collectionList){
var collection = collectionList[index];
var cur = db.getCollection(collection).getIndexes();
if(cur.length == 1){
continue;
}
for(var index1 in cur){
var next = cur[index1];
if(next["key"]["_id"] == '1'){
continue;
}

print(
"try{ db.getCollection(\""+collection+"\").ensureIndex("+JSON.stringify(next.key)+",{background:1, unique:" + (next.unique || false) + "" + (next.expireAfterSeconds > 0 ? ", expireAfterSeconds :" + next.expireAfterSeconds  : "") + " })}catch(e){print(e)}")}}

// 数据量、存储使用量查询语句：

var collectionList = db.getCollectionNames()
for(var i in collectionList){
    var collection = collectionList[i];
    var collection_stats = db.getCollection(collection).stats()
    print(collection+"\t"+
        JSON.stringify(collection_stats.count)+"\t"+
        JSON.stringify(collection_stats.size/1024/1024)+"M"+"\t"+
        JSON.stringify(collection_stats.avgObjSize/1024/1024)+"M"+"\t"+
        JSON.stringify(collection_stats.storageSize/1024/1024)+"M"+"\t"+
        JSON.stringify(collection_stats.totalIndexSize/1024/1024))+"M"
}



// 索引清单导出语句

var collectionList = db.getCollectionNames()
for(var i in collectionList){
    var collection = collectionList[i];
    var indexes = db.getCollection(collection).getIndexes();

    //if(indexes.length == 1){continue;}

    for(var j in indexes){
        var idx = indexes[j]
        //if(idx.key["_id"] == '1'){continue;}
        if("expireAfterSeconds" in idx){
            print(collection+"\t"+JSON.stringify(idx.name)+"\t"+JSON.stringify(idx.key)+"\texpireAfterSeconds:" + idx.expireAfterSeconds)
        }else{
            print(collection+"\t"+JSON.stringify(idx.name)+"\t"+JSON.stringify(idx.key))
        }

    }
}

//获取当前库的所有索引
db.adminCommand("listDatabases").databases.forEach(function(d){
   let mdb = db.getSiblingDB(d.name);
   mdb.getCollectionInfos({ type: "collection" }).forEach(function(c){
      let currentCollection = mdb.getCollection(c.name);
      currentCollection.getIndexes().forEach(function(idx){
        print("Index: " + idx.name + " on " + d.name + "." + c.name);
          printjson(idx);

      });
   });
});

//获取所有的索引
db.getCollectionNames().forEach(function(collection) {
   indexes = db[collection].getIndexes();
   print("Indexes for " + collection + ":");
   printjson(indexes);
});

//按照类型获取索引  (hashed、text)
db.adminCommand("listDatabases").databases.forEach(function(d){
   let mdb = db.getSiblingDB(d.name);
   mdb.getCollectionInfos({ type: "collection" }).forEach(function(c){
      let currentCollection = mdb.getCollection(c.name);
      currentCollection.getIndexes().forEach(function(idx){
        let idxValues = Object.values(Object.assign({}, idx.key));

        if (idxValues.includes("text")) {
          print("Hashed index: " + idx.name + " on " + d.name + "." + c.name);
          printjson(idx);
        };
      });
   });
});

--批量获取库中的索引创建语句
var collectionList = db.getCollectionNames(); for(var index in collectionList){ var collection = collectionList[index]; var cur = db.getCollection(collection).getIndexes(); if(cur.length == 1){ continue; } for(var index1 in cur){ var next = cur[index1]; if(next["key"]["_id"] == '1'){ continue; }print("try{ db.getCollection(\""+collection+"\").ensureIndex("+JSON.stringify(next.key)+",{background:1, unique:" + (next.unique || false) + " })}catch(e){print(e)}");}}

//找出分片不一致的索引  
1、自定义聚合管道 (适用MongoDB 4.2.4 及更高版本)
const pipeline = [
    // Get indexes and the shards that they belong to.
    {$indexStats: {}},
    // Attach a list of all shards which reported indexes to each document from $indexStats.
    {$group: {_id: null, indexDoc: {$push: "$$ROOT"}, allShards: {$addToSet: "$shard"}}},
    // Unwind the generated array back into an array of index documents.
    {$unwind: "$indexDoc"},
    // Group by index name.
    {
        $group: {
            "_id": "$indexDoc.name",
            "shards": {$push: "$indexDoc.shard"},
            // Convert each index specification into an array of its properties
            // that can be compared using set operators.
            "specs": {$push: {$objectToArray: {$ifNull: ["$indexDoc.spec", {}]}}},
            "allShards": {$first: "$allShards"}
        }
    },
    // Compute which indexes are not present on all targeted shards and
    // which index specification properties aren''t the same across all shards.
    {
        $project: {
            missingFromShards: {$setDifference: ["$allShards", "$shards"]},
            inconsistentProperties: {
                 $setDifference: [
                     {$reduce: {
                         input: "$specs",
                         initialValue: {$arrayElemAt: ["$specs", 0]},
                         in: {$setUnion: ["$$value", "$$this"]}}},
                     {$reduce: {
                         input: "$specs",
                         initialValue: {$arrayElemAt: ["$specs", 0]},
                         in: {$setIntersection: ["$$value", "$$this"]}}}
                 ]
             }
        }
    },
    // Only return output that indicates an index was inconsistent, i.e. either a shard was missing
    // an index or a property on at least one shard was not the same on all others.
    {
        $match: {
            $expr:
                {$or: [
                    {$gt: [{$size: "$missingFromShards"}, 0]},
                    {$gt: [{$size: "$inconsistentProperties"}, 0]},
                ]
            }
        }
    },
    // Output relevant fields.
    {$project: {_id: 0, indexName: "$$ROOT._id", inconsistentProperties: 1, missingFromShards: 1}}
];

2、要测试分片集合test.reviews是否在其关联分片中具有不一致的索引：
db.getSiblingDB("test").reviews.aggregate(pipeline)

3、输出结果
{ "missingFromShards" : [ "shardB" ], "inconsistentProperties" : [ ], "indexName" : "page_1_score_1" }
{ "missingFromShards" : [ ], "inconsistentProperties" : [ { "k" : "expireAfterSeconds", "v" : 60 }, { "k" : "expireAfterSeconds", "v" : 600 } ], "indexName" : "reviewDt_1" }

返回的文档表明分片集合有两个不一致之处test.reviews：
1.上page_1_score_1的集合中缺少名为的索引shardB。
2.命名的索引reviewDt_1在集合的分片中具有不一致的属性，具体而言，expireAfterSeconds 属性不同。

//mongodb执行命令并对结果进行切分
[root@ssg3-db-mongodb-02 ~]# mongo  -u*** -p"***"--authenticationDatabase admin --eval "rs.printReplicationInfo()" |grep 'oplog first event' | cut -d' ' -f7,8,9,10,11,12 


for(var i=500000;i<600000;i++){ db.news.insert({"_id":i,"month":"6","username":Math.random(),"createdate":new Date()})}

//查询库中表的碎片率
function getCollectionDiskSpaceFragRatio(dbname, coll) {
var res = db.getSiblingDB(dbname).runCommand({
collStats: coll
});
var totalStorageUnusedSize = 0;
var totalStorageSize = res['storageSize'] + res['totalIndexSize'];
Object.keys(res.indexDetails).forEach(function(key) {
var size = res['indexDetails'][key]['block-manager']['file bytes
available for reuse'];
print("index table " + key + " unused size: " +
size); totalStorageUnusedSize += size;
});
var size = res['wiredTiger']['block-manager']['file bytes available for reuse'];
print("collection table " + coll + " unused size: " + size);
totalStorageUnusedSize += size;
print("collection and index table total unused size: " +
totalStorageUnusedSize);
print("collection and index table total file size: " + totalStorageSize);
print("Fragmentation ratio: " + ((totalStorageUnusedSize * 100.0) /
totalStorageSize).toFixed(2) + "%");
12}
use xxxdb
db.getCollectionNames().forEach((c) => {print("\n\n" +
c); getCollectionDiskSpaceFragRatio(db.getName(),
c);});

##分片中复制集密码重置
--由于管理密码忘记，导致不能登录复制集的primary及secondary成员。
1、在复制集的所有成员中注销掉以下配置（在此之前要先确定下，主服务器是谁）：
security:
    authorization: enabled
    keyFile: /usr/local/mongodb/key/mongdb-keyfile

2、重启复制集的所有成员，在主节点admin库的system.users中查看root角色的用户，进行密码重置。
use admin
db.runCommand({ 
    "updateUser" : "admin_shard", 
    "pwd" : "45678", 
    "customData" : {

    }, 
    "roles" : [
        {
            "role" : "root", 
            "db" : "admin"
        }
    ]
});

3、打开授权配置，重启所有成员，验证登录。

##分片集群中的数据迁移
在分片集群中，现有集群的collecion已经完成分片的，但是，当从这个集群迁移这个表，到其它集群时需要：
1、提前在目标集群上，建立空表，并把分片键指定好，然后，再导入数据的时候，才会自动给各个分片写数据。

##关于主库较大全量数据同步时oplog的设置问题
3.2版本开始全量开始，在主库同步全量数据到从库的同时，会同时拉取主库oplog放在local数据库里面，只要从库空间足够大。就可以存放。不依赖oplog大小。
当主库的全量数据与从库的全量初始化完成时，这时才会用到从库的oplog，来实时拉取主库的数据，进行实时的消费。