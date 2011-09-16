//
//  CollisionDetection.h
//  Clay
//
//  Created by Brian Cable on 9/16/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CollisionDetection : NSObject
{
    CCTMXLayer *_collisionData;
}

-(CGPoint)testForCollisions;

@end
