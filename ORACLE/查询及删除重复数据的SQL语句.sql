--��ѯ��ɾ���ظ����ݵ�SQL���
 
1�����ұ��ж�����ظ���¼���ظ���¼�Ǹ��ݵ����ֶΣ�Id�����ж�
 
select * from �� where Id in (select Id from �� group byId having count(Id) > 1)
 
2��ɾ�����ж�����ظ���¼���ظ���¼�Ǹ��ݵ����ֶΣ�Id�����жϣ�ֻ����rowid��С�ļ�¼
 
DELETE from �� WHERE (id) IN ( SELECT id FROM �� GROUP BY id HAVING COUNT(id) > 1) AND ROWID NOT IN (SELECT MIN(ROWID) FROM �� GROUP BY id HAVING COUNT(*) > 1);
 
3�����ұ��ж�����ظ���¼������ֶΣ�
 
select * from �� a where (a.Id,a.seq) in(select Id,seq from �� group by Id,seq having count(*) > 1)
 
4��ɾ�����ж�����ظ���¼������ֶΣ���ֻ����rowid��С�ļ�¼
 
delete from �� a where (a.Id,a.seq) in (select Id,seq from �� group by Id,seq having count(*) > 1) and rowid not in (select min(rowid) from �� group by Id,seq having count(*)>1)
 
5�����ұ��ж�����ظ���¼������ֶΣ���������rowid��С�ļ�¼
 
select * from �� a where (a.Id,a.seq) in (select Id,seq from �� group by Id,seq having count(*) > 1) and rowid not in (select min(rowid) from �� group by Id,seq having count(*)>1)