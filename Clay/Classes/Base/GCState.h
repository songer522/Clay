//
//  GCState.h
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Records the current state of the achievements to be saved and loaded by the Database class between playthroughs.

#import <Foundation/Foundation.h>

@interface GCState : NSObject <NSCoding> {
    int chickensKickedIntoCows;
    int timesDied;
    bool completeStoryEasy;
    bool completeStoryNormal;
    bool completeStoryHard;
    bool completeStoryAll;
}

+ (GCState *) sharedInstance;
- (void)save;

@property (assign) int chickensKickedIntoCows;
@property (assign) int timesDied;
@property (assign) bool completeStoryEasy;
@property (assign) bool completeStoryNormal;
@property (assign) bool completeStoryHard;
@property (assign) bool completeStoryAll;

@end
