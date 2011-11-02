//
//  PlayerActionDodge.h
//  Clay
//
//  Created by Brian Cable on 10/18/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Player action for the dodge action (which is essentially the dancing action) which is used in level 4 (disco level). This action makes Tim invulnerable to the dancers in the level for the duration (might want to make it not work for the breakdancers though). A successful dodge will restore one health point back.

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

@interface PlayerActionDodge : PlayerAction
{
    CGPoint _preActionPlayerPosition;
}

@end
