MongoDB的连接字符串
本文导读：MongoDB数据库与传统的关系型数据库相比，它具有操作简单、完全免费、源码公开等特点，这使MongoDB产品广泛应用于各种大型门户网站和专业网站。由于MongoDB连接并不支持HTTP协议，所有你不能直接通过浏览器访问MongoDB，下面详细介绍MongoDB中连接字符串的编写

一、MongoDB连接字符串常用格式

 

mongodb://[username:password@]host1[:port1][,host2[:port2],…[,hostN[:portN]]][/[database][?options]]

 

备注：字符串连接不区分大小写，并非所有MongoDB驱动都支持完整的连接字符串，不支持此格式连接字串的驱动会有替代连接方案，具体请参照驱动自身的说明文档，看看如何定义uri标准连接的。

 

1、参数说明

 

     mongodb:// 这是固定的格式，必须要指定。

? username:password@ 可选项，如果设置，在连接数据库服务器之后，驱动都会尝试登陆这个数据库? host1 必须的指定至少一个host

    host1 是这个URI唯一要填写的。它指定了要连接服务器的地址。如果要连接复制集，请指定多个主机地址。


? :portX 可选的指定端口，如果不填，默认为27017

? /database 如果指定username:password@，连接并验证登陆指定数据库。若不指定，默认打开admin数据库。


? ?options 是连接选项。如果不使用/database，则前面需要加上/。所有连接选项都是键值对name=value，键值对之间通过&或;（分号）隔开

 

2、options 是连接参数

 

connect=direct|replicaSet
direct: 连接方式为单个服务器。如果提供了多个主机地址，建立连接之后，按顺序访问。如果仅仅指定了一个主机，direct是默认值。
replicaSet: 就和描述的那样，连接到replica set . 这个主机地址列表，是为了发现replica set。如果连接多个主机replicaSet是默认值。
 

replicaSet=name
验证replica set的名称。 Impliesconnect=replicaSet.
 

slaveOk=true|false
true:在connect=direct模式下，驱动会连接第一台机器，即使这台服务器不是主。在connect=replicaSet模式下，驱动会发送所有的写请求到主并且把读取操作分布在其他从服务器。
false: 在 connect=direct模式下，驱动会自动找寻主服务器. 在connect=replicaSet 模式下，驱动仅仅连接主服务器，并且所有的读写命令都连接到主服务器。
 

safe=true|false
true: 在执行更新操作之后，驱动都会发送getLastError命令来确保更新成功。(还要参考wtimeoutMS).
false: 在每次更新之后，驱动不会发送getLastError来确保更新成功。
 

w=n
驱动添加 { w : n } 到getLastError命令. 应用于safe=true。
 

wtimeoutMS=ms
驱动添加 { wtimeout : ms } 到 getlasterror 命令. 应用于 safe=true.
 

fsync=true|false
true: 驱动添加 { fsync : true } 到 getlasterror 命令.应用于 safe=true.
false: 驱动不会添加到getLastError命令中。.
 

maxPoolSize=n
minPoolSize=n
一些驱动会把没用的连接关闭。 然而,如果连接数低于minPoolSize值之下， 它们不会关闭空闲的连接。注意的是连接会按照需要进行创建，因此当连接池被许多连接预填充的时候，minPoolSize不会生效。
 

waitQueueTimeoutMS=ms
在超时之前，线程等待连接生效的总时间。如果连接池到达最大并且所有的连接都在使用，这个参数就生效了。
 

waitQueueMultiple=n
驱动强行限制线程同时等待连接的个数。 这个限制了连接池的倍数。
 

connectTimeoutMS=ms
可以打开连接的时间。
 

socketTimeoutMS=ms
发送和接受sockets的时间
 

 

二、MongoDB的连接字符串实例

 

 1、连接本地数据库服务器，端口是默认的。

 mongodb://localhost

 

 2、使用用户名fred，密码foobar登录localhost的admin数据库。

mongodb://fred:foobar@localhost

 

3、使用用户名fred，密码foobar登录localhost的baz数据库

mongodb://fred:foobar@localhost/baz

 

4、连接 replica pair, 服务器1为example1.com服务器2为example2

mongodb://example1.com:27017,example2.com:27017

 

5、连接 replica set 三台服务器 (端口 27017, 27018, 和27019)

mongodb://localhost,localhost:27018,localhost:27019

 

6、连接 replica set 三台服务器, 写入操作应用在主服务器 并且分布查询到从服务器

mongodb://host1,host2,host3/?slaveOk=true

 

7、直接连接第一个服务器，无论是replica set一部分或者主服务器或者从服务器

mongodb://host1,host2,host3/?connect=direct;slaveOk=true

 

8、当你的连接服务器有优先级，还需要列出所有服务器，你可以使用上述连接方式

安全模式连接到localhost:

mongodb://localhost/?safe=true

 

9、以安全模式连接到replica set，并且等待至少两个复制服务器成功写入，超时时间设置为2秒

mongodb://host1,host2,host3/?safe=true;w=2;wtimeoutMS=2000