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
#import "LayerManager.h"
#import "SoundEngine.h"
#import "Projectile.h"
#import "Player.h"
#import "PlayerAction.h"


@implementation BossJimShip


-(void)startBoss
{
    _level = [[LevelManager shared] currentLevel];
    
    _velocity = CGPointMake(-5.0f, 0.0f);
    _targetOnScreen = CGRectMake(240, 100, 160, 400);
    
    [_sprite setAlpha:1.0f];
    [[_sprite getCCSprite] setVisible:YES];
    
    _bullets = [[NSMutableArray alloc] initWithCapacity:3];
    
    _waitToShoot = -1.0f;
    xthrust = -1;
    ythrust = 0;
    _firstUpdate = true;

    _replaceProjectileId = 0;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:@"player died" object:nil];
}

-(void)setSprite:(Sprite *)sprite
{
    _sprite = sprite;
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"jimSpaceshipAnim"];
}


-(void)triggerAttack
{
    [[_cannonAnim getCCSprite] setVisible:YES];
    [[AnimationController sharedController] replaceSprite:_cannonAnim withAnimationNamed:@"jimSpaceshipWarningAnim"];
    _waitToShoot = 0.55f;
    [[SoundEngine shared] playSound:@"jimShipCharge"];
}

-(void)triggerAttack2 //giant cannon
{
    [[_megaCannonAnim getCCSprite] setVisible:YES];
    [[AnimationController sharedController] replaceSprite:_megaCannonAnim withAnimationNamed:@"computerMegaCannonAnim"];
    _waitToShoot = 0.55;
    [[SoundEngine shared] playSound:@""];
    
}

-(void)shootBullet
{
    [[SoundEngine shared] playSound:@"jimShipShoot"];
    
    Projectile *bullet = [_bullets objectAtIndex:_replaceProjectileId];
    _replaceProjectileId = (_replaceProjectileId + 1) % 3;
    
    [[_cannonAnim getCCSprite] setVisible:NO];
    
    CGPoint shipWorldPos = [[Camera sharedCamera] convertToWorldXY:[_sprite getScreenPosition]];    
    [bullet setPosition:CGPointMake(shipWorldPos.x - 120,shipWorldPos.y + 20.0f)];
    [bullet reset];
}

-(void)shootMegaCannon
{
    [[SoundEngine shared] playSound:@"jimShipShoot"];

    [[_megaCannonAnim getCCSprite] setVisible:NO];
    
    CGPoint shipWorldPos = [[Camera sharedCamera] convertToWorldXY:[_sprite getScreenPosition]];    
    [_megaCannonBullet setPosition:CGPointMake(shipWorldPos.x - 120,shipWorldPos.y + 20.0f)];
    [_megaCannonBullet reset];
    
}

-(void)update:(float)dt
{
    //have to reposition for now because the position gets set like three times in gameobject, but for the time being we need to call it
    //so we can put it under the right layers
    if (_firstUpdate) {
        _firstUpdate = false;
        _velocity = CGPointMake(-5.0f, 0.0f);
        [_sprite setScreenPosition:ccp(300,230)];
        _cannonAnim = [Sprite spriteWithFile:@"blank.png"];
        //[[_cannonAnim getCCSprite] setVisible:NO];

        for (int i=0; i<3; i++) {
            Projectile *_bullet = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_BOSS_SHIP_BULLET];
            [_bullet setActive:NO];
            [_bullets addObject:_bullet];
        }
    }
    
    [self updateVelocity:dt];
    [self updateCannon:dt];

    
    CGPoint position = [_sprite getPosition];
    
    [_sprite setScreenPosition:CGPointMake(position.x + _velocity.x, position.y + _velocity.y)];
    
    [self updateBullets:dt];
    
    }

-(void)updateBullets:(float)dt
{
    for (Projectile *_bullet in _bullets) {
        if ([_bullet isActive]) {
            
            //redirect the bullet towards the player unless the bullet drops below a certain Y point (around the midsection of the player)
            CGPoint bulletPos = [_bullet getPosition];
            if (bulletPos.y > 120.0f) {
                [_bullet pointTowardPlayerMaxAngle:-1.0f];
            }
            
            
            [_bullet update:dt];
            Player *_player = [[LayerManager sharedLayers] getPlayer];
            Level *currentLevel = [[LevelManager shared] currentLevel];
            
            
            bool collision = [currentLevel testCollisionWithGameObject:_bullet Source:_player];
            if (collision) {
                if(![[_player getThirdAction] isActive]) {
                    [_player startCollision:PLAYER_EFFECT_COLLIDE Source:_bullet];
                    
                } else {
                    [[_player getThirdAction] setKilledEnemy:YES];
                    [[SoundEngine shared] playSound:@"deflected"];
                }
                [_bullet disable];
            }
            
            
        }
        
    }
}

-(void)updateCannon:(float)dt
{
    CGPoint shipPos = [_sprite getScreenPosition];
    [_cannonAnim setScreenPosition:CGPointMake(shipPos.x - 120, shipPos.y + 12.0f)];        
    
    if (_waitToShoot > 0.0f) {
        _waitToShoot -= dt;
        if (_waitToShoot<=0.0f) {
            [self shootBullet];
        }
    }
}

-(void)updateMegaCannon:(float)dt
{
    CGPoint shipPos = [_sprite getScreenPosition];
    [_megaCannonAnim setScreenPosition:ccp(shipPos.x + 50,shipPos.y + 12.0f)];
    
    if (_waitToShoot > 0.0f) {
        _waitToShoot -= dt;
        if (_waitToShoot <= 0.0f) {
            [self shootMegaCannon];
        }
    }
}

-(void)switchToPhase:(BossPhase)phase
{
    switch (phase) {
        case BOSS_PHASE_NOT_TRIGGERED:
            _x = 1500;
            _y = 160;
            break;
        case BOSS_PHASE_ENTERING:
            _target = ccp(300,160);
            break;
        case BOSS_PHASE_EXITING:
            _target = ccp(1500,160);
            break;
        case BOSS_PHASE_ATTACKING:
            break;
        default:
            break;
    }
}

-(void)reset
{
    _waitToShoot = -1.0f;
    for (Projectile *_bullet in _bullets)
    {[_bullet disable];}
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
    
    float max = 0.5f;
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
