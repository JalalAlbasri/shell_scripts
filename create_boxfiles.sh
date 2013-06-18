#!/bin/sh
#batch operation to create box files from tif images for num language

for tiff_file in `ls *.tif`
do 
	filename=$(basename "$tiff_file")
	filename="${filename%.*}"
	echo "filename:$filename" "tiff_filename" $tiff_file
	tesseract $tiff_file $filename -l num batch.nochop makebox
done
