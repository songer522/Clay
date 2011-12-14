//
//  ChooseModeScene.m
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseModeScene.h"
#import "LayerManager.h"
#import "TextureManager.h"
#import "Sprite.h"
#import "GameLabel.h"
#import "ModePanel.h"
#import "SoundEngine.h"
#import "ActionButton.h"
#import "MainMenuScene.h"

@implementation ChooseModeScene

@synthesize isTransitioning = _isTransitioning;

+(CCScene*)scene
{
    CCScene *scene = [CCScene node];
    ChooseModeScene *layer = [ChooseModeScene node];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
    if((self=[super init])) {
        
        [self load];
        
        _isTransitioning = false;
        _waitToSwitch = 0.0f;
        _backToMainMenu = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
    }
    
    return self;
}


-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        if(!_isTransitioning) {
            if ([_storyModePanel testCollision:position]) {
                if (_currentPanel!=_storyModePanel) {
                    [_storyModePanel transitionToActive];
                    [_timedModePanel transitionToInactive];
                    [_extrasPanel transitionToInactive];
                    [_selectCursor setAlpha:0.0f];
                    _currentPanel = _storyModePanel;
                }
            } else if ([_timedModePanel testCollision:position]) {
                [_timedModePanel transitionToActive];
                [_storyModePanel transitionToInactive];
                [_extrasPanel transitionToInactive];
                [_selectCursor setAlpha:0.0f];
            } else if ([_extrasPanel testCollision:position]) {
                [_extrasPanel transitionToActive];
                [_timedModePanel transitionToInactive];
                [_storyModePanel transitionToInactive];
                [_selectCursor setAlpha:0.0f];
            }
            
            if([_startButton checkIfSelected:position]) {
                _waitToSwitch = 0.25f;
                _backToMainMenu = false;
                [[SoundEngine shared] playSound:@"buttonPressed"];
            }
            
            if([_backButton checkIfSelected:position]) {
                _waitToSwitch = 0.25f;
                _backToMainMenu = true;
                [[SoundEngine shared] playSound:@"buttonPressed"];     
            }

        }
    }
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    [[TextureManager shared] loadMemoryForKey:@"chooseMode"];
    
    _background = [Sprite spriteFromFrameCacheWithName:@"UI_GameType_Background.png"];
    
    _storyModePanel = [ModePanel panelAtPosition:ccp(80,154)];
    [_storyModePanel setHeaderFrame:@"UI_GameType_StoryModeC.png" Inactive:@"UI_GameType_StoryModeG.png"];
    [_storyModePanel addButtons:[NSArray arrayWithObjects:@"KIDS",@"NORMAL",@"INSANE", nil]];
    [_storyModePanel setParent:self];
    
    _timedModePanel = [ModePanel panelAtPosition:ccp(240,154)];
    [_timedModePanel setHeaderFrame:@"UI_GameType_TimeModeC.png" Inactive:@"UI_GameType_TimeModeG.png"];
    [_timedModePanel addButtons:[NSArray arrayWithObjects:@"NORMAL",@"INSANE", nil]];
    [_timedModePanel setParent:self];
    
    _extrasPanel = [ModePanel panelAtPosition:ccp(400,154)];
    [_extrasPanel setHeaderFrame:@"UI_GameType_ExtrasC.png" Inactive:@"UI_GameType_ExtrasG.png"];
    [_extrasPanel addButtons:[NSArray arrayWithObjects:@"SKINS",@"LEVELS",@"WEB", nil]];
    [_extrasPanel setParent:self];
    
    _startButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
    [_startButton setInitialText:@"START"];
    [_startButton setPosition:ccp(430,18)];
    
    _backButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
    [_backButton setInitialText:@"BACK"];
    [_backButton setPosition:ccp(50, 18)];
    
    _selectCursor = [Sprite spriteCenteredWithFrame:@"UI_GameType_Select.png" Position:ccp(240,160)];
    [_storyModePanel setSelectCursor:_selectCursor];
    [_timedModePanel setSelectCursor:_selectCursor];
    [_extrasPanel setSelectCursor:_selectCursor];
    [_selectCursor setAlpha:0.0f];
    
    _selectModeText = [GameLabel gameLabelWithText:@"SELECT GAME TYPE" Scale:0.65f];
    [_selectModeText setPosition:ccp(240.0f,292.0f)];
    
    //setup default selections
    _currentPanel = _storyModePanel;
    [_storyModePanel makeActive];

    

    [[LayerManager sharedLayers] forgetWorkingLayer];
}

-(void)switchToMainMenu
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MainMenuScene scene]]];
}


-(void)update:(ccTime)dt
{
    [_storyModePanel update:dt];
    [_timedModePanel update:dt];
    [_extrasPanel update:dt];
    [_backButton update:dt];
    [_startButton update:dt];
    
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        if(_waitToSwitch<=0.0f){
            _waitToSwitch = 0.0f;
            if (_backToMainMenu) {
                [self switchToMainMenu];
            }  else {
                //[self popAndSwitchToLevel:_levelToSwitchTo]; 
            }
        }
    }

}

-(void)onExit
{
    [self release];
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)dealloc
{
    [_background release];
    [_storyModePanel release];
    [_timedModePanel release];
    [_extrasPanel release];
    [_selectModeText release];
    [_backButton release];
    [_startButton release];
    
    [[TextureManager shared] unloadMemoryForKey:@"chooseMode"];
}

@end