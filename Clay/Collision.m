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

-(void)processNewTile:(NSString*)tile CollisionState:(CollisionState)state
{
    /*
    switch (_currentState) {
        case COLLISION_STATE_MIDAIR:
            [self wasMidairProcessNewTile:tile CollisionState:state];
            break;
        case COLLISION_STATE_GROUNDED:
            [self wasGroundedProcessNewTile:tile CollisionState:state];
        default:
            break;
    }*/
    
    _currentState = state;
}

/*
-(void)wasMidairProcessNewTile:(NSString*)tile CollisionState:(CollisionState)state
{
    if (state == COLLISION_STATE_GROUNDED) {
        
    }
}
             
-(void)wasGroundedProcessNewTile:(NSString*)tile CollisionState:(CollisionState)state
{
    if (state == COLLISION_STATE_MIDAIR) {
        
    } else if(state == COLLISION_STATE_GROUNDED) {
        
    }
}
*/

@end
