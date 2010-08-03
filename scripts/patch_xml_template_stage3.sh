#!/bin/bash

. error_codes

sed 's@FILTER_LIMIT_PLACEHOLDER@@' |
	sed 's@FILTER_LIST_PLACEHOLDER@@' |
	sed 's@ATTRIBUTE_FEATURE_INSTANCE_PLACEHOLDER@@' |
	sed 's@ATTRIBUTE_FEATURE_CONTEXT_PLACEHOLDER@@' |
	grep -v '^$'

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

