#! /bin/bash
#runs the tesseract font training process on adding an extra font to an existing .traineddata
#made to build a numbers only character set and train new fonts
#Usage: ./tess_train_font [font prefix] [lang to train prefix]
# Example: ./tess_train_font eng.comicsansms.exp0 num
#lang is the existing character set that we want to add to 

# build the environment
TROOT=`pwd`
FONT_NAME=$1
LANG=$2
FONT_PREFIX=eng.$FONT_NAME.exp0
FONT_PROPERTIES=$TROOT/font_properties
ALL_FONT_PROPERTIES=$TROOT/all_font_properties
NUMBERS=$TROOT/numbers
TIFF_FILE=$TROOT/$FONT_PREFIX.tif
BOX_FILE=$TROOT/$FONT_PREFIX.box
TR_FILE=$TROOT/$FONT_PREFIX.tr
TRAINEDDATA_FILE=$TROOT/build/$LANG/$FONT_PREFIX.traineddata

#enable for other users
mkdir $TROOT/build; mkdir $TROOT/build/$2

#download the font files from my guthub/dropbox
#download a tar folder and untar it
#GET http://dl.dropbox.com/u/106343520/tiffs/$FONT_PREFIX.tif > $TIFF_FILE
#do the same for numbers.txt and font_properties
#tar xzf traintess.num.tar.gz
cp $TROOT/tiffs/$FONT_PREFIX.tif $TIFF_FILE
echo "Environment Built"

echo "## Create box files for $font_prefix..."
tesseract $TIFF_FILE $FONT_PREFIX -l num batch.nochop makebox
mv $BOX_FILE $BOX_FILE.original

echo "## Correcting Box file with numbers"
#correct the incorrectly recognized characters in the box file
num_counter=1
while read line
do
	#get the correct character from the numbers.txt file
	correct_char=`cut -n -c $num_counter $NUMBERS`
	#get the box coordinates from the original box file
	box_coordinates=`echo $line | cut -c 2-`
	echo $correct_char $box_coordinates >> $BOX_FILE
	num_counter=`expr $num_counter + 1`
done < $BOX_FILE.original

echo "## Adding font to font_properties file..."
# Create the font_properties file
echo | grep "$FONT_NAME " $ALL_FONT_PROPERTIES >> $FONT_PROPERTIES

# BEGIN BUILDING NEW eng.traineddata
echo "## Running tesseract for training..."
tesseract $TIFF_FILE $FONT_PREFIX nobatch box.train
echo "## Running unicharset extractor..."
unicharset_extractor $BOX_FILE
echo "## Running shapeclustering..."
shapeclustering -F $FONT_PROPERTIES -U unicharset $TR_FILE
echo "## Running mftraining..."
mftraining -F $FONT_PROPERTIES -U unicharset -O eng.unicharset $TR_FILE
echo "## Running cntraining..."
cntraining $TR_FILE
echo "## eng.traineddata complete"

# BEGIN combining into an eng.traineddata set
# Note files are moved into an isoloated directory for combiing
# Note files have language prefix added
echo "## Copy files to build directory..."
cp eng.unicharset $TROOT/build/$LANG/$LANG.unicharset
cp normproto $TROOT/build/$LANG/$LANG.normproto
cp inttemp $TROOT/build/$LANG/$LANG.inttemp
cp pffmtable $TROOT/build/$LANG/$LANG.pffmtable
cp shapetable $TROOT/build/$LANG/$LANG.shapetable
echo "## Combine $LANG files..."
cd $TROOT/build/$LANG
combine_tessdata $LANG.

if [ -f $TRAINEDDATA_FILE]; then
	echo "## $LANG.trainddata sucsessfully built"
fi

su cp $TRAINNEDDATA_FILE $TESSDATA/$lang.traineddata
