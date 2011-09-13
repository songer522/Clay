//
//  PListLoader.h
//  Clay
//
//  Created by Dustin Werner on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PListLoader : NSObject


+(NSDictionary*)loadPlistWithName:(NSString*)plistName;

@end
