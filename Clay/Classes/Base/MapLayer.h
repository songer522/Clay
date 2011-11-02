//
//  MapLayer.h
//  Clay
//
//  Created by Brian Cable on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Not a CCLayer! This is a data structure class to hold the CCTMXLayer information from a CCTMXMap, in order to allow for background objects to be 
//  placed above them in the code. It's mainly used to keep references to the map layers after they've been added to the CCParallaxNodes (because it seems to kill the reference in the CCTMXTiledMap somehow), so that background objects can still access them so they can be placed on top of the layer afterwards.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MapLayer : NSObject
{
    CCTMXLayer *_layer;
    CGPoint _ratio;
}

+(id)instance;

@property(nonatomic,assign) CGPoint ratio;
@property(nonatomic,retain) CCTMXLayer *layer;

@end
