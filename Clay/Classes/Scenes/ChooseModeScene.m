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
#import "ChooseLevelScreen.h"
#import "GameLayer.h"
#import "GameSettings.h"
#import "HowToPlayScreen.h"

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
        
        NSString *musicStarted = [[GameSettings shared] getGlobalForKey:@"titleMusicStarted"];
        if (![musicStarted isEqualToString:@"YES"]) {
            [[SoundEngine shared] cueFadeIn];
            [[SoundEngine shared] playMusic:@"title"];
            [[GameSettings shared] setGlobal:@"YES" ForKey:@"titleMusicStarted"];
        }
        
        
        
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
                if (_currentPanel!=_timedModePanel) {
                    [_timedModePanel transitionToActive];
                    [_storyModePanel transitionToInactive];
                    [_extrasPanel transitionToInactive];
                    [_selectCursor setAlpha:0.0f];
                    _currentPanel = _timedModePanel;
                }
            } else if ([_extrasPanel testCollision:position]) {
                if (_currentPanel!=_extrasPanel) {
                    [_extrasPanel transitionToActive];
                    [_timedModePanel transitionToInactive];
                    [_storyModePanel transitionToInactive];
                    [_selectCursor setAlpha:0.0f];
                    _currentPanel = _extrasPanel;
                }
            }
            
            if([_startButton checkIfSelected:position]) {
                _waitToSwitch = 0.25f;
                _isTransitioning = true;
                _backToMainMenu = false;
                [[SoundEngine shared] playSound:@"buttonPressed"];
            }
            
            if([_backButton checkIfSelected:position]) {
                _waitToSwitch = 0.25f;
                _isTransitioning = true;
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
    [_storyModePanel addButtons:[NSArray arrayWithObjects:@"EASY",@"NORMAL",@"HARD", nil]];
    [_storyModePanel setParent:self];
    
    _timedModePanel = [ModePanel panelAtPosition:ccp(240,154)];
    [_timedModePanel setHeaderFrame:@"UI_GameType_TimeModeC.png" Inactive:@"UI_GameType_TimeModeG.png"];
    [_timedModePanel addButtons:[NSArray arrayWithObjects:@"NORMAL",@"INSANE",@"DLC", nil]];
    [_timedModePanel setParent:self];
    
    _extrasPanel = [ModePanel panelAtPosition:ccp(400,154)];
    [_extrasPanel setHeaderFrame:@"UI_GameType_ExtrasC.png" Inactive:@"UI_GameType_ExtrasG.png"];
    [_extrasPanel addButtons:[NSArray arrayWithObjects:@"ALBUM",@"WEB",@"SUPPORT", nil]];
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
    [_storyModePanel setSelectedIndex:1];
    [_storyModePanel makeCursorActive];

    [self updateLocked];

    [[LayerManager sharedLayers] forgetWorkingLayer];
}

-(void)getDesiredAction
{
    _playTutorial = false;
    int selectedButtonIndex = _currentPanel.selectedIndex;
    if (_currentPanel == _storyModePanel) {
        if (selectedButtonIndex == 0) {
            [[GameSettings shared] setGlobal:@"easy" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"story" ForKey:@"gameMode"];
            [[GameSettings shared] setSerializedGlobal:@"easy" ForKey:@"storyModeDifficulty"];
            _playTutorial = true;
            _action = GAMEMODE_STORY_EASY;
        } else if(selectedButtonIndex == 1) {
            [[GameSettings shared] setGlobal:@"normal" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"story" ForKey:@"gameMode"];
            [[GameSettings shared] setSerializedGlobal:@"normal" ForKey:@"storyModeDifficulty"];
            _action = GAMEMODE_STORY_NORMAL;            
        } else {
            [[GameSettings shared] setGlobal:@"hard" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"story" ForKey:@"gameMode"];
            [[GameSettings shared] setSerializedGlobal:@"hard" ForKey:@"storyModeDifficulty"];
            _action = GAMEMODE_STORY_HARD;            
        }
    } else if(_currentPanel == _timedModePanel) {
        if (selectedButtonIndex == 0) {
            [[GameSettings shared] setGlobal:@"normal" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"timed" ForKey:@"gameMode"];
            _action = GAMEMODE_TIMED_NORMAL;
        } else if(selectedButtonIndex == 1) {
            [[GameSettings shared] setGlobal:@"hard" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"timed" ForKey:@"gameMode"];
            _action = GAMEMODE_TIMED_INSANE;            
        } else {
            [[GameSettings shared] setGlobal:@"normal" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"timed" ForKey:@"gameMode"];
            _action = GAMEMODE_TIMED_DLC;
        }
    } else {
        if (selectedButtonIndex == 0) {
            _action = GAMEMODE_EXTRAS_ALBUM;
        } else if (selectedButtonIndex == 1){
            _action = GAMEMODE_EXTRAS_WEB;
        }
        else{
            _action=GameMODE_EXTRAS_SUPPORT;
        }
    }
}

