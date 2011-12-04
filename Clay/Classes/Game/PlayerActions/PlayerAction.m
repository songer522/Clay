//
//  PlayerAction.m
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerAction.h"
#import "Player.h"
#import "LayerManager.h"
#import "GameLayer.h"
#import "HudLayer.h"

@implementation PlayerAction

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _inAction = false;
        _cooldown = 0.0f;
        _cooldownStart = 0.1f;
        _canTrigger = true;
        [self initialize];
    }
    
    return self;
}

-(void) initialize
{
    
}


-(void)startAction
{
    if (!_inAction && _canTrigger) {
        _inAction = true;
        _isActive = false;
        _canTrigger = false;
        _hasKilledEnemy = false;
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
         
        [[gameLayer getHud] setEnabled:false ForButton:HUD_BUTTON_ACTION];
              
    }
}

-(void)update:(float)dt
{
    if (_inAction) {
        _duration -= dt;

        if (_duration <= 0.0f) {
            [self endAction];
        }
        
        [[[[[LayerManager sharedLayers] currentLayer] getHud] getActionButton] updateOverlayImageByPercentage:0.0f]; 
    }
    
    if (_cooldown>0.0f) {            
        _cooldown -= dt;
        if (_cooldown<=0.0f && !_canTrigger) {
            [self enableAction];
            _cooldown = 0.0f;
        }
        
        float percent = (_cooldownStart - _cooldown)/_cooldownStart;
        [[[[[LayerManager sharedLayers] currentLayer] getHud] getActionButton] updateOverlayImageByPercentage:percent];
    }
}

-(void) enableAction
{
    _canTrigger = true;
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_ACTION];
     
}

-(bool)inAction
{
    return _inAction;
}

-(bool)isActive
{
    return _isActive;
}

-(void)cancelAction
{
    _inAction = false;
    _isActive = false;
    _cooldown = _cooldownStart;
}


-(void)endAction
{
    _inAction = false;
    _isActive = false;
    _cooldown = _cooldownStart;
    if (_hasKilledEnemy) {
        [_parent changeHealth:1];
    }
}

-(NSMutableArray*)getProjectiles
{
    return nil;
}

-(void)setParent:(Player*)player
{
    _parent = player;
}

-(Player*)getParent
{
    return _parent;
}

-(void)setKilledEnemy:(bool)killedEnemy
{
    _hasKilledEnemy = killedEnemy;
}

-(bool)shouldTriggerPlayerHurtCollision
{
    return true;
}

-(bool)canAggressiveHit
{
    return false;
}

-(bool)canStartInMidAir
{
    return false;
}

-(void)dealloc
{
    _parent = nil;
    [super dealloc];
}



@end
