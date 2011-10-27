//
//  Projectile.m
//  Clay
//
//  Created by Brian Cable on 10/26/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Projectile.h"

#import "Sprite.h"
#import "Camera.h"
#import "Level.h"
#import "LevelManager.h"


@implementation Projectile


@synthesize boundingBox = _boundingBox;


+(id) projectileWithBehavior:(ProjectileBehavior)behavior
{
    return [[self alloc] initWithBehavior:behavior];
}

-(id) initWithBehavior:(ProjectileBehavior)behavior
{
    if ((self = [super init])) {
        _x = 0.0f;
        _y = 0.0f;
        _vx = 0.0f;
        _vy = 0.0f;
        _sprite = nil;
        _isActive = false;
        _hasGravity = false;
        _behavior = behavior;
        _angle = 0.0f;
        _angularVelocity = 0.0f;
        _isAggressive = true;
        
        switch (_behavior) {
            case PROJECTILE_BEHAVIOR_PLAYER_KICK:
                _sprite = nil;
                break;
            case PROJECTILE_BEHAVIOR_BULLET:
                _sprite = [Sprite spriteWithFile:@"bullet.png"];
                //[[_sprite getCCSprite] setScale:0.1f];
                [[_sprite getCCSprite] setVisible:NO];
                _vx = 800.0f;
                break;
            case PROJECTILE_BEHAVIOR_ZOMBIE_HEAD:
                _sprite = [Sprite spriteWithFile:@"zombieHead.png"];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
                
                _vx = 250 + rand()%100;
                _angularVelocity = rand()%10 + 10;                
                _vy = 50.0f;
                _hasGravity = true;
                _isAggressive = false;
            default:
                break;                
                
        }        
    }
    
    return self;
}


-(void) setAttachedTo:(GameObject*)object
{
    _attachedTo = object;
}

-(void) setActive:(bool)isActive
{
    _isActive = isActive;
}

-(CGRect)getBoundingBox
{
    return _boundingBox;
}

-(void)setBoundingBox:(CGRect)boundingBox
{
    _boundingBox = boundingBox;
}

-(void) setPosition:(CGPoint)point
{
    _x = point.x;
    _y = point.y;
    if (_sprite!=nil) {
        [[_sprite getCCSprite] setPosition:[[Camera sharedCamera] convertToScreenXY:point]];
    }
}

-(CGPoint)getPosition
{
    return CGPointMake(_x, _y);
}

-(void)startCollision
{
    
}

-(bool)getAggressive
{
    return _isAggressive;
}

-(bool)getActive
{
    return _isActive;
}

-(void)reset
{
    [[_sprite getCCSprite] setVisible:YES];
    _isActive = true;
}

-(CollisionBehavior)getCollisionBehavior
{
    return COLLISION_BEHAVIOR_NONE;
}

-(CCSprite*)getCCSprite
{
    return [_sprite getCCSprite];
}

-(void)disable
{
    _isActive = false;
    [[_sprite getCCSprite] setVisible:NO];
    
}

-(bool)hasBeenHit
{
    return false;
}

-(void) update:(float)dt
{
    if (_isActive) {
        
        //temp
        if (_behavior == PROJECTILE_BEHAVIOR_ZOMBIE_HEAD) {
            _x = _x;
        }
        //apply gravity if needed
        if(_hasGravity) {
            _vy -= 600.0f * dt;
        }
        
        //update position
        float x = _x + _vx * dt;
        float y = _y + _vy * dt;
        
        if (_hasGravity && y <= 85.0f) {
            y = 85.0f;
            _vy = 0.0f;
            _angularVelocity *= 0.92f;
            _vx *= 0.92f;      
        }
        
        CGPoint newPosition = CGPointMake(x, y);
        [self setPosition:newPosition];
        
        //change rotation based on angular velocity if needed
        if (_angularVelocity!=0.0f) {
            _angle += _angularVelocity * 25.0f * dt;
            [_sprite getCCSprite].rotation = _angle;
        }
        
        //want to disable projectile if it's offscreen so it doesn't hurt things before they appear,
        //otherwise we test to see if it collided with anything
        if (![self checkIfOnScreen:newPosition]) {
            [self disable];
        } else {
            if (_isAggressive) {
                bool collision = [[[LevelManager shared] currentLevel] testCollisionsForAggressive:self];
                if (collision) {
                    [self disable];            
                }                
            }
        }
        
    }
}

//simple bounds test with the screen
-(bool) checkIfOnScreen:(CGPoint)position
{
    CGPoint screenPosition = [[Camera sharedCamera] convertToScreenXY:position];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (screenPosition.x > 0 && screenPosition.x < 1024 && screenPosition.y > 0 && screenPosition.y < 768) {
            return true;
        }
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenPosition.x > 0 && screenPosition.x < 480 && screenPosition.y > 0 && screenPosition.y < 320) {
            return true;
        }
    }
    return false;
}


@end
