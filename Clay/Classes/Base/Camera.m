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

@implementation Camera

@synthesize trackingTarget = _trackingTarget;

#define CAMERA_MOVE_TO_TARGET_SPEED 6.0f

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
        _center = CGPointMake(size.width / 2.0f, size.height / 2.0f);
        _target = nil;
    }
    
    return self;
}

-(void)setBoundaries:(CGRect)rect Level:(Level*)level
{
    NSAssert(rect.origin.x < rect.size.width && rect.origin.y < rect.size.height, @"Invalid Rect for boundaries");
    
    //There is a blank row of tiles at the very bottom that we don't want to show, so the true camera
    //boundary is actually one tile above the bottom of the screen, or (64 pixels/32 points) normally. may require an #IPADFIX.
    rect.origin.y = 32;
    
    //restrict the camera in level 8
    NSString *levelName = level.name;
    if ([levelName isEqualToString:@"level6"]) {
        rect.size.height = 352;
    }

    
    if ([levelName isEqualToString:@"level8"]) {
        rect.size.height = 352;
    }
    
    _boundary = rect;
    
    [self keepWithinBoundaries];
}

-(void)keepWithinBoundaries
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

-(void)moveByX:(float)x Y:(float)y
{
    _x += x;
    //_y += y;
    [self keepWithinBoundaries];    
}

-(CGPoint)convertToScreenXY:(CGPoint)worldXY
{
    return CGPointMake(worldXY.x - _x + _center.x, worldXY.y - _y + _center.y);
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
    if (_target != nil) {
        
        float rate;
        if (onGround) {
            rate = 1.0f;
        } else {
            rate = 0.1f;
        }
        
        CGPoint position = [_target getPosition];
        float dx = (position.x - _x);
        float dy = (position.y - _y);
        
        float distance = sqrtf(dx*dx + dy*dy);
        
        float magnitude = distance * CAMERA_MOVE_TO_TARGET_SPEED * dt;
        
        if (distance > 2.0f) {
            if (_trackingTarget) {
                _x += (magnitude * (dx/distance));
            }
            _y += rate * (magnitude * (dy/distance));
            
        } else {
            if (_trackingTarget) {
                _x = position.x;
            }
            _y = position.y;
            
        }
    }
    [self keepWithinBoundaries];
}

-(void)snapToTarget
{
    if (_target!=nil) {
        _x = _target.x;
        _y = _target.y;
        [self keepWithinBoundaries];

    }
}

-(void)snapToTargetY
{
    if (_target!=nil) {
        _y = _target.y;
        [self keepWithinBoundaries];
    }
}

-(void)setPosition:(CGPoint)point
{
    _x = point.x;
    _y = point.y;
}

-(void)dealloc
{
    _target = nil;
    [super dealloc];
}

@end
