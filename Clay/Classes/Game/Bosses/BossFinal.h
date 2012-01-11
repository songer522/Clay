//
//  BossFinal.h
//  Clay
//
//  Created by Brian Cable on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Boss.h"

@class Sprite;
@class Player;
@class Level;
@class GameLayer;
@class Projectile;

typedef enum {
    TRAIN_PHASE_ACCELERATE,
    TRAIN_PHASE_BRAKE
} TrainPhase;

@interface BossFinal : Boss
{
    Sprite *_train;
    Sprite *_trainWheels;
    Sprite *_trainJim;
    
    Projectile *_bomb;
    Projectile *_door;
    
    
    CGPoint _trainPosition;
    
    FinalBossPhase _phase;
    
    TrainPhase _trainPhase;
    
    //weak reference
    Player *_player;
    GameLayer *_gameLayer;
    
    bool _resetSpriteVisibility;
    bool _inAttack;
    bool _hasThrownBomb;
    
    float _speed;
    float _speedModifier;
    float _waitToSwitch;
}

-(void)triggerAction:(FinalBossPhase)phase;
-(void)setVisible:(bool)isVisible;
-(void)setAlpha:(float)alpha;
-(void)resetSpriteVisibility;
-(void)updateBossEntrance:(float)dt;
-(void)updatePosition:(CGPoint)position;
-(void)addSpritesToLayer:(id)layer SpriteBatch:(CCSpriteBatchNode*)spriteBatch;
-(void)moveForward:(float)dt;
-(void)finishedPhase;
-(bool)checkWait:(float)dt;
-(void)testCollisions:(Projectile*)projectile;
@end
