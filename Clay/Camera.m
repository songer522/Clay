//
//  Camera.m
//  Clay
//
//  Created by Brian Cable on 9/7/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Camera.h"
#import "Sprite.h"

@implementation Camera

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

-(void)setBoundaries:(CGRect)rect
{
    NSAssert(rect.origin.x < rect.size.width && rect.origin.y < rect.size.height, @"Invalid Rect for boundaries");
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
}

-(void)setCenter:(CGPoint)point
{
    _center = point;
}

-(void)moveByX:(float)x Y:(float)y
{
    _x += x;
    _y += y;
    [self keepWithinBoundaries];    
}

-(CGPoint)convertToScreenXY:(CGPoint)worldXY
{
    float x = (worldXY.x - _x + _center.x);
    float y = (worldXY.y - _y + _center.y);
    return CGPointMake(x, y);
}

-(CGPoint)convertToWorldXY:(CGPoint)screenXY
{
    float x = (_x - _center.x + screenXY.x);
    float y = (_y - _center.y + screenXY.y);
    return CGPointMake(x, y);    
}

-(void)moveTowardsTarget:(float)dt
{
    if (_target != nil) {
        
        CGPoint position = [_target getPosition];
        float dx = (position.x - _x);
        float dy = (position.y - _y);
        
        float distance = sqrtf(dx*dx + dy*dy);
        //float magnitude = distance * CAMERA_MOVE_TO_TARGET_SPEED * dt;
        
        float magnitude = distance * CAMERA_MOVE_TO_TARGET_SPEED * dt;;
        
        //NSLog(@"Magnitude: %.2f, DT: %.4f",magnitude,dt);
        
        if (distance > 2.0f) {
            //NSLog(@"X: %.2f, Y: %.2f, TX: %.2f, TY: %.2f, DX: %.2f, DY: %.2f MOVE",_x,_y,position.x,position.y,dx,dy);
            _x += (magnitude * (dx/distance));
            _y += (magnitude * (dy/distance));
            
        } else {
            //NSLog(@"X: %.2f, Y: %.2f, TX: %.2f, TY: %.2f, DX: %.2f, DY: %.2f SNAP",_x,_y,position.x,position.y,dx,dy);
            _x = position.x;
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

-(void)setPosition:(CGPoint)point
{
    _x = point.x;
    _y = point.y;
}

@end
