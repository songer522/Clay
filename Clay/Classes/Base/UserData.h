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
    float bestTimeEasy;
    float bestTimeNormal;
    float bestTimeHard;
    int currentLevel;
}


+ (UserData *) sharedInstance;
- (void)save;

@property (assign) float bestTimeEasy;
@property (assign) float bestTimeNormal;
@property (assign) float bestTimeHard;
@property (assign) int currentLevel;
@end
