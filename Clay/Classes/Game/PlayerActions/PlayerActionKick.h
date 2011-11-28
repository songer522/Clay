//
//  PlayerActionKick.h
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Player action for the kick action that is used in level 2 (barn level). When the player has gone through enough of the kicking animation, it will then create a projectile located at the foot to be used to test to see if any chickens can be kicked. Could possibly be used for other levels. A successful chicken kicking will restore a health point back.

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

@class Projectile;

@interface PlayerActionKick : PlayerAction
{
    Projectile *_kick;
    bool _madeFootProjectile;
    
}

-(void)testKickCollisions;
-(void)updateBoundingBox;


@end
