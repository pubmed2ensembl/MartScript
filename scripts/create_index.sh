#!/bin/bash

# usage: create_index.sh host port username password martdb

host=$1
port=$2
user=$3
pass=$4
mart=$5

for table in `echo "use $mart; show tables;" | mysql -h $host -P $port -u $user --password=$pass | grep __mscript` ; do

	echo $table

	for column in `echo "show create table $mart.$table;" | mysql -h $host -P $port -u $user --password=$pass | awk '{ split($0, chunks, " "); for (x in chunks) { print $x } }' | awk '/[[:alpha:]]{2,}_[[:digit:]]+.$/ { print $0 }' | cut -d \\\` -f 2` ; do
	
		echo "    $column"
		echo "CREATE INDEX ${column}_index ON $mart.$table ($column(20));" | mysql -h $host -P $port -u $user --password=$pass

	done

done

