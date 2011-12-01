//
//  RainyLevelEffects.m
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "RainyLevelEffects.h"
#import "Raindrop.h"
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
            Raindrop *raindrop = [Raindrop instance];
            [_raindrops addObject:raindrop];
        }
    }
    
    return self;
}

-(void)update:(float)dt
{
    for (Raindrop *raindrop in _raindrops) {
        [raindrop update:dt];
    }
}

-(void)dealloc
{
    [_raindrops removeAllObjects];
    [_rainBehindTim release];
    [_lightning release];
    [super dealloc];
}

@end
