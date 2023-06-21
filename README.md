# Create Oracle stored procedure to archive historical data

This is an Oracle stored procedure that archives data from an interval partitioned table (source) into another interval partitioned table (archive).  

Interval partitioning can simplify the manageability by automatically creating the new partitions as needed by the data.  Interval partitioning is enabled in the table's definition by defining one or more range partitions and including a specified interval.  The data type that will be partitioned is a date column.  The code below leverages interval partitions based on the month.  When a new month is inserted, a new partition will automatically be created to hold the data.  

Most customers would like to leverage interval partitions in the archived table.  This requires moving data from a source table (partitioned) into an interim table (non-partitioned) and then from interim table into the archived table (partitioned).  This dynamic stored procedure performs this task. 

### Prerequisites

A sample data set was leveraged for this example.  This data set is provided with AWS Simple Database Archival Solution (SDAS).  This data set contains approximately 10 GB of data. Table row counts range from a few records to more than 55 million records. Several indexes exist that are larger than 1.5 GB. The data set can be found at https://github.com/aws-samples/aws-database-migration-samples.  The table used to test the stored procedure is 'SPORTING_EVENT'.


Two database objects are required to log actions from the stored procedure.  Feel free to change the schema name from DMS_SAMPLE to the schema name of your choice.  The DDL is as follows:

```
create sequence dms_sample.order_seq increment by 1 start with 1;
```

```
create table dms_sample.result_table (
     order_id number(38), 
     table_owner varchar2(50), 
     table_name varchar2(50), 
     ddl_string varchar2(2000), 
     ddl_time date);
```

## Input parameters

Five parameters are provided as input and the stored procedure handles data movement. The parameters are as follows:

  Table owner - Schema owner
  Table name - Source table
  Staging table name - Temporary table to hold the archived data
  Archive table name - Table to hold the historical data
  Days back to archive - Determines which partitions to archive based on number of days back (i.e., 365 means data older than one year is archived)

## Usage

The following line is an example to call the stored procedure (and don't forget to commit when done).

```
execute dms_sample.archive_data('DMS_SAMPLE', 'SPORTING_EVENT_PAR', 'SPORTING_EVENT_STAGING', 'SPORTING_EVENT_ARCHIVE', 365);
```


## License
Copyright 2023 Amazon.com, Inc. or its affiliates. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
