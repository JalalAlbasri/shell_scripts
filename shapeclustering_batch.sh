#!/bin/sh

command="shapeclustering -F font_properties -U unicharset "
for tr_file in `ls *.tr`
do 
	command="$command $tr_file"
done
echo $command
exec $command
