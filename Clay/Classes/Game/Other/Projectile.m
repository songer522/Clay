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

@interface Projectile()

-(id) initWithBehavior:(ProjectileBehavior)behavior;

@end

@implementation Projectile


@synthesize boundingBox = _boundingBox;
@synthesize hurtsPlayer = _hurtsPlayer;
@synthesize isBehindObstacle = _isBehindObstacle;



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
        _attachedTo = nil;
        _hurtsPlayer = true;
        
        switch (_behavior) {
            case PROJECTILE_BEHAVIOR_PLAYER_KICK:
                //make it blank so we can access the sprite position for debug drawing. for now at least.
                _sprite = [Sprite spriteWithFile:@"blank.png"];
                break;
            case PROJECTILE_BEHAVIOR_PLAYER_BLOWING:
                //using a separate sprite to represent the animation
                _sprite = [Sprite spriteWithFile:@"blank.png"];
                break;
            case PROJECTILE_BEHAVIOR_BULLET:
                _sprite = [Sprite spriteFromFrameCacheWithName:@"Zombies_Bullet.png"];
                //[[_sprite getCCSprite] setScale:0.1f];
                [[_sprite getCCSprite] setVisible:NO];
                _offscreenPadding = 20;
                break;
            case PROJECTILE_BEHAVIOR_BOSS_SHIP_MEGACANNON:
                _sprite = [Sprite spriteFromFrameCacheWithName:@"Level7_JimSpaceCraft_Atkv2_7.png"];
                [[_sprite getCCSprite] setVisible:NO];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f,0.5f);
                _offscreenPadding = 20;
                break;
            case PROJECTILE_BEHAVIOR_ZOMBIE_HEAD:
                //_sprite = [Sprite spriteFromFrameCacheWithName:@"F_Zombie_Head.png"];
                _sprite = [Sprite spriteFromFrameCacheWithName:@"Level6_Brain_1.png"];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
                _hasGravity = true;
                _isAggressive = false;                
                _offscreenPadding = 42;
                _offsetGroundDetectionY = -10.0f;
                break;
            case PROJECTILE_BEHAVIOR_ZOMBIE_HEART:
                _sprite = [Sprite spriteFromFrameCacheWithName:@"Level6_Heart_1.png"];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
                _hasGravity = true;
                _isAggressive = false;
                _offscreenPadding = 42;
                _offsetGroundDetectionY = -10.0f;
                break;                
            case PROJECTILE_BEHAVIOR_BOSS_SHIP_BULLET:
                _sprite = [Sprite spriteFromFrameCacheWithName:@"Level7_JimSpaceCraft_Bullet.png"];
                [_sprite getCCSprite].anchorPoint = ccp(0,0);
                [[_sprite getCCSprite] setVisible:NO];
                _isAggressive = false;
                break;
            case PROJECTILE_BEHAVIOR_FIRE_DEMON_BULLET:
                _sprite = [Sprite spriteWithFile:@"blank.png"];
                [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"fireBullet"];
                [[_sprite getCCSprite] setVisible:NO];
                _isAggressive = false;
                break;
            case PROJECTILE_BEHAVIOR_RAINY_SQUIRREL_NUT:
                _sprite = [Sprite spriteFromFrameCacheWithName:@"Level9_Squirrel_Nut.png"];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f,0.5f);
                [[_sprite getCCSprite] setVisible:NO];
                _hasGravity = true;
                _offscreenPadding = 20.0f;
                _offsetGroundDetectionY = -13.0f;
                _isAggressive = false;
                break;
            case PROJECTILE_BEHAVIOR_FIRE_FOXFIRE:
                _sprite = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
                [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"fireFoxFireAnim"];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f,0.5f);
                [[_sprite getCCSprite] setVisible:YES];
                _offscreenPadding = 20.0f;
                _hurtsPlayer = false;
                _isAggressive = false;
                break;
            case PROJECTILE_BEHAVIOR_WATER_SQUID_INK:
                _sprite = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
                [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"waterSquidInkMovingAnim"];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f,0.5f);
                [[_sprite getCCSprite] setVisible:NO];
                _offscreenPadding = 20.0f;
                _isBehindObstacle = true;
                _isAggressive = false;
                break;
            case PROJECTILE_BEHAVIOR_DARK_BOMB:
                _sprite = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
                [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkBossJimBombAttack2"];
                [_sprite getCCSprite].anchorPoint = ccp(0.5f,0.5f);
                [[_sprite getCCSprite] setVisible:NO];
                _offscreenPadding = 100.0f;
                _hasGravity = true;
                _offsetGroundDetectionY = -10.0f;
                _isAggressive = false;
                break;
            case PROJECTILE_BEHAVIOR_DARK_TRAIN_DOOR:
                _sprite = [Sprite spriteWithFile:@"blank.png"];
                break;
            default:
                break;                
                
        }        
    }
    
    [self setInitialVelocity];
    
    return self;
}

