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
#import "GCState.h"
#import "GCHelper.h"
#import "LevelManager.h"
#import "Level.h"

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
        _isCheering = false;
        _hud = [[[LayerManager sharedLayers] currentLayer] getHud];
        _actionButton = [[[[LayerManager sharedLayers] currentLayer] getHud] getActionButton];
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
        [_hud setEnabled:false ForButton:HUD_BUTTON_ACTION];
              
    }
}

-(void)update:(float)dt
{
    if (_inAction) {
        _duration -= dt;

        if (_duration <= 0.0f) {
            [self endAction];
        }
        [[_hud getActionButton] updateOverlayImageByPercentage:0.0f];
    }
    
    if (_cooldown>0.0f) {            
        _cooldown -= dt;
        if (_cooldown<=0.0f && !_canTrigger) {
            [self enableAction];
            _cooldown = 0.0f;
        }
        
        float percent = (_cooldownStart - _cooldown)/_cooldownStart;
        [[_hud getActionButton] updateOverlayImageByPercentage:percent];
    }
    
 
}

-(void) enableAction
{
    _canTrigger = true;
    [_hud setEnabled:true ForButton:HUD_BUTTON_ACTION];
}
-(void) disableAction
{
    _canTrigger = false;
    [_hud setEnabled:true ForButton:HUD_BUTTON_ACTION];
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

-(void)reportAchievementData
{
    Level *level = [[LevelManager shared] currentLevel];
    if([level.name isEqualToString:@"level4"])
    {
        [self shuffledOver];
    }
    
    else if ([level.name isEqualToString:@"level6"])
    {
        [self shotZombie];
    }
  
    else if ([level.name isEqualToString:@"level7"])
    {
        [self blockshot];
    }
    
}


-(void)endAction
{
    _inAction = false;
    _isActive = false;
    _cooldown = _cooldownStart;
    if (_hasKilledEnemy) {
        [_parent changeHealth:1];
        [self reportAchievementData];
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

-(void)isCheering:(bool)cheering
{
    _isCheering=cheering;
}

-(bool)canAggressiveHit
{
    return false;
}

-(bool)canStartInMidAir
{
    return false;
}

-(bool)canStartOnGround
{
    return true;
}

-(bool) playerAllowedToJump
{
    return false;
}

-(bool) playerAllowedToSprint
{
    return false;
}

-(void)shuffledOver
{
    int maxShuffle = 200;
  
    if ([GCState sharedInstance].peopleShuffled < maxShuffle) {
        [GCState sharedInstance].peopleShuffled++;
        
        double pctComplete = ((double) [GCState sharedInstance].peopleShuffled / (int)maxShuffle) * 100.0;
        if(pctComplete == 100.0)
        {
            //[[GCState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:gcAchievementShuffled200people percentComplete:pctComplete];
        }
    }
    
}

-(void)shotZombie
{
    int maxZombie = 300;
     
    if ([GCState sharedInstance].zombiesShot < maxZombie) {
        [GCState sharedInstance].zombiesShot++;
        
        double pctComplete2 = ((double) [GCState sharedInstance].zombiesShot / (int)maxZombie) * 100.0;
        if(pctComplete2 == 100.0)
        {
            //[[GCState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:gcAchievementShoot300zombies percentComplete:pctComplete2];
        }
    }
    
}


-(void)blockshot
{
    int maxBlock = 75;
    
    if ([GCState sharedInstance].attacksBlocked < maxBlock) {
        [GCState sharedInstance].attacksBlocked++;
        
        double pctComplete4 = ((double) [GCState sharedInstance].attacksBlocked / (int)maxBlock) * 100.0;
        if(pctComplete4 == 100.0)
        {
           // [[GCState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:gcAchievementBlock75attack percentComplete:pctComplete4];
        }
    }
    
}


-(void)dealloc
{
    _parent = nil;
    [super dealloc];
}



@end
