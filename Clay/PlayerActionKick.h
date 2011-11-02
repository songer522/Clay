//
//  PlayerActionKick.h
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

@class Projectile;

@interface PlayerActionKick : PlayerAction
{
    Projectile *_kick;
    bool _madeFootProjectile;
    
}

-(void)testKickCollisions;

@end