-(void) setInitialVelocity
{    
    switch (_behavior) {
        case PROJECTILE_BEHAVIOR_BULLET:
            _vx = 800.0f;
            break;
        case PROJECTILE_BEHAVIOR_BOSS_SHIP_MEGACANNON:
            _vx = 400.0f;
            break;
        case PROJECTILE_BEHAVIOR_ZOMBIE_HEAD:
            _vx = 250 + rand()%100;
            _angularVelocity = rand()%10 + 10;                
            _vy = 50.0f;
            break;
        case PROJECTILE_BEHAVIOR_FIRE_DEMON_BULLET:
            _vx = -250.0f;
            break;
        case PROJECTILE_BEHAVIOR_ZOMBIE_HEART:
            _vy = 10.0f;
            _vx = 75 + rand()%25;
            break;
        case PROJECTILE_BEHAVIOR_RAINY_SQUIRREL_NUT:
            _angularVelocity = -1 * (rand()%10 + 10);
            _vy = 75.0f;
            _vx = -1.0f * (50.0f + rand()%100);
        case PROJECTILE_BEHAVIOR_WATER_SQUID_INK:
            //call shootWithSpeed instead
            break;
        case PROJECTILE_BEHAVIOR_DARK_BOMB:
            //call throwBomb instead
            break;
        case PROJECTILE_BEHAVIOR_DARK_GRAPES:
            //call throwBomb for grapes also
        default:
            break;                
    }        
}

-(void) throwBombFromPosition:(CGPoint)position
{
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkBossJimBombAttack2"];
    [_sprite setPosition:position];
    [[_sprite getCCSprite] setVisible:YES];
    _vy = 230.0f;        //was 30.0f;
    _vx = 140.0f;
    _x = position.x;
    _y = position.y;
    _angularVelocity = 8;
    _isActive = true;
    [self setBoundingBox:CGRectMake(30, 30, 60, 60)];
}

//so far, used only by squid ink
-(void) shootWithSpeed:(float)speed atAngle:(float)angle
{
    float squidInkAngleOffset = 40.0f;
    
    [[_sprite getCCSprite] setVisible:YES];
    [_sprite getCCSprite].rotation =-(_angle - squidInkAngleOffset);
    
    //angle = angle + squidInkAngleOffset;
    //NSLog(@"Angle: %f",angle);
    
    angle = CC_DEGREES_TO_RADIANS(angle);
    
    _vx = cosf(angle) * speed;
    _vy = sinf(angle) * speed;
    
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"waterSquidInkShootAnim"];
}
                                               
                                               
-(float) getAngleBetweenPoint1:(CGPoint)point1 Point2:(CGPoint)point2 InDegrees:(bool)convertToDegrees
{
    float dx, dy, angle;
    
    dx = point1.x - point2.x;
    dy = point1.y - point2.y;
    angle = atan2f( dy, dx );
    if (convertToDegrees) {
        angle = CC_RADIANS_TO_DEGREES(angle);
        if ( angle < 0 ) {
            angle = (360.0f + angle);
        }
    }
    return angle;
}


-(float)getAngleBetweenSource:(CGPoint)source andTarget:(CGPoint)target
{
    float dx = target.x - source.x;
    float dy = target.y - source.y;
    float angle = atan2f(dy,dx);
    return angle;
}


//so far used only by boss ship
-(void)pointTowardPlayerMaxAngle:(float)maxAngle
{
    Player *player = [[LayerManager sharedLayers] getPlayer];
    CGPoint playerPos = [player getPosition];
    
    float speed = 450.0f;
    float dx = (playerPos.x + 10.0f) - _x;
    float dy = (playerPos.y + 20.0f) - _y;
    float angle = atan2f(dy, dx);
    
    if (angle > maxAngle) {
        angle = maxAngle;
    }

    float angleInDegs = (angle * 180.0f)/3.14159f - 45;

    _vx = cosf(angle) * speed;
    _vy = sinf(angle) * speed;
    
    [_sprite getCCSprite].rotation = angleInDegs;
}

