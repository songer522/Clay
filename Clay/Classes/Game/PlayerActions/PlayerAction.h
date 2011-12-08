//
//  PlayerAction.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  The base class for all the custom third actions the player can use. These are managed and called by the Player class, and interacts with the HudLayer class as far as showing the correct HudButton for the level. Also the LevelManager might use it briefly when loading levels. Mostly controlled by the player, though.

#import <Foundation/Foundation.h>

@class Player;

@protocol PlayerActionProtocol

+(id)instance;
-(bool)inAction;
-(void)startAction;
-(void)cancelAction;
-(void)endAction;
-(bool)isActive;
-(void)update:(float)dt;
-(bool)shouldTriggerPlayerHurtCollision;
-(void)setParent:(Player*)player;
-(void)setKilledEnemy:(bool)killedEnemy;
-(Player*)getParent;
-(NSMutableArray*)getProjectiles;
-(bool)canAggressiveHit;
-(bool)canStartInMidAir;
-(bool)canStartOnGround;

@end



@interface PlayerAction : NSObject<PlayerActionProtocol>
{
    Player *_parent;
    bool _inAction;     //if currently executing the action
    bool _isActive;     //if true, then the action is currently "active", which means whatever
    //it can trigger will be triggered during this time (a kick will actually kick,
    //a "woo" will scare the background, etc.
    bool _hasKilledEnemy;
    float _duration;
    float _cooldown;
    float _cooldownStart; //used to determine percentage the cooldown is complete
    bool _canTrigger;
}

-(void) initialize; //individual actions can setup specific vars here

-(void) enableAction; //called when action can be called again

-(bool) playerAllowedToJump;

@end
