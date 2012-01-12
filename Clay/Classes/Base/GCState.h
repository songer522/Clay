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
    int hurdlesJumpedOver;
    int peopleShuffled;
    int dogsJumpedOver;
    int zombiesShot;
    int attacksBlocked;
    int demonsFreezed;
    int frogsJumpedOver;
    
    
    int hurdlesHit;
    int cowsHit;
    int dancersHit;
    int birdsHit;
    int dogsHit;
    int zombiesHit;
    int viruesHit;
    int fireDemonHit;
    int frogsHit;
    int fishHit;
    int batHit;
    
    
    bool flawlessRun;
    bool completeStoryEasy;
    bool completeStoryNormal;
    bool completeStoryHard;
    bool completeStoryAll;
    
    bool _enabled;

}

+ (GCState *) sharedInstance;
- (void)save;

@property (assign) int chickensKickedIntoCows;
@property (assign) int timesDied;
@property (assign) int hurdlesJumpedOver;
@property (assign) int peopleShuffled;
@property (assign) int dogsJumpedOver;
@property (assign) int zombiesShot;
@property (assign) int attacksBlocked;
@property (assign) int demonsFreezed;
@property (assign) int frogsJumpedOver;
@property (assign) int hurdlesHit;
@property (assign) int cowsHit;
@property (assign) int dancersHit;
@property (assign) int birdsHit;
@property (assign) int dogsHit;
@property (assign) int zombiesHit;
@property (assign) int viruesHit;
@property (assign) int fireDemonHit;
@property (assign) int frogsHit;
@property (assign) int fishHit;
@property (assign) int batHit;

@property (assign) int enimiesCleared;
@property (assign) int timesWhooed;
@property (assign) int timesFellIntoDeathPit;
@property (assign) int timesFellDown;




@property (assign) bool completeStoryEasy;
@property (assign) bool completeStoryNormal;
@property (assign) bool completeStoryHard;
@property (assign) bool completeStoryAll;
@property (assign) bool flawlessRun;



@end
