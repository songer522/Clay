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

@implementation PlayerActionSlowTime

-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 0.4f;
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        
        _duration = 1.75f;
        
        [self updateSlowdown:0.2f];
    }
}

-(void)endAction
{
    [self updateSlowdown:1.0f];
    [super endAction];
}

-(void)cancelAction
{
    [self updateSlowdown:1.0f];
    [super cancelAction];
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
    NSMutableArray *mapObjects = [[LevelManager shared] currentLevel].obstacleSprites;
    for (MapObject *mapObject in mapObjects) {
        GameObject *obstacle = mapObject.object;
        obstacle.slowTimeModifier = modifier;
    }
}


-(bool)canStartInMidAir
{
    return true;
}

-(void)dealloc
{
    [super dealloc];
}

@end
