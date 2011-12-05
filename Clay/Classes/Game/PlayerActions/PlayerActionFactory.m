//
//  PlayerActionFactory.m
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionFactory.h"
#import "PlayerActionBlock.h"
#import "PlayerActionBlow.h"
#import "PlayerActionDodge.h"
#import "PlayerActionKick.h"
#import "PlayerActionShoot.h"
#import "PlayerActionSlowTime.h"
#import "PlayerActionSpin.h"
#import "PlayerActionWoo.h"

@implementation PlayerActionFactory


+(id<PlayerActionProtocol>)buildPlayerAction:(PlayerActionType)type
{
    switch (type) {
        case PLAYER_ACTION_BLOCK:
            return [PlayerActionBlock instance];
            break;
        case PLAYER_ACTION_BLOW:
            return [PlayerActionBlow instance];
            break;
        case PLAYER_ACTION_DODGE:
            return [PlayerActionDodge instance];
            break;
        case PLAYER_ACTION_KICK:
            return [PlayerActionKick instance];
            break;
        case PLAYER_ACTION_SHOOT:
            return [PlayerActionShoot instance];
            break;
        case PLAYER_ACTION_SLOW_TIME:
            return [PlayerActionSlowTime instance];
            break;
        case PLAYER_ACTION_SPIN:
            return [PlayerActionSpin instance];
            break;
        case PLAYER_ACTION_WOO:
            return [PlayerActionWoo instance];
            break;
        default:
            NSLog(@"PlayerActionFactory:buildPlayerAction - Error! Wrong type selected");
            break;
    }
    
    return nil;
}

-(void)dealloc
{
    [super dealloc];
}

@end
