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
    _jim = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    _mineCart = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    [_mineCart getCCSprite].anchorPoint = ccp(0.5f,0.5f);
    _firstUpdate = true;
    _gameLayer = [[LayerManager sharedLayers] currentLayer];
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
            _mineCartPosition = ccp(_player.x + 600,100);
            _jimPosition = _mineCartPosition;
            [_mineCart setPosition:_mineCartPosition];
            [[AnimationController sharedController] replaceSprite:_jim withAnimationNamed:@"darkShadowTimLaughingAnim"];
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
    [_gameLayer addChild:[_jim getCCSprite]];
    [_gameLayer addChild:[_mineCart getCCSprite]];
    _firstUpdate = false;
}

-(void)updateBossEntrance:(float)dt
{
    float speed = 20.0f * dt;
    _mineCartPosition.x -= speed;
    _jimPosition.x = _mineCartPosition.x;
    _jimPosition.y = _mineCartPosition.y + 20.0f;
    [_mineCart setPosition:_mineCartPosition];
    [_jim setPosition:_jimPosition];
}

-(void)setVisible:(_Bool)isVisible
{
    [[_jim getCCSprite] setVisible:isVisible];
    [[_mineCart getCCSprite] setVisible:isVisible];
}

-(void)changeAnimationSpeed:(float)modifier
{
    [[_jim getAnimation] changeAnimationSpeed:modifier];
    [[_mineCart getAnimation] changeAnimationSpeed:modifier];
}

@end
