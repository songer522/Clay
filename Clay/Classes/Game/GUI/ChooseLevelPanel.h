//
//  ChooseLevelPanel.h
//  Clay
//
//  Created by Brian Cable on 12/14/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;
@class GameLabel;

@interface ChooseLevelPanel : NSObject
{
    float _currentXPos;
    
    Sprite *_background;
    Sprite *_levelTitle;
    Sprite *_levelPreview;
    
    Sprite *_facebookIcon;
    Sprite *_twitterIcon;
    
    GameLabel *_bestTimeLabel;
    GameLabel *_bestTimeValue;
    
    GameLabel *_timeForMedalLabel;
    GameLabel *_timeForMedalValue;
    
    GameLabel *_levelNumber;
}

+(id)instance;

@end
