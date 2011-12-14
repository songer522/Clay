//
//  ChooseModeScene.h
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"

@class Sprite;
@class ModePanel;
@class GameLabel;

@interface ChooseModeScene : CCLayer
{
    Sprite *_background;
    
    ModePanel *_storyModePanel;
    ModePanel *_timedModePanel;
    ModePanel *_extrasPanel;
    
    GameLabel *_selectModeText;
    
    bool _isTransitioning;
}

@property(nonatomic,assign) bool isTransitioning;

+(CCScene*)scene;

-(void)load;

@end
