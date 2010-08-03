#!/bin/bash

# create_master_schema.sh username password host port martversion

exec 1>/dev/null
exec 2>/dev/null

. error_codes

# these lines might fail because the databases may not exist
echo -e "DROP DATABASE master_schema_$5;\n" | mysql -h $3 -P $4 -u $1 --password=$2
echo -e "DROP DATABASE master_schema_variation_$5;\n" | mysql -h $3 -P $4 -u $1 --password=$2

echo -e "CREATE DATABASE master_schema_$5;\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_DATABASE
fi

echo -e "CREATE DATABASE master_schema_variation_$5;\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_DATABASE
fi

cat templates/master_schema_$5.sql | mysql -h $3 -P $4 -u $1 --password=$2 master_schema_$5

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SQL_FILE
fi

cat templates/master_schema_variation_$5.sql | mysql -h $3 -P $4 -u $1 --password=$2 master_schema_variation_$5

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SQL_FILE
fi

