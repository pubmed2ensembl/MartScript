#!/bin/bash

# create_sequence_mart.sh pathtoscripts enshome perl5libs username password host port sqldriver martversion

exec 1>/dev/null
exec 2>/dev/null

. error_codes

export PATH=.:$PATH
export PERL5LIB=$PERL5LIB:$2
export ENSMARTHOST=$6
export ENSMARTPORT=$7
export ENSHOME=$2
export ENSMARTUSER=$4
export ENSMARTPWD=$5
export ENSMARTDRIVER=$8

echo "CREATE DATABASE sequence_mart_$9;\n" | mysql -u $4 --password=$5

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_CREATE_DATABASE
fi

./make_all_dna_chunks.pl sequence_mart_$9 $9 0

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_PERL
fi

