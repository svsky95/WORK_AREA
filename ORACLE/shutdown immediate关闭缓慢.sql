--SQL��ѯ���ݿ⵱ǰ�����Ƿ���ڳ��Ự����
SELECT 'alter system kill session '''||t."SID"||'.'||t."SERIAL#"||''';' killcommond,t."SQL_ID",t."USERNAME" from v$session_longops t  where time_remaining>0;

--SQL��ѯ���ݿ��д�ʱ�Ƿ���ڴ��������
SELECT 'alter system kill session '''||s."SID"||'.'||s."SERIAL#"||''';' killcommond,s."SQL_ID",s."OSUSER",s."MACHINE" FROM v$transaction t ,v$session s WHERE t."ADDR"=s."TADDR" ;

shutdown immediate
�ر����ݿ�ֻ��Ҫ�����ݿ���ǿ��ѡ����㲢�ر��ļ�������Ҫ�ȴ���ǰ���ﴦ�����������Ҫ�ȴ���ǰ�Ự�����������������ӡ�

����shutdown immediate slowly and hanging��ԭ��

>>>>
processes still continue to beconnected to the database and do not terminate
>>>>
������ݿ��ڹرյ�ʱ���н��̳����������ݣ����Ҳ��ܱ��жϣ��ͻ����shutdown immediate slowly����hanging

>>>>
SMON is cleaning temp segments orperforming delayed block cleanouts
>>>>
Temp segment cleanup: �����ݿ�������д�����sql�����������pga�з����sort_area_size̫С�����������������Ҫʱ�򣬾ͻ�ռ����ʱ�ν���������Щ�������ʱ�η�����һ�����䣬ֱ�����ݿ�shutdown?��ʱ��Ż��ͷš����Ե����ڽ������ݿ�ر�ʱ���д�������ʱ������������Ҫ���̱��ͷţ��������row cache?����Դ�������Ӷ��������ݿ�shutdownimmediate��������hanging��

>>>>
Uncommitted transactions are beingrolled back
>>>>
�����ݿ���Ҫ��һ���Թر����ݿ�ʱ������˿����ݿ������ô������еĴ������ʱ�����ݿ���Ҫ�Դ�������лع����벻Ҫ���֮ǰ�ᵽ��֪ʶ�㣬֮ǰ�ᵽshutdown immediate ����Ҫ�ȴ�������ָ��Ҫ�ȴ��������ύ����������Ҫ�Դ˿�����δ�ύ��������лع�������Ϊ������Ļع���Ҫ�ܳ���ʱ�䣬���Ծͻ���ִ��shutdownimmediateʱ�о�solwly����hanging����Ȼ��������Ļع������ǿ���ͨ���������ز������ӿ�ع����������⿼�ǵ����ٵĻع����û�������Դ�������������ܻ�Ӿ�shutdown immediate�������е�����������⣩

>>>>
Oracle Bug
>>>>

Oracle BUG oracle��ĳЩBUGҲ�ᵼ��shutdownimmedaite����

����������mos��������BUG֤��BUGҲ�ᵼ��shutdown immediate
Bug 6512622 - SHUTDOWN IMMEDIATE hangs / OERI[3708] (�ĵ� ID 6512622.8)
Bug 5057695: Shutdown Immediate Very Slow To CloseDatabase (�ĵ� ID 428688.1)
Bug 23309880 - SHUTDOWN IMMEDIATE may hang on primarydatabase if DG broker is configured (�ĵ� ID 23309880.8)

