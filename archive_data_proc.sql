create or replace procedure dms_sample.archive_data (
 in_table_owner in        varchar2,
 in_table_name in         varchar2,
 in_stage_table_name in   varchar2,
 in_archive_table_name in varchar2,
 in_days_back in          number
) is
  l_ddl                   varchar2(4000);
begin
    for i in (
      select table_owner, table_name, partition_name,
           to_date (
              trim (
                 '''' from regexp_substr (
                              extractvalue (
                              dbms_xmlgen.
                              getxmltype (
                                    'select high_value from all_tab_partitions where table_name='''
                                    || table_name
                                    || ''' and table_owner = '''
                                    || table_owner
                                    || ''' and partition_name = '''
                                    || partition_name
                                    || ''''),
                                 '//text()'),
                              '''.*?''')),
              'syyyy-mm-dd hh24:mi:ss') high_value
      from all_tab_partitions
      where table_name = in_table_name
      and table_owner = in_table_owner
      and to_date (
              trim (
                 '''' from regexp_substr (
                              extractvalue (
                              dbms_xmlgen.
                              getxmltype (
                                    'select high_value from all_tab_partitions where table_name='''
                                    || table_name
                                    || ''' and table_owner = '''
                                    || table_owner
                                    || ''' and partition_name = '''
                                    || partition_name
                                    || ''''),
                                 '//text()'),
                              '''.*?''')),
              'syyyy-mm-dd hh24:mi:ss') < sysdate - in_days_back)
    loop
        begin
              -- Truncate data from the staging table to start the process
              l_ddl := 'truncate table ' || i.table_owner || '.' || in_stage_table_name ;
              insert into dms_sample.result_table values (order_seq.nextval, in_table_owner,  in_table_name, l_ddl, sysdate);
              execute immediate l_ddl;

              -- Place the source archived partitioned data into the staging table
              l_ddl := 'alter table ' || i.table_owner || '.' || i.table_name || ' exchange partition ' || i.partition_name|| ' with table '  || i.table_owner || '.' || in_stage_table_name  || ' including indexes';
              insert into dms_sample.result_table values (order_seq.nextval, in_table_owner,  in_table_name, l_ddl, sysdate);
              execute immediate l_ddl;

              -- Place the staging table into the archived partitioned table
              l_ddl := 'insert into ' || i.table_owner || '.' ||  in_archive_table_name || ' select * from  ' || i.table_owner || '.' || in_stage_table_name ;
              insert into dms_sample.result_table values (order_seq.nextval, in_table_owner,  in_table_name, l_ddl, sysdate);
              execute immediate l_ddl;
exception
           when others then
              l_ddl := 'Cannot determine correct partition name for table ' || i.table_owner || '.' || i.table_name || ' partition ' || i.partition_name||' high='||i.high_value; 
              insert into dms_sample.result_table values (order_seq.nextval, in_table_owner,  in_table_name, l_ddl, sysdate);
      end;
   end loop;
   -- Truncate data from the staging table to complete the process
   l_ddl := 'truncate table ' || in_table_owner || '.' || in_stage_table_name ;
   insert into dms_sample.result_table values (order_seq.nextval, in_table_owner,  in_table_name, l_ddl, sysdate);
   execute immediate l_ddl;
end;
/
