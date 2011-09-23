//
//  ParticleSystem.m
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "ParticleSystem.h"
#import "LayerManager.h"

@implementation ParticleSystem

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

+(void)addDustImpactAtPosition:(CGPoint)position
{
    CCParticleSystem *_emitter = [CCParticleMeteor node];        
    [_emitter setEmitterMode:kCCParticleModeGravity];
    
    _emitter.duration = 0.5f;
    _emitter.totalParticles = 10;
    _emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"ball.png"];
    ccColor4F startColor = { 0.8f, 0.6f, 0.04f, 1.0f };
    ccColor4F endColor = { 1.0f, 1.0f, 1.0f, 0.9f };
    _emitter.position = position;
    _emitter.startColor = startColor;
    _emitter.endColor = endColor;
    _emitter.scale = 0.25f;
    _emitter.angle = 160;
    _emitter.angleVar = 10;
    _emitter.blendAdditive = YES;
    _emitter.speed = 300;
    _emitter.gravity = CGPointMake(-1090.0f, -475.0f);
    _emitter.life = 0.4;
    _emitter.emissionRate = 100.0f;
    _emitter.autoRemoveOnFinish = YES;
    
    [[[LayerManager sharedLayers] currentLayer] addChild:_emitter];    
}

-(void) dealloc
{
    [super dealloc];
}


@end
