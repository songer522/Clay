import os, sys
from subprocess import call

root = os.getcwd()

filter = ['wav','mp3','caf']



for r,d,f in os.walk(root):
	for file in f:
		if file[-3:] in filter:
			command = "afconvert -d 'ima4' -f 'caff' " + file + " new/" + file[:-4] + ".caf"
			print command
			os.system(command)