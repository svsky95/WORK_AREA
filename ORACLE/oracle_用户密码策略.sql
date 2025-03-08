--oracle 密码策略
#查询配置文件
SQL> select * from dba_profiles;

PROFILE                        RESOURCE_NAME                    RESOURCE LIMIT
------------------------------ -------------------------------- -------- ----------------------------------------
DEFAULT                        COMPOSITE_LIMIT                  KERNEL   UNLIMITED
DEFAULT                        SESSIONS_PER_USER                KERNEL   UNLIMITED
DEFAULT                        CPU_PER_SESSION                  KERNEL   UNLIMITED
DEFAULT                        CPU_PER_CALL                     KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_SESSION        KERNEL   UNLIMITED
DEFAULT                        LOGICAL_READS_PER_CALL           KERNEL   UNLIMITED
DEFAULT                        IDLE_TIME                        KERNEL   UNLIMITED
DEFAULT                        CONNECT_TIME                     KERNEL   UNLIMITED
DEFAULT                        PRIVATE_SGA                      KERNEL   UNLIMITED

- 密码出错次数（超过后账号将锁定）
DEFAULT                        FAILED_LOGIN_ATTEMPTS            PASSWORD 10
- 密码有效期(天）
DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD 200
- 密码不能重新用的天数
DEFAULT                        PASSWORD_REUSE_TIME              PASSWORD UNLIMITED
- 密码重用之前修改的最少次数
DEFAULT                        PASSWORD_REUSE_MAX               PASSWORD UNLIMITED
- 超过了1天后，帐号自动解锁
DEFAULT                        PASSWORD_VERIFY_FUNCTION         PASSWORD NULL
- 超过了1天后，帐号自动解锁
DEFAULT                        PASSWORD_LOCK_TIME               PASSWORD 1
- 密码到期提前7天提示 
DEFAULT                        PASSWORD_GRACE_TIME              PASSWORD 7

#修改策略
alter profile DEFAULT limit PASSWORD_LIFE_TIME 200; 

#修改登录失败次数不限制
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED; 

#修改密码用不过期
alter profile DEFAULT limit PASSWORD_LIFE_TIME UNLIMITED;