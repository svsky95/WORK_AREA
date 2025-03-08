--GG-director用户密码过期导致无法登录
GG-director默认会在所在的oracle数据库中创建一些账户表及配置信息。
--在此路径下，有一个配置文件，其中记录了连接数据库的明文用户名及密码
more /home/oracle/GG_Directorgg-director/cds_current_db_config.xml

# The URL that the driver class recognizes

jdbc.url=jdbc:oracle:thin:@oggdb:1521:oggdb


# The username to log into the db with.

jdbc.username=oggdirector

# the password to log into the db with

jdbc.password=foresee2017

可以重新再数据库中修改密码，就可正常登录了。
