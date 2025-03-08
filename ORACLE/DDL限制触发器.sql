###ͨ��������ʵ�� DDL ���###
���´�����ʵ�ֶ����ض���� DROP�� TRUNCATE ������

--���������

CREATE OR REPLACE TRIGGER trg_dtdeny
  BEFORE DROP OR TRUNCATE ON DATABASE
BEGIN
  IF LOWER(ora_dict_obj_name()) = 'test' THEN
    raise_application_error(num => -20000,
                            msg => 'You Can not Drop/Truncate Table ' ||
                                   ora_dict_obj_name() ||
                                   ' Pls check you plan.');
  END IF;
END;
/

--��������
create or replace trigger ddl_deny
  before create or alter or drop or truncate on database declare128 l_errmsg varchar2(100) := 'You have no permission to this operation';
begin
  if ora_sysevent = 'CREATE' then
    raise_application_error(-20001,
                            ora_dict_obj_owner || '.' || ora_dict_obj_name || ' ' ||
                            l_errmsg);
  elsif ora_sysevent = 'ALTER' then
    raise_application_error(-20001,
                            ora_dict_obj_owner || '.' || ora_dict_obj_name || ' ' ||
                            l_errmsg);
  elsif ora_sysevent = 'DROP' then
    raise_application_error(-20001,
                            ora_dict_obj_owner || '.' || ora_dict_obj_name || ' ' ||
                            l_errmsg);
  elsif ora_sysevent = 'TRUNCATE' then
    raise_application_error(-20001,
                            ora_dict_obj_owner || '.' || ora_dict_obj_name || ' ' ||
                            l_errmsg);
  end if;
exception
  when no_data_found then
    null;
end;
/

3������ָ�� trigger
 
alter trigger trigger_name disable;

4������ָ�� trigger

alter trigger trigger_name enable;