//
//  ComicLayer.h
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCLayer.h"
#import "cocos2d.h"

@class ComicManager;

typedef enum {
    BLACKBOX_IN = 1,
    BLACKBOX_OUT = -1,
    BLACKBOX_IDLE = 0
}BlackBoxTransition;

@interface ComicLayer : CCLayer
{
    float _position;
    float _targetPosition;
    float _timeToWait;
    bool _atTarget;
    
    ComicManager *_parent;
    
    BlackBoxTransition _transition;
}

@property (nonatomic,retain) ComicManager *parent;


+(id)instance;

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2;
-(void)startTransition:(BlackBoxTransition)transition;

@end
