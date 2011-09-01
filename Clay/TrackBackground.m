//
//  Background.m
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "TrackBackground.h"
#import "TrackBackgroundLayer.h"
#import "GameLayer.h"

@implementation TrackBackground

+(id)backgroundForLayer:(id)layer
{
    return [[self alloc] initForLayer:layer];
}

-(id)initForLayer:(id)layer
{
    self = [super init];
    if (self) {
        _track = [TrackBackgroundLayer trackLayerWithImage:@"track.png" Layer:layer RateOfChange:0.004f];
        _bushes = [TrackBackgroundLayer trackLayerWithImage:@"foreground.png" Layer:layer RateOfChange:-0.30f];
        _sky = [TrackBackgroundLayer trackLayerWithImage:@"sky.png" Layer:layer RateOfChange:-0.001f];
        _fence = [TrackBackgroundLayer trackLayerWithImage:@"fence.png" Layer:layer RateOfChange:-0.34f];
    }
    
    return self;
}

-(void)update:(float)dt Velocity:(float)vx
{
    [_sky update:dt Velocity:vx];
    [_track update:dt Velocity:vx];
    [_bushes update:dt Velocity:vx];
    [_fence update:dt Velocity:vx];
}

@end
