#!/bin/bash

# usage: patch_xml_template_stage1.sh heading description internalName collectionHeading collectionInternalName martName

. error_codes

cat templates/xml.$6.template.patch |
	sed 's@ATTRIBUTE_FEATURE_CONTEXT_PLACEHOLDER@+    <AttributeGroup description="'"$2"'" displayName="'"$1"'" internalName="'"$3"'">\
+      <AttributeCollection displayName="'"$4"'" internalName="'"$5"'">\
ATTRIBUTE_FEATURE_INSTANCE_PLACEHOLDER\
+      </AttributeCollection>\
+    </AttributeGroup>@'

if [ $? -ne 0 ] ; then
	exit $ERR_SHELL_CMD
fi

