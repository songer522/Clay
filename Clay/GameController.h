//
//  GameController.h
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameLayer;

typedef enum {
    GAMESTATE_INITIALIZE,
    GAMESTATE_PRE_RACE,
    GAMESTATE_RACING,
    GAMESTATE_PRE_DAYDREAM,
    GAMESTATE_IN_DAYDREAM,
    GAMESTATE_POST_DAYDREAM,
    GAMESTATE_POST_RACE
} GameState;

@interface GameController : NSObject
{
    GameState _currentGameState;
    GameLayer *_layer;
}

@property(nonatomic,retain) GameLayer *layer;

+(id)gameController;

-(void)changeGameState:(GameState)gameState;
-(void)reactToTouchAt:(CGPoint)location;
-(void)setLayer:(GameLayer*)layer;

@end
