//
//  UserData.h
//  Clay
//
//  Created by Dustin Werner on 10/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Keeps track of whatever user data we want to save between game sessions via the Database class.


#import <Foundation/Foundation.h>

@interface UserData : NSObject 
{
    float bestTime;
    int currentLevel;
}


+ (UserData *) sharedInstance;
- (void)save;

@property (assign) float bestTime;
@property (assign) int currentLevel;
@end
