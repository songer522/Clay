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
#import "LayerManager.h"
#import "Player.h"

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
        _alpha = 1.0f;
        _fadeOut = false;
        _angularVelocity = 0.0f;
        _offsetGroundDetectionY = 0.0f;
        _isAggressive = true;
        
        switch (_behavior) {
            case PROJECTILE_BEHAVIOR_PLAYER_KICK:
                //make it blank so we can access the sprite position for debug drawing. for now at least.
                _sprite = [Sprite spriteWithFile:@"blank.png"];
                break;
            case PROJECTILE_BEHAVIOR_BULLET:
                _sprite = [Sprite spriteWithFile:@"bullet.png"];
                //[[_sprite getCCSprite] setScale:0.1f];
                [[_sprite getCCSprite] setVisible:NO];
                _vx = 800.0f;
                _offscreenPadding = 20;
                break;
            case PROJECTILE_BEHAVIOR_ZOMBIE_HEAD:
                _sprite = [Sprite spriteWithFile:@"zombieHead.png"];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
                [[_sprite getCCSprite] setScale:0.8];
                _vx = 250 + rand()%100;
                _angularVelocity = rand()%10 + 10;                
                _vy = 50.0f;
                _hasGravity = true;
                _isAggressive = false;
                _offscreenPadding = 42;
                _offsetGroundDetectionY = 10.0f;
                break;
            case PROJECTILE_BEHAVIOR_BOSS_SHIP_BULLET:
                _sprite = [Sprite spriteWithFile:@"shipBullet2.png"];
                [_sprite getCCSprite].anchorPoint = ccp(0,0);
                _isAggressive = false;
                break;
            default:
                break;                
                
        }        
    }
    
    return self;
}

//so far used only by boss ship
-(void)pointTowardPlayer
{
    Player *player = [[LayerManager sharedLayers] getPlayer];
    CGPoint playerPos = [player getPosition];
    
    float speed = 350.0f;
    float dx = playerPos.x - _x;
    float dy = playerPos.y - _y;
    float angle = atan2f(dy, dx);
    
    //float angleInRads = (angle * 3.14159)/180.0f;
    
    _vx = cosf(angle) * speed;
    _vy = sinf(angle) * speed;
    
    NSLog(@"bullet angle: %f VX: %f, VY: %f",angle,_vx,_vy);
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

-(bool) isActive
{
    return _isActive;
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
    _fadeOut = true;
    [_sprite setAlpha:1.0f];
    _isActive = false;
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
    _fadeOut = false;
    [_sprite setAlpha:1.0f];
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
    if (_sprite !=nil) {
        [[_sprite getCCSprite] setVisible:NO];   
    }    
}

-(bool)hasBeenHit
{
    return false;
}

-(void) update:(float)dt
{
    if (_fadeOut) {
        if ([_sprite reachedMinAfterModifyAlpha:-2.0f * dt]) {
            [[_sprite getCCSprite] setVisible:NO];
        } else {
            [_sprite move:CGPointMake(100.0f *dt, 200.0f*dt)];
        }
    }
    
    if (_isActive) {
        
        //apply gravity if needed
        if(_hasGravity) {
            _vy -= 600.0f * dt;
        }
        
        //update position
        float x = _x + _vx * dt;
        float y = _y + _vy * dt;
        
        if (_hasGravity && y <= (85.0f + _offsetGroundDetectionY)) {
            y = 85.0f + _offsetGroundDetectionY;
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
        //float minAmount = 
        
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
