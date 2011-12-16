import os, sys, glob, re, shutil
import fileinput

prefix = raw_input("Append a prefix to each filename: ")

path = os.getcwd()

out = []

for name in glob.glob(os.path.join(path,'*.tmx')):
	filename = os.path.basename(name)
	if filename is not "FastLevelFixer.py":
		dirname = os.path.dirname(name)

		newFile = open(os.path.join(dirname,(prefix+"_"+filename)),"w")
		oldFile = open(filename)

		for line in oldFile:
		   line = line.replace("TrackLapse_Icons-hd.png","../TrackLapse_Icons-hd.png")
		   line = line.replace("TrackLapse_Icons.png","../TrackLapse_Icons.png")
		   line = line.replace("tileset_","../tileset_")
		   line = line.replace("meta.png","../meta.png")
		   line = line.replace("meta-hd.png","../meta-hd.png")
		   newFile.write(line)
		
		newFile.close()
		oldFile.close()
		print "Processing " + name + "..."
		