//
//  EndLevelLayer.m
//  Clay
//
//  Created by Brian Cable on 1/11/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "EndLevelLayer.h"
#import "LayerManager.h"
#import "GameController.h"
#import "GameLabel.h"
#import "GameLayer.h"
#import "Button.h"
#import "ActionButton.h"
#import "Sprite.h"
#import "SoundEngine.h"
#import "GameSettings.h"
#import "Camera.h"
#import "LevelManager.h"
#import "SoundEngine.h"
#import "HudLayer.h"
#import "TextureManager.h"
#import "GameSettings.h"
#import "Level.h"
#import "BestTimes.h"
#import "TrackTimer.h"

@interface EndLevelLayer()

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2;
-(void) doButtonAction;

@end

@implementation EndLevelLayer

@synthesize gameController = _gameController;
@synthesize timer=_timer;


+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {      

        _alpha = 0.0;
        _buttonPressed=false;
        
        [self scheduleUpdate];
        [[[LayerManager sharedLayers] currentScene] addChild:self];
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        [[TextureManager shared] loadMemoryForKey:@"endLevel"];
        _replayButton = [ActionButton actionButtonInGameWithText:@"REPLAY"];
        _menuButton = [ActionButton actionButtonInGameWithText:@"MENU"];
        
        _finalTimePanel = [Sprite spriteFromFrameCacheWithName:@"EndGame_TimeBack.png"];
        
        //IPAD FIX: reposition so paused text is centered on x, and slightly above center on y, and buttons are side by side, with the middle button centered on x, and each one slightly below center on y
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float centerX = winSize.width/2.0f;
        float centerY = winSize.height/2.0f;
        [_replayButton setPosition:ccp(centerX-185,centerY - 140.0f)];
        [_menuButton setPosition:ccp(centerX + 185.0f,centerY - 140.0f)];
        [_finalTimePanel getCCSprite].position=ccp(centerX-225,centerY+70);
        //_timer=[[GameSettings shared] getGlobalForKey:@"finalLevelTime"];
        
        
        _finalTimeText = [GameLabel gameLabelWithText:[[GameSettings shared] getGlobalForKey:@"finalLevelTimeText"]  Scale:1.0f Position:ccp(centerX,centerY+90)];
        [self showMedal];
        _action = END_LEVEL_NONE;
        _waitToSwitch = -1.0f;
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        //[[SoundEngine shared] cueFadeOut];
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        
        if([_replayButton checkIfSelected:position]) {
            [[SoundEngine shared] playSound:@"buttonPressed"];
            _action = END_LEVEL_REPLAY;
            _waitToSwitch = 0.35f;
        } else if([_menuButton checkIfSelected:position]) {
            [[SoundEngine shared] playSound:@"buttonPressed"];
            _action = END_LEVEL_BACK;
            _waitToSwitch = 0.35f;
        }
        
        break;
    }
}

-(void)showMedal
{
    NSString  *gameDifficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    
    NSString *levelName =[[LevelManager shared] currentLevel].name;
    
    float bestTime = [[BestTimes shared] getBestTimeForLevelName:levelName forDifficulty:gameDifficulty];
    
    float newTime=[[[GameSettings shared] getGlobalForKey:@"finalLevelTime"] floatValue];
    if(bestTime > newTime)
    {
        _timeHeaderText = [GameLabel gameLabelWithText:@"New Record!"  Scale:0.6f Position:ccp(240,280)];
    }
    else
    {
        _timeHeaderText = [GameLabel gameLabelWithText:@"Your Time:"  Scale:0.6f Position:ccp(240,280)];
    }
    
    
}

-(void) doButtonAction
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    NSString *gameMode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
    
    switch (_action) {
        case END_LEVEL_REPLAY:
            /*
            [self setVisible:false];
            [gameLayer unpause];
            [gameLayer initForLevel];
            gameLayer.inComic = false;
            gameLayer.visible = true;
            gameLayer.gameController.isInputEnabled = false;
            
            [[gameLayer getHud] fadeIn];
            _buttonPressed=true;
            
           // [gameLayer restartLevel];
            */
            
            //[gameLayer.gameController pauseGame];
            //[gameLayer restartLevel];
           
           
            [gameLayer unpause];
             [gameLayer restartLevel];
           
            gameLayer.inComic = false;
            gameLayer.visible = true;
            
            
            [[gameLayer getHud] fadeIn];
           
            // gameLayer.gameController.isInputEnabled = true;
           //gameLayer= [[LayerManager sharedLayers] currentLayer];
              gameLayer.gameController.isInputEnabled = true;
             gameLayer.isTouchEnabled=true;
            gameLayer.gameController.isHandlingPause = false;
             //[gameLayer restartLevel];
             
            [self onExit];
            
                                   
            break;
        case END_LEVEL_BACK:
            //[_gameController pauseGame];
            
            if([gameMode isEqualToString:@"story"]) {
                [gameLayer switchToChooseMode];
            } else {
                [gameLayer switchToChooseLevel];
            }
            break;            
        default:
            break;
    }
}

-(void)draw
{
    [self ccDrawFilledRectFrom:ccp(0,0) To:CGPointMake(1500,1500)];
    [super draw];
}

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2
{
    CGPoint poli[] = {v1, CGPointMake(v1.x,v2.y),v2,CGPointMake(v2.x,v1.y)};
    
    GLubyte rectAlpha = floor(_alpha * 180);
    glColor4ub(0, 0, 0, rectAlpha);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glVertexPointer(2, GL_FLOAT, 0, poli);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
}



-(void)onExit
{
   // [_finalTimePanel getCCSprite].visible = false;
    //[_finalTimeText setText:nil];
    [self release];
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}


-(void)update:(ccTime)dt
{
   
    [[SoundEngine shared] update:dt];
    
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        
        
        if (_waitToSwitch<=0.0f) {
            _waitToSwitch = 0.0f;
         
            [self doButtonAction];
            
        }
        
        if (_action != END_LEVEL_BACK && _waitToSwitch<=0.20f) {
            _alpha = 5.0f * _waitToSwitch;            
        }
        
    } else {
        _alpha += 3.0f * dt;
        if (_alpha > 1.0f) {
            _alpha = 1.0f;
        }        
    }
    
    //set alpha for all elements
    
    [_replayButton setAlpha:_alpha];
    [_menuButton setAlpha:_alpha];
    [_finalTimeText setAlpha:_alpha];
    [_finalTimePanel setAlpha:_alpha];
    [_timeHeaderText setAlpha:_alpha];
    
    [_replayButton update:dt];
    [_menuButton update:dt];
    
}

-(void)dealloc
{
    [[TextureManager shared] unloadMemoryForKey:@"endLevel"];
    _gameController = nil;
    [_finalTimeText release];
    [_finalTimePanel release];
    [_timeHeaderText release];
 
    //[super dealloc];
}

@end
