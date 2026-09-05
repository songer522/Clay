//
//  PlayerActionSlowTime.m
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionSlowTime.h"
#import "LevelManager.h"
#import "Level.h"
#import "MapObject.h"
#import "GameObject.h"
#import "Sprite.h"
#import "Animation.h"
#import "Player.h"
#import "RunningSpeed.h"
#import "GameLayer.h"
#import "LayerManager.h"
#import "BossFinalJim.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133f : 1.0f)


@implementation PlayerActionSlowTime

-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 1.4f;
    
    _sprite = [Sprite spriteWithFile:@"blank.png"];
    [[_sprite getCCSprite] setVisible:NO];
    
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    _boss = [gameLayer getBoss];
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        
        [super startAction];        
        [_parent endTurbo:false];
        
        [self updateSlowdown:0.2f];
        _duration = 5.00f;
        _waitToHideSprite = 0.9f;

        //[_parent setPlayerAnimation:PLAYER_ANIM_SLOWTIME];
        [[_parent getSpeed] setVelocityModifier:0.8f];
        
        [[_sprite getCCSprite] setVisible:YES];
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"slowTimeAnim"];
        
        [[SoundEngine shared] playSound:@"darkSlowTimeAction"];
        
    }
}

-(void)endAction
{
    [self updateSlowdown:1.0f];
    [[_parent getSpeed] setVelocityModifier:1.0f];
    [self setKilledEnemy:YES];
    
    [[_sprite getCCSprite] setVisible:NO];
    [super endAction];
    
}

-(void)cancelAction
{
    //NOTE: for now, can't be cancelled
    //if this gets undone in the future, keep in mind you'll need to write an exception for
    //slowdowns, because they call 'startcollision' constantly, which calls cancelAction
    return;
}


-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
    } else {
        _isActive = true;
        //[_sprite setPosition:ccp(_player.x - 0.0f, _player.y + 45.0f)];
        // Unlike the Level 9 rain splash (which had a commented-out iPad branch, i.e. a
        // clearly unfinished fix), this offset had no such marker: -70 world px was authored
        // when the world was phone-scale. On iPad the world is MULTIPLIERX wider, so an
        // unscaled -70 sits proportionally much closer to Tim than intended. This keeps the
        // aura at the same position relative to him on both devices - but it is a real iPad
        // feel change, not a no-op. Confirm on the overlay.
        [_sprite setPosition:ccp(_parent.x - 70.0f * MULTIPLIERX, _parent.y)];
        
        if (_waitToHideSprite > 0.0f) {
            _waitToHideSprite -= dt;
            if (_waitToHideSprite <=0.0f) {
                [[_sprite getCCSprite] setVisible:NO];
            }
        }
    }
    [super update:dt];
}

-(void)updateSlowdown:(float)modifier
{
    float animModifier = modifier * 2.0f;
    if (animModifier > 1.0f) {
        animModifier = 1.0f;
    }
    
    NSMutableArray *mapObjects = [[LevelManager shared] currentLevel].obstacleSprites;
    for (MapObject *mapObject in mapObjects) {
        GameObject *obstacle = mapObject.object;
        obstacle.slowTimeModifier = modifier;
        
        //not working yet
        Animation *anim = [[obstacle getSprite] getAnimation];
        if(anim!=nil) {
            [anim changeAnimationSpeed:animModifier];
        }
        
    }
    
    [_boss changeAnimationSpeed:animModifier];
}

-(bool)canStartInMidAir
{
    return true;
}

-(bool) playerAllowedToJump
{
    return true;
}

-(bool) playerAllowedToSprint
{
    return true;
}

-(void)dealloc
{
    _boss = nil;
    [super dealloc];
}

@end
