//
//  PlayerActionPunch.m
//  Clay
//
//  Created by Brian Cable on 1/26/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionPunch.h"
#import "Projectile.h"
#import "Level.h"
#import "LevelManager.h"
#import "GameSettings.h"
#import "RunningSpeed.h"
#import "Player.h"

@implementation PlayerActionPunch

#define kPlayerActionKickMoveX 20.0f
#define kPlayerActionKickFullDuration 0.605f;
#define kPlayerActionKickActiveWhileDurationLessThan 0.75f

-(void) initialize
{
    [super initialize];
    _punch = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_DOJO_PUNCH];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
    {
        [_punch setBoundingBox:CGRectMake(0, 0, 35, 35)];
    }
    else
    {
        [_punch setBoundingBox:CGRectMake(0, 35, 35, 35)];
    }
    _cooldownStart = 0.2f;
    _cooldown = 0.0f;
    _canTrigger = true;
    _level = [[LevelManager shared] currentLevel];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        _duration = kPlayerActionKickFullDuration;
        _madePunchProjectile = false;
        [_parent endTurbo:false];
        [_punch reset];
        [_parent setPlayerAnimation:PLAYER_ANIM_PUNCH];
        [[_parent getSpeed] setVelocityModifier:0.8f];
    }
    [super startAction];
}

-(void)update:(float)dt
{
    if (_inAction) {
        [self updateBoundingBox];
        
        CGPoint position = [_parent getPosition];
        
        if ([[GameSettings shared] usingHighResolutionGraphics])
        {
            position.x += 10.0f;
            position.y += 30.0f;
        }
        else
        {
            position.x += 10.0f;
            position.y += 68.0f;
            
        }
        [_punch setPosition:position];
        
        if (!_madePunchProjectile) {
            _madePunchProjectile = true;
        }
        
        [self testPunchCollisions];
    }
    [super update:dt];
}

-(void)updateBoundingBox
{
    int startX = 0;
    int projWidth = 35;
    
    int frame = [[[_parent getSprite] getAnimation] getCurrentFrameNumber];
    switch (frame) {
        case 2:
        case 3:
        case 4:
        case 5:
            startX = 0;
            projWidth = 45;
            [_punch setActive:true];
            break;
        case 6:
        case 7:
        case 8:
            startX = 0;
            projWidth = 30;
            [_punch setActive:true];
            break;
        default:
            [_punch setActive:false];
            startX = 0;
            projWidth = 1;
            break;
    }
    
    if ([[GameSettings shared] usingHighResolutionGraphics])
    {
        [_punch setBoundingBox:CGRectMake(startX, 0, projWidth, 35)];
    }
    else
    {
        [_punch setBoundingBox:CGRectMake(startX, 35, projWidth, 35)];
    }
    
}

-(void)testPunchCollisions
{
    //guard
    if(![_punch getActive]) { return; }

    NSMutableArray *obstacles = [[[LevelManager shared] currentLevel] getActiveGameObjectList];
    for (GameObject *object in obstacles) {
        if([object getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_DOJO_DROP_NINJA || [object getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_DOJO_WHITE_NINJA_CHARGING)
        {
            if([_level testCollisionWithGameObject:object Source:_punch])
            {
                [object startCollision:YES];
                [self setKilledEnemy:YES];
            }
        }
    }
}

-(void)cancelAction
{
    [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    [_punch setActive:false];
    [_punch disable];
    [[_parent getSpeed] setVelocityModifier:1.0f];
    [super cancelAction];
}

-(void)endAction
{
    [_punch setActive:false];
    [_punch disable];
    [[_parent getSpeed] setVelocityModifier:1.0f];

    [super endAction];
}

-(NSMutableArray*)getProjectiles
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:_punch, nil];
    return array;
}

-(bool)shouldTriggerPlayerHurtCollision
{
    return true;
}


-(void)dealloc
{
    [_punch release];
    [super dealloc];
}

@end
