//
//  Collision.m
//  Clay
//
//  Created by Brian Cable on 9/9/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Collision.h"

@implementation Collision

@synthesize currentState = _currentState;

+(id)collisionNode
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _currentState = COLLISION_STATE_GROUNDED;
    }
    
    return self;
}

-(void)processNewCollisionState:(CollisionState)state
{
    _currentState = state;
}

-(void)dealloc
{
    [super dealloc];
}

@end
