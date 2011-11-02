//
//  PlayerActionShoot.m
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionShoot.h"

#import "Player.h"
#import "Projectile.h"
#import "LevelManager.h"

#define PLAYER_ACTION_SHOOT_MAX_BULLETS 3

#define PLAYER_ACTION_SHOOT_OFFSET_BULLET_X 0
#define PLAYER_ACTION_SHOOT_OFFSET_BULLET_Y 45

@implementation PlayerActionShoot

-(void)initialize
{
    _cooldown = 0.0f;
    
    //setup projectiles (trying to avoid need for mutable array)
    Projectile *b1 = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_BULLET];
    Projectile *b2 = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_BULLET];
    Projectile *b3 = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_BULLET];
    [b1 setBoundingBox:CGRectMake(50, 0, 50, 20)];
    [b2 setBoundingBox:CGRectMake(50, 0, 50, 20)];
    [b3 setBoundingBox:CGRectMake(50, 0, 50, 20)];
    
    _bullets = [[NSArray alloc] initWithObjects:b1,b2,b3,nil];
    _currentBulletIndex = 0;
    
    
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        _duration = 0.4f;
        _cooldown = 0.4f;
        [_parent endTurbo];
        [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"shootingAnim"];
        [[SoundEngine shared] playSound:@"shootAction"];
        [self createBullet];
    }
}

-(void)createBullet
{
    Projectile *bullet = [_bullets objectAtIndex:_currentBulletIndex];
    
    [bullet reset];
    [bullet setPosition:CGPointMake(_parent.x + PLAYER_ACTION_SHOOT_OFFSET_BULLET_X, _parent.y + PLAYER_ACTION_SHOOT_OFFSET_BULLET_Y)];
    
    _currentBulletIndex = (_currentBulletIndex + 1) % 3;
    
}

-(void)enableAction
{
    [[SoundEngine shared] playSound:@"shootActionReload"];
    [super enableAction];
}

-(void)endAction
{
    [super endAction];
}

-(void)cancelAction
{
    [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"runningAnim"];
    _cooldown = 1.0f;
    [super cancelAction];
}


-(void)update:(float)dt
{
    if (!_inAction) {
        if (_cooldown > 0.0f) {
            _cooldown -= dt;
        }
    }
    
    for (Projectile *bullet in _bullets) {
        [bullet update:dt];
    }
    
    [super update:dt];
    
}

-(void)dealloc
{
    [super dealloc];
}

@end
