//
//  Particle.h
//  Clay
//
//  Created by Brian Cable on 9/23/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Particle : NSObject
{
    CCParticleSystem *_emitter;
    CGPoint _position;
    
    bool isRunning;
}

@property(nonatomic,readonly,assign)CGPoint position;
@property(nonatomic,readonly,retain)CCParticleSystem *emitter;

- (id)initWithEmitter:(CCParticleSystem*)emitter At:(CGPoint)position;

@end
