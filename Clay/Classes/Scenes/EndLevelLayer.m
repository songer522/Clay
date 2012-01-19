//
//  EndLevelLayer.m
//  Clay
//
//  Created by Brian Cable on 1/11/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "EndLevelLayer.h"
#import "LayerManager.h"
#import "GameController.h"
#import "GameLabel.h"
#import "GameLayer.h"
#import "Button.h"
#import "ActionButton.h"
#import "Sprite.h"
#import "SoundEngine.h"
#import "GameSettings.h"
#import "Camera.h"
#import "LevelManager.h"
#import "SoundEngine.h"
#import "HudLayer.h"
#import "TextureManager.h"
#import "GameSettings.h"
#import "Level.h"
#import "BestTimes.h"
#import "TrackTimer.h"
#import "PListLoader.h"

@interface EndLevelLayer()

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2;
-(void) doButtonAction;

@end

@implementation EndLevelLayer

@synthesize gameController = _gameController;
@synthesize timer=_timer;
@synthesize isNewRecord =_isNewRecord;


+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {      

        _alpha = 0.0;
        _buttonPressed=false;
        
        [self scheduleUpdate];
        [[[LayerManager sharedLayers] currentScene] addChild:self];
         _gameLayer = [[LayerManager sharedLayers] currentLayer];
        [[LayerManager sharedLayers] setWorkingLayer:self];
        [[TextureManager shared] loadMemoryForKey:@"endLevel"];
        _replayButton = [ActionButton actionButtonInGameWithText:@"REPLAY"];
        _menuButton = [ActionButton actionButtonInGameWithText:@"MENU"];
        
        _finalTimePanel = [Sprite spriteFromFrameCacheWithName:@"EndGame_TimeBack.png"];
        
        medalsDict = [PListLoader loadPlistWithName:@"medals"];
        _modeDict = [[NSDictionary alloc] initWithDictionary:[medalsDict objectForKey:@"timed"]];

        [self showMedal];
     //  _trophyFront = [Sprite spriteFromFrameCacheWithName:@"EndGame_Trophy_3.png"];
        
        //IPAD FIX: reposition so paused text is centered on x, and slightly above center on y, and buttons are side by side, with the middle button centered on x, and each one slightly below center on y
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float centerX = winSize.width/2.0f;
        float centerY = winSize.height/2.0f;
        [_replayButton setPosition:ccp(centerX-185,centerY - 140.0f)];
        [_menuButton setPosition:ccp(centerX + 185.0f,centerY - 140.0f)];
        [_finalTimePanel getCCSprite].position=ccp(centerX-225,centerY+70);
        
        //_timer=[[GameSettings shared] getGlobalForKey:@"finalLevelTime"];
        
        
        _finalTimeText = [GameLabel gameLabelWithText:[[GameSettings shared] getGlobalForKey:@"finalLevelTimeText"]  Scale:1.0f Position:ccp(centerX,centerY+90)];
        
        _action = END_LEVEL_NONE;
        _waitToSwitch = -1.0f;
        
      
        
        
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        //[[SoundEngine shared] cueFadeOut];
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        
        if([_replayButton checkIfSelected:position]) {
            [[SoundEngine shared] playSound:@"buttonPressed"];
            _action = END_LEVEL_REPLAY;
            _waitToSwitch = 0.35f;
        } else if([_menuButton checkIfSelected:position]) {
            [[SoundEngine shared] playSound:@"buttonPressed"];
            _action = END_LEVEL_BACK;
            _waitToSwitch = 0.35f;
        }
        
        break;
    }
}
-(int)getMedalNumberForLevelNamed:(NSString*)levelName Time:(float)time
{
    int returnVal = 0;
    
    NSDictionary *levelDict = [_modeDict objectForKey:levelName];
    
    //get medal data based on the levels difficulty
    NSDictionary *medals = [levelDict objectForKey:[[GameSettings shared] getGlobalForKey:@"gameDifficulty"]];
    
    int bronzeTime = [[medals objectForKey:@"bronze"] intValue];
    int silverTime = [[medals objectForKey:@"silver"] intValue];
    int goldTime = [[medals objectForKey:@"gold"] intValue];
    
    
    //set trophy based on what player's best time is for that level
    if (time!=0) {
        if (time<goldTime) {
            returnVal = 3;
        } else if(time<silverTime) {
            returnVal = 2;
        } else if(time<bronzeTime) {
            returnVal = 1;
        } else {
            returnVal = 0;
        }
    }
    
    return returnVal;
}




