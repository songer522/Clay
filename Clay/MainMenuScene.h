//
//  MainMenuScene.h
//  Clay
//
//  Created by Brian Cable on 10/7/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;

typedef enum {
    MAINMENU_TRANSITION_IN,
    MAINMENU_TRANSITION_OUT,
    MAINMENU_TRANSITION_IDLE
} MainMenuTransition;

@class ComicLayer;

@interface MainMenuScene : CCLayer
{
    Sprite *_trackBackground;
    Sprite *_rain1;
    Sprite *_rain2;
    
    Sprite *_logo;
    Sprite *_playButtonBlue;
    Sprite *_playButtonOrange;
    Sprite *_copyright;
    
    Sprite *_blackCover;
    float _blackFadeOut;
    
    MainMenuTransition _transition;
    
    float _totalTime;
    float _time;
    
    bool _reinit;
    
}
+(CCScene *) scene;


#pragma mark - private methods
-(void)private_switchToGame;
-(void)private_switchToChooseLevel;
-(void)reinit;
-(void)switchToTransitionIn;
-(void)switchToTransitionOut;

@end
