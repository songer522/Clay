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
#import "HowToPlayScreen.h"
#import "GameWindow.h"
#import "GameSettings.h"
#import "BestTimes.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

//IPAD FIX: width and offset
#define OPTIONS_SCENE_OFFSET_X 62.0f
#define OPTIONS_SCENE_WIDTH 768.0f
#define OPTIONS_LEGACY_PHONE_WIDTH 480.0f
#define OPTIONS_LEGACY_PHONE_HEIGHT 320.0f
#define OPTIONS_LEGACY_IPAD_WIDTH 1024.0f
#define OPTIONS_LEGACY_IPAD_HEIGHT 768.0f

static void OptionsConfigureBackground(Sprite *background)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *backgroundSprite = [background getCCSprite];
    backgroundSprite.anchorPoint = ccp(0.5f, 0.5f);
    backgroundSprite.position = ccp(winSize.width * 0.5f, winSize.height * 0.5f);

    CGFloat widthScale = winSize.width / [background getWidth];
    CGFloat heightScale = winSize.height / [background getHeight];
    [backgroundSprite setScale:MAX(widthScale, heightScale)];
}

static CGPoint OptionsLegacyPhoneOffset(void)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat legacyWidth = IS_IPAD ? OPTIONS_LEGACY_IPAD_WIDTH : OPTIONS_LEGACY_PHONE_WIDTH;
    CGFloat legacyHeight = IS_IPAD ? OPTIONS_LEGACY_IPAD_HEIGHT : OPTIONS_LEGACY_PHONE_HEIGHT;
    return ccp(MAX(0.0f, floorf((winSize.width - legacyWidth) * 0.5f)),
               MAX(0.0f, floorf((winSize.height - legacyHeight) * 0.5f)));
}

static CGPoint OptionsPhonePoint(CGFloat x, CGFloat y)
{
    CGPoint offset = OptionsLegacyPhoneOffset();
    return ccp(offset.x + x, offset.y + y);
}

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
        _windowOpen = false;
        
        
        //check to see if the title menu music is loaded. if not, play it.
        NSString *musicStarted = [[GameSettings shared] getGlobalForKey:@"titleMusicStarted"];
        if (![musicStarted isEqualToString:@"YES"]) {
            [[SoundEngine shared] playMusic:@"title"];
            [[GameSettings shared] setGlobal:@"YES" ForKey:@"titleMusicStarted"];
            [[SoundEngine shared] cueFadeIn];
        }
    }
    
    return self;
}

