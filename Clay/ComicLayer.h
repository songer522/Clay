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

typedef enum {
    BLACKBOX_IN = 1,
    BLACKBOX_OUT = -1,
    BLACKBOX_IDLE = 0
}BlackBoxTransition;

@interface ComicLayer : CCLayer
{
    float _position;
    float _targetPosition;
    
    BlackBoxTransition _transition;
}

+(id)instance;

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2;
-(void)startTransition:(BlackBoxTransition)transition;

@end
