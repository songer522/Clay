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

@class GameLayer;

@interface Background : NSObject
{
    GameLayer *_layer;                  //reference to the game layer
    
    Sprite *_bkg1;                      //the first background sprite (starts on the screen)
    Sprite *_bkg2;                      //the second background sprite (starts to the right of the first)
    
    Sprite *_foreground1;
    Sprite *_foreground2;
    
    float _backgroundPositionTrack;          //current background position
    float _backgroundPositionForeground;
}

+(id)backgroundForLayer:(id)layer;      //creates background, attaches it to given layer, and returns it

-(id)initForLayer:(id)layer;            //constructor

-(void)update:(float)dt;                //updates the background positions, dt = seconds since last update

//private methods
-(float)updateBackgroundPosition:(float)dt BackgroundPosition:(float)position withModifier:(float)modifier;

@end
