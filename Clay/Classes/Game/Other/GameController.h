//
//  GameController.h
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Manages the controlling of the game itself. Right now this basically means it handles pausing/unpausing the game, and reacting to the hud button inputs. Was also going to manage gamestate, but that seems to have been taken over by the ComicManager class.


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
    HudLayer *_hud; //weak reference
    PauseMenuScreen *_pauseMenu;
    
    bool _isPaused;
    bool _isHandlingPause; //game layer checks this to know whether the scene is either being killed or game controller wants to pause
    bool _handledPauseEvent;
    bool _isInputEnabled;
    bool _isSprintEnabled;
    
}

@property(nonatomic,retain) GameLayer *layer;
@property(readonly,nonatomic,assign) bool isPaused;
@property(nonatomic,assign) bool isInputEnabled;
@property(nonatomic,assign) bool isSprintEnabled;
@property(nonatomic,assign) bool isHandlingPause;

+(id)gameController;

-(void)changeGameState:(GameState)gameState;
-(void)reactToTouchAt:(CGPoint)location InputType:(InputType)type;
-(void)setGameLayer:(GameLayer*)layer;
-(void)setHud:(HudLayer*)hud;
-(void)pauseGame;
-(void)enableSprint:(bool)Enable;

@end
