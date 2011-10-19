//
//  PlayerAction.m
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"

@implementation PlayerAction

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
        [self initialize];
    }
    
    return self;
}

-(void) initialize
{
    
}

-(void)startAction
{
    if (!_inAction) {
        _inAction = true;
        _isActive = false;
        _duration = 0.4f;
    }
}

-(void)update:(float)dt
{
    if (_inAction) {
        _duration -= dt;

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
}

-(void)endAction
{
    _inAction = false;
    _isActive = false;
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
    return true;
}

-(void)dealloc
{
    [super dealloc];
}



@end
