#!/bin/bash

# usage: generate_db_stats.sh host port username password martscript_table column ensembl_version database martscriptdbname outputtable

# database can be either 'core', 'otherfeatures', 'variation', 'funcgen', 'coreexpressionest', 'coreexpressiongnf', or 'vega'

exec 1>/dev/null
exec 2>/dev/null

. error_codes

column=$6
version=$7
dbtable=$8

# this might fail if the table exists already
echo -e "CREATE TABLE $9.${10} (taxonomy_id INT, gene_id INT, $6 BIGINT)" | mysql -h $1 -P $2 -u $3 --password=$4

# test query to see whether the table is in place
echo -e "SELECT * FROM $9.${10} LIMIT 0,1" | mysql -h $1 -P $2 -u $3 --password=$4

if [ $? -ne 0 ] ; then
        # infer that the create table must have failed, not because the table was already in place, but due to another reason
        exit $ERR_SQL_CREATE_TABLE
fi

# test-run
echo "SHOW DATABASES;" | mysql -h $1 -P $2 -u $3 --password=$4 | grep _core_$7_ > /dev/null

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

for db in `echo "SHOW DATABASES;" | mysql -h $1 -P $2 -u $3 --password=$4 | grep _core_$7_` ; do

	if [[ $dbtable == 'core' ]] ; then
		species=`echo $db | awk -F _ '{ print substr($0,1,match($0,"_core_")-1) }'`
	elif [[ $dbtable == 'otherfeatures' ]] ; then
		species=`echo $db | awk -F _ '{ print substr($0,1,match($0,"_otherfeatures_")-1) }'`
	elif [[ $dbtable == 'variation' ]] ; then
		species=`echo $db | awk -F _ '{ print substr($0,1,match($0,"_variation_")-1) }'`
	elif [[ $dbtable == 'funcgen' ]] ; then
		species=`echo $db | awk -F _ '{ print substr($0,1,match($0,"_funcgen_")-1) }'`
	elif [[ $dbtable == 'coreexpressionest' ]] ; then
		species=`echo $db | awk -F _ '{ print substr($0,1,match($0,"_coreexpressionest_")-1) }'`
	elif [[ $dbtable == 'coreexpressiongnf' ]] ; then
		species=`echo $db | awk -F _ '{ print substr($0,1,match($0,"_coreexpressiongnf_")-1) }'`
	elif [[ $dbtable == 'vega' ]] ; then
		species=`echo $db | awk -F _ '{ print substr($0,1,match($0,"_vega_")-1) }'`
	else
		exit $ERR_PARAM_NOT_SUPPORTED
	fi

	speciesname=`echo $species | sed s/_/\ / | awk -F' ' '{ print toupper(substr($1,1,1))substr($1,2,length($1)-1)" "toupper(substr($2,1,1))substr($2,2,length($2)-1) }'`

	if [ $? -ne 0 ] ; then
		exit $ERR_SHELL_CMD
	fi

	result_rows=`echo "INSERT INTO $9.${10} (taxonomy_id, gene_id, $6) SELECT taxonomy_id, gene_id, $6 FROM $db.mscript_$5;" | mysql -h $1 -P $2 -u $3 --password=$4 | tail -n 1`

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_SELECT
	fi

	# this was once in to deal with empty text fields that represented missing PMIDs of PMCIDs
	# however, the current implementation is more general and we can deal with the number discrepancy
	# at a later stage. funny data should NOT obscure the algorithm.
	#result_rows=`echo "SELECT DISTINCT $6 FROM $db.$5 WHERE NOT LENGTH($6)=0;" | mysql -h $1 -P $2 -u $3 --password=$4 | wc -l`

	# get rid of the extra line for the column titles
	#if [[ "$result_rows" -ge "1" ]] ; then
	#	let result_rows=result_rows-1
	#fi

	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_INSERT
	fi

done
