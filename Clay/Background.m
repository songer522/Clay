//
//  Background.m
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Background.h"
#import "GameLayer.h"

#define BACKGROUND_1_STARTING_X -160
#define BACKGROUND_STARTING_Y 0
#define CCX_IPHONE_WIDTH 479
#define BACKGROUND_VELOCITY_MODIFIER 0.3

@implementation Background

+(id)backgroundForLayer:(id)layer
{
    return [[self alloc] initForLayer:layer];
}


-(id)initForLayer:(id)layer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _layer = layer;
        _bkg2 = [Sprite spriteWithFile:@"background.png" toLayer:layer];
        _bkg1 = [Sprite spriteWithFile:@"background.png" toLayer:layer];
        [_bkg1 setPositionAtX:BACKGROUND_1_STARTING_X Y:BACKGROUND_STARTING_Y];
        [_bkg2 setPositionAtX:(BACKGROUND_1_STARTING_X + CCX_IPHONE_WIDTH) Y:BACKGROUND_STARTING_Y];
        _backgroundPosition = BACKGROUND_1_STARTING_X;
    }
    
    return self;
}


-(void)update:(float)dt
{
    float vx = [_layer._player getVelocity];
    _backgroundPosition -= vx * BACKGROUND_VELOCITY_MODIFIER;
    
    if (_backgroundPosition<=-CCX_IPHONE_WIDTH) {
        _backgroundPosition+=CCX_IPHONE_WIDTH;
    }
    [_bkg1 setPositionAtX:(int)_backgroundPosition Y:BACKGROUND_STARTING_Y];
    [_bkg2 setPositionAtX:(int)(_backgroundPosition + CCX_IPHONE_WIDTH) Y:BACKGROUND_STARTING_Y];
}

@end
