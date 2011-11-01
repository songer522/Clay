//
//  PlayerAction.h
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

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
    bool _canTrigger;
}

-(void) initialize; //individual actions can setup specific vars here

-(void) enableAction; //called when action can be called again


@end
