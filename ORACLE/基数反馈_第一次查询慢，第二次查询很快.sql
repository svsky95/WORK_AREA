##��������##  cardinality feedback used for this statement
--cardianality feedback
 ������һ��ִ�е�ʱ���Ż������ɳ�ʼ��ִ�мƻ���
     �Ż�������������»������ִ��ʱ��ͳ����Ϣ��
     1.����û��ͳ����Ϣ����̬������Ȼ�򿪵���ͳ����ϢҲ��׼ȷ����
     2.����ϲ���ֿ���ν��������
     3.ν�ʰ������ӵĲ����������Ż���û������ѡ���ԡ�
     �����ִ�еĺ��ڣ��Ż�����ÿ�������Ƚϳ�ʼ�Ļ��������ͷ��ص�����������������Ļ�����ʵ�ʵ�������ȥ��Զ���Ż������洢��ȷ�Ļ�����������ִ��ʹ�á�
     ����ѯ�ڶ���ִ�е�ʱ���Ż�����ʹ��֮ǰ�洢�Ļ���ȥ���ɸ�׼ȷ��ִ�мƻ���
     
11.2�е������ԣ������ԣ�ֻ���ͳ����Ϣ�¾ɡ���ֱ��ͼ����Ȼ��ֱ��ͼ���Ի������㲻׼ȷ�������
cardianality�����ļ���ֱ��Ӱ�쵽join cost�ȵļ�����ɱ������CBOѡ�񲻵���
���͵ľ����ڲ����������ܵ�ʱ�򣬵�һ�ο죬�ڶ��ξͺ�����

acs(adaptive_cursor_sharing) ����Ӧ�α����ԣ����bind peeking�������������Ͻ����������⡣����Ҳ������������Ϊacs���Ա���Ҳ��ȷ�����Ӷ����Ӳ�������һᵼ��child cursor���࣬�Ӷ������ɨ��chain��ʱ��䳤��ͬʱ��shared pool�ռ�����Ҳ���ӣ�������bug�϶࣬��ʹOracleĬ��Ҳ�ǿ���������Եģ��ܶ�ͻ���������Ҳ�ǽ���رյġ�


##�������飬�ر�����Ӧ�α�ͻ�������
alter system set "_optimizer_use_feedback" = false scope = both;
alter system set "_optimizer_adaptive_cursor_sharing" = false scope = both;


##������������##
QL> alter system flush shared_pool;

System altered

SQL> alter system flush buffer_cache;

System altered
                 
                 
                 
                 
                 
                 




