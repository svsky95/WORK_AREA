--oracle �������
#��ѯ�����ļ�
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

- �������������������˺Ž�������
DEFAULT                        FAILED_LOGIN_ATTEMPTS            PASSWORD 10
- ������Ч��(�죩
DEFAULT                        PASSWORD_LIFE_TIME               PASSWORD 200
- ���벻�������õ�����
DEFAULT                        PASSWORD_REUSE_TIME              PASSWORD UNLIMITED
- ��������֮ǰ�޸ĵ����ٴ���
DEFAULT                        PASSWORD_REUSE_MAX               PASSWORD UNLIMITED
- ������1����ʺ��Զ�����
DEFAULT                        PASSWORD_VERIFY_FUNCTION         PASSWORD NULL
- ������1����ʺ��Զ�����
DEFAULT                        PASSWORD_LOCK_TIME               PASSWORD 1
- ���뵽����ǰ7����ʾ 
DEFAULT                        PASSWORD_GRACE_TIME              PASSWORD 7

#�޸Ĳ���
alter profile DEFAULT limit PASSWORD_LIFE_TIME 200; 

#�޸ĵ�¼ʧ�ܴ���������
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED; 

#�޸������ò�����
alter profile DEFAULT limit PASSWORD_LIFE_TIME UNLIMITED;