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

#define kPlayerActionDodgeMoveX 20.0f
#define kPlayerActionDodgeFullDuration 0.4f;
#define kPlayerActionDodgeActiveWhileDurationLessThan 0.2f

@implementation PlayerActionKick

-(void) initialize
{
    [super initialize];
    _kick = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_PLAYER_KICK];
    [_kick setBoundingBox:CGRectMake(0, 0, 35, 35)];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        _duration = kPlayerActionDodgeFullDuration;
        _madeFootProjectile = false;
        _cooldown = 1.0f;
        [_parent endTurbo];
        [_kick reset];
        [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"kickingAnim"];
    }
    [super startAction];
}

-(void)update:(float)dt
{
    if (_inAction) {
        if (_duration < kPlayerActionDodgeActiveWhileDurationLessThan) {
            _isActive = true;
            [_kick setActive:YES];
            
            GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
            CGPoint position = [gameLayer.player getPosition];
            position.x += 10.0f;
            position.y -= 5.0f;
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

-(void)testKickCollisions
{
    NSMutableArray *obstacles = [[LevelManager shared] getObstacleArray];
    for (MapObject *mapObject in obstacles) {
        GameObject *object = mapObject.object;
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
    [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"runningAnim"];
    [_kick disable];
    [super cancelAction];
}

-(void)endAction
{
    [_parent pushAfterAnimation:kPlayerActionDodgeMoveX];
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
    [super dealloc];
}


@end
