#!/bin/sh

cd ..
TESSERACT=`pwd`
#path to numbers.txt
#need to provide
NUMBERS=$TESSERACT/numbers.txt
#path to font properties file
#need to provide
FONT_PROPERTIES=$TESSERACT/font_properties

#if box files are not present
if [ ! -e $TESSERACT/eng.verdanai.exp0.box ]; then
	#create box files
	for tiff_file in `ls $TESSERACT/*.tif`
	do 
		filename=$(basename "$tiff_file")
		filename="${filename%.*}"
		echo "filename:$filename" "tiff_filename" $tiff_file
		tesseract $tiff_file $filename -l num batch.nochop makebox
	done
	echo mv $TESSERACT/*.box $TESSERACT/original_box_files/*.box

	#Ammend matched character on boxfile line with correct numbers from numbers.txt
	for box_file in `ls $TESSERACT/original/box_files/*.box`
	do	
	counter=1
	box_filename=`basename $box_file`
		while read line
		do
			correct_number=`cut -n -c $counter $NUMBERS`
			box_coordinates=`echo $line | cut -c 2-`
			echo $correct_number $box_coordinates >> $TESSERACT/$(basename box_file)
			counter=`expr $counter + 1`
		done < $box_file
	done
	
	#Run tesseract for training.
	for tiff_file in `ls $TESSERACT/*.tif`
	do 
		filename=$(basename "$tiff_file")
		filename="${filename%.*}"
		echo "filename:$filename" "tiff_filename" $tiff_file
		tesseract $tiff_file $filename nobatch box.train
	done
fi
unicharset_cmd="unicharset_extractor "

if [ ! -e $TESSERACT/unicharset ]; then

	for box_file in `ls $TESSERACT/*.box`
	do 	
		unicharset_cmd="$unicharset_cmd $box_file"
	done
	echo $unicharset_cmd
	$unicharset_cmd
fi

shapeclustering_cmd="shapeclustering -F $FONT_PROPERTIES -U unicharset "
mftraining_cmd="mftraining -F $FONT_PROPERTIES -U unicharset -O eng.unicharset "
cntraining_cmd="cntraining -F $FONT_PROPERTIES -U unicharset -O eng.unicharset $tr_file "

echo "shape clustering about to begin..."

for tr_file in `ls $TESSERACT/*.tr`
do
	shapeclustering_cmd="$shapeclustering_cmd $tr_file"
	mftraining_cmd="$mftraining_cmd $tr_file"
	cntraining_cmd="$cntraining_cmd $tr_file"
done

echo $shapeclustering_cmd
$shapeclustering_cmd

echo $mftraining_cmd
$mftraining_cmd

echo $cntraining_cmd
$cntraining_cmd

# BEGIN combining into an eng.traineddata set
# Note files are moved into an isoloated directory for combiing
# Note files have language prefix added

cp $TESSERACT/eng.unicharset $TESSERACT/build/eng/eng.unicharset
cp $TESSERACT/normproto $TESSERACT/build/eng/eng.normproto
cp $TESSERACT/inttemp $TESSERACT/build/eng/eng.inttemp
cp $TESSERACT/pffmtable $TESSERACT/build/eng/eng.pffmtable
cp $TESSERACT/shapetable $TESSERACT/build/eng/eng.shapetable

cd $TESSERACT/build/eng
combine_tessdata eng.
