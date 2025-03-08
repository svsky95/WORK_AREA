--查看对象的使用
select /*+ rule*/  SID from V$ACCESS WHERE object='F_FXPT_YHS_JYDX_MXSJ';

--查看对象的使用SID
SELECT 'alter system kill session '''||SID||','||SERIAL#||''';' FROM V$SESSION WHERE SID IN (select /*+ rule*/  SID from V$ACCESS WHERE object='F_FXPT_YHS_JYDX_MXSJ');  --存储过程名