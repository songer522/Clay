//
//  SoundEngine.m
//  Clay
//
//  Created by Brian Cable on 9/23/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "SoundEngine.h"
#import "SimpleAudioEngine.h"

@implementation SoundEngine

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"footsteps.caf"];
    }
    
    return self;
}

+(id)instance
{
    return [[self alloc] init];
}

+(void) playSound:(NSString*)sound
{
    [[SimpleAudioEngine sharedEngine] playEffect:sound];
}

@end
