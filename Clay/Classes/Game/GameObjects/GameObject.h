//
//  GameObject.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  An object in the game. Means it will have a sprite associated with it, an x/y position, and if it's an obstacle then it will respond to a collision depending on what type of obstacle it is. This class is in dire need of converting from state/enum based to having separate gameobject classes per type, and turning this class into a generic base class again. That process has been started, but is not complete yet.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "Collidable.h"

@class Sprite;

@class Collision;
@class Projectile;
@class Boss;

typedef enum {
    PLAYER_EFFECT_COLLIDE,
    PLAYER_EFFECT_SLOWDOWN,
    PLAYER_EFFECT_ACTION_OR_COLLIDE,
    PLAYER_EFFECT_VACCUUM,
    PLAYER_EFFECT_DANCE,
    PLAYER_EFFECT_NONE
} PlayerEffect;

//NOTE: CollisionBehavior enum moved to "Collidable.h" protocol

@interface GameObject : NSObject<Collidable>
{
    Sprite *_sprite;
    
    Boss *_boss;
    
    bool _isActive;      //starts true, but switched to false if we no longer
                         //want the object to be seen or updated
    
    bool _hasGravity;
    bool _isInMidAir;
    bool _isFalling;
    bool _isCooldown;
    bool _hasTriggered;
    float _waitToTrigger;
    float _rate;
    float _x;
    float _y;
    CGPoint _startingPosition;
    float _vx;
    float _vy;
    float _offsetX;     //how much to offset whatever x position comes in by
    float _offsetY;     //how much to offset whatever y position comes in by
    float _angle;
    float _rotationAmount;
    float _alpha;
    float _fallVelocity;
    float _direction;
    float _reloading;
    float _magnitude;
    float _slowTimeModifier;
    bool _stopCurve;
    bool _madeSound;
    bool _isInvincible;
    bool _fadeout;
    bool _rotateLights;
    bool _aggressiveCanHit;
    bool _beatsPlayerAction;
    bool _hasAppeared;
    bool _chaseTriggered;
    bool _isVisible;
    float _movedBy;
    float _initialPosition;

    
    CGRect _range;       //range in which this object can move on screen. absolute positions.
    
    CGPoint _prevLocation;
    
    //collision
    CGRect _boundingBox;
    CGRect _originalBoundingBox; //used by zombies
    
    NSString *_originalAnimation;
    
    Projectile *_projectile;
    
    bool _collided;     //starts false, but switches to true when player collides with it
                        //so the player can't keep colliding with it
    
    bool _isAggressive;
    
    bool _persistsBetweenRegions;
    
    bool _isHurdle;
    
    Collision *_collisionState;     //used to keep track of whether the object is in midair or on
                                    //the ground.
    
    CollisionBehavior _currentBehavior;
    CollisionBehavior _collideBehavior;
    
    bool _isStutterMode;
    
    PlayerEffect _playerEffect;
}

@property(nonatomic,retain) Sprite *sprite;
@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;
@property(nonatomic,assign) float vx;
@property(nonatomic,assign) float vy;
@property(nonatomic,assign) CGRect boundingBox;
@property(nonatomic,assign) CollisionBehavior CurrentBehavior;
@property(nonatomic, retain)NSString *originalAnimation;
@property(nonatomic,assign) bool collided;
@property(nonatomic,assign) bool hasGravity;
@property(nonatomic,assign) bool isAggressive;
@property(nonatomic,assign) bool isInMidAir;
@property(nonatomic,assign) bool isFalling;
@property(nonatomic,assign) bool isInvincible;
@property(nonatomic,assign) bool isHurdle;
@property(nonatomic,assign) bool rotateLights;
@property(nonatomic,assign) bool beatsPlayerAction;
@property(nonatomic,assign) bool hasAppeared;
@property(nonatomic,assign) float magnitude;
@property(nonatomic,assign) bool persistsBetweenRegions;
@property(nonatomic,assign) float slowTimeModifier;


#pragma mark - initialization

+(id) instance;
+(id) objectWithSprite:(Sprite*)sprite;     //create game object, add a sprite to it, return
-(id) initWithSprite:(Sprite*)initSprite;   //constructor
-(void) initialize:(NSString*)type;

#pragma mark - getters and setters


-(bool)canAggressiveHit;

-(Collision*) getCollision;
-(CollisionBehavior)getCurrentCollisionBehavior;
-(CGPoint) getPosition;
-(CGPoint) getPreviousPosition;
-(CCSprite*) getCCSprite;
-(Projectile*) getProjectile;
-(Boss*)getBoss;
-(Sprite*) getSprite;

-(void) setOffsetForX:(float)x Y:(float)y;
-(void) setPosition:(CGPoint)position;
-(void) setPositionAtX:(float)x Y:(float)y;     //give new x and y position on screen (with cocos2D, both hi and low-res use 320x480 resolution for its points)
-(void) setStartingPosition:(CGPoint)position;
-(void) setCollideBehavior:(NSString*)behavior;
-(void) setPlayerEffect:(NSString*)effect;
-(void) setOriginalAnimation:(NSString*)animation;
-(void) setRange:(CGRect)rect;
-(bool) checkIfOffScreen:(CGPoint)position;

#pragma mark - public methods
-(void) move:(CGPoint)amount;
-(void) reset;
-(PlayerEffect) startCollision;
-(void) special_kickHen;
-(void) update:(float)dt;
-(bool) closeToPlayer:(float)closerThan;


#pragma mark - private methods
-(void) switchToInactive;
-(void) updateCollisionBehavior:(float)dt;
-(void) updateFadeOut:(float)dt;
-(void) updateFlags;
-(void) updateLights:(float)dt;

#pragma mark - obstacle behaviors
-(void) chaseAtDistance:(float)distance DefaultSpeed:(float)defaultSpeed ChaseSpeed:(float)chaseSpeed;
-(void) chaseAtDistance:(float)distance DefaultSpeed:(float)defaultSpeed ChaseSpeed:(float)chaseSpeed ChaseSound:(NSString*)sound;
-(void) chaseAtDistance:(float)distance DefaultSpeed:(float)defaultSpeed ChaseSpeed:(float)chaseSpeed ChaseSound:(NSString*)sound ChaseAnimation:(NSString*)chaseAnim DefaultAnimation:(NSString*)defaultAnim;


-(void) moveToStartingPosition;


@end
