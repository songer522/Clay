//
//  ParticleSystem.h
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ParticleSystem : NSObject
{
}

+(void)addDustImpactAtPosition:(CGPoint)position;
+(void)testLimits;
@end
