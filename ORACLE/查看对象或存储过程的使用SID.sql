--�鿴�����ʹ��
select /*+ rule*/  SID from V$ACCESS WHERE object='F_FXPT_YHS_JYDX_MXSJ';

--�鿴�����ʹ��SID
SELECT 'alter system kill session '''||SID||','||SERIAL#||''';' FROM V$SESSION WHERE SID IN (select /*+ rule*/  SID from V$ACCESS WHERE object='F_FXPT_YHS_JYDX_MXSJ');  --�洢������