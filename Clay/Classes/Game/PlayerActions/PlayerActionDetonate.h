//
//  PlayerActionDetonate.h
//  Clay
//
//  Created by Brian Cable on 1/12/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

@class Boss;
@class Sprite;

@interface PlayerActionDetonate : PlayerAction
{
    float _slowdown;
    float _waitForDetonate;
    
    bool _playedDetonateSound;
    Boss *_boss;
}


-(void)pressDetonator;

@end
