//
//  TrackBackgroundLayer.h
//  Clay
//
//  Created by Brian Cable on 9/1/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Each layer of the track background will move at a different rate relative to the velocity (and sometimes direction), so this class
//  keeps track of the sprite, a copy of the sprite to put beside it for scrolling purposes, and what the r

#import <Foundation/Foundation.h>
#import "BaseClasses.h"

@class Sprite;
@class GameLayer;

@interface TrackBackgroundLayer : NSObject
{
    Sprite *_background;
    Sprite *_backgroundCopy;
    
    float _position;
    float _rate;                //the rate the position changes relative to the velocity
    float _y;
}

+(id)trackLayerWithImage:(NSString*)filename Layer:(GameLayer*)layer RateOfChange:(float)rate;
-(id)initWithImage:(NSString*)filename Layer:(GameLayer*)layer RateOfChange:(float)rate;

-(void)setPositionAtX:(float)x Y:(float)y;

-(void)update:(float)dt Velocity:(float)vx;


@end
