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


@implementation PlayerActionFactory


+(id<PlayerAction>)buildPlayerAction:(PlayerActionType)type
{
    switch (type) {
        case PLAYER_ACTION_KICK:
            return [PlayerActionKick instance];
            break;
        case PLAYER_ACTION_WOO:
            return [PlayerActionWoo instance];
        default:
            NSLog(@"PlayerActionFactory:buildPlayerAction - Error! Wrong type selected");
            break;
    }
    
    return nil;
}

@end
