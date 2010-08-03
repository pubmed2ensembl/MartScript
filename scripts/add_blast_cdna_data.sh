#!/bin/bash

# add_blast_cdna_data.sh username password host port dbname tblname perl_interpreter shell_script_dir blast_output_directory

exec 1>/dev/null
exec 2>/dev/null

. error_codes

tmpdir=`date "+%Y%m%d_%H%M%S_import"`

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

# CREATE DATABASE might fail because the database already exists
echo -e "CREATE DATABASE $5;\n" | mysql -h $3 -P $4 -u $1 --password=$2
# DROP TABLE might fail because the table might not exist
echo -e "DROP TABLE $5.$6;\n" | mysql -h $3 -P $4 -u $1 --password=$2

echo -e "CREATE TABLE $5.$6 (taxonomy_id INTEGER NOT NULL,$6_display_label INTEGER NOT NULL,dbprimary_acc VARCHAR(20) NOT NULL,stable_id VARCHAR(128) NOT NULL,percent_identity DECIMAL(5,2),alignment_length INTEGER,number_of_mismatches INTEGER,number_of_gap_openings INTEGER,query_start INTEGER,query_end INTEGER,subject_start INTEGER,subject_end INTEGER,expect_value DOUBLE,hsp_bit_score DECIMAL(12,3));\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_TABLE
fi

mkdir /tmp/$tmpdir

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_MKDIR
fi

for i in $9/*.blast ; do
	$7 $8/prepare_blast_output.pl $i >> /tmp/$tmpdir/$6
	if [ $? -ne 0 ] ; then
		exit $ERR_SHELL_PERL
	fi
done

mysqlimport -h $3 -P $4 -u $1 --password=$2 $5 -L /tmp/$tmpdir/$6

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_IMPORT
fi

rm -rf /tmp/$tmpdir

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_RM
fi

echo -e "CREATE INDEX stable_id_index ON $5.$6 (stable_id(20));\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_INDEX
fi

echo -e "CREATE INDEX display_label_index ON $5.$6 ($6_display_label);\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
        exit $ERR_SQL_CREATE_INDEX
fi

echo -e "CREATE INDEX dbprimary_acc_index ON $5.$6 (dbprimary_acc(20));\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
        exit $ERR_SQL_CREATE_INDEX
fi

echo -e "CREATE INDEX taxonomy_id_index ON $5.$6 (taxonomy_id);\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
        exit $ERR_SQL_CREATE_INDEX
fi

