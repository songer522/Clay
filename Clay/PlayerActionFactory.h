//
//  PlayerActionFactory.h
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Factory class for creating the third actions that the player can do. Called by the player class.

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

typedef enum {
    PLAYER_ACTION_KICK,
    PLAYER_ACTION_WOO,
    PLAYER_ACTION_DODGE,
    PLAYER_ACTION_SHOOT,
    PLAYER_ACTION_MAGNET
}PlayerActionType;

@interface PlayerActionFactory : NSObject
{
    
}

+(id<PlayerActionProtocol>)buildPlayerAction:(PlayerActionType)type;

@end
