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
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Footstep.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Craziness.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"HurdleCollision.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Jump1.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Jump2.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Noooo.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Supercharge.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"UhOh.wav"];
        //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"rock_bkg.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"rock_bkg.caf"];
        [CDAudioManager sharedManager].backgroundMusic.volume = 1.0f;
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
