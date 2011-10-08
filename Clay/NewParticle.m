//
//  NewParticle.m
//  Clay
//
//  Created by Brian Cable on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewParticle.h"

@implementation NewParticle

@synthesize vx = _vx;
@synthesize vy = _vy;
@synthesize ax = _ax;
@synthesize ay = _ay;
@synthesize angle = _angle;
@synthesize angleVelocity = _angleVelocity;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _vx = 0;
        _vy = 0;
        _ax = 0;
        _ay = 0;
        _angle = 0;
        _angleVelocity = 0;
        _alpha = 1.0f;
    }
    
    return self;
}



@end
