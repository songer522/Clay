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

@implementation PlayerActionKick

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _inAction = false;
    }
    
    return self;
}

-(void)startAction
{
    if (!_inAction) {
        _inAction = true;
        _isActive = false;
        _duration = 0.4f;
        _madeNoise = false;
        [_parent endTurbo];
        [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"kickingAnim"];
    }
}

-(void)update:(float)dt
{
    if (_inAction) {
        _duration -= dt;
        
        if (_duration < 0.4f) {
            _isActive = true;
            if (!_madeNoise) {
                _madeNoise = true;
                [[_parent getSpeed] startKick];
            }
        } else {
            _isActive = false;
        }
        
        if (_duration <= 0.0f) {
            [self endAction];
        }
    }
    
}

-(bool)inAction
{
    return _inAction;
}

-(bool)isActive
{
    return _isActive;
}

-(void)cancelAction
{
    _inAction = false;
    _isActive = false;
    [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"runningAnim"];
    
}

-(void)endAction
{
    _inAction = false;
    _isActive = false;
    [_parent pushAfterAnimation:20.0f];
}

-(void)setParent:(Player*)player
{
    _parent = player;
}

-(Player*)getParent
{
    return _parent;
}

-(void)dealloc
{
    [super dealloc];
}


@end
