#!/bin/bash

# link_gene_data_all_species.sh username password host port martdbname tblname targetdb version namedmppath

. error_codes

echo "SHOW DATABASES;" | mysql -h $3 -P $4 -u $1 --password=$2 | grep _$7_$8 | awk -F'_' '{ print $1"_"$2 }' > /dev/null

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

for species in `echo "SHOW DATABASES;" | mysql -h $3 -P $4 -u $1 --password=$2 | grep _$7_$8 | awk -F'_' '{ print $1"_"$2 }'` ; do

	./link_gene_data.sh $1 $2 $3 $4 $5 $6 $species $7 $8 $9

	if [ $? -ne 0 ] ; then
	        # return the error code from link_gene.sh
	        exit $?
	fi

done

