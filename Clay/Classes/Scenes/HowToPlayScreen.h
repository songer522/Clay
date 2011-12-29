//
//  HowToPlayScreen.h
//  Clay
//
//  Created by Brian Cable on 12/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"

@class Tutorial;
@class Sprite;
@class ActionButton;
@class GameLabel;

@interface HowToPlayScreen : CCLayer
{
    Tutorial *_tutorial;
    Sprite *_background;
    GameLabel *_header;
    
    ActionButton *_backButton;
    ActionButton *_startButton;
    
    bool _switchToGame;
    bool _hasSwitched;
    float _waitToSwitch;
    
}

+(CCScene *) scene;
+(id)layerWithScene:(CCScene*)scene;
-(id) initWithScene:(CCScene*)scene;

-(void)switchToOptionsScreen;
-(void)switchToGameScreen;

@end
