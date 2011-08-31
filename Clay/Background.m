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
#define CCX_IPHONE_WIDTH 480
#define BACKGROUND_VELOCITY_MODIFIER_TRACK 0.03f
#define BACKGROUND_VELOCITY_MODIFIER_FOREGROUND 0.3f

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
        _backgroundPositionTrack = BACKGROUND_1_STARTING_X;
        _backgroundPositionForeground = BACKGROUND_1_STARTING_X;
        
        //creates the two backgrounds, and places them beside each other
        _bkg2 = [Sprite spriteWithFile:@"track.png" toLayer:layer];
        _bkg1 = [Sprite spriteWithFile:@"track.png" toLayer:layer];
        [_bkg1 setPositionAtX:BACKGROUND_1_STARTING_X Y:BACKGROUND_STARTING_Y];
        [_bkg2 setPositionAtX:(BACKGROUND_1_STARTING_X + CCX_IPHONE_WIDTH) Y:BACKGROUND_STARTING_Y];
        
        _foreground1 = [Sprite spriteWithFile:@"foreground.png" toLayer:layer];
        _foreground2 = [Sprite spriteWithFile:@"foreground.png" toLayer:layer];
        [_foreground1 setPositionAtX:BACKGROUND_1_STARTING_X Y:BACKGROUND_STARTING_Y];
        [_foreground2 setPositionAtX:(BACKGROUND_1_STARTING_X + CCX_IPHONE_WIDTH) Y:BACKGROUND_STARTING_Y];
        
    }
    
    return self;
}

-(float)updateBackgroundPosition:(float)dt BackgroundPosition:(float)position withModifier:(float)modifier
{
    //determine how far to scroll based on a multiple of the player's velocity
    float vx = [_layer.player getVelocityX];
    position -= vx * modifier;
    
    //if we've scrolled to the point where the right image is about to move off the screen,
    //then we want to reset the position of the background so the left image replaces the right
    if (position<=-CCX_IPHONE_WIDTH) {
        position+=CCX_IPHONE_WIDTH;
    }
    return position;
}


-(void)update:(float)dt
{
    _backgroundPositionTrack = [self updateBackgroundPosition:dt BackgroundPosition:_backgroundPositionTrack withModifier:BACKGROUND_VELOCITY_MODIFIER_TRACK];
    
    //position the backgrounds based on the position, one beside the other
    //rounded to ints to keep seams from appearing between the two
    [_bkg1 setPositionAtX:(int)_backgroundPositionTrack Y:BACKGROUND_STARTING_Y];
    [_bkg2 setPositionAtX:(int)(_backgroundPositionTrack + CCX_IPHONE_WIDTH) Y:BACKGROUND_STARTING_Y];

    _backgroundPositionForeground = [self updateBackgroundPosition:dt BackgroundPosition:_backgroundPositionForeground withModifier:BACKGROUND_VELOCITY_MODIFIER_FOREGROUND];
    
    [_foreground1 setPositionAtX:(int)_backgroundPositionForeground Y:BACKGROUND_STARTING_Y];
    [_foreground2 setPositionAtX:(int)(_backgroundPositionForeground + CCX_IPHONE_WIDTH) Y:BACKGROUND_STARTING_Y];
}

@end
