//
//  GameObject.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  An object in the game. Means it will have a sprite associated with it, an x/y position, maybe other things like animation and velocity

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;

@class Collision;

typedef enum {
    COLLISION_BEHAVIOR_FALL_OVER,
    COLLISION_BEHAVIOR_ALIEN_ABDUCTION,
    COLLISION_BEHAVIOR_FLYING_SHURIKEN,
    COLLISION_BEHAVIOR_HEN_KICKED,
    COLLISION_BEHAVIOR_PLAY_ANIMATION,
    COLLISION_BEHAVIOR_STATIC,
    COLLISION_BEHAVIOR_COW_COLLAPSE,
    COLLISION_BEHAVIOR_NONE
} CollisionBehavior;

typedef enum {
    PLAYER_EFFECT_COLLIDE,
    PLAYER_EFFECT_SLOWDOWN,
    PLAYER_EFFECT_ACTION_OR_COLLIDE,
    PLAYER_EFFECT_NONE
} PlayerEffect;

@interface GameObject : NSObject
{
    Sprite *_sprite;
    
    bool _isActive;      //starts true, but switched to false if we no longer
                         //want the object to be seen or updated
    
    bool _hasGravity;
    bool _isInMidAir;
    bool _isFalling;
    
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
    bool _chickenSound;
    bool _isInvincible;
    bool _fadeout;
    bool _rotateLights;
    
    int _direction;
    
    CGRect _range;       //range in which this object can move on screen. absolute positions.
    
    CGPoint _prevLocation;
    
    //collision
    CGRect _boundingBox;
    
    NSString *_originalAnimation;
    
    bool _collided;     //starts false, but switches to true when player collides with it
                        //so the player can't keep colliding with it
    
    bool _isAggressive;
    
    Collision *_collisionState;     //used to keep track of whether the object is in midair or on
                                    //the ground.
    
    CollisionBehavior _currentBehavior;
    CollisionBehavior _collideBehavior;
    
    PlayerEffect _playerEffect;
}

@property(nonatomic,retain) Sprite *sprite;
@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;
@property(nonatomic,assign) float vx;
@property(nonatomic,assign) float vy;
@property(nonatomic,assign) CGRect boundingBox;
@property(nonatomic,assign) CollisionBehavior CurrentBehavior;
@property(readonly,nonatomic,assign) bool collided;
@property(nonatomic,assign) bool hasGravity;
@property(nonatomic,assign) bool isAggressive;
@property(nonatomic,assign) bool isInMidAir;
@property(nonatomic,assign) bool isFalling;
@property(nonatomic,assign) bool isInvincible;
@property(nonatomic,assign) bool rotateLights;


+(id) instance;

+(id) objectWithSprite:(Sprite*)sprite;     //create game object, add a sprite to it, return
-(id) initWithSprite:(Sprite*)initSprite;   //constructor

-(void) initialize:(NSString*)type;

-(void) setOffsetForX:(float)x Y:(float)y;
-(void) switchToInactive;

-(void) setPosition:(CGPoint)position;
-(void) setPositionAtX:(float)x Y:(float)y;     //give new x and y position on screen (with cocos2D, both hi and low-res use 320x480 resolution for its points)
-(void) setStartingPosition:(CGPoint)position;

-(CCSprite*) getCCSprite;

-(void)special_kickHen;


-(void)reset;

-(CGPoint) getPosition;
-(CGPoint) getPreviousPosition;

-(void)setRange:(CGRect)rect;

-(Collision*) getCollision;

-(void) setCollideBehavior:(NSString*)behavior;
-(void) setPlayerEffect:(NSString*)effect;
-(void) setOriginalAnimation:(NSString*)animation;

-(void) updateFlags;

-(void) updateLights:(float)dt;

-(PlayerEffect) startCollision;

-(void) update:(float)dt;

@end
