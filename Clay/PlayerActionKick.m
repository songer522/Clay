//
//  PlayerActionKick.m
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionKick.h"

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
        NSLog(@"Kick!");
        _inAction = true;
        _duration = 1.0f;
        [_parent endTurbo];
    }
}

-(void)update:(float)dt
{
    if (_inAction) {
        _duration -= dt;
        
        if (_duration < 0.5f) {
            _isActive = true;
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

-(void)endAction
{
    _inAction = false;
    _isActive = false;
    NSLog(@"End kick.");
}

-(void)setParent:(Player*)player
{
    _parent = player;
}

-(Player*)getParent
{
    return _parent;
}


@end
