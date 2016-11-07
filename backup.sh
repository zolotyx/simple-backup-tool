#!/bin/bash


CONFIG_FILE="config"
BACKUP_FILE="backup.tar"

if [ ! -z "$1" ]; then
    CONFIG_FILE="$1"
fi

echo "Config file is set to '$CONFIG_FILE'"

while read -r line
do
	if [ ! -z "$line" ]; then
		echo "Config line = $line"

		IFS=' ' read -ra params <<< "$line"
		path=${params[2]}
		if [ ! -f $BACKUP_FILE ]; then
			tar cvf $BACKUP_FILE --files-from /dev/null
		fi

		find $path -regex ${params[1]} -size ${params[0]} | while read filename
		do
			echo "file = ${filename}"
			if tar xf $BACKUP_FILE -O ${filename#/} &> /dev/null; then

			    if tar xf backup.tar -O ${filename#/} | diff $filename - &> /dev/null; then
					true
				else
					echo "differs"
				fi
		    else
		    	tar -rf $BACKUP_FILE ${filename} 2> /dev/null
			fi
			
		done 

		
	fi
    
done < "$CONFIG_FILE"
