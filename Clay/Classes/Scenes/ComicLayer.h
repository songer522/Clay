//
//  ComicLayer.h
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The layer where the black bars drop down and come back up before
//  the videos are played (which are the comics). Was originally going to be displayed
//  above the comics as well, hence the name.
//

#import <Foundation/Foundation.h>

#import "CCLayer.h"
#import "cocos2d.h"

@class ComicManager;

typedef enum {
    BLACKBOX_IN = 1,
    BLACKBOX_OUT = -1,
    BLACKBOX_WAIT = 2,
    BLACKBOX_IDLE = 0
}BlackBoxTransition;

@interface ComicLayer : CCLayer
{
    float _position;
    float _targetPosition;
    float _timeToWait;
    bool _atTarget;
    int _phase;
    float _rate;
    
    ComicManager *_comicManager; //weak reference
    
    BlackBoxTransition _transition;
}

@property (nonatomic,retain) ComicManager *comicManager;


+(id)instance;

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2;
-(void)startTransition:(BlackBoxTransition)transition;
-(void)drawBars:(float)position;

#pragma mark - private methods
-(void)blackBoxIn:(ccTime)dt;
-(void)blackBoxOut:(ccTime)dt;
-(void)secondTierBars;
-(void)moveBars:(ccTime)dt;
-(void)update:(ccTime)dt;
-(void)waitToPlayVideo:(float)time;

-(void)resetLayer;

@end
