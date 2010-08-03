#!/bin/bash

# process_sql_zip.sh username password host port martname sqlzipfile perlinterpreter

exec 1>/dev/null
exec 2>/dev/null

. error_codes

tmpdir=`date "+%Y%m%d_%H%M%S_sql"`

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

BINDIR=`pwd`

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

mkdir /tmp/$tmpdir

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_MKDIR
fi

cd /tmp/$tmpdir

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CD
fi

unzip -qq $6 -d /tmp/$tmpdir

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_UNZIP
fi

# drop might fail when the database does not yet exist
echo -e "DROP DATABASE $5;\n" | mysql -h $3 -P $4 -u $1 --password=$2

echo -e "CREATE DATABASE $5;\n" | mysql -h $3 -P $4 -u $1 --password=$2

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_DATABASE
fi

$7 $BINDIR/process_sql_zip_pools.pl $1 $2 $3 $4

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_PERL
fi

rm -rf /tmp/$tmpdir

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_RM
fi

