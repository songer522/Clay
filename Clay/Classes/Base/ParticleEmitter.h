//
//  NewEmitter.h
//  Clay
//
//  Created by Brian Cable on 10/8/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Emitter for particles. Emitter will store how many particles to create and what types for each effect we desire. Cocos2d built-in particle system really screws with the framerate, so we have to make our own.


#import <Foundation/Foundation.h>

@interface ParticleEmitter : NSObject
{
    NSArray *_particles;
}
@end
