//
//  BossFactory.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Boss.h"

typedef enum {
    BOSS_SPACESHIP,
    BOSS_FINAL_JIM
}BossType;

@interface BossFactory : Boss
{

}

+(id<BossProtocol>)buildWithType:(BossType)type;
+(id<BossProtocol>)buildWithString:(NSString*)type;

@end
