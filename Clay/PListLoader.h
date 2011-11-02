//
//  PListLoader.h
//  Clay
//
//  Created by Dustin Werner on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  Converts a property list (plist) by name into a NSDictionary data structure to be used to load configuration settings for all sorts of things throughout the project.

#import <Foundation/Foundation.h>

@interface PListLoader : NSObject


+(NSDictionary*)loadPlistWithName:(NSString*)plistName;

@end
