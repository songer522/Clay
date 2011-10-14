//
//  PlayerAction.h
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@protocol PlayerAction

+(id)instance;
-(bool)inAction;
-(void)startAction;
-(void)cancelAction;
-(void)endAction;
-(bool)isActive;
-(void)update:(float)dt;
-(bool)shouldTriggerPlayerHurtCollision;
-(void)setParent:(Player*)player;
-(Player*)getParent;

@end
