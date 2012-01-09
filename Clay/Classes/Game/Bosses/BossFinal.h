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
@class GameLayer;

@interface BossFinal : Boss
{
    Sprite *_train;
    Sprite *_trainWheels;
    Sprite *_trainJim;
    
    
    CGPoint _trainPosition;
    
    FinalBossPhase _phase;
    
    
    //weak reference
    Player *_player;
    GameLayer *_gameLayer;
    
    bool _resetSpriteVisibility;
    
    float _speed;
    float _speedModifier;
}

-(void)triggerAction:(FinalBossPhase)phase;
-(void)setVisible:(bool)isVisible;
-(void)setAlpha:(float)alpha;
-(void)resetSpriteVisibility;
-(void)updateBossEntrance:(float)dt;
-(void)updatePosition:(CGPoint)position;
-(void)addSpritesToLayer:(id)layer SpriteBatch:(CCSpriteBatchNode*)spriteBatch;
@end
