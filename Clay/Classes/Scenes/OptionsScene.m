//
//  OptionsScene.m
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "OptionsScene.h"
#import "Sprite.h"
#import "ActionButton.h"
#import "LayerManager.h"
#import "TextureManager.h"
#import "ClippingNode.h"
#import "SoundEngine.h"
#import "GameLabel.h"
#import "MainMenuScene.h"
#import "Tutorial.h"
#import "CreditsScene.h"

//IPAD FIX: width and offset
#define OPTIONS_SCENE_OFFSET_X 30.0f
#define OPTIONS_SCENE_WIDTH 420.0f

@implementation OptionsScene

+(CCScene*)scene
{
    CCScene *scene = [CCScene node];
    OptionsScene *layer = [OptionsScene node];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
    if((self=[super init])) {
        
        [self load];
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
        _isTransitioning = false;
        _backToMainMenu = false;
        _inTutorial = false;
        _waitToSwitch = 0.0f;
    }
    
    return self;
}

-(void)load
{
    float eraseX = 85.0f;
    float tutorialX = 240.0f;
    float creditsX = 395.0f;
    float textScale = 0.68f;
    float smallPanelY = 76.0f;

    
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    [[TextureManager shared] loadMemoryForKey:@"optionsScreen"];

    _background = [Sprite spriteFromFrameCacheWithName:@"Options_Background.png"];
    _musicPanel = [Sprite spriteCenteredWithFrame:@"Options_Panel_L.png" Position:ccp(240,232)];
    _musicVolumeHeader = [Sprite spriteCenteredWithFrame:@"Options_Title_1.png" Position:ccp(97,264)];
    _musicSheetMasked = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeA_2.png" AddToLayer:NO];

    [_musicSheetMasked setScreenPosition:ccp(240,230)];

    _musicMask = [[ClippingNode alloc] init];
    [self addChild:_musicMask];
    [_musicMask addChild:[_musicSheetMasked getCCSprite]];
    [self setMusicPositionByVolume:[[SoundEngine shared] getMastersMusicVolume]];
    
    _musicSheetTop = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeA_1.png" Position:ccp(240,230)];
    _sfxPanel = [Sprite spriteCenteredWithFrame:@"Options_Panel_L.png" Position:ccp(240,152)];
    _sfxVolumeHeader = [Sprite spriteCenteredWithFrame:@"Options_Title_2.png" Position:ccp(391,184)];
    _sfxSheetMasked = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeB_2.png" AddToLayer:NO];
    [_sfxSheetMasked setScreenPosition:ccp(240,150)];
    
    _sfxMask = [[ClippingNode alloc] init];
    [self addChild:_sfxMask];
    [_sfxMask addChild:[_sfxSheetMasked getCCSprite]];
    [self setSfxPositionByVolume:[[SoundEngine shared] getMastersSfxVolume]];
    
    _sfxSheetTop = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeB_1.png" Position:ccp(240,150)];
    
    _howToPlayButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    [_howToPlayButton setPosition:ccp(240,smallPanelY)];
    [_howToPlayButton setHitboxBySize:CGSizeMake(143, 70)];

    _eraseDataButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    [_eraseDataButton setPosition:ccp(85,smallPanelY)];
    [_eraseDataButton setHitboxBySize:CGSizeMake(143, 70)];
    
    _eraseText = [GameLabel gameLabelWithText:@"ERASE" Scale:textScale Position:ccp(eraseX,83)];
    _dataText = [GameLabel gameLabelWithText:@"DATA" Scale:textScale Position:ccp(eraseX,65)];

    _howToText = [GameLabel gameLabelWithText:@"HOW TO" Scale:textScale Position:ccp(tutorialX,83)];
    _playText = [GameLabel gameLabelWithText:@"PLAY" Scale:textScale Position:ccp(tutorialX,65)];
    
    _creditsButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    _creditsText = [GameLabel gameLabelWithText:@"CREDITS" Scale:textScale Position:ccp(creditsX,smallPanelY - 2)];
    [_creditsButton setPosition:ccp(creditsX,smallPanelY)];
    [_creditsButton setHitboxBySize:CGSizeMake(143, 70)];
    
    
    _optionsHeader = [GameLabel gameLabelWithText:@"OPTIONS" Scale:0.65f];
    [_optionsHeader setPosition:ccp(240.0f,291.0f)];

    _backButton = [ActionButton actionButtonWithText:@"BACK"];
    [_backButton setPosition:ccp(50, 18)];
    
    _tutorial = [[Tutorial alloc] initWithinLayer:self];
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        if(!_isTransitioning && !_inTutorial) {
            [self sliderReactionAtPosition:position];
        }
    }
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        if(!_isTransitioning && !_inTutorial) {
            [self sliderReactionAtPosition:position];
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        if(!_isTransitioning && !_inTutorial) {
            if ([_howToPlayButton checkIfSelected:position]) {
                _waitToSwitch = 0.25f;
                _backToMainMenu = false;
                _switchToType = OPTIONS_SWITCHTO_HOWTOPLAY;
                [[SoundEngine shared] playSound:@"buttonPressed"];
            } else if([_creditsButton checkIfSelected:position]) {
                _waitToSwitch = 0.25f;
                _backToMainMenu = false;
                _switchToType = OPTIONS_SWITCHTO_CREDITS;
            }
            
            if([_backButton checkIfSelected:position]) {
                _waitToSwitch = 0.25f;
                _backToMainMenu = true;
                [[SoundEngine shared] playSound:@"buttonPressed"];     
            }
        } else if(_inTutorial) {
            if (position.y > 260.0f || position.y < 60.0f) {
                [self switchToTutorial];
            }
        }
    }
}


