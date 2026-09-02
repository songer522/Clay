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



#define LEVELPANEL_MAX_LEVEL_NUMBER 13
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
// Phone keeps the original left-panel X; 210 was an iPad-only value that was
// incorrectly applied to phones and overlaps the level grid.
#define LEVELPANEL_PANEL_X (IS_IPAD ? 210.0f : 105.0f)
#define LEVELPANEL_LEGACY_PHONE_WIDTH 480.0f
#define LEVELPANEL_LEGACY_PHONE_HEIGHT 320.0f
#define LEVELPANEL_LEGACY_IPAD_WIDTH 1024.0f
#define LEVELPANEL_LEGACY_IPAD_HEIGHT 768.0f

static CGPoint ChooseLevelPanelLayoutOffset(void)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat legacyWidth = IS_IPAD ? LEVELPANEL_LEGACY_IPAD_WIDTH : LEVELPANEL_LEGACY_PHONE_WIDTH;
    CGFloat legacyHeight = IS_IPAD ? LEVELPANEL_LEGACY_IPAD_HEIGHT : LEVELPANEL_LEGACY_PHONE_HEIGHT;
    return ccp(MAX(0.0f, floorf((winSize.width - legacyWidth) / 2.0f)),
               MAX(0.0f, floorf((winSize.height - legacyHeight) / 2.0f)));
}

@implementation ChooseLevelPanel

@synthesize levelId = _levelId;

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
    
    _rootUnlocked = [[CCNode alloc] init];
    _rootLocked = [[CCNode alloc] init];
    
    [[LayerManager sharedLayers] setWorkingLayer:_rootUnlocked];
    
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
    
    [self setDlcText:@"blah"];
    
    [layer addChild:_rootUnlocked];
    [layer addChild:_rootLocked];
    
    [self setPanelXPosition:LEVELPANEL_PANEL_X];
}

-(void)setUnlocked:(bool)isUnlocked
{
    if (isUnlocked) {
        [_facebookIcon setVisible:YES];
        [_twitterIcon setVisible:YES];
        [_bestTimeLabel setVisible:YES];
        [_bestTimeValue setVisible:YES];
        [_timeForMedalLabel setVisible:YES];
        [_timeForMedalValue setVisible:YES];
        [_dlcDescription setVisible:NO];
    } else {
        [_facebookIcon setVisible:NO];
        [_twitterIcon setVisible:NO];
        [_bestTimeLabel setVisible:NO];
        [_bestTimeValue setVisible:NO];
        [_timeForMedalLabel setVisible:NO];
        [_timeForMedalValue setVisible:NO];
        [_dlcDescription setVisible:YES];
    }
}

-(void)setDlcText:(NSString*)text
{
    if (_levelId == 12) {
        text = @"Help Tim train for the big race! This bonus level finds Tim at his local gym…but this isn’t your typical workout.";
    } else if(_levelId == 13) {
        text = @"This bonus level finds Tim working out at the Dojo, fighting off ninjas and dodging throwing stars. Fortunately, it’s all in his head…isn’t it?";
        
    }
    _dlcDescription = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(172*MULTIPLIERX, 100*MULTIPLIERY) alignment:UITextAlignmentLeft fontName:@"Impact.ttf" fontSize:22];
    [_dlcDescription setPosition:ccp(106,97)];
    [_rootLocked addChild:_dlcDescription];
}

-(void)reset:(id)layer
{
    [_rootUnlocked removeFromParentAndCleanup:NO];
    [layer addChild:_rootUnlocked];
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
    [_dlcDescription setOpacity:((int)(255 * alpha))];
}

//sets bestTimeText
-(void)setBestTime:(NSString*)timeString
{
    _bestTimeText = [NSString stringWithString:timeString];    
}

//sets levelName, levelPreviewFrame, levelTitleFrame
-(void)setLevelDataByNumber:(int)levelNumber
{
    NSAssert((levelNumber>0&&levelNumber<=LEVELPANEL_MAX_LEVEL_NUMBER),@"ChooseLevelPanel.m - levelNumber outside range. Value: %d",levelNumber);
    
    NSString *difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    
    _levelId = levelNumber;
    
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
    CGPoint offset = ChooseLevelPanelLayoutOffset();
    _currentXPos = newX;
    float iconX = newX + 70.0f * MULTIPLIERX;
    float textX = newX - 78.0f * MULTIPLIERX;
    float levelNumberX = newX + 53.0f * MULTIPLIERX;
     float dlcX = newX - 0.0f;
    
    [_background setScreenPosition:ccp(offset.x + newX, offset.y + 165 * MULTIPLIERY)];
    [_levelPreview setScreenPosition:ccp(offset.x + newX, offset.y + 219 * MULTIPLIERY)];
    [_levelTitle setScreenPosition:ccp(offset.x + newX, offset.y + 170 * MULTIPLIERY)];
    [_facebookIcon setScreenPosition:ccp(offset.x + iconX, offset.y + 131 * MULTIPLIERY)];
    [_twitterIcon setScreenPosition:ccp(offset.x + iconX, offset.y + 89 * MULTIPLIERY)];
    [_bestTimeLabel setPosition:ccp(offset.x + textX, offset.y + 138 * MULTIPLIERY)];
    [_bestTimeValue setPosition:ccp(offset.x + textX, offset.y + 123 * MULTIPLIERY)];
    [_timeForMedalLabel setPosition:ccp(offset.x + textX, offset.y + 95 * MULTIPLIERY)];
    [_timeForMedalValue setPosition:ccp(offset.x + textX, offset.y + 80 * MULTIPLIERY)];
    [_levelNumber setPosition:ccp(offset.x + levelNumberX, offset.y + 67 * MULTIPLIERY)];
    [_dlcDescription setPosition:ccp(offset.x + dlcX, offset.y + 97* MULTIPLIERY)];
}

-(void)setPanelTransitionAmount:(float)amount
{
    [self setPanelXPosition:((LEVELPANEL_PANEL_X - (1.0f - amount) * 20))];
}

-(void)dealloc
{
    [_background release];
    [_levelTitle release];
    [_levelPreview release];
    [_facebookIcon release];
    [_twitterIcon release];
    [_bestTimeLabel release];
    [_bestTimeValue release];
    [_timeForMedalLabel release];
    [_timeForMedalValue release];
    [_levelNumber release];
    
    //maybe not needed
    /*
    [_levelNameText release];
    [_timeForMedalLabelText release];
    [_timeForMedalValueText release];
    [_bestTimeText release];
    [_levelPreviewFrameName release];
    [_levelTitleFrameName release];
     */

    [_rootUnlocked removeFromParentAndCleanup:NO];
    [_rootUnlocked release];
    
    [super dealloc];
}

@end
