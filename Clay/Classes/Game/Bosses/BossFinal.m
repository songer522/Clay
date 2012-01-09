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
    _resetSpriteVisibility = FALSE;
    _gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    _trainWheels = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    _trainJim = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
    
    _speedModifier = 1.0f;
    
    [self setVisible:NO];
}

-(void)setSprite:(Sprite *)sprite
{
    _train = sprite;
}

-(void)triggerAction:(FinalBossPhase)phase
{    
    _phase = phase;
    
    switch (phase) {
        case FINAL_BOSS_ATTACK_1:
            break;
        case FINAL_BOSS_ATTACK_2:
            break;
        case FINAL_BOSS_ATTACK_3:
            break;
        case FINAL_BOSS_ENTER:
            _trainPosition = CGPointMake(_player.x + 900,165); //230,135
            [self updatePosition:_trainPosition];
            [self setVisible:YES];
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
    if (_resetSpriteVisibility) {
        [self resetSpriteVisibility];
    }
    
    switch (_phase) {
        case FINAL_BOSS_ENTER:
            [self updateBossEntrance:dt];
            break;
            
        default:
            break;
    }
}

-(void)resetSpriteVisibility
{
    [self setAlpha:1.0f];
    [self setVisible:YES];
    _resetSpriteVisibility = false;
}

-(void)updateBossEntrance:(float)dt
{
    [self updatePosition:_trainPosition];
}

-(void)setVisible:(_Bool)isVisible
{
    [[_train getCCSprite] setVisible:isVisible];
    [[_trainWheels getCCSprite] setVisible:isVisible];
    [[_trainJim getCCSprite] setVisible:isVisible];
}

-(void)setAlpha:(float)alpha
{
    [_train setAlpha:1.0f];
    [_trainWheels setAlpha:1.0f];
    [_trainJim setAlpha:1.0f];
}

-(void)changeAnimationSpeed:(float)modifier
{
    [[_train getAnimation] changeAnimationSpeed:modifier];
    _speedModifier = modifier;
}

-(void)addSpritesToLayer:(id)layer SpriteBatch:(CCSpriteBatchNode*)spriteBatch
{
    [layer addChild:[_trainWheels getCCSprite]];
    [[AnimationController sharedController] replaceSprite:_trainWheels withAnimationNamed:@"darkBossWheelAnim"];
    [layer addChild:[_trainJim getCCSprite]];
    [[AnimationController sharedController] replaceSprite:_trainJim withAnimationNamed:@"darkBossJimIdle1"];
    
    //[[_trainWheels getCCSprite] useBatchNode:spriteBatch];

}

-(void)updatePosition:(CGPoint)position
{
    [_train setPosition:position];
    [_trainWheels setPosition:CGPointMake(position.x - 268.0f,position.y - 118.0f)];
    [_trainJim setPosition:CGPointMake(position.x - 268.0f,position.y - 118.0f)];
    
}

-(void) reset
{
    [self triggerAction:FINAL_BOSS_IDLE];
    _resetSpriteVisibility = true;
}

@end
