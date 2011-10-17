//
//  GCState.m
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GCState.h"
#import "GCDatabase.h"

@implementation GCState
@synthesize chickensKickedIntoCows;

static GCState *sharedInstance = nil;

+(GCState*)sharedInstance {
    @synchronized([GCState class])
    {
        if (!sharedInstance) {
            sharedInstance = [loadData(@"GCState") retain];
            if (!sharedInstance) {
                [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil;
}

+(id)alloc {
    @synchronized([GCState class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of the GCState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}

-(void)save {
    saveData(self, @"GCState");
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:chickensKickedIntoCows forKey:@"ChickensKickedIntoCows"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super  init])) {
        chickensKickedIntoCows = [decoder decodeIntForKey:@"ChickensKickedIntoCows"];
    }
    return self;
}

@end
