//
//  GameController.h
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameLayer;

@class PauseMenuScreen;

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
    GameLayer *_gameLayer;
    PauseMenuScreen *_pauseMenu;
    
    bool _isPaused;
}

@property(nonatomic,retain) GameLayer *layer;
@property(readonly,nonatomic,assign) bool isPaused;

+(id)gameController;

-(void)changeGameState:(GameState)gameState;
-(void)reactToTouchAt:(CGPoint)location;
-(void)setGameLayer:(GameLayer*)layer;

-(void)pauseGame;

@end
