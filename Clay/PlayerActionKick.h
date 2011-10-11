//
//  PlayerActionKick.h
//  Clay
//
//  Created by Brian Cable on 10/11/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerAction.h"

@interface PlayerActionKick : NSObject <PlayerAction>
{
    Player *_parent;    
}

+(id)instance;
-(void)startAction;
-(void)update:(float)dt;

-(void)setParent:(Player*)player;
-(Player*)getParent;


@end
