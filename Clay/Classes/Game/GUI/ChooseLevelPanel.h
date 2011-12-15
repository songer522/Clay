//
//  ChooseLevelPanel.h
//  Clay
//
//  Created by Brian Cable on 12/14/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    CHOOSEPANEL_MEDAL_BRONZE = 1,
    CHOOSEPANEL_MEDAL_SILVER = 2,
    CHOOSEPANEL_MEDAL_GOLD = 3,
    CHOOSEPANEL_MEDAL_NONE = 4
}ChoosePanelMedalType;

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
    
    //required data
    NSString *_levelNameText;
    NSString *_timeForMedalLabelText;
    NSString *_timeForMedalValueText;
    NSString *_bestTimeText;
    NSString *_levelPreviewFrameName;
    NSString *_levelTitleFrameName;
    
}

+(id)instance;

-(void)loadObjectsAfterDataInit;
-(void)setAlpha:(float)alpha;

//sets bestTimeText
-(void)setBestTime:(NSString*)timeString;

//sets levelName, levelPreviewFrame, levelTitleFrame
-(void)setLevelDataByNumber:(int)levelNumber;

//sets timeForMedal label and value text
-(void)setNextMedal:(int)medalId RequiredTime:(NSString*)time;

-(void)setPanelXPosition:(float)newX;

@end