-(void)load
{
    float eraseX = 85.0f * MULTIPLIERX;
    float tutorialX = 240.0f *MULTIPLIERX;
    float creditsX = 395.0f *MULTIPLIERX;
    float textScale = 0.68f;
    float smallPanelY = 76.0f *MULTIPLIERY;

    
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    [[TextureManager shared] loadMemoryForKey:@"optionsScreen"];

    _background = [Sprite spriteFromFrameCacheWithName:@"Options_Background.png"];
    OptionsConfigureBackground(_background);
    _musicPanel = [Sprite spriteCenteredWithFrame:@"Options_Panel_L.png" Position:OptionsPhonePoint(240 * MULTIPLIERX,232 *MULTIPLIERY)];
    _musicVolumeHeader = [Sprite spriteCenteredWithFrame:@"Options_Title_1.png" Position:OptionsPhonePoint(97 * MULTIPLIERX,264* MULTIPLIERY)];
    _musicSheetMasked = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeA_2.png" AddToLayer:NO];

    [_musicSheetMasked setScreenPosition:OptionsPhonePoint(240 * MULTIPLIERX,230 * MULTIPLIERY)];

    _musicMask = [[ClippingNode alloc] init];
    [self addChild:_musicMask];
    [_musicMask addChild:[_musicSheetMasked getCCSprite]];
    [self setMusicPositionByVolume:[[SoundEngine shared] getMastersMusicVolume]];
    
    _musicSheetTop = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeA_1.png" Position:OptionsPhonePoint(240 * MULTIPLIERX,230 * MULTIPLIERY)];
    _sfxPanel = [Sprite spriteCenteredWithFrame:@"Options_Panel_L.png" Position:OptionsPhonePoint(240 * MULTIPLIERX,152 *MULTIPLIERY)];
    _sfxVolumeHeader = [Sprite spriteCenteredWithFrame:@"Options_Title_2.png" Position:OptionsPhonePoint(391 *MULTIPLIERX,184 *MULTIPLIERY)];
    _sfxSheetMasked = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeB_2.png" AddToLayer:NO];
    [_sfxSheetMasked setScreenPosition:OptionsPhonePoint(240 *MULTIPLIERX,150 *MULTIPLIERY)];
    
    _sfxMask = [[ClippingNode alloc] init];
    [self addChild:_sfxMask];
    [_sfxMask addChild:[_sfxSheetMasked getCCSprite]];
    [self setSfxPositionByVolume:[[SoundEngine shared] getMastersSfxVolume]];
    
    _sfxSheetTop = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeB_1.png" Position:OptionsPhonePoint(240 *MULTIPLIERX,150* MULTIPLIERY)];
    
    _howToPlayButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    [_howToPlayButton setPosition:OptionsPhonePoint(240 *MULTIPLIERX,smallPanelY)];
    [_howToPlayButton setHitboxBySize:CGSizeMake(143 *MULTIPLIERX, 70 *MULTIPLIERY)];

    _eraseDataButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    [_eraseDataButton setPosition:OptionsPhonePoint(85 *MULTIPLIERX,smallPanelY)];
    [_eraseDataButton setHitboxBySize:CGSizeMake(143 *MULTIPLIERX, 70 *MULTIPLIERY)];
    
    _eraseText = [GameLabel gameLabelWithText:@"ERASE" Scale:textScale Position:OptionsPhonePoint(eraseX,83 * MULTIPLIERY)];
    _dataText = [GameLabel gameLabelWithText:@"DATA" Scale:textScale Position:OptionsPhonePoint(eraseX,65 *MULTIPLIERY)];

    _howToText = [GameLabel gameLabelWithText:@"HOW TO" Scale:textScale Position:OptionsPhonePoint(tutorialX,83 *MULTIPLIERY)];
    _playText = [GameLabel gameLabelWithText:@"PLAY" Scale:textScale Position:OptionsPhonePoint(tutorialX,65 *MULTIPLIERY)];
    
    _creditsButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    _creditsText = [GameLabel gameLabelWithText:@"CREDITS" Scale:textScale Position:OptionsPhonePoint(creditsX,smallPanelY - 2)];
    [_creditsButton setPosition:OptionsPhonePoint(creditsX,smallPanelY)];
    [_creditsButton setHitboxBySize:CGSizeMake(143 *MULTIPLIERX, 70 *MULTIPLIERY)];
    
    
    _optionsHeader = [GameLabel gameLabelWithText:@"OPTIONS" Scale:0.65f];
    [_optionsHeader setPosition:OptionsPhonePoint(240.0f * MULTIPLIERX,291.0f *MULTIPLIERY)];

    _backButton = [ActionButton actionButtonWithText:@"BACK"];
    [_backButton setPosition:OptionsPhonePoint(50 *MULTIPLIERX, 18 *MULTIPLIERY)];
    
    //_tutorial = [[Tutorial alloc] initWithinLayer:self];
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        if(!_isTransitioning && !_inTutorial) {
            [self sliderReactionAtPosition:position LastTouch:NO];
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
            [self sliderReactionAtPosition:position LastTouch:NO];
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        
        if(_windowOpen) {
            if (_eraseWindowFirstOpen) {
                WindowSelectionType type = [_eraseWindowFirst checkCollisionAtPoint:position];
                if (type == WIN_SELECT_YES) {
                    [_eraseWindowFirst release];
                    _eraseWindowFirst = nil;
                    _eraseWindowFirstOpen = false;
                    _eraseWindowSecond = [GameWindow gameWindowWithHeader:@"ERASE DATA" Message:@"Seriously, there's no way to undo this. Are you sure you want to delete your data?" Choices:WINDOW_CHOICE_YESNO Layer:self withBackground:@"MessageBox.png"];
                    _eraseWindowSecondOpen = true;
                    [[SoundEngine shared] playSound:@"guiSelectionForward"];                    
                } else if(type == WIN_SELECT_NO) {
                    _windowOpen = false;
                    [_eraseWindowFirst release];
                    _eraseWindowFirst = nil;
                    _eraseWindowFirstOpen = false;
                    [[SoundEngine shared] playSound:@"guiSelectionBack"];
                }
            } else if(_eraseWindowSecondOpen) {
                WindowSelectionType type = [_eraseWindowSecond checkCollisionAtPoint:position];
                if (type == WIN_SELECT_YES) {
                    _windowOpen = false;
                    [_eraseWindowSecond release];
                    _eraseWindowSecond = nil;
                    _eraseWindowSecondOpen = false;
                    [[GameSettings shared] eraseData];
                    [[BestTimes shared] erase];
                    [[BestTimes shared] reload];
                    [[GameSettings shared] setGlobal:@"YES" ForKey:@"titleMusicStarted"];
                    [[SoundEngine shared] playSound:@"eraseData"];
                } else if(type == WIN_SELECT_NO) {
                    _windowOpen = false;
                    [_eraseWindowSecond release];
                    _eraseWindowSecond = nil;
                    _eraseWindowSecondOpen = false;
                    [[SoundEngine shared] playSound:@"guiSelectionBack"];

                }
                
            }
            
        } else {
        
        
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
                    [[SoundEngine shared] playSound:@"buttonPressed"];
                } else if([_eraseDataButton checkIfSelected:position]) {
                    _windowOpen = true;
                    _eraseWindowFirst = [GameWindow gameWindowWithHeader:@"ERASE DATA" Message:@"This will delete all of your data, except achievements and leaderboard scores. Are you sure you want to do this?" Choices:WINDOW_CHOICE_NOYES Layer:self withBackground:@"MessageBox.png"];
                    _eraseWindowFirstOpen = true;
                   [[SoundEngine shared] playSound:@"windowOpenWarning"]; 
                }
                
                [self sliderReactionAtPosition:position LastTouch:YES];

                if([_backButton checkIfSelected:position]) {
                    _waitToSwitch = 0.25f;
                    _backToMainMenu = true;
                    _isTransitioning = true;
                    [[SoundEngine shared] playSound:@"guiSelectionBack"];
                }
            } else if(_inTutorial && _tutorial.scroller.currentScreen==3) {
                if (position.y < 60.0f && position.x < 120.0f) {
                    //[self switchToTutorial];
                }
            }
            
        }
    }
}


