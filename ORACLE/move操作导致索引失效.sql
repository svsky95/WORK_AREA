--�Ա����ѹ�� ѹ����50%
ALTER TABLE CZ_TEST MOVE;

--����ʧЧ�������ؽ�  online-�ؽ�����Ӱ��������ҵ��
ALTER INDEX idx_object_id_cz REBUILD ONLINE NOLOGGING PARALLEL 8;

--ȡ����������
ALTER INDEX idx_object_id_cz NOPARALLEL;

