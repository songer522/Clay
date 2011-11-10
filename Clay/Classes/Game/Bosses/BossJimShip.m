//
//  BossJimShip.m
//  Clay
//
//  Created by Brian Cable on 11/7/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GameObject.h"
#import "BossJimShip.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Sprite.h"
#import "Camera.h"
#import "LevelManager.h"
#import "Level.h"
#import "SoundEngine.h"
#import "Projectile.h"

@implementation BossJimShip


-(void)startBoss
{
    _level = [[LevelManager shared] currentLevel];
    
    _velocity = CGPointMake(-5.0f, 0.0f);
    _targetOnScreen = CGRectMake(240, 100, 160, 400);
    
    [_sprite setAlpha:1.0f];
    [[_sprite getCCSprite] setVisible:YES];

    
    _waitToShoot = 5.0f;
    xthrust = -1;
    ythrust = 0;
    _firstUpdate = true;
    
    for (int i=0; i<3; i++) {
        Projectile *_bullet = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_BOSS_SHIP_BULLET];
        [_bullet setActive:NO];
    }
    _replaceProjectileId = 0;
}

-(void)setSprite:(Sprite *)sprite
{
    _sprite = sprite;
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"jimSpaceshipAnim"];    
    //[_sprite setPosition:ccp(300,200)];
}


-(void)shootBullet
{
    [[SoundEngine shared] playSound:@"jimShipShoot"];
    
    /*
    GameObject *object = [_level addObstacleNamed:name];
    CGPoint point = [[Camera sharedCamera] convertToWorldXY:[_sprite getPosition]];
    //[object setPosition:ccp(point.x + 50,point.y + 150)];
    [object setPosition:[[Camera sharedCamera] convertToWorldXY:ccp(50,50)]];
    [object setVx:50.0f];
    [object setVy:5.0f];    
    */
}

-(void)updateGun:(float)dt
{
    _waitToShoot -= dt;
    if (_waitToShoot<=0.0f) {
        _waitToShoot = rand()%4 + 0.5f;
        [self shootBullet];
    }
}

-(void)update:(float)dt
{
    //have to reposition for now because the position gets set like three times in gameobject, but for the time being we need to call it
    //so we can put it under the right layers
    if (_firstUpdate) {
        _firstUpdate = false;
        _velocity = CGPointMake(-5.0f, 0.0f);
        [_sprite setScreenPosition:ccp(300,230)];
    }
    
    [self updateVelocity:dt];
    [self updateGun:dt];
    
    CGPoint position = [_sprite getPosition];
    
    [_sprite setScreenPosition:CGPointMake(position.x + _velocity.x, position.y + _velocity.y)];
}

-(void)updateVelocity:(float)dt
{
    float rate = 6.0f * dt;
    float iterations = 10;
    
    CGPoint position = [_sprite getPosition];
    
    float futureXPosition = position.x + (_velocity.x * rate * iterations);
    if (futureXPosition < _targetOnScreen.origin.x) {
        xthrust = 1;
    } else if(futureXPosition > (_targetOnScreen.origin.x + _targetOnScreen.size.width)) {
        xthrust = -1;
    }
    
    if (position.y > 260) {
        ythrust = 0;
    } else if (position.y < 200) {
        ythrust = 1;
    }
    
    float dragX = 0.95f;
    float gravity = 5.0f;
    _velocity.y = dragX * (_velocity.y + (ythrust * 7.0f - gravity) * rate);
    _velocity.x = (_velocity.x + (xthrust * 15.0f) * 0.4f * rate);
    
    float max = 2.0f;
    if (_velocity.x < -max) {
        _velocity.x = -max;
    } else if(_velocity.x > max) {
        _velocity.x = max;
    }
    
    if (_velocity.y < -max) {
        _velocity.y = -max;
    } else if(_velocity.y > max) {
        _velocity.y = max;
    }
    
}


@end
