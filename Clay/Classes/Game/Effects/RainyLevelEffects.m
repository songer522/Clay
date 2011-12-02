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
#import "LevelManager.h"
#import "Player.h"
#import "Lightning.h"

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
        
        _rainBehindTim = [Sprite instance];
        [_rainBehindTim setAnimationByName:@"rainyBehindTimAnim"];
        [[_rainBehindTim getCCSprite] setAnchorPoint:ccp(0.5f,0)];
        
        _lightning = [Lightning instance];
    }
    
    return self;
}

-(void)update:(float)dt
{
    Player *player = [[LayerManager sharedLayers] getPlayer];
    
    //IPAD FIX
    //place underneath tim's feet
    [_rainBehindTim setPosition:CGPointMake(player.x - 40, player.y - 12)];
    if (player.isInMidAir) {
        [[_rainBehindTim getCCSprite] setVisible:NO];
    } else {
        [[_rainBehindTim getCCSprite] setVisible:YES];
    }
    
    for (Raindrop *raindrop in _raindrops) {
        [raindrop update:dt];
    }
    
    [_lightning update:dt];
}

-(void)triggerWind:(TriggerType)duration
{
    switch (duration) {
        case TRIGGER_WIND_SHORT:
            _windDuration = 1.0f;
            break;
        case TRIGGER_WIND_MEDIUM:
            _windDuration = 2.0f;
            break;
        case TRIGGER_WIND_LONG:
            _windDuration = 4.0f;
            break;
        default:
            break;
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
