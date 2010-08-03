#!/bin/bash

# findspeciesid.sh namesdmp species

. error_codes

cat $1 |
	awk -F "|" '{ print $1":"tolower($2) }' |
	tr -d '\t' |
	tr ' ' '_' |
	awk -F : '$2 == search' search=$2 |
	awk -F : '{ print $1 }'

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

