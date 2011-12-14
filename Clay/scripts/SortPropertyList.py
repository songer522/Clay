# NewAnimation.py
#
# Utility to make creating new animations slightly faster by copying the appropriate files where they need to go and saving a new
# Zwoptex animation file in the appropriate Dropbox directory. Eventually, we want to have it copy directly to the appropriate animation
# directory in the project and add a new entry to anims.plist (and optionally, objects.plist) and add the file directly to the apple project file, if possible.

import os,sys,shutil,plistlib

#project dirs
parentDir = os.path.abspath(os.path.join(os.getcwd(),os.path.pardir))
plistsDir = os.path.join(parentDir,"Plists")

sortname = raw_input("Name of plist to sort?")

filename = os.path.join(plistsDir,sortname+".plist")

print filename

plist = plistlib.readPlist(filename)
plistlib.writePlist(plist,filename)

print sortname + " sorted alphabetically"