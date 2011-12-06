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
#import "HudLayer.h"


@implementation GameController

@synthesize layer = _gameLayer;
@synthesize isPaused = _isPaused;
@synthesize isInputEnabled = _isInputEnabled;
@synthesize isSprintEnabled=_isSprintEnabled;
@synthesize isHandlingPause=_isHandlingPause;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self changeGameState:GAMESTATE_INITIALIZE];
        _isPaused = false;
        _isInputEnabled = true;
        _isSprintEnabled = true;
        _isHandlingPause = false;
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

-(void)reactToTouchAt:(CGPoint)location InputType:(InputType)type
{
    //guards
    if (!_isInputEnabled || _handledPauseEvent) { return; }
    
    if (location.x > 400 && location.y > 270) {
        if (type == INPUT_TOUCH_END) {
            [self pauseGame];            
        }
    } else if(!_isPaused) {
        
        HudButtonType result = [_hud testInput:location InputType:type];
        
        //??? for some reason this is called whenever a touch is released....
        //this is causing issues with endJump being called when it shouldn't, like when
        //the spin action is called
        if (type == INPUT_TOUCH_END && result == HUD_BUTTON_JUMP) {
            [_gameLayer.player endJump];
            return;
        }
        
        switch (result) {
            case HUD_BUTTON_JUMP:
                if (type == INPUT_TOUCH_PRESSED && !_gameLayer.player.isJumping) {
                    [_gameLayer.player startJump:JUMP_SHORT];
                } else {
                    if (type == INPUT_TOUCH_PRESSED && !_gameLayer.player.hasDoubleJumped)
                    {
                        [_gameLayer.player startDoubleJump];
                    } else if (type == INPUT_TOUCH_HOLD_MEDIUM) {
                        [_gameLayer.player boostJump:JUMP_MEDIUM];
                    }
                }
                
                break;
            case HUD_BUTTON_SPRINT:
                if(_isSprintEnabled)
                {
                if(![_gameLayer.player getIsTurbo]) {
                    [_gameLayer.player startTurbo];
                   
                } else {
                    [_gameLayer.player endTurbo];
                }
                }
                
                break;
            case HUD_BUTTON_ACTION:
                [_gameLayer.player startThirdAction];
            default:
                break;
        }
    }        
    
}

-(void)update
{
    _handledPauseEvent = false;
}

-(void)enableSprint:(bool)Enable
{
    _isSprintEnabled=Enable;
}
-(void)setHud:(HudLayer*)hud
{
    _hud = hud;
}

-(void)setGameLayer:(GameLayer*)gameLayer
{
    _gameLayer = gameLayer;
}

-(void)pauseGame
{
    //toggles. if paused, then unpause, and vice versa
    if (!_isPaused) {
        _isHandlingPause = true;
        [_gameLayer onExit];
        _pauseMenu = [PauseMenuScreen instance];
        _pauseMenu.gameController = self;
        _isPaused = true;
        [[SoundEngine shared] playSound:@"pause"];
    } else {
        _isHandlingPause = true;
        [[[LayerManager sharedLayers] currentScene] removeChild:_pauseMenu cleanup:NO];
        _isPaused = false;
        [_gameLayer onEnter];
        _gameLayer.isTouchEnabled = true;
    }
    _isHandlingPause = false;
    _handledPauseEvent = true;
}

-(void)dealloc
{
    _gameLayer = nil;
    [_pauseMenu release];
    _hud = nil;
    [super dealloc];
}

@end
