//
//  ParticleSystem.m
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "ParticleSystem.h"

@implementation ParticleSystem

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:20];
        [_particleSystem setEmitterMode:kCCParticleModeGravity];
        
        _dustParticles = [[CCParticleSnow alloc] initWithTotalParticles:100];
        
        [[CCTextureCache sharedTextureCache] addImage:@"Dot.png"];
        
    }
    
    
    
    
    
    return self;
}





@end
