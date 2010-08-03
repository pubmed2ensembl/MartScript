#!/bin/bash

# link_transcript_data.sh username password host port dbname tblname species_name targettbl version namedmppath

exec 1>/dev/null
exec 2>/dev/null

. error_codes

dbprefix="mscript"

speciesid=`./findspeciesid.sh ${10} $7`

if [ $? -ne 0 ] ; then
	# report problem from findspeciesid.sh
	exit $?
fi

# test-run
echo -e "SHOW DATABASES;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep ^$7_$8_$9 > /dev/null

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

for targetdb in `echo -e "SHOW DATABASES;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep ^$7_$8_$9` ; do

	# next line might fail if the table did not exist already
	echo -e "DROP TABLE $targetdb.${dbprefix}_$6;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	echo -e "CREATE TABLE $targetdb.${dbprefix}_$6 SELECT DISTINCT $targetdb.transcript_stable_id.transcript_id,$5.$6.* FROM $targetdb.transcript_stable_id,$5.$6 WHERE $5.$6.taxonomy_id=$speciesid AND $targetdb.transcript_stable_id.stable_id=$5.$6.stable_id;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_TABLE
	fi

	echo -e "CREATE INDEX transcript_id_index ON $targetdb.${dbprefix}_$6 (transcript_id);\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_INDEX
	fi

	echo -e "CREATE INDEX dbprimary_acc_index ON $targetdb.${dbprefix}_$6 (dbprimary_acc(20));\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_INDEX
	fi

done