-(void)setMusicPositionByVolume:(float)volume
{
    float xPos = OptionsLegacyPhoneOffset().x + (volume * OPTIONS_SCENE_WIDTH) + OPTIONS_SCENE_OFFSET_X;
    [_musicMask setClippingRegion:CGRectMake(0,0,xPos,768 * MULTIPLIERY)];
}

-(void)setSfxPositionByVolume:(float)volume
{
    float xPos = OptionsLegacyPhoneOffset().x + (volume * OPTIONS_SCENE_WIDTH) + OPTIONS_SCENE_OFFSET_X;
    [_sfxMask setClippingRegion:CGRectMake(0,0,xPos,768 * MULTIPLIERY)];  
}


-(void)setMusicXPosition:(float)xPos
{
    float volume = (xPos - OptionsLegacyPhoneOffset().x - OPTIONS_SCENE_OFFSET_X)/OPTIONS_SCENE_WIDTH;
    volume = MIN(MAX(volume, 0.0f), 1.0f);
    
    [[SoundEngine shared] setMasterMusicVolume:volume];
    [_musicMask setClippingRegion:CGRectMake(0,0,xPos,768 * MULTIPLIERY)];
    
}

-(void)setSfxXPosition:(float)xPos
{
    float volume = (xPos - OptionsLegacyPhoneOffset().x - OPTIONS_SCENE_OFFSET_X)/OPTIONS_SCENE_WIDTH;
    volume = MIN(MAX(volume, 0.0f), 1.0f);
    
    [[SoundEngine shared] setMasterSfxVolume:volume];
    [_sfxMask setClippingRegion:CGRectMake(0,0,xPos,768 * MULTIPLIERY)];
}
             
-(void)sliderReactionAtPosition:(CGPoint)position LastTouch:(bool)isLastTouch
{
    //IPAD FIX: should correspond to the y positions for the music and sfx volume
    CGFloat yOffset = OptionsLegacyPhoneOffset().y;
    if (position.y > (200 * MULTIPLIERY) + yOffset && position.y < (260 * MULTIPLIERY) + yOffset) {
        [self setMusicXPosition:position.x];
    } else if(position.y > (120 * MULTIPLIERY) + yOffset && position.y < (180 * MULTIPLIERY) + yOffset) {
        [self setSfxXPosition:position.x];
        if (isLastTouch) {
            [[SoundEngine shared] playSound:@"checkpoint"];
        }
    }
}

-(void)switchToMainMenuScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MainMenuScene scene]]];
}

-(void)switchToTutorial
{
    [[GameSettings shared] setGlobal:@"options" ForKey:@"preTutorialScreen"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[HowToPlayScreen scene]]];
}

-(void)switchToCreditsScreen
{
    [[GameSettings shared] setGlobal:@"options" ForKey:@"switchToCreditsFrom"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[CreditsScene scene]]];
}


-(void)update:(ccTime)dt
{
    [[SoundEngine shared] update:dt];
    
    [_backButton update:dt];
    //[_tutorial update:dt];
    
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
    //[self release];
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
    
    //[_tutorial release];
    
     [_optionsHeader release];
    [_backButton release];
    
    [[TextureManager shared] unloadMemoryForKey:@"optionsScreen"];
    [super dealloc];
}

@end
