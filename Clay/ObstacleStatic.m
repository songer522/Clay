//
//  ObstacleStatic.m
//  Clay
//
//  Created by Brian Cable on 10/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObstacleStatic.h"

@implementation ObstacleStatic

-(void)startCollision
{
    _fallingVelocity = 525.0f;
    _angle = 0.0f;
}

-(void)update:(float)dt
{
    if ([self getActive]) {
        _angle += _fallingVelocity * dt;
        if (_angle >= 90) {
            _angle = 90;
            [self setActive:NO];
        }
        [self getCCSprite].rotation = _angle;
    }
}

-(void)reset
{
    _angle = 0.0f;
    [self getCCSprite].rotation = _angle;
}

@end
