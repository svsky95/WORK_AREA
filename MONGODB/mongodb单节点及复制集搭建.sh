##centos7安装mongodb4.x (centos8无需此过程)
1、安装yum install gcc

2、下载glibc
http://mirrors.ustc.edu.cn/gnu/libc/
wget http://mirrors.ustc.edu.cn/gnu/libc/glibc-2.18.tar.gz
3、安装部署
解压
tar -zxvf  glibc-2.18.tar.gz

创建编译目录
cd glibc-2.18 
mkdir build

编译、安装
cd build/
../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin

make -j 8
make install


#参考mongodb搭建以管理完成系统优化
1.1 mongod创建用户账号
groupadd -g 400001363 mongod
useradd -u 200000173 -g mongod mongod
passwd mongod
密码：123456

1.2 程序包目录(把程序包，用mongod用户解压到此路径下)
mkdir -p  /usr/local/mongodb509
chown -R mongod:mongod /usr/local/mongodb509

1.3 目录分配
mkdir -p  /usr/local/mongodb
chown -R mongod:mongod /usr/local/mongodb

###单节点创建###
创建目录：
#mongod账户执行
mkdir -p /usr/local/mongodb/config
mkdir -p /usr/local/mongodb/data
mkdir -p /usr/local/mongodb/log

vim /usr/local/mongodb/config/mongod.conf 
#shard1 mongod.conf
systemLog:
   destination: file
   path: "/usr/local/mongodb/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/data"
processManagement:
   fork: true
   pidFilePath: /usr/local/mongodb/pid
net:
   bindIp: 192.168.2.118  ##绑定本机的物理网卡IP
   port: 27018
setParameter:
   enableLocalhostAuthBypass: false
#security:
#    authorization: enabled   

#启动服务
mongod --config /usr/local/mongodb/config/mongod.conf
#连接服务器，创建管理员账号
mongosh 192.168.2.121:27017
mongos> use admin // 切换到admin
mongos> db.createUser( { user: 'mongo_admin', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })

#开启认证
vim /usr/local/mongodb/config/mongod.conf 
取消注释：
security:
    authorization: enabled  

#重启mongod服务

#尝试连接：
mongosh MGR4:27017 -u mongo_admin -p '123456'  --authenticationDatabase admin

#创建普通读写用户
use cpcdata   //把用户放在admin数据库中
db.createUser({user:'cpcdbwr',pwd:'123456', roles:[{role:'readWrite', db:'cpcdata'}]})

###复制集搭建###
#####同一台主机搭建复制集
su - mongod
mkdir -p /usr/local/mongodb/config
mkdir -p /usr/local/mongodb/data
mkdir -p /usr/local/mongodb/log

vim /usr/local/mongodb/config/mongod.conf

systemLog:
   destination: file
   path: "/usr/local/mongodb/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/data"
processManagement:
   fork: true
   pidFilePath: /usr/local/mongodb/pid
net:
   bindIp: 192.168.2.121  ##绑定本机的物理网卡IP
   port: 27017
setParameter:
   enableLocalhostAuthBypass: false
#security:
#    authorization: enabled 
#    keyFile: /usr/local/mongodb/key/mongdb-keyfile
replication:
   replSetName: "rep_1"

--配置好一个节点，其它的节点拷贝文件夹，改下对应配置文件中的路径和端口和PID就可以
cp -r config config2
cp -r config config3
mkdir data2
mkdir data3
mkdir log2
mkdir log3

--启动复制集
mongod --config /usr/local/mongodb/config/mongod.conf
mongod --config /usr/local/mongodb/config2/mongod.conf
mongod --config /usr/local/mongodb/config3/mongod.conf

--无密码连接
mongosh MGR4:27017
--初始化配置
test> config = {
   _id : "rep_1",
    members : [
        {_id : 0, host : "MGR4:27017" },
        {_id : 1, host : "MGR4:27018" },
        {_id : 2, host : "MGR4:27019" }
    ]
}
rs.initiate(config);

--创建管理账号
admin> use admin // 切换到admin
admin> db.createUser( { user: 'mongo_admin', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })

--创建keyfile（复制集必须开始keyfile认证）
mkdir -p /usr/local/mongodb/key

-生成密码配置文件
openssl rand -base64 100 > /usr/local/mongodb/key/mongdb-keyfile
chmod 600 /usr/local/mongodb/key/mongdb-keyfile

#开启认证
vim /usr/local/mongodb/config/mongod.conf 
取消注释：
security:
    authorization: enabled  
	keyFile: /usr/local/mongodb/key/mongdb-keyfile
	
#创建普通读写用户
use cpcdata   //把用户放在admin数据库中
db.createUser({user:'cpcdbwr',pwd:'123456', roles:[{role:'readWrite', db:'cpcdata'}]})

#连接复制集
mongo MGR4:27018 -u mongo_admin -p '123456'  --authenticationDatabase admin


#####三台主机搭建复制集
MGR1 27017
MGR2 27017
MGR3 27017

--创建目录
su - mongod
mkdir -p /usr/local/mongodb/config
mkdir -p /usr/local/mongodb/data
mkdir -p /usr/local/mongodb/log

--配置文件
vim /usr/local/mongodb/config/mongod.conf

systemLog:
   destination: file
   path: "/usr/local/mongodb/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/data"
processManagement:
   fork: true
   pidFilePath: /usr/local/mongodb/pid
net:
   bindIp: 192.168.2.121  ##绑定本机的物理网卡IP
   port: 27017
setParameter:
   enableLocalhostAuthBypass: false
#security:
#    authorization: enabled 
#    keyFile: /usr/local/mongodb/key/mongdb-keyfile
replication:
   replSetName: "rep_1"

--拷贝文件夹到另外两台服务器
scp -r /usr/local/mongodb mongod@MGR1:/usr/local
scp -r /usr/local/mongodb mongod@MGR2:/usr/local
scp -r /usr/local/mongodb mongod@MGR3:/usr/local

--修改配置文件中的IP地址
--启动复制集
启动MGR1：
mongod --config /usr/local/mongodb/config/mongod.conf
启动MGR2：
mongod --config /usr/local/mongodb/config/mongod.conf
启动MGR3：
mongod --config /usr/local/mongodb/config/mongod.conf

--连接复制集，进行初始化
mongo 192.168.2.118:27018    // mongosh 192.168.2.118:27018 (mongodb6.0+)
config = {
   _id : "shard1",
    members : [
        {_id : 0, host : "192.168.2.118:27018" },
        {_id : 1, host : "192.168.2.119:27018" },
        {_id : 2, host : "192.168.2.120:27018" }
    ]
}
rs.initiate(config);

--创建管理账号
admin> use admin // 切换到admin
admin> db.createUser( { user: 'mongo_admin', pwd: '123456', roles: [ { role: 'root', db: 'admin' } ] })

--创建keyfile（复制集必须开始keyfile认证）
mkdir -p /usr/local/mongodb/key

-生成密码配置文件
openssl rand -base64 100 > /usr/local/mongodb/key/mongdb-keyfile
chmod 600 /usr/local/mongodb/key/mongdb-keyfile

#开启认证
vim /usr/local/mongodb/config/mongod.conf 
取消注释：
security:
    authorization: enabled  
	keyFile: /usr/local/mongodb/key/mongdb-keyfile
	
#创建普通读写用户
use cpcdata   //把用户放在admin数据库中
db.createUser({user:'cpcdbwr',pwd:'123456', roles:[{role:'readWrite', db:'cpcdata'}]})