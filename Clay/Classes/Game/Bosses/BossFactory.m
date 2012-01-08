//
//  BossFactory.m
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "BossFactory.h"

#import "BossFinalJim.h"
#import "BossFinal.h"
#import "BossJimShip.h"

@implementation BossFactory

+(id<BossProtocol>)buildWithType:(BossType)type
{
    switch (type) {
        case BOSS_SPACESHIP:
            return [BossJimShip instance];
            break;
        case BOSS_FINAL_JIM:
            return [BossFinalJim instance];
            break;
        case BOSS_FINAL_BOSS:
            return [BossFinal instance];
            break;
        default:
            //NSLog(@"BossFactory:build - Error! Not yet implemented.");
            break;
    }
    
    return nil;
}

+(id<BossProtocol>)buildWithString:(NSString*)type
{
    NSLog(@"BossFactory:build - Error! %@ not yet implemented.",type);  
    return nil;
}

@end
