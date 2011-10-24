//
//  UserData.h
//  Clay
//
//  Created by Dustin Werner on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