-(void)switchToAction
{
    NSURL *url;
    
    switch (_action) {
        case GAMEMODE_STORY_EASY:
        case GAMEMODE_STORY_NORMAL:
        case GAMEMODE_STORY_HARD:
            if (_action == GAMEMODE_STORY_HARD) {
                [[GameSettings shared] setNotNewForKey:@"storyHardUnlocked"];
            }
            [[GameSettings shared] setGlobal:@"NO" ForKey:@"titleMusicStarted"];
            [[GameSettings shared] setGlobal:@"level1" ForKey:@"startingLevel"];
            [[GameSettings shared] setSerializedGlobal:@"level1" ForKey:@"storyModeCurrentLevel"];
            [[GameSettings shared] setUnlockedForKey:@"storyHardUnlocked"];
            [self switchToStartGame];
            break;
        case GAMEMODE_TIMED_NORMAL:
            [[GameSettings shared] setGlobal:@"NO" ForKey:@"timedShowDLC"];
            [[GameSettings shared] setNotNewForKey:@"timedNormalUnlocked"];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseLevelScreen scene]]];
            
            break;
        case GAMEMODE_TIMED_INSANE:
            [[GameSettings shared] setNotNewForKey:@"timedHardUnlocked"];
            [[GameSettings shared] setGlobal:@"NO" ForKey:@"timedShowDLC"];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseLevelScreen scene]]];
            break;
        case GAMEMODE_TIMED_DLC:
            [[GameSettings shared] setGlobal:@"YES" ForKey:@"timedShowDLC"];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseLevelScreen scene]]];
            break;
        case GAMEMODE_EXTRAS_ALBUM:
            url = [NSURL URLWithString:@"http://itunes.apple.com/ca/album/track-lapse-official-game/id494170466"];
            [[UIApplication sharedApplication] openURL:url];
            _isTransitioning = false;
            break;
        case GAMEMODE_EXTRAS_WEB:
            url = [NSURL URLWithString:@"http://www.tracklapse.com"];
            [[UIApplication sharedApplication] openURL:url];
            _isTransitioning = false;
            break;
        case GameMODE_EXTRAS_SUPPORT:
            url = [NSURL URLWithString:@"mailto:support@xecudev.com"];
            [[UIApplication sharedApplication] openURL:url];
            _isTransitioning = false;
            break;

        default:
            break;
    }
}

-(void)switchToMainMenu
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MainMenuScene scene]]];
}

-(void)switchToStartGame
{
    if(_playTutorial) {
        [[GameSettings shared] setGlobal:@"choosemode" ForKey:@"preTutorialScreen"];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[HowToPlayScreen scene]]];
    } else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameLayer scene]]];
    }
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
                [self getDesiredAction];
                [self switchToAction];
            }
        }
    }

}

-(void)updateLocked
{
     
    LockType setting = [[GameSettings shared] getLockTypeForKey:@"storyHardUnlocked"];
    if (setting == LOCKTYPE_UNLOCKED_NEW) {
        [[_storyModePanel getButtonWithIndex:2] setLocked:LOCKTYPE_UNLOCKED_NEW];
    } else if(setting == LOCKTYPE_LOCKED) {
        [[_storyModePanel getButtonWithIndex:2] setLocked:LOCKTYPE_LOCKED];
    }

    setting = [[GameSettings shared] getLockTypeForKey:@"timedNormalUnlocked"];
    if (setting == LOCKTYPE_UNLOCKED_NEW) {
        [[_timedModePanel getButtonWithIndex:0] setLocked:LOCKTYPE_UNLOCKED_NEW];
    } else if(setting == LOCKTYPE_LOCKED) {
        [[_timedModePanel getButtonWithIndex:0] setLocked:LOCKTYPE_LOCKED];
    }
    
    setting = [[GameSettings shared] getLockTypeForKey:@"timedHardUnlocked"];
    if (setting == LOCKTYPE_UNLOCKED_NEW) {
        [[_timedModePanel getButtonWithIndex:1] setLocked:LOCKTYPE_UNLOCKED_NEW];
    } else if(setting == LOCKTYPE_LOCKED) {
        [[_timedModePanel getButtonWithIndex:1] setLocked:LOCKTYPE_LOCKED];
    }
    
}

-(void)onExit
{
    //[self release];
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)dealloc
{
    [_background release];
    [_selectCursor release];
    [_storyModePanel release];
    [_timedModePanel release];
    [_extrasPanel release];
    [_backButton release];
    [_startButton release];
    
    [_selectModeText release];
    [[TextureManager shared] unloadMemoryForKey:@"chooseMode"];
    [super dealloc];
}

@end