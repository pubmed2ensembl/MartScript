#!/bin/bash

# customize_xml.sh username password host port

exec 1>/dev/null
exec 2>/dev/null

. error_codes

for i in *.xml ; do
        cat $i | 
                sed -e "s/outputPort=\"18001\"/outputPort=\"$4\"/g" | 
                sed -e "s/overrideHost=\"ens-staging\"/overrideHost=\"$3\"/g" | 
                sed -e "s/overridePort=\"3306\"/overridePort=\"$4\"/g" | 
                sed -e "s/localhost:43306/$3:$4/g" | 
                sed -e "s/username=\"joebloggs\"/username=\"$1\"/g" | 
                sed -e "s/password=\"\"/password=\"$2\"/g" > $i.new ; 
	
	if [ $? -ne 0 ] ; then
		exit $ERR_SHELL_CMD
	fi

        mv $i.new $i ; 

	if [ $? -ne 0 ] ; then
		exit $ERR_SHELL_CMD
	fi

done

