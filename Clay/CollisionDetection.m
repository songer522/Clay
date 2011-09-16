//
//  CollisionDetection.m
//  Clay
//
//  Created by Brian Cable on 9/16/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "CollisionDetection.h"

@implementation CollisionDetection

- (id)initWithCollisionLayer:(CCTMXLayer*)collisionLayer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _collisionData = collisionLayer;
    }
    
    return self;
}


@end
