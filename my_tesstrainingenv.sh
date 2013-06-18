#! /bin/bash

# build the environment
mkdir ../tessenv; cd ../tessenv 
TROOT=`pwd` 
mkdir $TROOT/stockfonts; mkdir $TROOT/build; mkdir $TROOT/build/eng 
echo "Environment built"
# Get the stock english fonts from Google (old, but they work)
cd $TROOT/stockfonts
GET http://tesseract-ocr.googlecode.com/files/boxtiff-2.01.eng.tar.gz > boxtiff-2.01.eng.tar.gz
echo "Google box/tiff tar.gz loaded"


# unpack the fonts, a new english (eng) directory is created with tif/box files
tar -xzf boxtiff-2.01.eng.tar.gz
echo "box/tiff file unpacked"


# Move the arial font data into the build space (yes, the exp0 is required)
mv $TROOT/stockfonts/eng/eng.arial.g4.tif $TROOT/build/eng.arial.exp0.tif
mv $TROOT/stockfonts/eng/eng.arial.box $TROOT/build/eng.arial.exp0.box
echo "ariel box/tif moved and renamed"
cd $TROOT/build
# Create the font_properties file
echo "arial 0 0 0 0 0" > font_properties

# BEGIN BUILDING NEW eng.traineddata
tesseract eng.arial.exp0.tif eng.arial.exp0 nobatch box.train
unicharset_extractor eng.arial.exp0.box
shapeclustering -F font_properties -U unicharset  eng.arial.exp0.tr
mftraining -F font_properties -U unicharset -O eng.unicharset eng.arial.exp0.tr
cntraining eng.arial.exp0.tr
echo "eng.traineddata complete"

# BEGIN combining into an eng.traineddata set
# Note files are moved into an isoloated directory for combiing
# Note files have language prefix added

cp eng.unicharset $TROOT/build/eng/eng.unicharset
cp normproto $TROOT/build/eng/eng.normproto
cp inttemp $TROOT/build/eng/eng.inttemp
cp pffmtable $TROOT/build/eng/eng.pffmtable
cp shapetable $TROOT/build/eng/eng.shapetable

cd $TROOT/build/eng
combine_tessdata eng.

# You now have an eng.trainedddata file in your $TROOT/build/eng directory
# You must move this file to your /usr/local/share/tessdata directory.
# You will need sudo permission. 
# BE SURE to back up your old eng.traineddata FIRST
# Recommend testing your new tesseract with the eng.arial.exp0.tif file in
# the build directory.

