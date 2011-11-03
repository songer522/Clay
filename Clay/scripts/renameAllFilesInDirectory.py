import os, sys

characters = raw_input("How many characters at beginning to replace?")
newText = raw_input("What should text be replaced to?")

for filename in os.listdir('.'):
	if "TrackLapse_Icons" not in filename:
		newFilename = newText + str(filename[int(characters):])
		print newFilename
	