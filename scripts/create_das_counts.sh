#!/bin/bash

# usage: create_das_counts.sh host port username password martdb

host=$1
port=$2
user=$3
pass=$4
mart=$5

for table in `echo "use $mart; show tables;" | mysql -h $host -P $port -u $user --password=$pass | grep -v _flat__dm | grep -v _count__dm | grep __mscript` ; do

        echo $table

        for column in `echo "show create table $mart.$table;" | mysql -h $host -P $port -u $user --password=$pass | awk '{ split($0, chunks, " "); for (x in chunks) { print $x } }' | grep pmid | sed s/\\\`//g` ; do

                echo " -> $column"
		newtable=`echo "$table" | sed s/__dm/_count__dm/g`
		echo " -> $newtable"
		echo "DROP TABLE IF EXISTS $mart.$newtable" | mysql -h $host -P $port -u $user --password=$pass
                echo "CREATE TABLE $mart.$newtable SELECT gene_id_1020_key, COUNT(DISTINCT $column) as $column FROM $mart.$table GROUP BY gene_id_1020_key" | mysql -h $host -P $port -u $user --password=$pass
		echo "CREATE INDEX gene_id_1020_key_index ON $mart.$newtable (gene_id_1020_key)" | mysql -h $host -P $port -u $user --password=$pass
        done

done

