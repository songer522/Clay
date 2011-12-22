//
//  GCState.m
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GCState.h"
#import "Database.h"

@implementation GCState
@synthesize chickensKickedIntoCows;
@synthesize timesDied;
@synthesize completeStoryAll,completeStoryEasy,completeStoryHard,completeStoryNormal;

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
    [encoder encodeInt:timesDied forKey:@"timesDied"];
    [encoder encodeBool:completeStoryEasy forKey:@"completeStoryEasy"];
    [encoder encodeBool:completeStoryNormal forKey:@"completeStoryNormal"];
    [encoder encodeBool:completeStoryHard forKey:@"completeStoryHard"];
    [encoder encodeBool:completeStoryAll forKey:@"completeStoryAll"];
    

}

-(id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super  init])) {
        chickensKickedIntoCows = [decoder decodeIntForKey:@"ChickensKickedIntoCows"];
        timesDied = [decoder decodeIntForKey:@"timesDied"];
        completeStoryEasy = [ decoder decodeBoolForKey:@"completeStoryEasy"];
        completeStoryNormal = [ decoder decodeBoolForKey:@"completeStoryNormal"];
        completeStoryHard = [ decoder decodeBoolForKey:@"completeStoryHard"];
        completeStoryAll = [ decoder decodeBoolForKey:@"completeStoryAll"];
    }
    return self;
}

@end
