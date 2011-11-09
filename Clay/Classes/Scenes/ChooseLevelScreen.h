//
//  ChooseLevelScreen.h
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  The scene for choosing a level displayed after the main menu.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;
@class ActionButton;

@interface ChooseLevelScreen : CCLayer
{
    Sprite *blackBackground;
    NSMutableArray *_buttons;
    float _waitToSwitch;
    float _alpha;
    NSString *_levelToSwitchTo;
    
    
    
    Sprite *_background;
    Sprite *_levelInfoFront;
    
    Sprite *_selector;
    
    CCLabelBMFont *_levelSelectText;
    CCLabelBMFont *_levelPanelText;
    
    ActionButton *_startButton;
    ActionButton *_backButton;
    
}

+(CCScene*)scene;
+(id)layerWithScene:(CCScene*)scene;
-(id) initWithScene:(CCScene*)scene;

-(void)load;

-(void)popAndSwitchToLevel:(NSString*)level;


@end
