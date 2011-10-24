# NewAnimation.py
#
# Utility to make creating new animations slightly faster by copying the appropriate files where they need to go and saving a new
# Zwoptex animation file in the appropriate Dropbox directory. Eventually, we want to have it copy directly to the appropriate animation
# directory in the project and add a new entry to anims.plist (and optionally, objects.plist) and add the file directly to the apple project file, if possible.

import os,sys,shutil

currentProject = "Clay"

animationFilename = raw_input("What will the filename be for this animation?")
sequenceName = raw_input("What is the name of the sequence in the art folder?")
fullSequenceName = sequenceName + "1.png"

root = os.getenv("HOME") #get home directory, equivalent to "~" in terminal
projectRoot = os.path.join(os.getcwd(),os.path.pardir)
templateDir = os.path.join(os.getcwd(),"templates")
publicDir = os.path.join(root,"public")
artUpdateDir = os.path.join(publicDir,"Art_Update")

#dropbox dirs
dropboxDir = os.path.join(root,"Dropbox")
dbProjectDir = os.path.join(os.path.join(dropboxDir,"Projects"),currentProject)
dbSpritesDir = os.path.join(dbProjectDir,"Sprites")

#walk through art update folder to try to match any filename to the 'sequenceName' provided
folders = []
for top, dirs, files in os.walk(artUpdateDir):
	for name in files:
			if sequenceName.lower() in name.lower():
				folders.append(top)

#remove duplicates from folders[] and use that
possibleOptions = list(set(folders))
possibleOptions.sort()

#show the possible directories to the user, and let them
#pick which one is correct
number = 1
for opt in possibleOptions:
	root,choice = opt.rsplit('/',1)
	print str(number) + ". " + choice
	number = number + 1

choice = raw_input("Which folder is correct?")

animationFolder = possibleOptions[(int(choice)-1)]

#create appropriate dropbox folder if not already created
dir = os.path.join(dbSpritesDir,animationFilename)
if not os.path.exists(dir):
	os.makedirs(dir)

#copy contents of the chosen artupdate folder to the new dropbox folder
for top,dirs,files in os.walk(animationFolder):
	for name in files:
		shutil.copyfile(os.path.join(top,name),os.path.join(dir,name))

#copy the template zwoptex file to dropbox folder (NOTE: since we can use this script for updating animations, we don't want this to
#overwrite if it exists already, because it's easy to update that file within the zwoptex application
fullAnimFilename = os.path.join(dir,animationFilename+".zwd")
if not os.path.isfile(fullAnimFilename):
	shutil.copyfile(os.path.join(templateDir,"animationTemplate.zwd"),fullAnimFilename)
