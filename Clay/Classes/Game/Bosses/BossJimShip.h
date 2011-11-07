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

@interface BossJimShip : Boss
{
    Sprite *_sprite;
    CGPoint _velocity;
    CGRect _targetOnScreen;
    
    CGPoint _thrust; //which directions the "thrusters" are going, -1,0,1 in X, or 1,0 in y
}

-(void)updateVelocity:(float)dt;


@end
