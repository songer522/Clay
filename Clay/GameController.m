//
//  GameController.m
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "GameController.h"
#import "Player.h"
#import "GameLayer.h"
#import "PauseMenuScreen.h"


@implementation GameController

@synthesize layer = _gameLayer;
@synthesize isPaused = _isPaused;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self changeGameState:GAMESTATE_INITIALIZE];
        _isPaused = false;
    }
    
    return self;
}

+(id)gameController
{
    return [[self alloc] init];
}

-(void) initialize
{
    
}

-(void) changeGameState:(GameState)gameState
{
    switch (gameState) {
        case GAMESTATE_INITIALIZE:
            [self initialize];
            break;            
        default:
            break;
    }
    
    //hold off actually switching until later in case
    //some logic above needs to know the previous state
    _currentGameState = gameState;

}

-(void)reactToTouchAt:(CGPoint)location
{
    if (location.x > 400 && location.y > 270) {
        [self pauseGame];
    } else if(location.x < 80 && location.y > 270) {
        [[LevelManager shared] loadNextLevel];
    } else if(!_isPaused) {
        if (location.x < 240) {
            if (!_gameLayer.player.isJumping) {
                [_gameLayer.player startJump:JUMP_MEDIUM];
            }
        } else {
            if(![_gameLayer.player getIsTurbo]) {
                [_gameLayer.player startTurbo];
            }
        }
    }
}

-(void)setGameLayer:(GameLayer*)gameLayer
{
    _gameLayer = gameLayer;
}

-(void)pauseGame
{
    //toggles. if paused, then unpause, and vice versa
    if (!_isPaused) {
        //[_gameLayer unscheduleUpdate];
        [_gameLayer onExit];
        _pauseMenu = [PauseMenuScreen instance];
        _pauseMenu.gameController = self;
        _isPaused = true;
    } else {
        [[[LayerManager sharedLayers] currentScene] removeChild:_pauseMenu cleanup:YES];
        [_pauseMenu release];
        _pauseMenu = nil;
        _isPaused = false;
        [_gameLayer onEnter];
    }
}

@end
