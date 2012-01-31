#!/bin/bash

for i in *.caf; do
	afconvert -f caff -d LEI16 -c 1 $i
	echo $i
done

for i in *.mp3; do
	afconvert -f caff -d LEI16 -c 1 $i
	echo $i
done

for i in *.wav; do
	afconvert -f caff -d LEI16 -c 1 $i
	echo $i
done

