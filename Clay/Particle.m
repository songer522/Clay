//
//  Particle.m
//  Clay
//
//  Created by Brian Cable on 9/23/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Particle.h"

@implementation Particle

@synthesize position = _position;
@synthesize emitter = _emitter;

- (id)initWithEmitter:(CCParticleSystem*)emitter At:(CGPoint)position
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _emitter = emitter;
        _position = position;
    }
    
    return self;
}

-(void)dealloc
{
    [_emitter release];
    [super dealloc];
}

@end
