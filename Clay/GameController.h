//
//  GameController.h
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InputController.h"

@class GameLayer;

@class PauseMenuScreen;
@class HudLayer;

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
    HudLayer *_hud;
    PauseMenuScreen *_pauseMenu;
    
    
    
    bool _isPaused;
    bool _isInputEnabled;
}

@property(nonatomic,retain) GameLayer *layer;
@property(readonly,nonatomic,assign) bool isPaused;
@property(nonatomic,assign) bool isInputEnabled;

+(id)gameController;

-(void)changeGameState:(GameState)gameState;
-(void)reactToTouchAt:(CGPoint)location InputType:(InputType)type;
-(void)setGameLayer:(GameLayer*)layer;
-(void)setHud:(HudLayer*)hud;
-(void)pauseGame;

@end
