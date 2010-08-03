#!/bin/bash

# link_gene_data.sh username password host port martdbname tblname species_name targetdb version namedmppath

exec 1>/dev/null
exec 2>/dev/null

. error_codes

dbprefix="mscript"

speciesid=`./findspeciesid.sh ${10} $7`

if [ $? -ne 0 ] ; then
	# return the error code from findspeciesid.sh
	exit $?
fi

stableid=`echo -e "SHOW COLUMNS FROM $5.$6;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep stable_id | awk -F' ' '{ print $1 }'`

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

# a stable_id column has precedence over dbprimary_acc, since the stable_id is directly linked to genes
if [[ $stableid != 'stable_id' ]] ; then

	dbprimaryacc=`echo -e "SHOW COLUMNS FROM $5.$6;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep dbprimary_acc | awk -F' ' '{ print $1 }'`

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_SHOW
	fi

	# at least one of the columns is needed in order to map the data
	if [[ $dbprimaryacc != 'dbprimary_acc' ]] ; then
		exit $ERR_SQL_CORRUPT_TABLE
	fi
fi

# test-run
echo -e "SHOW DATABASES;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep ^$7_$8_$9 > /dev/null

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

for targetdb in `echo -e "SHOW DATABASES;\n" | mysql -h $3 -P $4 -u $1 --password=$2 | grep ^$7_$8_$9` ; do

	echo -e "DROP TABLE IF EXISTS $targetdb.${dbprefix}_$6;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	# map Entrez Gene IDs
	if [[ $dbprimaryacc == 'dbprimary_acc' ]] ; then
		# at least up to ensembl 55, all entrez genes are mapped to translations
		echo -e "CREATE TABLE $targetdb.${dbprefix}_$6 SELECT DISTINCT $targetdb.transcript.gene_id,$5.$6.* FROM $targetdb.xref,$targetdb.object_xref,$targetdb.translation,$targetdb.transcript,$5.$6 WHERE $5.$6.taxonomy_id=$speciesid AND $targetdb.xref.external_db_id=1300 AND $targetdb.object_xref.ensembl_object_type='Translation' AND $targetdb.xref.xref_id=$targetdb.object_xref.xref_id AND $targetdb.xref.dbprimary_acc=$5.$6.dbprimary_acc AND $targetdb.translation.translation_id=$targetdb.object_xref.ensembl_id AND $targetdb.transcript.transcript_id=$targetdb.translation.transcript_id;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

		if [ $? -ne 0 ] ; then
			exit $ERR_SQL_CREATE_TABLE
		fi

		echo -e "CREATE INDEX dbprimary_acc_index ON $targetdb.${dbprefix}_$6 (dbprimary_acc(20));\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

		if [ $? -ne 0 ] ; then
			exit $ERR_SQL_CREATE_INDEX
		fi
	fi

	# use Ensembl Gene IDs
	if [[ $stableid == 'stable_id' ]] ; then
		echo -e "CREATE TABLE $targetdb.${dbprefix}_$6 SELECT DISTINCT $targetdb.gene_stable_id.gene_id,$5.$6.* FROM $targetdb.gene_stable_id,$5.$6 WHERE $targetdb.gene_stable_id.stable_id = $5.$6.stable_id;\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

		if [ $? -ne 0 ] ; then
			exit $ERR_SQL_CREATE_TABLE
		fi

		echo -e "CREATE INDEX stable_id_index ON $targetdb.${dbprefix}_$6 (stable_id(20));\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

		if [ $? -ne 0 ] ; then
			exit $ERR_SQL_CREATE_INDEX
		fi
	fi

	echo -e "CREATE INDEX gene_id_index ON $targetdb.${dbprefix}_$6 (gene_id);\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_INDEX
	fi

done

