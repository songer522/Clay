//
//  PlayerActionDodge.m
//  Clay
//
//  Created by Brian Cable on 10/18/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionDodge.h"
#import "Sprite.h"
#import "AnimationController.h"

@implementation PlayerActionDodge

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
        _duration = 0.9f;
        [_parent endTurbo];
        [[AnimationController sharedController] replaceSprite:[_parent getSprite] withAnimationNamed:@"dodgingAnim"];
    }
}

-(void)update:(float)dt
{
    if (_inAction) {
        _duration -= dt;
        
        if (_duration < 0.9f) {
            _isActive = true;
            _parent.isInvincible = true;
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
    _parent.isInvincible = false;
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

-(bool)shouldTriggerPlayerHurtCollision
{
    if (_inAction) {
        return false;
    } else {
        return true;
    }
}

-(void)dealloc
{
    [super dealloc];
}


@end
