//
//  Player.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The main player and runner in the game. He inherits from GameObject, then from Runner (since other runners are expected to be in the game at some point, although now they probably could just be GameObjects). So if something is not here, it's probably under Runner or GameObject.

#import <Foundation/Foundation.h>
#import "BaseClasses.h"
#import "Runner.h"
#import "cocos2d.h"
#import "Skin.h"

typedef enum {
    JUMP_HIGH = 3,
    JUMP_MEDIUM = 2,
    JUMP_SHORT = 1
} RunnerJump;

typedef enum {
    SKINTYPE_REGULAR,
    SKINTYPE_8BIT
}SkinType;


//TODO: Make player animations easier to predict by having it determined in only one location, governed by a state machine.

@class RunningSpeed;
@class Battery;
@class Skin;
@class PlayerAction;
@protocol PlayerActionProtocol;


@interface Player : Runner
{
    float _totalTime; //used for equation-based movement
    
    
   
    bool _isJumping;
    bool _isTripping;
    bool _firstFrameJumping;
    bool _isDead;
    bool _offLedge;
    
    
    float _yPosition;
    float _waitToGetUp;
    float _waitToTurbo;
    bool _onLedge;
    
    bool _isHighJump;
    bool _isTurbo;
    bool _isWindy;
    bool _inVaccuum; //used only by water bubbles, sucks tim in place
    bool _hasDoubleJumped;
    bool _soundFalling;
    bool _hadCollisionThisUpdate;
    
    PlayerEffect _currentPlayerEffect;
    
    float _timeLeftBeforeVulnerable;    //set to a time whenever tim gets back up, to allow proper time for him to get back up to speed before he has to jump on things
    
    float _waitToEndJump;
    
    int _hitPoints;
    Battery *_battery;
    
    RunnerJump _jumpHeight;
    
    float _adjustX;
    float _waitToPlaySlowSound;
    
    NSString *_previousAnimation;
    
    NSMutableArray *projectiles;
    
    Skin *_skin;
    
    PlayerAction *_thirdAction; //playeraction
    
    Sprite *_playerOnledge;
    Sprite *_tempSprite;
}

@property(nonatomic,assign) bool isDead;
@property(nonatomic,assign) bool isTripping;
@property(nonatomic,assign) bool isJumping;
@property(nonatomic,assign) bool isWindy;
@property(nonatomic,assign) bool hasDoubleJumped;
@property(nonatomic,assign) bool inVaccuum;
@property(nonatomic,assign) bool hadCollisionThisUpdate;
@property(nonatomic,assign) bool onLedge;


@property(nonatomic,retain) Battery *battery;

+(id) instance;                                 //constructor

-(float)getVelocityX;                           //get the current velocity (read-only, for now)
-(void)update:(float)dt Level:(Level*)level;    //update, dt = seconds since last update

-(void)startJump:(RunnerJump)type;
-(void)boostJump:(RunnerJump)type;
-(void)endJump;
-(void)updateJump:(float)dt;

-(void)startTurbo;
-(bool)getIsTurbo;

-(void)endTurbo;

-(void)endKick;
-(RunningSpeed*)getSpeed;

-(void)startThirdAction;
-(void)startCollision:(PlayerEffect)effect Source:(id<Collidable>)source;

-(void)setPlayerAnimation:(PlayerAnimation)animation;
-(void)setKilledEnemy:(bool)killEnemy;
-(void)changeHealth:(int)amount;
-(bool)objectShouldReactToCollision;
-(void)reset;
-(void)resetSprite:(CCLayer*)layer;
-(void)setLedgeSprite:(CCLayer*)layer;
-(void)setCurrentSprite:(Sprite *)sprite;
-(void)rechargeBattery;
-(void)resetSprint;

-(void)setVelocity:(float)velocity;
-(void)startDoubleJump;
-(int)getHitPoints;

-(void)dieIfFallenIntoPit;

-(void)private_StartPlayerCollision;

-(void)pushAfterAnimation:(float)xAmount;

-(void)updatePitFalling:(float)dt;
-(void)updateSlow:(float)dt;
-(void)updateInvulnerable:(float)dt;
-(void)updateTurbo:(float)dt;
-(void)updateLedge:(float)dt;
-(void)updatePlayerPosition:(float)dt Level:(Level*)level;
-(void)updateSkin:(SkinType)skin;

-(void)startVaccuum;
-(void)endVaccuum;

-(void)setThirdAction:(NSString*)action;
-(id<PlayerActionProtocol>)getThirdAction;

@end
