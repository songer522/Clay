//
//  RainyLevelEffects.m
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "RainyLevelEffects.h"
#import "Sprite.h"
#import "Animation.h"
#import "AnimationController.h"

@implementation RainyLevelEffects

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
 
        _raindrops = [[NSMutableArray alloc] initWithCapacity:6];
        
        for (int i=0; i<6; i++) {
            Sprite *raindrop = [Sprite spriteWithFile:@"blank.png"];
            [[AnimationController sharedController] replaceSprite:raindrop withAnimationNamed:@"rainyRaindropAnim"];
            [_raindrops addObject:raindrop];
        }
    }
    
    return self;
}

-(void)update:(float)dt
{
    for (Sprite *raindrop in _raindrops) {
        if ([[raindrop getAnimation] getCurrentFrameNumber] == 5) {
            ccp
        }
    }
    for (Laser *laser in _lasers) {
        [laser update:dt];
    }
}

-(void)dealloc
{
    [_lasers removeAllObjects];
    [_lasers release];
    [super dealloc];
}

@end
