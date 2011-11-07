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
}

+ (GCState *) sharedInstance;
- (void)save;

@property (assign) int chickensKickedIntoCows;

@end
