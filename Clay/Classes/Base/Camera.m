//
//  Camera.m
//  Clay
//
//  Created by Brian Cable on 9/7/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Camera.h"
#import "Sprite.h"
#import "LevelManager.h"
#import "Level.h"
#import "Player.h"
#import "GameSettings.h"

@implementation Camera

@synthesize trackingTarget = _trackingTarget;
@synthesize isPlayerResetting = _isPlayerResetting;
@synthesize isShiftForwardForKickAction = _isShiftForwardForKickAction;


#define CAMERA_MOVE_TO_TARGET_SPEED 6.0f
#define CAMERA_OFFSCREEN_PADDING_LEFT 300.0f
#define CAMERA_OFFSCREEN_PADDING_RIGHT 780.0f //include the size of the screen (in points?)

static Camera *_sharedCamera = nil;

+(Camera*)sharedCamera
{
	if (!_sharedCamera) {
        _sharedCamera = [[self alloc] init];
	}
	return _sharedCamera;
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        CGSize size = [[CCDirector sharedDirector] winSize];
        _x = 0;
        _y = 0;
        _vx = 0;
        _center = CGPointMake(size.width / 2.0f, size.height / 2.0f);
        _target = nil;
        
        _isStutterMode = [[GameSettings shared] isStutterMode];
        _isPlayerResetting = true;
        
    }
    
    return self;
}

-(void)setBoundaries:(CGRect)rect Level:(Level*)level
{
    NSAssert(rect.origin.x < rect.size.width && rect.origin.y < rect.size.height, @"Invalid Rect for boundaries");
    
    //There is a blank row of tiles at the very bottom that we don't want to show, so the true camera
    //boundary is actually one tile above the bottom of the screen, or (64 pixels/32 points) normally.
    //IPAD FIX: may not be 32 for ipad
    rect.origin.y = 32;

    //restrict the camera in certain levels
    //IPAD FIX: may need a different greater height for ipad, since the ipad has more pixels in the y plane.
    rect.size.height = 320;
    _boundary = rect;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _precalculateWinsizeHeight = winSize.height;
    _precalculateBoundaryY = _boundary.origin.y;
    _precalculateBoundaryYplusBoundaryHeight = _boundary.origin.y + _boundary.size.height;
    
    
    _player = [[LayerManager sharedLayers] getPlayer];
    
    [self keepWithinBoundaries];
    [self updateOnScreenRange];
}

-(void)keepWithinBoundaries
{
    if ([[GameSettings shared] isStutterMode]) {
        [self keepWithinBoundaries_old];
        return;
    }
    
    float bottom = _y - _center.y;
    float top = bottom + _precalculateWinsizeHeight; 
    
    if(top > (_precalculateBoundaryYplusBoundaryHeight)) {
        _y = _precalculateBoundaryYplusBoundaryHeight - _precalculateWinsizeHeight + _center.y;
    } else if (bottom < _precalculateBoundaryY) {
        _y = _precalculateBoundaryY + _center.y;
    }
}


-(void)keepWithinBoundaries_old
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    float left = _x - _center.x;
    float right = left + winSize.width;
    float bottom = _y - _center.y;
    float top = bottom + winSize.height;
    
    if(left < _boundary.origin.x) {
        _x = _boundary.origin.x + _center.x;
    } else if(right > (_boundary.origin.x + _boundary.size.width)) {
        _x = _boundary.origin.x + _boundary.size.width - winSize.width + _center.x;
    }
    
    if(top > (_boundary.origin.y + _boundary.size.height)) {
        _y = _boundary.origin.y + _boundary.size.height - winSize.height + _center.y;
    } else if (bottom < _boundary.origin.y) {
        _y = _boundary.origin.y + _center.y;
    }
}

-(void)setTarget:(Sprite *)sprite
{
    _target = sprite;
    _trackingTarget = true;
}

-(void)setCenter:(CGPoint)point
{
    _center = point;
    
}

-(void)setDefaultCenter:(CGPoint)point
{
    _defaultCenter = point;
}

-(void)restoreDefaultCenter:(CGPoint)point
{
    _center = _defaultCenter;
}

