//
//  PlayerActionWoo.m
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionWoo.h"

@implementation PlayerActionWoo

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)startAction
{
    if (!_inAction) {
        NSLog(@"Woo!");
        _inAction = true;
        _duration = 1.0f;        
    }
}

-(void)endAction
{
    _inAction = false;
    NSLog(@"End woo.");
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

-(void)setParent:(Player*)player
{
    _parent = player;
}

-(Player*)getParent
{
    return _parent;
}

-(bool)inAction
{
    return _inAction;
}

-(bool)isActive
{
    return _isActive;
}


@end
