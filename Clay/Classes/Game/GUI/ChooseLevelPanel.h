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
    
    CCNode *_rootUnlocked;
    CCNode *_rootLocked;
    
    
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
    
    CCLabelTTF *_dlcDescription;
    
    int _levelId;
    
    //required data
    NSString *_levelNameText;
    NSString *_timeForMedalLabelText;
    NSString *_timeForMedalValueText;
    NSString *_bestTimeText;
    NSString *_levelPreviewFrameName;
    NSString *_levelTitleFrameName;
    
}

@property(nonatomic,readonly) int levelId;

+(id)instance;

-(void)loadObjectsAfterDataInit:(id)layer;


-(void)reset:(id)layer;

-(void)setAlpha:(float)alpha;

//sets bestTimeText
-(void)setBestTime:(NSString*)timeString;

//sets levelName, levelPreviewFrame, levelTitleFrame
-(void)setLevelDataByNumber:(int)levelNumber;

//sets timeForMedal label and value text
-(void)setNextMedal:(int)medalId RequiredTime:(NSString*)time;

-(void)setDlcText:(NSString*)text;

-(void)setPanelXPosition:(float)newX;
-(void)setPanelTransitionAmount:(float)amount;
-(void)setUnlocked:(bool)isUnlocked;

@end
