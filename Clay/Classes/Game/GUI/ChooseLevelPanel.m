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
#import "GameSettings.h"
#import "LayerManager.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
#define LEVELPANEL_PANEL_X 210.0f

@implementation ChooseLevelPanel

+(id)instance
{
    return [[self alloc] init];
}

-(id)init
{
    if((self=[super init])) {
    }
    
    return self;
}

-(void)loadObjectsAfterDataInit:(id)layer;
{
    NSAssert((_levelPreviewFrameName!=nil&&_bestTimeText!=nil&&_timeForMedalLabelText!=nil),@"ChooseLevelPanel.m - do not call loadObjectsAfterDataInit before calling setLevelData,setNextMedal, and setBestTime");
    
    float medTextScale = 0.53f;
    float smallTextScale = 0.5f;
    
    _root = [[CCNode alloc] init];
    
    [[LayerManager sharedLayers] setWorkingLayer:_root];
    
    _currentXPos = LEVELPANEL_PANEL_X;
    
    _background = [Sprite spriteCenteredWithFrame:@"LevelSelector_LevelInfo.png"];
    _levelPreview = [Sprite spriteCenteredWithFrame:_levelPreviewFrameName];
    _levelTitle = [Sprite spriteCenteredWithFrame:_levelTitleFrameName];
    
    _facebookIcon = [Sprite spriteCenteredWithFrame:@"Icon_Facebook.png"];
    _twitterIcon = [Sprite spriteCenteredWithFrame:@"Icon_Twitter.png"];
    
    _bestTimeLabel = [GameLabel gameLabelWithText:@"BEST TIME" Scale:medTextScale];
    [_bestTimeLabel setHorizontalAlignment:TEXT_ALIGN_LEFT];
    
    _bestTimeValue = [GameLabel gameLabelWithText:_bestTimeText Scale:medTextScale];
    [_bestTimeValue setHorizontalAlignment:TEXT_ALIGN_LEFT];
    
    _timeForMedalLabel = [GameLabel gameLabelWithText:_timeForMedalLabelText Scale:medTextScale];
    [_timeForMedalLabel setHorizontalAlignment:TEXT_ALIGN_LEFT];
    _timeForMedalValue = [GameLabel gameLabelWithText:_timeForMedalValueText Scale:medTextScale];
    [_timeForMedalValue setHorizontalAlignment:TEXT_ALIGN_LEFT];
    
    _levelNumber = [GameLabel gameLabelWithText:_levelNameText Scale:smallTextScale];
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
        
    [layer addChild:_root];
    
    [self setPanelXPosition:LEVELPANEL_PANEL_X];
}

-(void)reset:(id)layer
{
    [_root removeFromParentAndCleanup:NO];
    [layer addChild:_root];
}

-(void)setAlpha:(float)alpha
{
    [_background setAlpha:alpha];
    [_levelPreview setAlpha:alpha];
    [_levelTitle setAlpha:alpha];
    [_facebookIcon setAlpha:alpha];
    [_twitterIcon setAlpha:alpha];
    [_bestTimeLabel setAlpha:alpha];
    [_bestTimeValue setAlpha:alpha];
    [_timeForMedalLabel setAlpha:alpha];
    [_timeForMedalValue setAlpha:alpha];
    [_levelNumber setAlpha:alpha];
}

//sets bestTimeText
-(void)setBestTime:(NSString*)timeString
{
    _bestTimeText = [NSString stringWithString:timeString];    
}

//sets levelName, levelPreviewFrame, levelTitleFrame
-(void)setLevelDataByNumber:(int)levelNumber
{
    NSAssert((levelNumber>0&&levelNumber<=11),@"ChooseLevelPanel.m - levelNumber outside range. Value: %d",levelNumber);
    
    NSString *difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    
    _levelNameText = [NSString stringWithFormat:@"LEVEL %d",levelNumber];
    _levelPreviewFrameName = [NSString stringWithFormat:@"LevelPreview_%d.png",levelNumber];
    
    if ([difficulty isEqualToString:@"normal"]) {        
        _levelTitleFrameName = [NSString stringWithFormat:@"Name_Normal_%d.png",levelNumber];
    } else {
        _levelTitleFrameName = [NSString stringWithFormat:@"Name_Insane_%d.png",levelNumber];
    }    
}

//sets timeForMedal label and value text
-(void)setNextMedal:(int)medalId RequiredTime:(NSString*)time
{
    switch (medalId) {
        case CHOOSEPANEL_MEDAL_BRONZE:
            _timeForMedalLabelText = [NSString stringWithString:@"TIME FOR BRONZE"];
            _timeForMedalValueText = [NSString stringWithString:time];
            break;
        case CHOOSEPANEL_MEDAL_SILVER:
            _timeForMedalLabelText = [NSString stringWithString:@"TIME FOR SILVER"];
            _timeForMedalValueText = [NSString stringWithString:time];
            break;
        case CHOOSEPANEL_MEDAL_GOLD:
            _timeForMedalLabelText = [NSString stringWithString:@"TIME FOR GOLD"];
            _timeForMedalValueText = [NSString stringWithString:time];
            break;
        default:
            _timeForMedalLabelText = [NSString stringWithString:@""];
            _timeForMedalValueText = [NSString stringWithString:@""];
            break;
    }
}


-(void)setPanelXPosition:(float)newX
{
    //IPAD FIX: refer to reference for proper positions, this is the level information panel in the choose level screen
    _currentXPos = newX;
    float iconX = newX + 70.0f * MULTIPLIERX;
    float textX = newX - 78.0f * MULTIPLIERX;
    float levelNumberX = newX + 53.0f * MULTIPLIERX;
    
    [_background setScreenPosition:ccp(newX,165 * MULTIPLIERY)];
    [_levelPreview setScreenPosition:ccp(newX,219 * MULTIPLIERY)];
    [_levelTitle setScreenPosition:ccp(newX,170 * MULTIPLIERY)];
    [_facebookIcon setScreenPosition:ccp(iconX,131 * MULTIPLIERY)];
    [_twitterIcon setScreenPosition:ccp(iconX,89 * MULTIPLIERY)];
    [_bestTimeLabel setPosition:ccp(textX,138 * MULTIPLIERY)];
    [_bestTimeValue setPosition:ccp(textX,123 * MULTIPLIERY)];
    [_timeForMedalLabel setPosition:ccp(textX,95 * MULTIPLIERY)];
    [_timeForMedalValue setPosition:ccp(textX,80 * MULTIPLIERY)];
    [_levelNumber setPosition:ccp(levelNumberX, 67 * MULTIPLIERY)];
}

-(void)setPanelTransitionAmount:(float)amount
{
    [self setPanelXPosition:((LEVELPANEL_PANEL_X - (1.0f - amount) * 20))];
}

-(void)dealloc
{
    [_root removeFromParentAndCleanup:YES];
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
