//
//  ObstacleZombie.m
//  Clay
//
//  Created by Brian Cable on 11/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObstacleZombie.h"
#import "Projectile.h"
#import "AnimationController.h"
#import "GameLayer.h"
#import "LayerManager.h"
#import "Player.h"
#import "PlayerAction.h"

@implementation ObstacleZombie

-(void)startCollision
{
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"femaleHeadlessZombieAnim"];
    _alpha = 1.5f;
    _projectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_ZOMBIE_HEAD];
    [_projectile reset];
    [_projectile setPosition:CGPointMake(_x, _y + 41)];
    [_projectile setBoundingBox:CGRectMake(15, 33, 30, 30)];
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    [[gameLayer.player getThirdAction] setKilledEnemy:YES];
}

-(Projectile*)getProjectile
{
    return _projectile;
    
}

@end