-(float)getTimeForNextMedalForLevelNamed:(NSString*)levelName BestTime:(float)time
{
    int returnVal = 0;
    
    NSDictionary *levelDict = [_modeDict objectForKey:levelName];
    
    //get medal data based on the levels difficulty
    NSDictionary *medals = [levelDict objectForKey:[[GameSettings shared] getGlobalForKey:@"gameDifficulty"]];
    
    int bronzeTime = [[medals objectForKey:@"bronze"] intValue];
    int silverTime = [[medals objectForKey:@"silver"] intValue];
    int goldTime = [[medals objectForKey:@"gold"] intValue];
    
    if (time<goldTime) {
        returnVal = goldTime;
    } else if(time<silverTime) {
        returnVal = silverTime;
    } else if(time<bronzeTime) {
        returnVal = bronzeTime;
    } else {
        returnVal = 0;
    }
    
    return returnVal;
}

-(NSString *)covertTrophyname:(TrophyName)Trophy
{
    NSString *TrophyName;
    switch (Trophy) {
        case NO_TROPHY:
            TrophyName=[NSString stringWithFormat:@"You Need More Practice !"];
            break;
        case BRONZE_TROPHY:
            TrophyName=[NSString stringWithFormat:@"You Won A Bronze Trophy !"];
            break;
        case SLIVER_TROPHY:
            TrophyName=[NSString stringWithFormat:@"You Won A Sliver Trophy !"];
            break;
        case GOLD_TROPHY:
            TrophyName=[NSString stringWithFormat:@"You Won A Gold Trophy !"];
            break;
                   
        default:
            break;
    }
    
    return TrophyName;
}

-(void)setTrophyPosition
{
    // if (_trophyFront!=nil) {
    //CGPoint position = [_buttonGraphic getPosition];
    // [_trophyFront getCCSprite].position= ccp(240,160);  
    [_trophyFront getCCSprite].position=ccp(200,65);
    // }
}

-(void)setNewTrophy:(int)trophyId
{
    NSString *frameName = [NSString stringWithFormat:@"EndGame_Trophy_%d.png",trophyId];
    _trophyFront = [Sprite spriteFromFrameCacheWithName:frameName];
  
    [self setTrophyPosition];
    _trophyText = [GameLabel gameLabelWithText:[self covertTrophyname:trophyId]  Scale:0.6f Position:ccp(240,50)];
}

-(void)setOldTrophy:(int)trophyId
{
    int i;
    for(i=0;i<3;i++)
    {
    NSString *frameName = [NSString stringWithFormat:@"EndGame_Trophy.png"];
    _trophyBack = [Sprite spriteFromFrameCacheWithName:frameName];
    }
    [self setTrophyPosition];
}

-(void)showMedal
{
   // GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
 //   NSString  *gameDifficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    
    NSString *levelName =[[LevelManager shared] currentLevel].name;
    
   // float bestTime = [[BestTimes shared] getBestTimeForLevelName:levelName forDifficulty:gameDifficulty];
  
    float newTime=[[[GameSettings shared] getGlobalForKey:@"finalLevelTime"] floatValue];
    //NSLog(@"%f",newTime);
       
   
    
    int medalForNewTime = [self getMedalNumberForLevelNamed:levelName Time:newTime];
    //int medalForBestTime =[self getMedalNumberForLevelNamed:levelName Time:bestTime];
   // if (medalForNewTime>0 && medalForNewTime<4 && medalForNewTime > medalForBestTime) {
     if (medalForNewTime>=0 && medalForNewTime<4) {
        [self setNewTrophy:medalForNewTime];
    }
    else
    {
       // [self setOldTrophy:medalForBestTime];
    }

    
    
}

