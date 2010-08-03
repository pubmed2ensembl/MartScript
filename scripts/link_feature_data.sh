#!/bin/bash

# link_feature_data.sh username password host port dbname tblname species_name targettbl version namedmppath featuretable

exec 1>/dev/null
exec 2>/dev/null

. error_codes

dbprefix="mscript"

speciesid=`./findspeciesid.sh ${10} $7`

if [ $? -ne 0 ] ; then
	# return the error code determined by findspeciesid.sh
	exit $?
fi

featureshort=`echo "${11}" | awk -F_ '{ print substr($1,1,3) "_" substr($2,1,3) }'`

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

# test-run
echo -e "SHOW DATABASES;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep ^$7_$8_$9 > /dev/null

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

for targetdb in `echo -e "SHOW DATABASES;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep ^$7_$8_$9` ; do

	# next line should be revised..
	echo -e "DROP TABLE $targetdb.${dbprefix}_${featureshort}_$6;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	echo -e "CREATE TABLE $targetdb.${dbprefix}_${featureshort}_$6 SELECT DISTINCT $targetdb.${11}.${11}_id,$5.$6.* FROM $targetdb.${11},$targetdb.xref,$targetdb.object_xref,$5.$6 WHERE $5.$6.taxonomy_id=$speciesid AND $targetdb.xref.dbprimary_acc=$5.$6.dbprimary_acc AND $targetdb.xref.xref_id=$targetdb.object_xref.xref_id AND $targetdb.object_xref.ensembl_id=$targetdb.${11}.${11}_id;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_TABLE
	fi

	echo -e "CREATE INDEX ${11}_id_index ON $targetdb.${dbprefix}_${featureshort}_$6 (${11}_id);\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_INDEX
	fi

	echo -e "CREATE INDEX dbprimary_acc_index ON $targetdb.${dbprefix}_${featureshort}_$6 (dbprimary_acc(20));\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_INDEX
	fi

done

