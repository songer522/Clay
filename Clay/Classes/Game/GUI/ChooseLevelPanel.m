//
//  ChooseLevelPanel.m
//  Clay
//
//  Created by Brian Cable on 12/14/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseLevelPanel.h"
#import "Sprite.h"
#import "GameLabel.h"

#define LEVELPANEL_PANEL_X 105.0f

@implementation ChooseLevelPanel

+(id)instance
{
    return [[self alloc] init];
}

-(id)init
{
    if((self=[super init])) {
        _currentXPos = LEVELPANEL_PANEL_X;
        
        _background = [Sprite spriteCenteredWithFrame:@"LevelSelector_LevelInfo.png" Position:ccp(_currentXPos,155)];
        _levelPreview = [Sprite spriteCenteredWithFrame:@"LevelPreview_1.png" Position:ccp(_currentXPos,219)];
        _levelTitle = [Sprite spriteCenteredWithFrame:@"Name_Normal_1.png" Position:ccp(_currentXPos,160)];
        
        _facebookIcon = [Sprite spriteCenteredWithFrame:@"Icon_Facebook.png" Position:ccp(_currentXPos + 70,121)];
        _twitterIcon = [Sprite spriteCenteredWithFrame:@"Icon_Twitter.png" Position:ccp(_currentXPos + 70,79)];
        
        _bestTimeLabel = [GameLabel gameLabelWithText:@"BEST TIME" Scale:0.55f Position:ccp(_currentXPos - 89,128)];
        [_bestTimeLabel setHorizontalAlignment:TEXT_ALIGN_LEFT];
        
        _bestTimeValue = [GameLabel gameLabelWithText:@"02:41:55" Scale:0.55f Position:ccp(_currentXPos - 89,113)];
        [_bestTimeValue setHorizontalAlignment:TEXT_ALIGN_LEFT];
        
        _timeForMedalLabel = [GameLabel gameLabelWithText:@"TIME FOR SILVER" Scale:0.55f Position:ccp(_currentXPos - 89,85)];
        [_timeForMedalLabel setHorizontalAlignment:TEXT_ALIGN_LEFT];
        _timeForMedalValue = [GameLabel gameLabelWithText:@"02:30:00" Scale:0.55f Position:ccp(_currentXPos - 89,70)];
        [_timeForMedalValue setHorizontalAlignment:TEXT_ALIGN_LEFT];
        
        _levelNumber = [GameLabel gameLabelWithText:@"LEVEL 11" Scale:0.5f Position:ccp(_currentXPos + 56,37)];
    }
    
    return self;
}

-(void)dealloc
{
    [_background release];
    [_levelTitle release];
    [_levelPreview release];
    [_facebookIcon release];
    [_twitterIcon release];
    [_bestTimeValue release];
    [_bestTimeLabel release];
    [_timeForMedalValue release];
    [_timeForMedalLabel release];
    [_levelNumber release];
    [super dealloc];
}

@end
