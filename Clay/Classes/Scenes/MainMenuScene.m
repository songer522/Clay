//
//  MainMenuScene.m
//  Clay
//
//  Created by Brian Cable on 10/7/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "MainMenuScene.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "ComicLayer.h"
#import "ComicManager.h"
#import "SoundEngine.h"
#import "GCHelper.h"
#import "ChooseLevelScreen.h"
#import "TextureManager.h"
#import "Appirater.h"
#import "ActionButton.h"
#import "SoundEngine.h"
#import "GameSettings.h"
#import "ContinueGameManager.h"



@implementation MainMenuScene


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuScene *layer = [MainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pause) name:UIWindowDidResignKeyNotification object:nil];
        [self pause];
        [[GCHelper sharedInstance] authenticateLocalUser];
    
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"mainMenu"];
          
        
      
        
        _trackBackground = [Sprite spriteFromFrameCacheWithName:@"Menu_Background.png"];
        [_trackBackground getCCSprite].position = ccp(0,0);
        [_trackBackground setAlpha:1.0f];
        
        _rain1 = [Sprite spriteFromFrameCacheWithName:@"Menu_Rain_01.png"];
        [_rain1 getCCSprite].position = ccp(0, 0);
        [_rain1 setAlpha:0.0f];
        
        _rain2 = [Sprite spriteFromFrameCacheWithName:@"Menu_Rain_02.png"];
        [_rain2 getCCSprite].position = ccp(0, 0);
        [_rain2 setAlpha:0.0f];
        
        _logo = [Sprite spriteFromFrameCacheWithName:@"Menu_Logo.png"];
        [_logo setAlpha:0.0f];
        [_logo getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_logo getCCSprite].position = ccp(240, 258); //final 240, 262
        

        _isContinueButtonEnabled = [ContinueGameManager isAbleToContinueGame];
        
        _playButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_PlayBlue.png" Selected:@"Menu_PlayGreen.png"];
        [_playButton setAlpha:0.0f];
        
        if (_isContinueButtonEnabled) {
            [_playButton setPosition:ccp(240,115)];            
        } else {
            [_playButton setPosition:ccp(240,142)];                        
        }
        _selectedButton = _playButton;

        _continueButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_ContinueBlue.png" Selected:@"Menu_ContinueGreen.png"];
        [_continueButton setAlpha:0.0f];
        [_continueButton setPosition:ccp(240,158)];
        
        _gameCenterButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_GameCenter.png" Selected:@"Menu_GameCenter.png"];
        [_gameCenterButton setAlpha:0.0f];
        [_gameCenterButton setPosition:ccp(440,24)];
        
        _optionsButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Menu_OptionsBlue.png" Selected:@"Menu_OptionsGreen.png"];
        [_optionsButton setAlpha:0.0f];
        [_optionsButton setPosition:ccp(40,24)];
        
        

        _copyright = [Sprite spriteFromFrameCacheWithName:@"Menu_Copyright.png"];
        [_copyright setAlpha:0.0f];
        [_copyright getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_copyright getCCSprite].position = ccp(240,24); //final 240,20
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        _totalTime = 0.0f;
        _time = 0.0f;
        _transition = MAINMENU_TRANSITION_IN;
        
        
        _switchSceneTriggered = false;
        
        _reinit = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
        
        NSString *musicStarted = [[GameSettings shared] getGlobalForKey:@"titleMusicStarted"];
        if (![musicStarted isEqualToString:@"YES"]) {
            [[SoundEngine shared] playMusic:@"title"];
            [[GameSettings shared] setGlobal:@"YES" ForKey:@"titleMusicStarted"];
        }
                
        [myPool drain];

    }
   
   
    return self;
}

-(void)pause
{
    [[CCDirector sharedDirector] pause];
}
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
        if (_transition == MAINMENU_TRANSITION_IDLE) 
    {
        bool shouldStart = false;
        NSSet *allTouches = [event allTouches];
        for(UITouch *touch in allTouches)
        {
            shouldStart = true;
        }
        
        if (shouldStart) {
            [self switchToTransitionOut];
            [[SoundEngine shared] playSound:@"menuPlayButton"];
            [[GameSettings shared] setGlobal:@"timed" ForKey:@"gameMode"];
            [[GameSettings shared] setGlobal:@"normal" ForKey:@"gameDifficulty"];
        }
    }
}

