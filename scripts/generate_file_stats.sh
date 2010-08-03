#!/bin/bash

# Usage: generate_file_stats.sh host port username password martdatabase destinationtable tsv_file column_no

exec 1>/dev/null
exec 2>/dev/null

. error_codes

tsv_file=$7
filename=`basename $tsv_file`
columns=`head $tsv_file | grep -v ^# | head -n 1 | awk -F'\t' '{ print NF }'`
column_no=$8

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

# this might fail if the table exists already
echo -e "CREATE TABLE $5.$6 (species VARCHAR(500),distinct_rows BIGINT,origin TEXT)" | mysql -h $1 -P $2 -u $3 --password=$4

# test query to see whether the table is in place
echo -e "SELECT * FROM $5.$6 LIMIT 0,1" | mysql -h $1 -P $2 -u $3 --password=$4

if [ $? -ne 0 ] ; then
	# infer that the create table must have failed, not because the table was already in place, but due to another reason
	exit $ERR_SQL_CREATE_TABLE
fi

unique_entries=`grep -v ^# $tsv_file | cut -f $column_no | sort | uniq | wc -l`

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

filename=`basename $tsv_file`

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

echo -e "INSERT INTO $5.$6 VALUES ('$filename',$unique_entries,'column $column_no of file $filename')" | mysql -h $1 -P $2 -u $3 --password=$4

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_INSERT
fi

