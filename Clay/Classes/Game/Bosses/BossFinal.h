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
    Sprite *_jim;
    Sprite *_mineCart;
    CGPoint _jimPosition;
    CGPoint _mineCartPosition;
    
    FinalBossPhase _phase;
    
    
    //weak reference
    Player *_player;
    GameLayer *_gameLayer;
    
    bool _firstUpdate;
}

-(void)triggerAction:(FinalBossPhase)phase;
-(void)setVisible:(bool)isVisible;
-(void)firstUpdate;
-(void)updateBossEntrance:(float)dt;
@end
