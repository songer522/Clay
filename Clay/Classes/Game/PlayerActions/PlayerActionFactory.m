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
#import "PlayerActionDetonate.h"
#import "PlayerActionPump.h"

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
            return [PlayerActionDetonate instance];
            break;
        case PLAYER_ACTION_SPIN:
            return [PlayerActionSpin instance];
            break;
        case PLAYER_ACTION_WOO:
            return [PlayerActionWoo instance];
            break;
        case PLAYER_ACTION_PUMP:
            return [PlayerActionPump instance];
            break;
        default:
            NSLog(@"PlayerActionFactory:buildPlayerAction - Error! Wrong type selected");
            break;
    }
    
    return nil;
}

+(PlayerAction*)buildPlayerActionFromName:(NSString*)action
{
    PlayerAction *_thirdAction = nil;
    
    if ([action compare:@"woo"] == NSOrderedSame) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_WOO];
    } else if([action compare:@"kick"] == NSOrderedSame) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_KICK];
    } else if([action isEqualToString:@"dodge"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_DODGE];
    } else if([action isEqualToString:@"shoot"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_SHOOT];
    } else if([action isEqualToString:@"block"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_BLOCK];
    } else if([action isEqualToString:@"blow"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_BLOW];
    } else if([action isEqualToString:@"spin"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_SPIN];
    } else if([action isEqualToString:@"slowtime"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_SLOW_TIME];
    } else if([action isEqualToString:@"pump"]) {
        _thirdAction = (PlayerAction*)[PlayerActionFactory buildPlayerAction:PLAYER_ACTION_PUMP];
    } else {
        NSLog(@"ERROR! PlayerActionFactory.m - No action found for %@.",action);
    }
    
    return _thirdAction;
}

+(NSString*)getButtonImageForAction:(NSString*)action
{
    NSString *buttonImage;
    if ([action isEqualToString:@"woo"]) {
        buttonImage = @"UI_Button_Woo.png";
    } else if([action isEqualToString:@"kick"]) {
        buttonImage = @"UI_Button_Kicking.png";
    } else if([action isEqualToString:@"dodge"]) {
        buttonImage = @"UI_Button_Dodging.png";
    } else if([action isEqualToString:@"shoot"]) {
        buttonImage = @"UI_Button_Shooting.png";
    } else if([action isEqualToString:@"block"]) {
        buttonImage = @"UI_Button_Blocking.png";
    } else if([action isEqualToString:@"blow"]) {
        buttonImage = @"UI_Button_Blowing.png";
    } else if([action isEqualToString:@"spin"]) {
        buttonImage = @"UI_Button_Swimming.png";
    } else if([action isEqualToString:@"slowtime"]) {
        //buttonImage = @"UI_Button_SlowTime.png";
        buttonImage = @"UI_Button_Detonating.png";
    } else if([action isEqualToString:@"pump"]) {
        buttonImage = @"UI_Button_BicepCurl.png";
    } else {
        buttonImage = @"";
    }
    
    return [NSString stringWithString:buttonImage];
}

-(void)dealloc
{
    [super dealloc];
}

@end