-(void) pointTowardPlayerCannon
{
    Player *player = [[LayerManager sharedLayers] getPlayer];
    CGPoint playerPos = [player getPosition];
    
    float speed = 450.0f;
    float dx = (playerPos.x + 10.0f) - _x;
    float dy = (playerPos.y + 20.0f) - _y;
    float angle = atan2f(dy, dx);
    
    float angleInDegs = (angle * 180.0f)/3.14159f - 45;
    
    _vx = cosf(angle) * speed;
    _vy = sinf(angle) * speed;
    
    [_sprite getCCSprite].rotation = angleInDegs;
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
    
    //if projectile is attached to something, then its position is relative to what it's attached to
    //the fox's fire, for example.
    if (_attachedTo!=nil) {
        point.x = _attachedTo.x + point.x;
        point.y = _attachedTo.y + point.y;
    }
    
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
    if (_behavior == PROJECTILE_BEHAVIOR_ZOMBIE_HEAD) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"zombieBrainSquishAnim"];
    } else if(_behavior == PROJECTILE_BEHAVIOR_ZOMBIE_HEART) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"zombieHeartSquishAnim"];
    } else if(_behavior == PROJECTILE_BEHAVIOR_WATER_SQUID_INK) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"waterSquidInkLandAnim"];
    } else if(_behavior == PROJECTILE_BEHAVIOR_DARK_BOMB) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"darkBossJimBombAttack3"];
    }
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
    if(_behavior == PROJECTILE_BEHAVIOR_WATER_SQUID_INK) { //should be safe for other behaviors, but no time to check so being safe
        _vx = 0;
        _vy = 0;
    }
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
            if(_behavior == PROJECTILE_BEHAVIOR_FIRE_FOXFIRE) {
                [_sprite move:CGPointMake(50.0f * dt, 0.0f * dt)];
            } else if (_behavior!=PROJECTILE_BEHAVIOR_ZOMBIE_HEAD && _behavior!=PROJECTILE_BEHAVIOR_ZOMBIE_HEART && _behavior!=PROJECTILE_BEHAVIOR_WATER_SQUID_INK && _behavior != PROJECTILE_BEHAVIOR_DARK_BOMB) {
                [_sprite move:CGPointMake(100.0f *dt, 200.0f*dt)];                
            }
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
            if (_behavior == PROJECTILE_BEHAVIOR_DARK_BOMB) {
                [self startCollision];
                _isActive = false;
            } else if (_behavior == PROJECTILE_BEHAVIOR_ZOMBIE_HEAD) {
                y = 85.0f + _offsetGroundDetectionY;
                _vy = 0.0f;
                _angle = 0.0f;
                _vx *= 0.92f;
                _angularVelocity = 0.0f;
                [_sprite getCCSprite].rotation = _angle;
            } else {
                y = 85.0f + _offsetGroundDetectionY;
                _vy = 0.0f;
                _angularVelocity *= 0.92f;
                _vx *= 0.92f;
            }

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
          //  [self disable];
          //??? the above line shouldn't be commented out. the projectile still goes through the update cycle even when it's offscreen with this
        } else {
            if (_isAggressive) {
                Level *level = [[LevelManager shared] currentLevel];
                NSMutableArray *obstacles = [level getActiveGameObjectList];
                bool collision = [level testCollisionsForAggressive:self Obstacles:obstacles];
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
    if (screenPosition.x > 0 && screenPosition.x < 480 && screenPosition.y > 0 && screenPosition.y < 320) {
        return true;
    }
    //NOTE: USER_INTERFACE_IDIOM is SLOOOOOOOOOOOW
    /*
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //float minAmount = 
        
        if (screenPosition.x > 0 && screenPosition.x < 1024 && screenPosition.y > 0 && screenPosition.y < 768) {
            return true;
        }
    } else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenPosition.x > 0 && screenPosition.x < 480 && screenPosition.y > 0 && screenPosition.y < 320) {
            return true;
        }
    }*/
    return false;
}

-(void)dealloc
{
    //[_sprite release];
    [[_sprite getCCSprite] removeFromParentAndCleanup:YES];
    _sprite = nil;
    [super dealloc];
}



@end
