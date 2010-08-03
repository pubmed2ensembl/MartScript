#!/bin/bash

# rename_column.sh username password host port dbname tblname oldcolumn newcolumn

exec 1>/dev/null
exec 2>/dev/null

. error_codes

definition=`echo -e \`echo "SHOW CREATE TABLE $5.$6" | mysql -h $3 -P $4 -u $1 --password=$2\` | grep $7 | head -n 1 | awk -F\\\` '{ print $3 }' | sed s/,//`

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

# the index might not exist and therefore the next command might fail
echo -e "DROP INDEX $7_index ON $5.$6" | mysql -h $3 -P $4 -u $1 --password=$2

echo -e "ALTER TABLE $5.$6 CHANGE $7 $8 $definition;\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_ALTER
fi

echo -e "CREATE INDEX $8_index ON $5.$6 ($8(128));\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_INDEX
fi

