//
//  ObstacleChicken.m
//  Clay
//
//  Created by Brian Cable on 10/31/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ObstacleChicken.h"
#import "AnimationController.h"
#import "GameLayer.h"
#import "LayerManager.h"
#import "SoundEngine.h"
#import "Player.h"


@implementation ObstacleChicken

-(void)startCollision
{
    //hen always dies, but don't actually kick hen unless player decides it's been kicked
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    _hasGravity = false;
    _madeSound = false;

    if ([gameLayer.player objectShouldReactToCollision]) {
        _hasBeenHit = true;
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"henKicked"];
        [[SoundEngine shared] playSound:@"henKicked"];
    }

}

-(void)update:(float)dt
{
    if ([self getActive]) {
        //_angle += _rotationAmount * dt;
        [self getCCSprite].rotation = _angle;
        _velocity = CGPointMake(_velocity.x, _velocity.y + 500.0f * dt);
        [super updateMovement:dt];
    }
}

//called by player once it decides that the hen is actually kicked by the leg
-(void)kickHen
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    [gameLayer.player changeHealth:1];
    
    if (!_madeSound) {
        [[SoundEngine shared] playSound:@"henKicked"];
        _madeSound = true;
    }
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"henKicked"];
    
    
    _hasGravity = true;
    _hasBeenHit = false; //want it to remain aggressive
    float magnitude = 555.0f;
    _angle = -20;
    _angularVelocity = 75;
    

    float vx = magnitude * cosf((_angle * 3.14159)/180.0f);
    float vy = magnitude * sinf((_angle * 3.14159)/180.0f);
    
    [self setVelocity:CGPointMake(vx, vy)];
    
}

-(void)reset
{
}


@end
