//
//  PlayerActionSlowTime.h
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@class Boss;
@class Sprite;

@interface PlayerActionSlowTime : PlayerAction
{
    float _slowdown;
    Sprite *_sprite;

    float _waitToHideSprite;
    
    Boss *_boss;
}

-(void)updateSlowdown:(float)modifier;

@end
