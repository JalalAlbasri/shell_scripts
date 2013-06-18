#!/bin/sh
mkdir corrected_boxfiles
for boxfile in `ls *.box`
do
	java correct_boxfile $boxfile
done
mv corrected_boxfiles/* ./*
rmdir corrected_boxfiles
