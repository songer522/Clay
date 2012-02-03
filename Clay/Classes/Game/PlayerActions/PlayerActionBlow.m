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
#import "GCState.h"
#import "GCHelper.h"

@implementation PlayerActionBlow
-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 0.3f;
    _wind = [Sprite spriteWithFile:@"blank.png"];
    _windProjectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_PLAYER_BLOWING];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 30, 140, 140)];
    }
    else
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 75, 140, 140)];
    }
    [super initialize];    
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        
        [_parent endTurbo:false];
        [_parent setPlayerAnimation:PLAYER_ANIM_BLOW];

        _duration = 0.78f;
        _startedWindAnimation = false;

        _hasKilledEnemy = false;
        _hasKilledSuperEnemy = false;
        
        [[_parent getSpeed] startBlow];
        [[_parent getSpeed] stop];
    }
}

-(void)endAction
{
    [[_wind getCCSprite] setVisible:NO];
    [[_parent getSpeed] start];
    [_windProjectile disable];
    [[_parent getSpeed] endBlow];
    [super endAction];
}

-(void)cancelAction
{
    //[_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    [[_parent getSpeed] start];
    [[_parent getSpeed] endBlow];
    [[_wind getCCSprite] setVisible:NO];
    [_windProjectile disable];    
    [super cancelAction];
}

-(void)freezeFireDemon:(GameObject *)obstacle
{
    int maxFireDemon = 200;
     //NSLog(@"%d",[GCState sharedInstance].demonsFreezed);
    if ([GCState sharedInstance].demonsFreezed < maxFireDemon) {
        [GCState sharedInstance].demonsFreezed++;
        obstacle.hasAppeared=true;
        double pctComplete3 = ((double) [GCState sharedInstance].demonsFreezed / (int)maxFireDemon) * 100.0;
        if(pctComplete3 == 100.0)
        {
            //[[GCState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:gcAchievementFreeze200demon percentComplete:pctComplete3];
        }
    }
    
}



-(void)testBlowCollisions
{
    NSMutableArray *obstacles = [[[LevelManager shared] currentLevel] getActiveGameObjectList];
    for (GameObject *object in obstacles) {
        if(![object hasBeenHit] && [object getCollisionBehavior] == COLLISION_BEHAVIOR_FIRE_DEMON)
        {
            if([[[LevelManager shared] currentLevel] testCollisionWithGameObject:object Source:_windProjectile])
            {
                [object startCollision:true];
                if(!object.hasAppeared)
                    [self freezeFireDemon:object];
            }
        } else if(![object hasBeenHit] && [object getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_FIREFOX_PREATTACK) {
            if([[[LevelManager shared] currentLevel] testCollisionWithGameObject:object Source:_windProjectile])
            {
                [object startCollision:true];
            }
        }
    }
}



-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
    } else {
        _isActive = true;
        
        if (!_startedWindAnimation) {
            if (_duration <= 0.58) {
                _startedWindAnimation = true;
                [_windProjectile reset];

                [[SoundEngine shared] playSound:@"blowAction"];
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
        
        if (_duration <= 0.37f) { //was 0.27f
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


-(bool) shouldActionStopPlayer
{
    return true;
}


-(bool)canStartInMidAir
{
    return false;
}

-(void)dealloc
{
    [_wind release];
    [_windProjectile release];
    [super dealloc];
}

@end
