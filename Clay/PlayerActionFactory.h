//
//  PlayerActionFactory.h
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

typedef enum {
    PLAYER_ACTION_KICK,
    PLAYER_ACTION_WOO,
    PLAYER_ACTION_DODGE
}PlayerActionType;

@interface PlayerActionFactory : NSObject
{
    
}

+(id<PlayerAction>)buildPlayerAction:(PlayerActionType)type;

@end
