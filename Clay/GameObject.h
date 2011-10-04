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
    COLLISION_BEHAVIOR_STATIC
} CollisionBehavior;

@interface GameObject : NSObject
{
    Sprite *_sprite;
    
    bool _isActive;      //starts true, but switched to false if we no longer
                         //want the object to be seen or updated
    
    float _x;
    float _y;
    CGPoint _startingPosition;
    float _vx;
    float _vy;
    float _offsetX;     //how much to offset whatever x position comes in by
    float _offsetY;     //how much to offset whatever y position comes in by
    float _angle;
    float _rotationAmount;
    
    float _fallVelocity;
    
    CGPoint _prevLocation;
    
    //collision
    CGRect _boundingBox;
    
    bool _collided;     //starts false, but switches to true when player collides with it
                        //so the player can't keep colliding with it
    
    Collision *_collisionState;     //used to keep track of whether the object is in midair or on
                                    //the ground.
    
    CollisionBehavior _behavior;
}

@property(nonatomic,retain) Sprite *sprite;
@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;
@property(nonatomic,assign) float vx;
@property(nonatomic,assign) float vy;
@property(nonatomic,assign) CGRect boundingBox;
@property(readonly,nonatomic,assign) bool collided;


+(id) instance;
+(id) objectWithSprite:(Sprite*)sprite;     //create game object, add a sprite to it, return
-(id) initWithSprite:(Sprite*)initSprite;   //constructor

-(void) setOffsetForX:(float)x Y:(float)y;
-(void) switchToInactive;

-(void) setPosition:(CGPoint)position;
-(void) setPositionAtX:(float)x Y:(float)y;     //give new x and y position on screen (with cocos2D, both hi and low-res use 320x480 resolution for its points)
-(void) setStartingPosition:(CGPoint)position;

-(CCSprite*) getCCSprite;


-(void)reset;

-(CGPoint) getPosition;
-(CGPoint) getPreviousPosition;
-(Collision*) getCollision;

-(void) startCollision;

-(void) update:(float)dt;

@end
