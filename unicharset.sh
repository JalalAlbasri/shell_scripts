#!/bin/sh
command="unicharset_extractor "
for box_file in `ls *.box`
do 
	unicharset_extractor $boxfile
	command="$command $box_file"
done

echo $command
exec $command
