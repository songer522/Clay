//
//  UserData.m
//  Clay
//
//  Created by Dustin Werner on 10/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "UserData.h"
#import "Database.h"
@implementation UserData
@synthesize bestTimeEasy,bestTimeNormal,bestTimeHard;
@synthesize currentLevel;


static UserData *sharedInstance = nil;

+(UserData*)sharedInstance {
    @synchronized([UserData class])
    {
        if (!sharedInstance) {
            sharedInstance = [loadData(@"UserData") retain];
            if (!sharedInstance) {
                [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil;
}

+(id)alloc {
    @synchronized([UserData class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of the UserData singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}

-(void)save {
    saveData(self, @"UserData");
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:currentLevel forKey:@"currentLevel"];
    [encoder encodeFloat:bestTimeEasy forKey:@"bestTimeEasy"];
    [encoder encodeFloat:bestTimeNormal forKey:@"bestTimeNormal"];
    [encoder encodeFloat:bestTimeHard forKey:@"bestTimeHard"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super  init])) {
        currentLevel = [decoder decodeIntForKey:@"currentLevel"];
        bestTimeEasy = [decoder decodeFloatForKey:@"bestTimeEasy"];
        bestTimeNormal=[decoder decodeFloatForKey:@"bestTimeNormal"];
        bestTimeHard=[decoder decodeFloatForKey:@"bestTimeHard"];
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}


@end
