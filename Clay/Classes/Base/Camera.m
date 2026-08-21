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

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
#define LEGACY_PHONE_HEIGHT 320.0f

static float CameraPhoneVerticalOffset(void)
{
    if (IS_IPAD) {
        return 0.0f;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return MAX((winSize.height - LEGACY_PHONE_HEIGHT) * 0.5f, 0.0f);
}

static float CameraRestingY(void)
{
    return 54.0f - CameraPhoneVerticalOffset();
}
@implementation Camera

@synthesize trackingTarget = _trackingTarget;
@synthesize isPlayerResetting = _isPlayerResetting;
@synthesize isShiftForwardForKickAction = _isShiftForwardForKickAction;


#define CAMERA_MOVE_TO_TARGET_SPEED 6.0f
#define CAMERA_OFFSCREEN_PADDING_LEFT 300.0f
// Legacy phone used RIGHT=780 ≈ 480 (screen) + 300 (past right edge).
// Derive from the live winSize so modern wider phones don't cull/freeze
// kicked hens while they are still visible on the right.
#define CAMERA_OFFSCREEN_PADDING_RIGHT_EXTRA 300.0f

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
    // Preserve the old framing, but don't clamp shorter than the visible screen on modern iPads.
    rect.size.height = MAX(402 * MULTIPLIERX, [[CCDirector sharedDirector] winSize].height);
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
    float bottom = _y - _center.y;
    float top = bottom + _precalculateWinsizeHeight; 
    
    if(top > (_precalculateBoundaryYplusBoundaryHeight)) {
        _y = _precalculateBoundaryYplusBoundaryHeight - _precalculateWinsizeHeight + _center.y;
    } else if (bottom < _precalculateBoundaryY) {
        _y = _precalculateBoundaryY + _center.y;
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


-(void)moveTowardsTarget:(float)dt PlayerOnGround:(bool)onGround
{
    float dx;
    float magnitude;
    
    if (_target != nil) {
        
        CGPoint position = [_target getPosition];
        dx = (position.x - _x);
        _y = CameraRestingY();
        
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
        _y = CameraRestingY();
    }
}

-(void)updateOnScreenRange
{
    float currentX = _x - _center.x;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _leftOnscreen = currentX - CAMERA_OFFSCREEN_PADDING_LEFT * MULTIPLIERX;
    // Screen width + extra padding past the true right edge (legacy: 480+300).
    _rightOnscreen = currentX + winSize.width + CAMERA_OFFSCREEN_PADDING_RIGHT_EXTRA * MULTIPLIERX;
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
    _y = CameraRestingY();
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
