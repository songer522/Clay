//
//  Trigger.h
//  Clay
//
//  Created by Brian Cable on 9/22/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  A trigger for special events in the game, placed within the Tiled maps. So far, only three types supported: checkpoints, a trigger for switching to the next level, and spawn point for the player (which must always be 4,12 in the map or some things get positioned incorrectly). Supports triggering when the player has gone past a certain point in a given direction. Probably more complicated than it needs to be now. Originally this was designed for Tim to go any direction.

#import <Foundation/Foundation.h>

typedef enum {
    TRIGGER_CHECKPOINT,
    TRIGGER_NEXTLEVEL,
    TRIGGER_SPAWNPOINT
}TriggerType;

@interface Trigger : NSObject
{
    bool _triggered;
    CGPoint _position;
    CGPoint _direction;
    TriggerType _type;
}

@property(nonatomic,assign) bool triggered;
@property(nonatomic,assign) CGPoint position;
@property(nonatomic,assign) CGPoint direction;
@property(nonatomic,assign) TriggerType type;

@end
