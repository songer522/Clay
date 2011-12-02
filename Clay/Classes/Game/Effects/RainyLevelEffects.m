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
#import "MapObject.h"
#import "GameObject.h"
#import "Sprite.h"

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
        
        _player = [[LayerManager sharedLayers] getPlayer];
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
    
    [self updateWind:dt];
}

-(void)updateWind:(float)dt
{
    //guard
    if (_windDuration <= 0.0f) { return; }
    
    //slow down tim by triggering same code as sand pits
    [_player startCollision:PLAYER_EFFECT_SLOWDOWN Source:nil];
    
    //speed up umbrella obstacles (and maybe others)
    
    
    //if the time expired, end the wind effect

    
    //check to see if the wind effect is finished
    _windDuration -= dt;
    if (_windDuration <= 0.0f) {
        [self endWindEffect];
    }

}

-(void)triggerWind:(TriggerType)duration
{
    //set how long the wind will last and which sound to play
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
    
    //tell the player it's the wind causing this, so don't play sound
    _player.isWindy = true;
    
    //tell trees in background to change animation
    NSMutableArray *trees = [[[LevelManager shared] currentLevel] getBackgroundObjectsList];
    for (MapObject *mapObject in trees) {
        GameObject *tree = mapObject.object;
        if (tree.CurrentBehavior == COLLISION_BEHAVIOR_RAINY_TREE_A) {
            [[AnimationController sharedController] replaceSprite:tree.sprite withAnimationNamed:@"rainyTreeAWindAnim"];
        } else if(tree.CurrentBehavior == COLLISION_BEHAVIOR_RAINY_TREE_B) {
            [[AnimationController sharedController] replaceSprite:tree.sprite withAnimationNamed:@"rainyTreeBWindAnim"];             
        }
    }
}

-(void)endWindEffect
{
    _player.isWindy = false;
    
    //tell the trees in background to go back to normal animation
    NSMutableArray *trees = [[[LevelManager shared] currentLevel] getBackgroundObjectsList];
    for (MapObject *mapObject in trees) {
        GameObject *tree = mapObject.object;
        if (tree.CurrentBehavior == COLLISION_BEHAVIOR_RAINY_TREE_A) {
            [[AnimationController sharedController] replaceSprite:tree.sprite withAnimationNamed:@"rainyTreeAIdleAnim"];
        } else if(tree.CurrentBehavior == COLLISION_BEHAVIOR_RAINY_TREE_B) {
            [[AnimationController sharedController] replaceSprite:tree.sprite withAnimationNamed:@"rainyTreeBIdleAnim"];             
        }
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
