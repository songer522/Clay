//
//  PlayerActionFactory.m
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionFactory.h"
#import "PlayerActionKick.h"
#import "PlayerActionWoo.h"
#import "PlayerActionDodge.h"
#import "PlayerActionShoot.h"
#import "PlayerActionBlock.h"


@implementation PlayerActionFactory


+(id<PlayerActionProtocol>)buildPlayerAction:(PlayerActionType)type
{
    switch (type) {
        case PLAYER_ACTION_KICK:
            return [PlayerActionKick instance];
            break;
        case PLAYER_ACTION_WOO:
            return [PlayerActionWoo instance];
            break;
        case PLAYER_ACTION_DODGE:
            return [PlayerActionDodge instance];
            break;
        case PLAYER_ACTION_SHOOT:
            return [PlayerActionShoot instance];
            break;
        case PLAYER_ACTION_BLOCK:
            return [PlayerActionBlock instance];
        default:
            NSLog(@"PlayerActionFactory:buildPlayerAction - Error! Wrong type selected");
            break;
    }
    
    return nil;
}

@end
