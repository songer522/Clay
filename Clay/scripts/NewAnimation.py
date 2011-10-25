# NewAnimation.py
#
# Utility to make creating new animations slightly faster by copying the appropriate files where they need to go and saving a new
# Zwoptex animation file in the appropriate Dropbox directory. Eventually, we want to have it copy directly to the appropriate animation
# directory in the project and add a new entry to anims.plist (and optionally, objects.plist) and add the file directly to the apple project file, if possible.

import os,sys,shutil,plistlib

currentProject = "Clay"


#get information from the user
animationFilename = raw_input("What will the filename be for this animation?")
sequenceName = raw_input("What is the name of the sequence in the art folder?")

updating = raw_input("Is the data created already and only the sprites need updating? (y/n):")
if updating == "y":
	creatingPlists = False
else:
	creatingPlists = True

	print ""
	print "Choose type of object:"
	print "1. Background object"
	print "2. Obstacle"
	print "3. Player Animation"
	type = raw_input("Which?")

	if type == "1":
		isObstacle = True
	else:
		isObstacle = False

	if type == "3":
		isPlayer = True
	else:
		isPlayer = False

#prepare variables
fullSequenceName = sequenceName + "1.png"

#project dirs
root = os.getenv("HOME") #get home directory, equivalent to "~" in terminal
classesDir = os.path.join(os.getcwd(),os.path.pardir)
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

if number == 1:
	print "ERROR: no images found with " + sequenceName + " as part of its filename under Art_Update. Please try again with a different value."
	sys.exit(1)

choice = raw_input("Which folder is correct?")

animationFolder = possibleOptions[(int(choice)-1)]

#create appropriate dropbox folder if not already created
dir = os.path.join(dbSpritesDir,animationFilename)
if not os.path.exists(dir):
	os.makedirs(dir)

#copy contents of the chosen artupdate folder to the new dropbox folder
#also, prepare animationFrames list for updating the plist later (it just assumes it's 1 to # of files);
#not right for everything, but a good starting position
for top,dirs,files in os.walk(animationFolder):
	for name in files:
		shutil.copyfile(os.path.join(top,name),os.path.join(dir,name))

#copy the template zwoptex file to dropbox folder (NOTE: since we can use this script for updating animations, we don't want this to
#overwrite if it exists already, because it's easy to update that file within the zwoptex application
fullAnimFilename = os.path.join(dir,animationFilename+".zwd")
if not os.path.isfile(fullAnimFilename):
	shutil.copyfile(os.path.join(templateDir,"animationTemplate.zwd"),fullAnimFilename)


if creatingPlists:
	#read anims.plist and add a new animation to the list
	plistFilename = os.path.join(classesDir,"anims.plist")
	plistAnims = plistlib.readPlist(plistFilename)

	if isObstacle:
		groupValue = "Obstacle"
	elif isPlayer is not True:
		groupValue = "Background"
	else:
		groupValue = "Player"

	#TODO: ask about more of these options instead of just assuming
	newAnim = dict(
		clearPreviousAnims = "true",
		looping = "true",
		group = groupValue,
		spritesheetPlist = animationFilename,
		sequencePrefix = "PLEASE_UPDATE",
		animationFrames = "1",
		delay = "0.075"
	)

	plistAnims[animationFilename] = newAnim
	plistlib.writePlist(plistAnims,plistFilename)

	print ""
	print animationFilename + " has been added to anims.plist."
	print "It has been populated with default values. Please check it"
	print "in the project to modify it to your needs."

if creatingPlists and isPlayer is not True:
	#edit objects.plist if not a player animation
	plistFilenameObj = os.path.join(classesDir,"objects.plist")
	plistObjects = plistlib.readPlist(plistFilenameObj)

	if isObstacle:
		aggroValue = "true"
		playerEffectValue = "collide"
		collideBehaviorValue = "fadeout"
	else:
		aggroValue = "false"
		playerEffectValue = "none"
		collideBehaviorValue = "none"
	
	newObject = dict(
		aggressive = aggroValue,
		playerEffect = playerEffectValue,
		collideBehavior = collideBehaviorValue,
		offsetx = 0,
		offsety = 0,
		anchorpoint = dict(
			x = 0,
			y = 0
		),
		animationName = "",
		boundingBox = dict(
			x = 0,
			y = 0,
			width = 1,
			height = 1
		),
		imageName = "blank.png"
	)

	plistObjects[animationFilename] = newObject
	plistlib.writePlist(plistObjects,plistFilenameObj)

	print ""
	print animationFilename + " has been added to objects.plist."
	print "It has been populated with default values. Please check it"
	print "in the project to modify it to your needs."