-(void)setMusicPositionByVolume:(float)volume
{
    float xPos = volume * OPTIONS_SCENE_WIDTH + OPTIONS_SCENE_OFFSET_X;
    [_musicMask setClippingRegion:CGRectMake(0,0,xPos,768)];
}

-(void)setSfxPositionByVolume:(float)volume
{
    float xPos = volume * OPTIONS_SCENE_WIDTH + OPTIONS_SCENE_OFFSET_X;
    [_sfxMask setClippingRegion:CGRectMake(0,0,xPos,768)];  
}


-(void)setMusicXPosition:(float)xPos
{
    float volume = (xPos - OPTIONS_SCENE_OFFSET_X)/OPTIONS_SCENE_WIDTH;
    
    [[SoundEngine shared] setMasterMusicVolume:volume];
    [_musicMask setClippingRegion:CGRectMake(0,0,xPos,768)];
}

-(void)setSfxXPosition:(float)xPos
{
    float volume = (xPos - OPTIONS_SCENE_OFFSET_X)/OPTIONS_SCENE_WIDTH;
    
    [[SoundEngine shared] setMasterSfxVolume:volume];
    [_sfxMask setClippingRegion:CGRectMake(0,0,xPos,768)];
}
             
-(void)sliderReactionAtPosition:(CGPoint)position
{
    //IPAD FIX: should correspond to the y positions for the music and sfx volume
    if (position.y > 200 && position.y < 260) {
        [self setMusicXPosition:position.x];
    } else if(position.y > 120 && position.y < 180) {
        [self setSfxXPosition:position.x];
    }
}

-(void)switchToMainMenuScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MainMenuScene scene]]];
}

-(void)switchToTutorial
{
    [_tutorial switchToTutorial];
    _inTutorial = !_inTutorial;
}

-(void)switchToCreditsScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CreditsScene scene]]];
}


-(void)update:(ccTime)dt
{
    [_backButton update:dt];
    [_tutorial update:dt];
    
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        if(_waitToSwitch<=0.0f){
            _waitToSwitch = 0.0f;
            if (_backToMainMenu) {
                [self switchToMainMenuScreen];
            } else {
                switch (_switchToType) {
                    case OPTIONS_SWITCHTO_HOWTOPLAY:                        
                        [self switchToTutorial];
                        break;
                    case OPTIONS_SWITCHTO_CREDITS:
                        [self switchToCreditsScreen];
                        break;
                    default:
                        break;
                }
            }
        }
    }
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
    [self release];
}

-(void)dealloc
{
    [_background release];
    [_musicPanel release];
    [_sfxPanel release];
    [_musicSheetTop release];
    [_musicSheetMasked release];
     
    
    [_sfxSheetTop release];
    [_sfxSheetMasked release];
    [_musicVolumeHeader release];
    [_sfxVolumeHeader release];
    [_eraseDataButton release];
    [_howToPlayButton release];
    [_creditsButton release];
    
    [_musicMask release];
    [_sfxMask release];
    
    [_eraseText release];
    
    [_dataText release];
    [_howToText release];
    [_playText release];
    [_creditsText release];
    
    [_tutorial release];
    
     [_optionsHeader release];
    [_backButton release];
    
    [[TextureManager shared] unloadMemoryForKey:@"optionsScreen"];
}

@end
