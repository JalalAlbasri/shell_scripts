#!/bin/sh

command="mftraining -F font_properties -U unicharset -O eng.unicharset "
for tr_file in `ls *.tr`
do 
	command="$command $tr_file"
done
echo $command
exec $command
