//
//  PlayerActionSlowTime.m
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionSlowTime.h"
#import "LevelManager.h"
#import "Level.h"
#import "MapObject.h"
#import "GameObject.h"
#import "Sprite.h"
#import "Animation.h"
#import "Player.h"
#import "RunningSpeed.h"
#import "GameLayer.h"
#import "LayerManager.h"
#import "BossFinalJim.h"


@implementation PlayerActionSlowTime

-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 0.4f;
    
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    _boss = [gameLayer getBoss];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        
        [super startAction];        
        [_parent endTurbo:false];
        
        [self updateSlowdown:0.2f];
        _duration = 5.00f;
        [_parent setPlayerAnimation:PLAYER_ANIM_SLOWTIME];
        [[_parent getSpeed] startBlow];
        [[_parent getSpeed] stop];
        [[_parent getSpeed] setVelocityModifier:0.8f];
        
        [[SoundEngine shared] playSound:@"darkSlowTimeAction"];
        
    }
}

-(void)endAction
{
    [self updateSlowdown:1.0f];
    [[_parent getSpeed] setVelocityModifier:1.0f];
    [self setKilledEnemy:YES];
    [super endAction];
}

-(void)cancelAction
{
    //this gets called when the player hits something, so we use this to tell the boss to get closer
    [_boss triggerGetCloser];
    
    
    
    //NOTE: for now, can't be cancelled
    //if this gets undone in the future, keep in mind you'll need to write an exception for
    //slowdowns, because they call 'startcollision' constantly, which calls cancelAction
    return;
    
    //[self updateSlowdown:1.0f];
    //[super cancelAction];
}


-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
    } else {
        _isActive = true;
    }
    [super update:dt];
}

-(void)updateSlowdown:(float)modifier
{
    float animModifier = modifier * 2.0f;
    if (animModifier > 1.0f) {
        animModifier = 1.0f;
    }
    
    NSMutableArray *mapObjects = [[LevelManager shared] currentLevel].obstacleSprites;
    for (MapObject *mapObject in mapObjects) {
        GameObject *obstacle = mapObject.object;
        obstacle.slowTimeModifier = modifier;
        
        //not working yet
        Animation *anim = [[obstacle getSprite] getAnimation];
        if(anim!=nil) {
            [anim changeAnimationSpeed:animModifier];
        }
        
    }
    
    [_boss changeAnimationSpeed:animModifier];
}

-(bool)canStartInMidAir
{
    return true;
}

-(bool) playerAllowedToJump
{
    return true;
}

-(bool) playerAllowedToSprint
{
    return true;
}

-(void)dealloc
{
    [super dealloc];
}

@end
