#!/bin/bash

# rename_column.sh username password host port dbname oldtblname newtblname

exec 1>/dev/null
exec 2>/dev/null

. error_codes

echo -e "USE $5; RENAME TABLE $6 TO $7;\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_RENAME
fi

