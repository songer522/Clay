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
        //init
        _layer = layer;
        _backgroundPosition = BACKGROUND_1_STARTING_X;
        
        //creates the two backgrounds, and places them beside each other
        _bkg2 = [Sprite spriteWithFile:@"background.png" toLayer:layer];
        _bkg1 = [Sprite spriteWithFile:@"background.png" toLayer:layer];
        [_bkg1 setPositionAtX:BACKGROUND_1_STARTING_X Y:BACKGROUND_STARTING_Y];
        [_bkg2 setPositionAtX:(BACKGROUND_1_STARTING_X + CCX_IPHONE_WIDTH) Y:BACKGROUND_STARTING_Y];
        
    }
    
    return self;
}


-(void)update:(float)dt
{
    //determine how far to scroll based on a multiple of the player's velocity
    float vx = [_layer.player getVelocityX];
    _backgroundPosition -= vx * BACKGROUND_VELOCITY_MODIFIER;
    
    //if we've scrolled to the point where the right image is about to move off the screen,
    //then we want to reset the position of the background so the left image replaces the right
    if (_backgroundPosition<=-CCX_IPHONE_WIDTH) {
        _backgroundPosition+=CCX_IPHONE_WIDTH;
    }
    
    //position the backgrounds based on the position, one beside the other
    //rounded to ints to keep seams from appearing between the two
    [_bkg1 setPositionAtX:(int)_backgroundPosition Y:BACKGROUND_STARTING_Y];
    [_bkg2 setPositionAtX:(int)(_backgroundPosition + CCX_IPHONE_WIDTH) Y:BACKGROUND_STARTING_Y];
}

@end
