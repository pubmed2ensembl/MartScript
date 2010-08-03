#!/bin/bash

# Usage: patch_xml_template_complex_stage2.sh host port username password mart dataset filterName featureName filterTitle featureTitle linkoutURL columnName featureDefault

. error_codes

dbprefix="mscript"

host=$1
port=$2
user=$3
pass=$4

filterName=$7
featureName=$8
filterTitle="$9"
featureTitle="${10}"
featureDefault=${13}
linkoutURL="${11}"
mart=$5
dataset=$6

columnName=${12}

tblname=`echo -e "USE $mart; SHOW TABLES;\n" | mysql -h $host -P $port -u $user --password=$pass | grep $dataset | grep ${dbprefix}_${filterName}__dm | head -n 1`

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

column1=`echo -e "SHOW COLUMNS FROM $mart.$tblname;\n" | mysql -h $host -P $port -u $user --password=$pass | grep -E "^[a-zA-Z0-9_]+_key[[:space:]]" | awk -F' ' '{ print $1 }'`

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

column2=`echo -e "SHOW COLUMNS FROM $mart.$tblname;\n" | mysql -h $host -P $port -u $user --password=$pass | grep -E "^${columnName}_[[:digit:]]+[[:space:]]" | awk -F' ' '{ print $1 }'`

if [ $? -ne 0 ] ; then
	exit $ERR_SQL_SHOW
fi

sed 's@FILTER_LIMIT_PLACEHOLDER@+          <Option displayName="with '"$filterTitle"'" displayType="list" field="'"$dbprefix"'_'"$filterName"'_bool" internalName="with_'"$dbprefix"'_'"$filterName"'_'"$column2"'" isSelectable="true" key="'"$column1"'" legal_qualifiers="only,excluded" qualifier="only" style="radio" tableConstraint="main" type="boolean">\
+            <Option displayName="Only" internalName="only" isSelectable="true" value="only"/>\
+            <Option displayName="Excluded" internalName="excluded" isSelectable="true" value="excluded"/>\
+          </Option>\
FILTER_LIMIT_PLACEHOLDER@' |
sed 's@FILTER_LIST_PLACEHOLDER@+          <Option checkForNulls="true" displayName="'"$filterTitle"'" displayType="text" field="'"$column2"'" internalName="'"$column2"'" isSelectable="true" key="'"$column1"'" legal_qualifiers="=,in" multipleValues="1" qualifier="=" tableConstraint="'"$dbprefix"'_'"$filterName"'__dm" type="list"/>\
FILTER_LIST_PLACEHOLDER@' |
	sed 's@ATTRIBUTE_FEATURE_INSTANCE_PLACEHOLDER@+        <AttributeDescription default="'"$featureDefault"'" displayName="'"$featureTitle"'" field="'"$column2"'" internalName="'"$column2"'" key="'"$column1"'" linkoutURL="'"$linkoutURL"'" maxLength="11" tableConstraint="'"$dbprefix"'_'"$featureName"'__dm"/>\
ATTRIBUTE_FEATURE_INSTANCE_PLACEHOLDER@'

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

