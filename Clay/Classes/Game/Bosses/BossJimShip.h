//
//  BossJimShip.h
//  Clay
//
//  Created by Brian Cable on 11/7/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Boss.h"

@class Sprite;

typedef enum {
    RETRO_HURDLE = 0,
    RETRO_PIG = 1,
    RETRO_BIRD = 2,
    RETRO_GARBAGE = 3,
    RETRO_ZOMBIE = 4
}RetroObstacleType;

@interface BossJimShip : Boss
{
    Sprite *_sprite;
    CGPoint _velocity;
    CGRect _targetOnScreen;
    
    int xthrust;
    int ythrust;
    
    bool _firstUpdate;
    
    CGPoint _thrust; //which directions the "thrusters" are going, -1,0,1 in X, or 1,0 in y
    
    float _waitToShoot;
}

-(void)updateVelocity:(float)dt;
-(void)updateCannon:(float)dt;

@end
