//
//  BossFinal.m
//  Clay
//
//  Created by Brian Cable on 1/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BossFinal.h"
#import "Sprite.h"
#import "Player.h"
#import "LayerManager.h"
#import "GameLayer.h"

@implementation BossFinal

-(void)startBoss
{
    _player = [[LayerManager sharedLayers] getPlayer];
    _firstUpdate = true;
    _gameLayer = [[LayerManager sharedLayers] currentLayer];
    _speedModifier = 1.0f;
}

-(void)setSprite:(Sprite *)sprite
{
    _train = sprite;
}

-(void)triggerAction:(FinalBossPhase)phase
{
    [self setVisible:YES];
    
    _phase = phase;
    
    switch (phase) {
        case FINAL_BOSS_ATTACK_1:
            break;
        case FINAL_BOSS_ATTACK_2:
            break;
        case FINAL_BOSS_ATTACK_3:
            break;
        case FINAL_BOSS_ENTER:
            _trainPosition = ccp(_player.x + 0,100);
            [_train getCCSprite].visible = YES;
            _speed = 20.0f;
            break;
        case FINAL_BOSS_DIE:
            break;
        case FINAL_BOSS_IDLE:
            [self setVisible:NO];
            break;
        default:
            break;
    }
}

-(void)update:(float)dt
{
    if (_firstUpdate) {
        [self firstUpdate];
    }
    
    switch (_phase) {
        case FINAL_BOSS_ENTER:
            [self updateBossEntrance:dt];
            break;
            
        default:
            break;
    }
}

-(void)firstUpdate
{
    //[_gameLayer addChild:[_train getCCSprite]];
    _firstUpdate = false;
}

-(void)updateBossEntrance:(float)dt
{
    _trainPosition.x += _speed;
    [_train setPosition:_trainPosition];
}

-(void)setVisible:(_Bool)isVisible
{
    [[_train getCCSprite] setVisible:isVisible];
}

-(void)changeAnimationSpeed:(float)modifier
{
    [[_train getAnimation] changeAnimationSpeed:modifier];
    _speedModifier = modifier;
}

@end
