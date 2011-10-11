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
    }
    
    return self;
}

-(void)startAction
{
    NSLog(@"Kick!");
}

-(void)update:(float)dt
{
    
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
