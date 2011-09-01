//
//  Background.h
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The background layer for the game. Currently just loads two images and scrolls them based on the velocity
//  value for the player in the GameLayer

#import <Foundation/Foundation.h>
#import "BaseClasses.h"

@class TrackBackgroundLayer;

@interface TrackBackground : NSObject
{
    TrackBackgroundLayer *_clouds;
    TrackBackgroundLayer *_track;
    TrackBackgroundLayer *_bushes;
    TrackBackgroundLayer *_nearFence;
}

+(id)backgroundForLayer:(id)layer;                  //creates background, attaches it to given layer, and returns it

-(id)initForLayer:(id)layer;                        //constructor

-(void)update:(float)dt Velocity:(float)vx;         //updates the background positions, dt = seconds since last update

@end
