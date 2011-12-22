//
//  OptionsScene.h
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"

typedef enum {
    OPTIONS_SWITCHTO_HOWTOPLAY,
    OPTIONS_SWITCHTO_CREDITS
}OptionsSwitchToType;

@class ClippingNode;
@class Sprite;
@class GameWindow;
@class GameLabel;
@class ActionButton;
@class Tutorial;

@interface OptionsScene : CCLayer
{
    Sprite *_background;
    
    Sprite *_musicPanel;
    Sprite *_sfxPanel;
    
    Sprite *_musicSheetTop;
    Sprite *_musicSheetMasked;
    
    Sprite *_sfxSheetTop;
    Sprite *_sfxSheetMasked;
    
    Sprite *_musicVolumeHeader;
    Sprite *_sfxVolumeHeader;
    
    ActionButton *_eraseDataButton;
    ActionButton *_howToPlayButton;
    ActionButton *_creditsButton;
    
    ClippingNode *_musicMask;
    ClippingNode *_sfxMask;
    
    GameLabel *_eraseText;
    GameLabel *_dataText;
    
    GameLabel *_howToText;
    GameLabel *_playText;
    
    GameLabel *_creditsText;
    
    GameLabel *_optionsHeader;
    
    Tutorial *_tutorial;
    
    bool _windowOpen;
    bool _eraseWindowFirstOpen;
    GameWindow *_eraseWindowFirst;
    GameWindow *_eraseWindowSecond;
    
    OptionsSwitchToType _switchToType;
    
    bool _isTransitioning;
    bool _inTutorial;
    bool _backToMainMenu;
    float _waitToSwitch;
    
    ActionButton *_backButton;
}

+(CCScene*)scene;

-(void)load;
-(void)setMusicXPosition:(float)xPos;
-(void)setSfxXPosition:(float)xPos;

-(void)setMusicPositionByVolume:(float)volume;
-(void)setSfxPositionByVolume:(float)volume;

-(void)sliderReactionAtPosition:(CGPoint)position;

-(void)switchToMainMenuScreen;
-(void)switchToTutorial;
-(void)switchToCreditsScreen;

@end