-(void)setAlphaForAll:(float)alpha includingButtons:(bool)alphaButtons andButtonSelection:(bool)alphaSelected
{
    [_rain1 setAlpha:alpha];
    [_rain2 setAlpha:alpha];
    
    [_logo setAlpha:alpha];
    
    if (alphaButtons) {
        [_playButton setAlpha:alpha];
        [_optionsButton setAlpha:alpha];
        [_gameCenterButton setAlpha:alpha];
        
        if(_isContinueButtonEnabled) {
            [_continueButton setAlpha:alpha];
        }
    }
    
    if(alphaSelected) {
        [_playButton setSelectedAlpha:alpha];
        [_gameCenterButton setSelectedAlpha:alpha];
        [_optionsButton setSelectedAlpha:alpha];
        
        if (_isContinueButtonEnabled) {
            [_continueButton setSelectedAlpha:alpha];            
        }
    }
    
    [_copyright setAlpha:alpha];

}

-(void)setButtonAlphas:(float)alpha
{
    [_playButton setAlpha:alpha];
    [_optionsButton setAlpha:alpha];
    [_gameCenterButton setAlpha:alpha];
    
    if (_isContinueButtonEnabled) {
        [_continueButton setAlpha:alpha];
    }
}

-(void)switchToTransitionIn
{
    _time = 0.0f;
    _totalTime = 0.0f;
    
    _transition = MAINMENU_TRANSITION_IN;
    
    [self setAlphaForAll:0.0f includingButtons:YES andButtonSelection:YES];
    
    [_trackBackground setAlpha:1.0f];
}


-(void)switchToTransitionOut
{
    _time = 0.0f;
    _transition = MAINMENU_TRANSITION_OUT;
    
    //[_selectedButton setAlpha:0.0f];
}

-(void)reinit
{
    [self switchToTransitionIn];    
    _reinit = false;
}

-(void)update:(ccTime)dt
{
    
    float rate = 12.0f * dt;
    
    _totalTime += rate;
    _time += dt;
    
    //oscillate between two image files
    float rainFrame = sinf(2.0f * _totalTime);
    if (rainFrame > 0.0f) {
        [[_rain1 getCCSprite] setVisible:YES];
        [[_rain2 getCCSprite] setVisible:NO];
    } else {
        [[_rain1 getCCSprite] setVisible:NO];
        [[_rain2 getCCSprite] setVisible:YES];
    }
    
    switch (_transition) {
        case MAINMENU_TRANSITION_IN:
            if (_time>=1.0f) {
                _time = 1.0f;
                _transition = MAINMENU_TRANSITION_IDLE;
            }
            [_logo move:ccp(0, rate)];
            [_copyright move:ccp(0,-0.5f * rate)];
            
            [self setAlphaForAll:_time includingButtons:YES andButtonSelection:NO];
            
            break;
        case MAINMENU_TRANSITION_OUT:
            if (_time >=1.0f) {
                _time = 1.0f;
            }
            
            [self setAlphaForAll:(1.0f - _time) includingButtons:NO andButtonSelection:NO];
            [self setButtonAlphas:(MIN(1.0f,1.0f - 1.0f * _time))];
            
            [_selectedButton setSelectedAlpha:(MAX(1.0f - 8.0f * _time, 0.0f))];

            if (!_switchSceneTriggered) {
                if (_time >=1.0f) {
                    [self private_switchToChooseLevel];
                    _switchSceneTriggered = true;
                }
            }
            break;
        default:
            break;
    }
}


-(void)private_switchToChooseLevel
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[ChooseLevelScreen scene]]];
}

-(void)onExit
{    
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)dealloc
{
    //NSLog(@"Dealloc: MainMenuScene");
 
    
    [_trackBackground release];
    [_rain1 release];
    [_rain2 release];
    [_logo release];
    [_playButton release];
    [_continueButton release];
    [_copyright release];
    
    [[TextureManager shared] unloadMemoryForKey:@"mainMenu"];
}

@end
