#!/bin/sh

COUNTER=0
for tiff_file in `ls *.tif`
do
#rename tif files exp0 to exp[num]
#	mv $tiff_file "${tiff_file%.*.*}".exp$COUNTER.tif
	mv $tiff_file "${tiff_file%.*.*}".exp0.tif


	COUNTER=`expr $COUNTER + 1` 
#	cp $tiff_file eng."${tiff_file#*.}"
done
