import os, sys, shutil

#get required information
levelNumber = raw_input("What is the level number?")
levelName = raw_input("What is a one word name for the level?")

#set up quick access to necessary folders, assuming this script is in the 'scripts' directory, it is the
#current workind directory (getcwd) and has a 'templates' subdirectory
root = os.getcwd()
templateDir = os.path.join(root,"templates")
clayDir = os.path.join(root,os.path.pardir)
resourcesDir = os.path.join(clayDir,"Resources")
levelsDir = os.path.join(resourcesDir,"levels")
objectsDir = os.path.join(resourcesDir,"objects")

#prepare destination filenames using 'levelNumber'
realLevelName = "real_level_" + str(levelNumber) + ".tmx"
testLevelName = "test_level_" + str(levelNumber) + ".tmx"

#copy template.tmx to levels folder with real and test versions
shutil.copyfile(os.path.join(templateDir,"template.tmx"),os.path.join(levelsDir,realLevelName))
shutil.copyfile(os.path.join(templateDir,"template.tmx"),os.path.join(levelsDir,testLevelName))

#create new directory under objects using the given 'levelName' to store animations for that level
dir = os.path.join(objectsDir,levelName)
if not os.path.exists(dir):
	os.makedirs(dir)

#in the future, try to add these new files to the project file for the project
