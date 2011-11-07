//
//  BossJimShip.m
//  Clay
//
//  Created by Brian Cable on 11/7/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "BossJimShip.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Sprite.h"
#import "Camera.h"

@implementation BossJimShip


-(void)startBoss
{
    _sprite = [Sprite spriteWithFile:@"blank.png"];
    
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"jimSpaceshipAnim"];
    
    [_sprite setPosition:ccp(300,200)];
    
    _velocity = CGPointMake(0.0f, 0.0f);
    _targetOnScreen = CGRectMake(50, 80, 370, 200);
    
    [_sprite setAlpha:1.0f];

}

-(void)update:(float)dt
{
    //[self updateVelocity:dt];
    
    CGPoint position = [_sprite getPosition];
    
    [_sprite setScreenPosition:CGPointMake(position.x + _velocity.x, position.y + _velocity.y)];
    NSLog(@"BOSS VX: %f VY: %f PX: %f, PY: %f",_velocity.x, _velocity.y, position.x, position.y);
}

-(void)updateVelocity:(float)dt
{
    float rate = 8.0f * dt;
    float iterations = 10;
    
    int xthrust = 0;
    int ythrust = 0;
    
    CGPoint position = [_sprite getPosition];
    
    float futureXPosition = position.x + (_velocity.x * rate * iterations);
    if (futureXPosition < _targetOnScreen.origin.x) {
        xthrust = 1;
    } else if(futureXPosition > (_targetOnScreen.origin.x + _targetOnScreen.size.width)) {
        xthrust = -1;
    }
    
    if (position.y < 110) {
        ythrust = 1;
    }
    
    float dragX = 0.95f;
    float gravity = 20.0f;
    _velocity.y = _velocity.y + (ythrust * 30.0f - gravity) * rate;
    _velocity.x = dragX * (_velocity.x + (xthrust * 150.0f) * rate);
}


@end
