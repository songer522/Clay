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
    NSMutableArray *_buttons;
    float _waitToSwitch;
    float _alpha;
    bool _backToMainMenu;
    NSString *_levelToSwitchTo;
    
    Sprite *_background;    
    Sprite *_selector;
    
    CCLabelBMFont *_levelSelectText;
    
    ActionButton *_startButton;
    ActionButton *_backButton;
    
    int _selected;
}

+(CCScene*)scene;
+(id)layerWithScene:(CCScene*)scene;
-(id) initWithScene:(CCScene*)scene;

-(void)load;
-(void)loadMedals;

-(void)popAndSwitchToLevel:(NSString*)level;
-(void)switchToMainMenu;

-(void)transitionOut;


-(void)unload;



@end