-(void)moveByX:(float)x Y:(float)y
{
    _x += x;
    //_y += y;
    [self keepWithinBoundaries];    
}

-(CGPoint)convertToScreenXY:(CGPoint)worldXY
{
    //return CGPointMake(worldXY.x - _x + _center.x, worldXY.y - _y + _center.y);
    return ccp(worldXY.x - _x + _center.x, worldXY.y - _y + _center.y);
}

-(CGPoint)convertToScreenXYNew:(CGPoint)worldXY
{
    //return CGPointMake(worldXY.x - _x + _center.x, worldXY.y - _y + _center.y);
    return ccp(worldXY.x - _x + _center.x, worldXY.y - _y + _center.y);
}


-(CGPoint)convertToWorldXY:(CGPoint)screenXY
{
    float x = (_x - _center.x + screenXY.x);
    float y = (_y - _center.y + screenXY.y);
    return CGPointMake(x, y);    
}

-(float)convertToScreenX:(float)worldX
{
    return (worldX - _x + _center.x);
}

-(float)convertToScreenY:(float)worldY
{
    return (worldY - _y + _center.y);    
}


-(void)moveTowardsTargetNew:(float)dt
{
    //CGPoint position = [_target getPosition];
    //float dx = (position.x - _x);
    
    //float speed = [_player getVelocityX];
    
    if(_trackingTarget) {
        //_x = _target.
    }
    
    /*
    float distance = sqrtf(dx*dx);
    if (distance > 0.1f) {
        if (_trackingTarget) {
            
            if (dx > 0) {
                _vx += 6.0f * dt;
                _vx = MIN(40.0f, _vx);
            } else {
                _vx -= 6.0f * dt;
                _vx = MAX(-40.0f, _vx);                
            }
            _x += _vx;         
        }
    } else {
        if (_trackingTarget) {
            _vx = 0.0f;
            _x = position.x;            
        }
    }*/
}

-(void)moveTowardsTarget:(float)dt PlayerOnGround:(bool)onGround
{
    float dx;
    float magnitude;
    
    if (_target != nil) {
        
        CGPoint position = [_target getPosition];
        dx = (position.x - _x);
        _y = 54.0f; //this is the setting it would rest on from when we actually used to track the y position
        
        float distance = sqrtf(dx*dx);
        
        magnitude = distance * CAMERA_MOVE_TO_TARGET_SPEED * dt;
        
        if (distance > 0.1f) {
            if (_trackingTarget) {
                _x += (magnitude * (dx/distance));
            }
        } else {
            if (_trackingTarget) {
                _x = position.x;
            }
            _isPlayerResetting = false;
        }
        
        if (_isShiftForwardForKickAction) {
            //fixed time step of 1/60.0s, duration is 0.4seconds, therefore 24 steps. needs to move forward 20.0f, so 0.83333f per step.
            _totalStepsForKickShiftForward++;
            _x += 0.83333333f;
        }
    }
    [self updateOnScreenRange];
}

-(void)snapToTarget
{
    if (_target!=nil) { 
        _x = _target.x;
        _y = 54.0f;
    }
}

-(void)updateOnScreenRange
{
    float currentX = _x - _center.x;
    _leftOnscreen = currentX - CAMERA_OFFSCREEN_PADDING_LEFT;
    _rightOnscreen = currentX + CAMERA_OFFSCREEN_PADDING_RIGHT;
}

-(bool)isInVisualRange:(float)xPosition
{
    if(xPosition > _leftOnscreen && xPosition < _rightOnscreen) {
        return true;
    } else {
        return false;
    }
}

-(void)reset
{
    _x = 0;
    _y = 54.0f;
    _isShiftForwardForKickAction = false;
    [self keepWithinBoundaries];
}

-(void)setPosition:(CGPoint)point
{
    _x = point.x;
    _y = point.y;
}

-(void)startShiftForwardForKick
{
    _totalStepsForKickShiftForward = 0;
    _isShiftForwardForKickAction = true;
}

-(float) xPosition
{
    return _x;
}

-(void)dealloc
{
    _target = nil;
    [super dealloc];
}

@end
