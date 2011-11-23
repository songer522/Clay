//
//  PlayerActionBlow.h
//  Clay
//
//  Created by Brian Cable on 11/22/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@class Sprite;
@class Projectile;

@interface PlayerActionBlow : PlayerAction
{
    Projectile *_windProjectile;

    Sprite *_wind;
}

@end