-(void)showNewRecord
{
    [[LayerManager sharedLayers] setWorkingLayer:self];
    if(_isNewRecord)
    {
        _timeHeaderText = [GameLabel gameLabelWithText:@"New Record!"  Scale:0.6f Position:ccp(240,280)];
    }
    else
    {
        // _timeHeaderText = [GameLabel gameLabelWithText:@"Your Time:"  Scale:0.6f Position:ccp(240,280)];
    }
 [[LayerManager sharedLayers] forgetWorkingLayer];
}

-(void) doButtonAction
{
   
    NSString *gameMode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
    
    switch (_action) {
        case END_LEVEL_REPLAY:
            [_gameLayer scheduleUpdate];
            [[_gameLayer getHud] fadeIn];
            _gameLayer.inComic=false;
            [_gameLayer onEnter];
         
            [_gameLayer restartLevel];
             _gameLayer.gameController.isInputEnabled = true;
              _gameLayer.isTouchEnabled=true;
            [self onExit];
            
            /*
            _gameLayer.visible = true;
            
            
             [_gameLayer restartLevel];
            
           
            
            
            [[_gameLayer getHud] fadeIn];
             
            
            _gameLayer.gameController.isInputEnabled = true;
        _gameLayer.isTouchEnabled=true;
            _gameLayer.gameController.isHandlingPause = false;
           */
                        
                        
            
                                   
            break;
        case END_LEVEL_BACK:
            //[_gameController pauseGame];
            
            if([gameMode isEqualToString:@"story"]) {
                [_gameLayer switchToChooseMode];
            } else {
                [_gameLayer switchToChooseLevel];
            }
            break;            
        default:
            break;
    }
}

-(void)draw
{
    [self ccDrawFilledRectFrom:ccp(0,0) To:CGPointMake(1500,1500)];
    [super draw];
}

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2
{
    CGPoint poli[] = {v1, CGPointMake(v1.x,v2.y),v2,CGPointMake(v2.x,v1.y)};
    
    GLubyte rectAlpha = floor(_alpha * 180);
    glColor4ub(0, 0, 0, rectAlpha);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glVertexPointer(2, GL_FLOAT, 0, poli);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
}



-(void)onExit
{
   // [_finalTimePanel getCCSprite].visible = false;
    //[_finalTimeText setText:nil];
    
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
    [self release];
}


-(void)update:(ccTime)dt
{
   
    [[SoundEngine shared] update:dt];
    
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        
        
        if (_waitToSwitch<=0.0f) {
            _waitToSwitch = 0.0f;
         
            [self doButtonAction];
            
        }
        
        if (_action != END_LEVEL_BACK && _waitToSwitch<=0.20f) {
            _alpha = 5.0f * _waitToSwitch;            
        }
        
    } else {
        _alpha += 3.0f * dt;
        if (_alpha > 1.0f) {
            _alpha = 1.0f;
        }        
    }
    
    //set alpha for all elements
    
    [_replayButton setAlpha:_alpha];
    [_menuButton setAlpha:_alpha];
    [_finalTimeText setAlpha:_alpha];
    [_finalTimePanel setAlpha:_alpha];
    [_timeHeaderText setAlpha:_alpha];
    [_trophyFront setAlpha:_alpha];
    [_trophyText setAlpha:_alpha];
    
    [_replayButton update:dt];
    [_menuButton update:dt];
    
}

-(void)dealloc
{
    [[TextureManager shared] unloadMemoryForKey:@"endLevel"];
    _gameController = nil;
    [_finalTimeText release];
    _gameLayer=nil;
    [_finalTimePanel release];
    [_timeHeaderText release];
 
    //[super dealloc];
}

@end
