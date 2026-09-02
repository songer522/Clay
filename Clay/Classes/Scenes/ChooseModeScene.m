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
#import "ContinueGameManager.h"
#import "GameWindow.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
#define CHOOSEMODE_LEGACY_PHONE_WIDTH 480.0f
#define CHOOSEMODE_LEGACY_PHONE_HEIGHT 320.0f
#define CHOOSEMODE_LEGACY_IPAD_WIDTH 1024.0f
#define CHOOSEMODE_LEGACY_IPAD_HEIGHT 768.0f

static CGPoint ChooseModeLayoutOffset(void)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat legacyWidth = IS_IPAD ? CHOOSEMODE_LEGACY_IPAD_WIDTH : CHOOSEMODE_LEGACY_PHONE_WIDTH;
    CGFloat legacyHeight = IS_IPAD ? CHOOSEMODE_LEGACY_IPAD_HEIGHT : CHOOSEMODE_LEGACY_PHONE_HEIGHT;
    return ccp(MAX(0.0f, floorf((winSize.width - legacyWidth) / 2.0f)),
               MAX(0.0f, floorf((winSize.height - legacyHeight) / 2.0f)));
}

static CGPoint ChooseModeLayoutPoint(CGFloat x, CGFloat y)
{
    CGPoint offset = ChooseModeLayoutOffset();
    return ccp(offset.x + x, offset.y + y);
}

static void ChooseModeConfigureBackground(Sprite *background)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *backgroundSprite = [background getCCSprite];
    backgroundSprite.anchorPoint = ccp(0.5f, 0.5f);
    backgroundSprite.position = ccp(winSize.width * 0.5f, winSize.height * 0.5f);

    CGFloat widthScale = winSize.width / [background getWidth];
    CGFloat heightScale = winSize.height / [background getHeight];
    [backgroundSprite setScale:MAX(widthScale, heightScale)];
}

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
        _playTutorial = false;
        _losingProgressWarningWindowOpen=false;
        _lockedWarningWindowOpen=false;
        
        _isContinueButtonEnabled=[ContinueGameManager isAbleToContinueGame];
        _action=GAMEMODE_NONE;
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
- (void)showTwitterSupportingAlert {
    [[CCDirector sharedDirector] pause];
	UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Sorry..."
														 message:@"You will lose the current process in story mode, are you sure?"
														delegate:self
											   cancelButtonTitle:@"Cancel"
											   otherButtonTitles: @"Yes",nil] autorelease];
	//_twitterSupportingAlert = alertView;
	[alertView show];
}

-(void)openWarningWindowLosingProgress
{
   // [[CCDirector sharedDirector] pause];
    if (!_losingProgressWarningWindowOpen) {
        _losingProgressWarningWindowOpen = true;
        _losingProgressWarningWindow = [GameWindow gameWindowWithHeader:@"Warning" Message:@"You will lose the current progress in story mode, are you sure?" Choices:WINDOW_CHOICE_NOYES Layer:self withBackground:@"MessageBox.png"];        
    }
}

-(void)openWarningWindowLockedHardStory
{
    if (!_lockedWarningWindowOpen) {
        _lockedWarningWindowOpen = true;
        _lockedWarningWindow = [GameWindow gameWindowWithHeader:@"NOTE" Message:@"Please beat Normal Story Mode to unlock this." Choices:WINDOW_CHOICE_OK Layer:self withBackground:@"MessageBox.png"];        
    }

}

-(void)openWarningWindowLockedNormalTimed
{
    if (!_lockedWarningWindowOpen) {
        _lockedWarningWindowOpen = true;
        _lockedWarningWindow = [GameWindow gameWindowWithHeader:@"NOTE" Message:@"Please beat any Story Mode level to unlock this." Choices:WINDOW_CHOICE_OK Layer:self withBackground:@"MessageBox.png"];        
    }
    
}

-(void)openWarningWindowLockedInsaneTimed
{
    if (!_lockedWarningWindowOpen) {
        _lockedWarningWindowOpen = true;
        _lockedWarningWindow = [GameWindow gameWindowWithHeader:@"NOTE" Message:@"Please beat a Normal Timed level to unlock this." Choices:WINDOW_CHOICE_OK Layer:self withBackground:@"MessageBox.png"];        
    }
    
}


