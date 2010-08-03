#!/bin/bash

# usage: patch_xml_template_stage4.sh filterLimitLines filterListLines attributeFeatureLines

. error_codes

sed 's@FILTER_LIMIT_LINES@'"$1"'@' |
	sed 's@FILTER_LIST_LINES@'"$2"'@' |
	sed 's@ATTRIBUTE_FEATURE_LINES@'"$3"'@'

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

