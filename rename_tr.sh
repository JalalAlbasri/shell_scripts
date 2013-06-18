#!/bin/sh

COUNTER=0
for tr_file in `ls *.tr`
do
#rename tif files exp0 to exp[num]
#	mv $tiff_file "${tiff_file%.*.*}".exp$COUNTER.tif
	mv $tr_file "${tr_file%.*.*}".exp0.tr


	COUNTER=`expr $COUNTER + 1` 
#	cp $tiff_file eng."${tiff_file#*.}"
done
