# Create Oracle stored procedure to archive historical data

This is an Oracle stored procedure written in PL/SQL that archives data from an interval partitioned table (based on the month) into
another interval partitioned table.  

Most customers would like to leverage interval partitions in the archived table.  This requires moving data from source table (partitioned) 
table into an interim (non-partitioned) table and then from interim table into the archived (partitioned) table.  A dynamic stored procedure 
can be downloaded that performs this task.  Five parameters are provided as input and the stored procedure handles data movement.  



