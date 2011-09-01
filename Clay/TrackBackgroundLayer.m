//
//  TrackBackgroundLayer.m
//  Clay
//
//  Created by Brian Cable on 9/1/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "TrackBackgroundLayer.h"
#import "GameLayer.h"
#import "BaseClasses.h"

@implementation TrackBackgroundLayer

+(id)trackLayerWithImage:(NSString*)filename Layer:(GameLayer*)layer RateOfChange:(float)rate
{
    return [[self alloc] initWithImage:filename Layer:layer RateOfChange:rate];
}

-(id)initWithImage:(NSString*)filename Layer:(GameLayer*)layer RateOfChange:(float)rate
{
    self = [super init];
    if (self) {
        _background = [Sprite spriteWithFile:filename toLayer:layer];
        _backgroundCopy = [Sprite spriteWithFile:filename toLayer:layer];
        
        _position = 0;
        _rate = rate;
    }
    
    return self;
}

-(void)setPositionAtX:(float)x Y:(float)y
{
    _y = y;
    [_background setPositionAtX:(int)x Y:y];
    [_backgroundCopy setPositionAtX:(int)[_background getWidth] + x Y:y];
}

-(void)update:(float)dt Velocity:(float)vx
{
    _position += _rate * vx;
    
    float backgroundWidth = [_background getWidth];
    
    //reposition if the two images are about to go offscreen in either direction
    if (_rate > 0) {
        if (_position >= 0) {
            _position -= backgroundWidth;
        }
    } else {
        if (_position <= -1 * backgroundWidth) {
            _position += backgroundWidth;
        }
    }
    
    [self setPositionAtX:_position Y:_y];
}


@end
