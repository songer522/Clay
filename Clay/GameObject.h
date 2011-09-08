//
//  GameObject.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  An object in the game. Means it will have a sprite associated with it, an x/y position, maybe other things like animation and velocity

#import <Foundation/Foundation.h>

@class Sprite;

@interface GameObject : NSObject
{
    Sprite *_sprite;
    //Animation *_animation;
    float _x;
    float _y;
}

@property(nonatomic,retain) Sprite *sprite;
@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;

+(id) objectWithSprite:(Sprite*)sprite;     //create game object, add a sprite to it, return
-(id) initWithSprite:(Sprite*)initSprite;   //constructor

-(void) setPositionAtX:(int)x Y:(int)y;     //give new x and y position on screen (with cocos2D, both hi and low-res use 320x480 resolution for its points)

-(CGPoint) getPosition;

-(void) update:(float)dt;

@end
