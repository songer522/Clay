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

@class Level;
@class Sprite;
@class Player;

@interface Camera : NSObject
{
    float _x;                   //x position of the camera
    float _vx;
    float _y;                   //y position of the camera
    float _scale;               //scale for calculating positions of things
        
    CGRect _boundary;           //the boundary that the 2D camera window has to be within

    CGPoint _center;            //x and y position relative to the screen where the target should be. default is center.
    CGPoint _defaultCenter;
    
    Sprite *_target;          //what the camera is tracking towards (will be the runner mostly, but every
                                //once in awhile we might want to highlight something else)
    
    bool _shouldMoveY;
    bool _trackingTarget;
    
    Player *_player;
    
    //precalcs for minor optimizations
    float _precalculateBoundaryYplusBoundaryHeight;
    float _precalculateBoundaryY;
    float _precalculateWinsizeHeight;
    float _precalculateBottomBound;
    float _precalculateTopBound;
    
    float _leftOnscreen;
    float _rightOnscreen;
    
    bool _isStutterMode;
    
    bool _isPlayerResetting;
    bool _isShiftForwardForKickAction;
    int _totalStepsForKickShiftForward;
}

@property (nonatomic,assign) bool trackingTarget;
@property (nonatomic,assign) bool isPlayerResetting;
@property (nonatomic,assign) bool isShiftForwardForKickAction;


+(Camera*)sharedCamera;

#pragma mark - public methods
-(void)moveByX:(float)x Y:(float)y;
-(void)setBoundaries:(CGRect)rect Level:(Level*)level;

-(void)updateOnScreenRange;

-(CGPoint)convertToScreenXY:(CGPoint)worldXY;
-(CGPoint)convertToScreenXYNew:(CGPoint)worldXY;
-(float)convertToScreenX:(float)worldX;
-(float)convertToScreenY:(float)worldY;

-(CGPoint)convertToWorldXY:(CGPoint)screenXY;
-(void)setTarget:(Sprite*)sprite;
-(void)setPosition:(CGPoint)point;

-(void)setCenter:(CGPoint)point;
-(void)setDefaultCenter:(CGPoint)point;
-(void)restoreDefaultCenter:(CGPoint)point;

-(void)moveTowardsTarget:(float)dt PlayerOnGround:(bool)onGround;
-(void)snapToTarget;
-(void)snapToTargetY;
-(void)startShiftForwardForKick;

-(float) xPosition;

-(void)reset;

#pragma mark - private methods
-(void)keepWithinBoundaries_old;
-(void)keepWithinBoundaries;

-(bool)isInVisualRange:(float)xPosition;

@end
