//
//  MainMenuScene.h
//  Clay
//
//  Created by Brian Cable on 10/7/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The scene (and layer) for the Main Menu. All main menu screens should utilize this scene (although be different classes). Eventually add credits, options, and flesh out the choose level screen.


#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class Sprite;
@class ActionButton;

typedef enum {
    MAINMENU_TRANSITION_IN,
    MAINMENU_TRANSITION_OUT,
    MAINMENU_TRANSITION_IDLE
} MainMenuTransition;

typedef enum {
    MENU_SWITCHTO_CHOOSELEVEL,
    MENU_SWITCHTO_OPTIONS,
    MENU_SWITCHTO_GAMECENTER,
    MENU_SWITCHTO_CONTINUE
}MenuChoiceType;

@class ComicLayer;

@interface MainMenuScene : CCLayer
{
    Sprite *_trackBackground;
    Sprite *_rain1;
    Sprite *_rain2;
    
    Sprite *_logo;
    
    ActionButton *_playButton;
    ActionButton *_continueButton;
    
    ActionButton *_gameCenterButton;
    ActionButton *_optionsButton;
    
    ActionButton *_selectedButton; //weak reference to which button was selected to perform
    
    Sprite *_copyright;
    
    MainMenuTransition _transition;
    
    MenuChoiceType _switchToChoice;
    
    float _totalTime;
    float _time;
    
    bool _reinit;
    bool _switchSceneTriggered;
    bool _isContinueButtonEnabled;
    
}
+(CCScene *) scene;


#pragma mark - private methods
-(void)switchToChoice;

-(void)reinit;
-(void)switchToTransitionIn;
-(void)switchToTransitionOut;
-(void)pause;
-(void)setAlphaForAll:(float)alpha includingButtons:(bool)alphaButtons andButtonSelection:(bool)alphaSelected;
-(void)setButtonAlphas:(float)alpha;

@end
