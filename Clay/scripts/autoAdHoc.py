import os,sys,shutil,plistlib,datetime

plistName = "settings"

#project dirs
parentDir = os.path.abspath(os.path.join(os.getcwd(),os.path.pardir))
plistsDir = os.path.join(parentDir,"Plists")

filename = os.path.join(plistsDir,plistName+".plist")

plist = plistlib.readPlist(filename)

appDict = plist["app"]
currentVersionNumber = appDict["versionNumber"]

versionDate,versionBuild = currentVersionNumber.split(".")

now = datetime.datetime.now()

newVersionDate = now.strftime("%y%m%d")

if newVersionDate == versionDate:
	newNumber = int(versionBuild) + 1
	if newNumber < 10:
		newNumber = "0" + str(newNumber)
	newVersionBuild = str(newNumber)
else:
	newVersionBuild = "01"

newVersionNumber =  newVersionDate + "." + newVersionBuild

newPlist = dict(
	app = dict(
		showFps = "NO",
		versionNumber = newVersionNumber
	))

plistlib.writePlist(newPlist,filename)

blah = raw_input("Please make an archive build.")

newPlist = dict(
	app = dict(
		showFps = "YES",
		versionNumber = newVersionNumber
	))

plistlib.writePlist(newPlist,filename)

