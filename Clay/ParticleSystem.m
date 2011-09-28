//
//  ParticleSystem.m
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "ParticleSystem.h"
#import "Particle.h"
#import "Camera.h"
#import "LayerManager.h"

@implementation ParticleSystem

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _emitters = [[NSMutableArray alloc] initWithCapacity:10];
        _dustTexture = [[CCTextureCache sharedTextureCache] addImage:@"ball.png"];
    }
    
    return self;
}

+(id)instance
{
    return [[self alloc] init];
}

-(void)addDustImpactAtPosition:(CGPoint)position
{
    
    CCParticleSystem *_dust = [[CCParticleMeteor alloc] initWithTotalParticles:7];
    [_dust setEmitterMode:kCCParticleModeGravity];
    
    _dust.duration = 0.1f;
    _dust.totalParticles = 7;
    _dust.texture = _dustTexture;
    ccColor4F startColor = { 0.8f, 0.6f, 0.04f, 1.0f };
    ccColor4F endColor = { 1.0f, 1.0f, 1.0f, 0.0f };
    _dust.position = position;
    _dust.startColor = startColor;
    _dust.endColor = endColor;
    _dust.scale = 0.25f;
    _dust.angle = 90;
    _dust.angleVar = 90;
    _dust.blendAdditive = YES;
    _dust.speed = 150;
    _dust.gravity = CGPointMake(-50.0f, -175.0f);
    _dust.life = 0.1;
    _dust.emissionRate = 10000000.0f;
    _dust.autoRemoveOnFinish = NO;
    [[[LayerManager sharedLayers] currentLayer] addChild:_dust];
    Particle *particle = [[Particle alloc] initWithEmitter:_dust At:position];
    [_emitters addObject:particle];
     
}

+(void)testLimits
{
    CCParticleSystem *_emitter = [CCParticleFireworks node];        
    [_emitter setEmitterMode:kCCParticleModeGravity];
    
    _emitter.duration = -1.0f;
    _emitter.totalParticles = 1400;
    _emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"ball.png"];
    //ccColor4F startColor = { 0.8f, 0.6f, 0.04f, 1.0f };
    //ccColor4F endColor = { 1.0f, 1.0f, 1.0f, 0.9f };
    _emitter.position = ccp(240, 160);
    //_emitter.startColor = startColor;
    //_emitter.endColor = endColor;
    _emitter.scale = 0.75f;
    _emitter.angle = 160;
    _emitter.angleVar = 360;
    _emitter.blendAdditive = YES;
    _emitter.speed = 300;
    _emitter.gravity = CGPointMake(0.0f, -10.0f);
    _emitter.life = 1.0f;
    _emitter.emissionRate = 2200.0f;
    _emitter.autoRemoveOnFinish = YES;
    
    [[[LayerManager sharedLayers] currentLayer] addChild:_emitter];    
}

-(void)update:(float)dt
{
    for (Particle *particle in _emitters) {
        if (particle.emitter.active || particle.emitter.particleCount > 0) {
            particle.emitter.position = [[Camera sharedCamera] convertToScreenXY:CGPointMake(particle.position.x, particle.position.y)];
        } else {
            [_emitters removeObject:particle];
            [particle release];
        }
    }
}

-(void) dealloc
{
    [_emitters removeAllObjects];
    [_emitters release];
    [super dealloc];
}


@end
