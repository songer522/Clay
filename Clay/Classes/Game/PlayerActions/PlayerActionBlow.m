//
//  PlayerActionBlow.m
//  Clay
//
//  Created by Brian Cable on 11/22/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionBlow.h"
#import "Sprite.h"
#import "Skin.h"
#import "Projectile.h"
#import "Player.h"
#import "LevelManager.h"
#import "RunningSpeed.h"
#import "AnimationController.h"

@implementation PlayerActionBlow
-(void)initialize
{
    _cooldown = 0.0f;
    _wind = [Sprite spriteWithFile:@"blank.png"];
    _windProjectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_PLAYER_BLOWING];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 0, 110, 110)];
    }
    else
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 35, 110, 110)];
    }
    [super initialize];    
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        
        [_parent endTurbo];
        [_parent setPlayerAnimation:PLAYER_ANIM_BLOW];

        _duration = 0.78f;
        _cooldown = 0.6f;
        _startedWindAnimation = false;
        
        
        [[_parent getSpeed] startBlow];
        [[_parent getSpeed] stop];
    }
}

-(void)endAction
{
    [[_wind getCCSprite] setVisible:NO];
    [[_parent getSpeed] start];
    [_windProjectile disable];
    [super endAction];
}

-(void)cancelAction
{
    [_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    [[_parent getSpeed] start];
    [_windProjectile disable];
    
    _cooldown = 0.6f;
    [[_wind getCCSprite] setVisible:NO];
    [super cancelAction];
}

-(void)testBlowCollisions
{
    NSMutableArray *obstacles = [[[LevelManager shared] currentLevel] getActiveGameObjectList];
    for (GameObject *object in obstacles) {
        if([object getCollisionBehavior] == COLLISION_BEHAVIOR_FIRE_DEMON)
        {
            if([[[LevelManager shared] currentLevel] testCollisionWithGameObject:object Source:_windProjectile])
            {
                [object startCollision];
            }
        }
    }
}



-(void)update:(float)dt
{
    if (!_inAction) {
        if (_cooldown > 0.0f) {
            _cooldown -= dt;
        }
        _isActive = false;
    } else {
        _isActive = true;
        
        if (!_startedWindAnimation) {
            if (_duration <= 0.58) {
                _startedWindAnimation = true;
                [_windProjectile reset];

                [[AnimationController sharedController] replaceSprite:_wind withAnimationNamed:@"blowingWindAnim"];
                [[_wind getCCSprite] setVisible:YES];            
                CGPoint position = [_parent getPosition];
                [_wind setPosition:CGPointMake(position.x + 15, position.y + 30)];
                [_windProjectile setPosition:CGPointMake(position.x + 15, position.y + 30)];
            }
        } else {
            CGPoint position = [_parent getPosition];
            [_wind setPosition:CGPointMake(position.x + 15, position.y + 30)];            
            [_windProjectile setPosition:CGPointMake(position.x + 15, position.y + 30)];
        }
        
        if (_duration <= 0.27f) {
            [self testBlowCollisions];
        }
    }
    [super update:dt];
}




-(NSMutableArray*)getProjectiles
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:_windProjectile, nil];
    return array;
}


-(bool)canStartInMidAir
{
    return false;
}

-(void)dealloc
{
    [_wind release];
    [super dealloc];
}

@end
