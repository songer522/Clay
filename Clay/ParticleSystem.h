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
    NSMutableArray *_emitters;
    CCTexture2D *_dustTexture;
}

+(id)instance;
-(void)addDustImpactAtPosition:(CGPoint)position;
+(void)testLimits;
-(void)update:(float)dt;
@end