-(void)closeLosingProgressWarningWindow
{
    _losingProgressWarningWindowOpen = false;
    [_losingProgressWarningWindow release];
    _losingProgressWarningWindow = nil;
}

-(void)closeLockedWarningWindow
{
    _lockedWarningWindowOpen = false;
    [_lockedWarningWindow release];
    _lockedWarningWindow = nil;
}


-(bool)checkContinueButton
{
    return [ContinueGameManager isAbleToContinueGame];    
}
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        
        if(_losingProgressWarningWindowOpen) {
            WindowSelectionType type = [_losingProgressWarningWindow checkCollisionAtPoint:position];
            if (type == WIN_SELECT_YES) {
                //[[CCDirector sharedDirector] resume];
                _action=_actionSwitchTo;
                if(_action==GAMEMODE_STORY_NORMAL)
                {
                    [[GameSettings shared] setGlobal:@"NO" ForKey:@"firstNormalPlaythrough"];
                }
                [[SoundEngine shared] playSound:@"guiSelectionForward"];  
                [self closeLosingProgressWarningWindow];
                [self switchToAction];
                
            }
            else if(type == WIN_SELECT_NO)
            {
               // [[CCDirector sharedDirector] resume];
                _isTransitioning = false;
                _action = GAMEMODE_NONE;
                 [[SoundEngine shared] playSound:@"guiSelectionBack"];
                [self closeLosingProgressWarningWindow];

            }
            break;
        }
        
        if(_lockedWarningWindowOpen)
        {
            WindowSelectionType type = [_lockedWarningWindow checkCollisionAtPoint:position];
            if(type ==WIN_SELECT_OK)
            {
               // _isTransitioning =false;
                [self closeLockedWarningWindow];
                [[SoundEngine shared] playSound:@"guiSelectionForward"];  
            }
            break;

        }
        

        if(!_isTransitioning) {
            if ([_storyModePanel testCollision:position]) {
                if (_currentPanel!=_storyModePanel) {
                    [_storyModePanel transitionToActive];
                    [_timedModePanel transitionToInactive];
                    [_extrasPanel transitionToInactive];
                    [_selectCursor setAlpha:0.0f];
                    [[SoundEngine shared] playSound:@"guiSwitchSections"];
                    _currentPanel = _storyModePanel;
                }
            } else if ([_timedModePanel testCollision:position]) {
                if (_currentPanel!=_timedModePanel) {
                    [_timedModePanel transitionToActive];
                    [_storyModePanel transitionToInactive];
                    [_extrasPanel transitionToInactive];
                    [_selectCursor setAlpha:0.0f];
                    [[SoundEngine shared] playSound:@"guiSwitchSections"];
                    _currentPanel = _timedModePanel;
                }
            } else if ([_extrasPanel testCollision:position]) {
                if (_currentPanel!=_extrasPanel) {
                    [_extrasPanel transitionToActive];
                    [_timedModePanel transitionToInactive];
                    [_storyModePanel transitionToInactive];
                    [_selectCursor setAlpha:0.0f];
                    [[SoundEngine shared] playSound:@"guiSwitchSections"];
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
                [[SoundEngine shared] playSound:@"guiSelectionBack"];
            }

        }
    }
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    [[TextureManager shared] loadMemoryForKey:@"chooseMode"];
    
    _background = [Sprite spriteFromFrameCacheWithName:@"UI_GameType_Background.png"];
    ChooseModeConfigureBackground(_background);
    
    _storyModePanel = [ModePanel panelAtPosition:ChooseModeLayoutPoint(80 * MULTIPLIERX ,154 * MULTIPLIERY) PanelType:MODEPANEL_PANEL_STORY];
    [_storyModePanel setHeaderFrame:@"UI_GameType_StoryModeC.png" Inactive:@"UI_GameType_StoryModeG.png"];
    [_storyModePanel addButtons:[NSArray arrayWithObjects:@"EASY",@"NORMAL",@"HARD", nil]];
    [_storyModePanel setParent:self];
    
    _timedModePanel = [ModePanel panelAtPosition:ChooseModeLayoutPoint(240 * MULTIPLIERX,154 * MULTIPLIERY) PanelType:MODEPANEL_PANEL_TIMED];
    [_timedModePanel setHeaderFrame:@"UI_GameType_TimeModeC.png" Inactive:@"UI_GameType_TimeModeG.png"];
    [_timedModePanel addButtons:[NSArray arrayWithObjects:@"NORMAL",@"INSANE",@"DLC", nil]];
    [_timedModePanel setParent:self];
    
    _extrasPanel = [ModePanel panelAtPosition:ChooseModeLayoutPoint(400 * MULTIPLIERX,154 * MULTIPLIERY) PanelType:MODEPANEL_PANEL_EXTRAS];
    [_extrasPanel setHeaderFrame:@"UI_GameType_ExtrasC.png" Inactive:@"UI_GameType_ExtrasG.png"];
    [_extrasPanel addButtons:[NSArray arrayWithObjects:@"ALBUM",@"WEB",@"SUPPORT", nil]];
    [_extrasPanel setParent:self];
    
    _startButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
    [_startButton setInitialText:@"START"];
    [_startButton setPosition:ChooseModeLayoutPoint(430 * MULTIPLIERX,18 * MULTIPLIERY)];
    
    _backButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
    [_backButton setInitialText:@"BACK"];
    [_backButton setPosition:ChooseModeLayoutPoint(50 * MULTIPLIERX, 18 * MULTIPLIERY)];
    
    _selectCursor = [Sprite spriteCenteredWithFrame:@"UI_GameType_Select.png" Position:ChooseModeLayoutPoint(240 * MULTIPLIERX,160 * MULTIPLIERY)];
    [_storyModePanel setSelectCursor:_selectCursor];
    [_timedModePanel setSelectCursor:_selectCursor];
    [_extrasPanel setSelectCursor:_selectCursor];
    [_selectCursor setAlpha:0.0f];
    
    _selectModeText = [GameLabel gameLabelWithText:@"SELECT GAME TYPE" Scale:0.65f];
    [_selectModeText setPosition:ChooseModeLayoutPoint(240.0f * MULTIPLIERX,292.0f * MULTIPLIERY)];
    
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
        _actionSwitchTo= GAMEMODE_STORY_EASY;
            if(_isContinueButtonEnabled)
            {
                [self openWarningWindowLosingProgress];
                [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
            }
           else
           {
               _action = GAMEMODE_STORY_EASY;
               [self switchToAction];
           }
        } else if(selectedButtonIndex == 1) {
            [[GameSettings shared] setGlobal:@"normal" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"story" ForKey:@"gameMode"];
            [[GameSettings shared] setSerializedGlobal:@"normal" ForKey:@"storyModeDifficulty"];

            //see if it's the first time they're playing normal mode for the first time.
            NSString *firstNormalPlaythrough = [[GameSettings shared] getGlobalForKey:@"firstNormalPlaythrough"];
            if (![firstNormalPlaythrough isEqualToString:@"NO"]) {
                _playTutorial = true;
            }
            _actionSwitchTo= GAMEMODE_STORY_NORMAL;
            if(_isContinueButtonEnabled)
            {
                [self openWarningWindowLosingProgress];
                  [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
            }
            else
            {
                [[GameSettings shared] setGlobal:@"NO" ForKey:@"firstNormalPlaythrough"];
                
                _action = GAMEMODE_STORY_NORMAL; 
                  [self switchToAction];
                
            }

            //regardless, we're starting it, so set that value to no for the future
           
        } else {
            [[GameSettings shared] setGlobal:@"hard" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"story" ForKey:@"gameMode"];
            [[GameSettings shared] setSerializedGlobal:@"hard" ForKey:@"storyModeDifficulty"];
            
            _actionSwitchTo= GAMEMODE_STORY_HARD;
            if(_isContinueButtonEnabled)
            {
                [self openWarningWindowLosingProgress];
                  [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
            }
            else
            {
                _action = GAMEMODE_STORY_HARD; 
                  [self switchToAction];
            }

                       
        }
    } else if(_currentPanel == _timedModePanel) {
        if (selectedButtonIndex == 0) {
            [[GameSettings shared] setGlobal:@"normal" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"timed" ForKey:@"gameMode"];
            _action = GAMEMODE_TIMED_NORMAL;
            [self switchToAction];
        } else if(selectedButtonIndex == 1) {
            [[GameSettings shared] setGlobal:@"hard" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"timed" ForKey:@"gameMode"];
            _action = GAMEMODE_TIMED_INSANE;  
            [self switchToAction];
        } else {
            [[GameSettings shared] setGlobal:@"normal" ForKey:@"gameDifficulty"];
            [[GameSettings shared] setGlobal:@"timed" ForKey:@"gameMode"];
            _action = GAMEMODE_TIMED_DLC;
            [self switchToAction];
        }
    } else {
        if (selectedButtonIndex == 0) {
            _action = GAMEMODE_EXTRAS_ALBUM;
            [self switchToAction];
        } else if (selectedButtonIndex == 1){
            _action = GAMEMODE_EXTRAS_WEB;
            [self switchToAction];
        }
        else{
            _action=GAMEMODE_EXTRAS_SUPPORT;
            [self switchToAction];
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
            [[GameSettings shared] setSerializedGlobal:@"0" ForKey:@"storyModeCurrentTime"];

            [self switchToStartGame];
            break;
        case GAMEMODE_TIMED_NORMAL:
            [[GameSettings shared] setGlobal:@"NO" ForKey:@"timedShowDLC"];
            [[GameSettings shared] setNotNewForKey:@"timedNormalUnlocked"];
            [[GameSettings shared] setGlobal:@"chooseMode" ForKey:@"previousScreenName"];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseLevelScreen scene]]];
            
            break;
        case GAMEMODE_TIMED_INSANE:
            [[GameSettings shared] setGlobal:@"chooseMode" ForKey:@"previousScreenName"];

            [[GameSettings shared] setNotNewForKey:@"timedHardUnlocked"];
            [[GameSettings shared] setGlobal:@"NO" ForKey:@"timedShowDLC"];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseLevelScreen scene]]];
            break;
        case GAMEMODE_TIMED_DLC:
            [[GameSettings shared] setGlobal:@"chooseMode" ForKey:@"previousScreenName"];

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
        case GAMEMODE_EXTRAS_SUPPORT:
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
                //[self switchToAction];
            }
        }
    }

}

