#!/bin/sh
command="cntraining "
for tr_file in `ls *.tr`
do 
	command="$command $tr_file"
done
echo $command
exec $command
