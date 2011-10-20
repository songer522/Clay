//
//  UserData.m
//  Clay
//
//  Created by Dustin Werner on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UserData.h"
#import "Database.h"
@implementation UserData
@synthesize bestTime;
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
    [encoder encodeFloat:bestTime forKey:@"bestTime"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super  init])) {
        currentLevel = [decoder decodeIntForKey:@"currentLevel"];
        bestTime = [decoder decodeFloatForKey:@"bestTime"];
    }
    return self;
}


@end
