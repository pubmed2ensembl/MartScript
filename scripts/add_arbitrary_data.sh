#!/bin/bash

# add_arbitrary_data.sh username password host port dbname tblname import_file

exec 1>/dev/null
exec 2>/dev/null

. error_codes

tmpdir=`date "+%Y%m%d_%H%M%S_import"`

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

columns=`perl count_columns.pl $7`

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_PERL
fi

# only the number of data columns, i.e. we do not count the tax-id and entrez-id
let columns=columns-2

# CREATE DATABASE might fail because the database already exists
echo -e "CREATE DATABASE $5;\n" | mysql -h $3 -P $4 -u $1 --password=$2
# DROP TABLE might fail because the table might not exist
echo -e "DROP TABLE $5.$6;\n" | mysql -h $3 -P $4 -u $1 --password=$2

counter=0
data_cols=""
while [ $counter -lt $columns ] ; do
        let counter=counter+1 ;
	data_cols=$data_cols",$6_$counter TEXT CHARACTER SET utf8 COLLATE utf8_bin" ;
done

echo -e "CREATE TABLE $5.$6 (taxonomy_id INTEGER NOT NULL,dbprimary_acc VARCHAR(20) NOT NULL$data_cols);\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_TABLE
fi

mkdir /tmp/$tmpdir

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_MKDIR
fi

cp $7 /tmp/$tmpdir/$6

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CP
fi

mysqlimport -h $3 -P $4 -u $1 --password=$2 $5 -L /tmp/$tmpdir/$6

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_IMPORT
fi

rm -rf /tmp/$tmpdir

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_RM
fi

# The DELETE removes entries for which we do not have a Entrez gene id
echo "DELETE FROM $5.$6 WHERE $5.$6.dbprimary_acc='';\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_DELETE
fi

counter=0
while [ $counter -lt $columns ] ; do
	let counter=counter+1 ;
	echo -e "CREATE INDEX $6_$counter""_index ON $5.$6 ($6_$counter(128));\n" | mysql -h $3 -P $4 -u $1 --password=$2 ;
	if [ $? -ne 0 ] ; then
		exit $ERR_SQL_CREATE_INDEX
	fi ;
done

echo -e "CREATE INDEX dbprimary_acc_index ON $5.$6 (dbprimary_acc(20));\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_INDEX
fi

echo -e "CREATE INDEX taxonomy_id_index ON $5.$6 (taxonomy_id);\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_INDEX
fi

