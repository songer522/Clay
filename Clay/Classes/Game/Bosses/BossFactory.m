//
//  BossFactory.m
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "BossFactory.h"

#import "BossChicken.h"
#import "BossDisco.h"
#import "BossZombies.h"
#import "BossDevilJim.h"
#import "BossWhale.h"
#import "BossFinalJim.h"
#import "BossJimShip.h"

@implementation BossFactory

+(id<BossProtocol>)buildWithType:(BossType)type
{
    switch (type) {
        case BOSS_CHICKEN:
            return [BossChicken instance];
            break;
        case BOSS_DISCO:
            return [BossDisco instance];
            break;
        case BOSS_ZOMBIES:
            return [BossZombies instance];
            break;
        case BOSS_SPACESHIP:
            return [BossJimShip instance];
            break;
        case BOSS_DEVIL_JIM:
            return [BossDevilJim instance];
            break;
        case BOSS_WHALE:
            return [BossWhale instance];
            break;
        case BOSS_FINAL_JIM:
            return [BossFinalJim instance];
            break;
        default:
            NSLog(@"BossFactory:build - Error! Not yet implemented.");
            break;
    }
    
    return nil;
}

+(id<BossProtocol>)buildWithString:(NSString*)type
{
    if ([type isEqualToString:@"chicken"])
    {
        return [self buildWithType:BOSS_CHICKEN];
    }
    else if([type isEqualToString:@"disco"])
    {
        return [self buildWithType:BOSS_DISCO];
    }
    else if([type isEqualToString:@"zombies"])
    {
        return [self buildWithType:BOSS_ZOMBIES];
    }
    else
    {
        NSLog(@"BossFactory:build - Error! %@ not yet implemented.",type);  
    }
    
    return nil;
}

@end
