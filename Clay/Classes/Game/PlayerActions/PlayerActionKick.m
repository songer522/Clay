//
//  PlayerActionKick.m
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionKick.h"
#import "AnimationController.h"
#import "RunningSpeed.h"
#import "Player.h"
#import "Projectile.h"
#import "LevelManager.h"
#import "Level.h"
#import "MapObject.h"
#import "GameObject.h"
#import "LayerManager.h"
#import "GameLayer.h"
#import "GameSettings.h"

#define kPlayerActionKickMoveX 20.0f
#define kPlayerActionKickFullDuration 0.38f;
#define kPlayerActionKickActiveWhileDurationLessThan 0.75f

@implementation PlayerActionKick

-(void) initialize
{
    [super initialize];
    _kick = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_PLAYER_KICK];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
    {
    [_kick setBoundingBox:CGRectMake(0, 0, 35, 35)];
    }
    else
    {
    [_kick setBoundingBox:CGRectMake(0, 35, 35, 35)];
    }
    _cooldownStart = 0.6f;
    _cooldown = 0.0f;
    _canTrigger = true;
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        _duration = kPlayerActionKickFullDuration;
        _madeFootProjectile = false;
        [_parent endTurbo];
        [_kick reset];
        [_parent setPlayerAnimation:PLAYER_ANIM_KICK];
    }
    [super startAction];
}

-(void)update:(float)dt
{
    if (_inAction) {
        if (_duration < kPlayerActionKickActiveWhileDurationLessThan) {
            _isActive = true;
            [_kick setActive:YES];
            
            [self updateBoundingBox];
            
            CGPoint position = [[[LayerManager sharedLayers] getPlayer] getPosition];
            
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
            {
                position.x += 10.0f;
                position.y -= 5.0f;
            }
            else
            {
                position.x += 10.0f;
                position.y += 33.0f;
                
            }
            [_kick setPosition:position];
             
            if (!_madeFootProjectile) {
                _madeFootProjectile = true;
                [[_parent getSpeed] startKick];
            }
            
            [self testKickCollisions];
            
        } else {
            [_kick setActive:NO];
            _isActive = false;
        }
    }
    [super update:dt];
}

-(void)updateBoundingBox
{
    int startX = 0;
    int projWidth = 35;
    
    int frame = [[[_parent getSprite] getAnimation] getCurrentFrameNumber];
    switch (frame) {
        case 1:
            startX = 55;
            projWidth = 25;
            break;
        case 2:
            startX = 30;
            projWidth = 35;
            break;
        case 3:
            startX = 0;
            projWidth = 45;
            break;
        default:
            projWidth = 0;
            break;
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
    {
        [_kick setBoundingBox:CGRectMake(startX, 0, projWidth, 35)];
    }
    else
    {
        [_kick setBoundingBox:CGRectMake(startX, 35, projWidth, 35)];
    }

}

-(void)testKickCollisions
{
    NSMutableArray *obstacles = [[[LevelManager shared] currentLevel] getActiveGameObjectList];
    for (GameObject *object in obstacles) {
        if([object getCollisionBehavior] == COLLISION_BEHAVIOR_HEN_KICKED)
        {
           if([[[LevelManager shared] currentLevel] testCollisionWithGameObject:object Source:_kick])
           {
               [object startCollision];
               [object special_kickHen];
           }
        }
    }
}

-(void)cancelAction
{
    [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    [_kick disable];
    [super cancelAction];
}

-(void)endAction
{
    [_parent pushAfterAnimation:kPlayerActionKickMoveX];
    [_kick disable];
    [super endAction];
}

-(NSMutableArray*)getProjectiles
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:_kick, nil];
    return array;
}

-(bool)shouldTriggerPlayerHurtCollision
{
    return true;
}


-(void)dealloc
{
    [_kick release];
    [super dealloc];
}

@end