-(void)updateLocked
{
    if (![[GameSettings shared] isUnlockEverythingEnabled]) {
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
            //[[_timedModePanel getButtonWithIndex:0] setLocked:LOCKTYPE_LOCKED];
            [[_timedModePanel getButtonWithIndex:0] setLocked:LOCKTYPE_LOCKED];
        }
        
        setting = [[GameSettings shared] getLockTypeForKey:@"timedHardUnlocked"];
        if (setting == LOCKTYPE_UNLOCKED_NEW) {
            [[_timedModePanel getButtonWithIndex:1] setLocked:LOCKTYPE_UNLOCKED_NEW];
        } else if(setting == LOCKTYPE_LOCKED) {
            [[_timedModePanel getButtonWithIndex:1] setLocked:LOCKTYPE_LOCKED];
        }        
    }
}

-(void)onExit
{
    //[self release];
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	
	switch (buttonIndex) {
		case 0:
		{
			// they don't want to rate it
            //[[CCDirector sharedDirector] resume];
             _isTransitioning = false;
            _action = GAMEMODE_NONE;
			break;
		}
		case 1:
		{
			// they want to rate it
			//[[CCDirector sharedDirector] resume];
            _action=_actionSwitchTo;
            if(_action==GAMEMODE_STORY_NORMAL)
            {
                [[GameSettings shared] setGlobal:@"NO" ForKey:@"firstNormalPlaythrough"];
            }
            [self switchToAction];
			break;
		}
        default:
			break;
	}
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
