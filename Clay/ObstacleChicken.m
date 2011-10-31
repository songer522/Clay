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

    if ([gameLayer.player objectShouldReactToCollision]) {
        _hasBeenHit = true;
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"henKicked"];
        [[SoundEngine shared] playSound:@"henKicked"];
    }

}

-(void)update:(float)dt
{
    if ([self getActive]) {
    }
}

-(void)reset
{
}


@end
