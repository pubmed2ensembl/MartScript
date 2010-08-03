#!/bin/bash

# copy_data.sh username password host port dbname tblname species_name targettbl version namedmppath

exec 1>/dev/null
exec 2>/dev/null

. error_codes

dbprefix="mscript"

speciesid=`./findspeciesid.sh ${10} $7`

if [ $? -ne 0 ] ; then
	# findspeciesid.sh returns a proper description of what went wrong already
	exit $?
fi

# test run
echo -e "SHOW DATABASES;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep ^$7_$8_$9 > /dev/null

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

for targetdb in `echo -e "SHOW DATABASES;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep ^$7_$8_$9` ; do

	# drop table might fail if we have not added anything to the database beforehand..
	echo -e "DROP TABLE $targetdb.${dbprefix}_$6;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	echo -e "CREATE TABLE $targetdb.${dbprefix}_$6 SELECT * FROM $5.$6 WHERE $5.$6.taxonomy_id=$speciesid;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_TABLE
	fi

done

