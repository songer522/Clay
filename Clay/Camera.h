//
//  Camera.h
//  Clay
//
//  Created by Brian Cable on 9/7/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Camera class that will follow a target with an offset (the player on the left side of the screen, for example), while
//  ensuring the camera stays within the boundaries of the level.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;

@interface Camera : NSObject
{
    float _x;                   //x position of the camera
    float _y;                   //y position of the camera
        
    CGRect _boundary;           //the boundary that the 2D camera window has to be within

    CGPoint _center;            //x and y position relative to the screen where the target should be. default is center.
    
    Sprite *_target;          //what the camera is tracking towards (will be the runner mostly, but every
                                //once in awhile we might want to highlight something else)
}

+(Camera*)sharedCamera;

#pragma mark - public methods
-(void)moveByX:(float)x Y:(float)y;
-(void)setBoundaries:(CGRect)rect;
-(CGPoint)convertToScreenXY:(CGPoint)worldXY;
-(CGPoint)convertToWorldXY:(CGPoint)screenXY;
-(void)setTarget:(Sprite*)sprite;
-(void)setCenter:(CGPoint)point;
-(void)setPosition:(CGPoint)point;
-(void)moveTowardsTarget:(float)dt;
-(void)snapToTarget;

#pragma mark - private methods
-(void)keepWithinBoundaries;


@end
