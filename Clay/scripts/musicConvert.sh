#!/bin/bash

for i in *.wav; do
	afconvert -f AIFC -d ima4 -c 1 $i
done