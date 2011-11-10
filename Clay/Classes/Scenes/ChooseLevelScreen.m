//
//  ChooseLevelScreen.m
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseLevelScreen.h"
#import "Sprite.h"
#import "LevelManager.h"
#import "LayerManager.h"
#import "Button.h"
#import "ComicManager.h"
#import "LevelButton.h"
#import "ActionButton.h"

@implementation ChooseLevelScreen


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ChooseLevelScreen *layer = [ChooseLevelScreen layerWithScene:scene];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id)layerWithScene:(CCScene*)scene
{
    return [[self alloc] initWithScene:scene];
}

-(id) initWithScene:(CCScene*)scene
{
    if ((self = [super init])) {
        [[LayerManager sharedLayers] setScene:scene ForKey:@"chooseLevel"];
         _buttons = [[NSMutableArray alloc] initWithCapacity:4];
        
        _levelToSwitchTo = @"level1";
        _buttons = [[NSMutableArray alloc] initWithCapacity:11];
        _alpha = 1.0f;
        _waitToSwitch = 0.0f;
        [self load];
    }
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        for (LevelButton *button in _buttons) {
            if([button checkIfSelected:position]) {
                int levelNumber = button.buttonId;
                
                if(_levelToSwitchTo) {
                    [_levelToSwitchTo release];
                    _levelToSwitchTo = nil;
                }
                _levelToSwitchTo = [[NSString alloc] initWithFormat:@"level%d",levelNumber];
                
                NSLog(@"SWITCH TO LEVEL %d",levelNumber);
            }
        }
        
        if([_startButton checkIfSelected:position]) {
            _waitToSwitch = 0.25f;
        }
        
        if([_backButton checkIfSelected:position]) {
            NSLog(@"want to go back!");
        }        
    }
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    

    
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:@"chooseLevel.plist"];
    
    _background = [Sprite spriteFromFrameCacheWithName:@"CL_Background.png"];
    [_background setScreenPosition:ccp(0,0)];
    
    /*
    _levelInfoFront = [Sprite spriteFromFrameCacheWithName:@"CL_LevelInfo.png"];
    [_levelInfoFront getCCSprite].anchorPoint = ccp(0.5f,0.5f);
    [_levelInfoFront setScreenPosition:ccp(105.0f,152.0f)];
    */
     
    _selector = [Sprite spriteFromFrameCacheWithName:@"CL_LevelSelected.png"];
    [_selector setPosition:ccp(0,0)];
    [[_selector getCCSprite] setVisible:NO];
    
    _startButton = [ActionButton actionButtonWithText:@"START"];
    [_startButton setPosition:ccp(430,18)];
    
    //_backButton = [ActionButton actionButtonWithText:@"BACK"];
    //[_backButton setPosition:ccp(50, 18)];
    
    
    for (int i=0; i<11; i++) {
        LevelButton *button = [LevelButton levelButtonWithCache:frameCache andId:i];
        [button setCursor:_selector];
        
        if(i==0) {
            [button setSelected];
        }
        
        [_buttons addObject:button];
    }
    
    
    _levelSelectText = [CCLabelBMFont labelWithString:@"LEVEL SELECT" fntFile:@"GraphicFont.fnt"];
    [_levelSelectText setScale:0.75f];
    _levelSelectText.position = ccp(365.0f,278.0f);
    [[[LayerManager sharedLayers] currentLayer] addChild:_levelSelectText];


    /*
    _levelPanelText = [CCLabelBMFont labelWithString:@"LEVEL 1" fntFile:@"GraphicFont.fnt"];
    [_levelPanelText setScale:0.5f];
    _levelPanelText.position = ccp(158,34.5f);
    [[[LayerManager sharedLayers] currentLayer] addChild:_levelPanelText];
    */
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
    [self scheduleUpdate];
    self.isTouchEnabled = true;    
    
}


-(void)popAndSwitchToLevel:(NSString*)level
{
    [[LevelManager shared] loadLevelNamed:level];
    [[LevelManager shared] switchToNextLevel];
    [[ComicManager shared] startComic:@"intro" StartPhase:COMIC_PHASE_PLAY_VIDEO];

    //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[[LayerManager sharedLayers] currentScene]]];
    [self unload];
    [self unscheduleUpdate];

    
    //[[LayerManager sharedLayers] popAndPushSceneNamed:@"game"];
    [[LayerManager sharedLayers] pushSceneNamed:@"game"];
     
}

-(void)unload
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"chooseLevel.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"chooseLevel.png"];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];    
}

-(void)update:(ccTime)dt
{
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        if(_waitToSwitch<=0.0f){
            _waitToSwitch = 0.0f;
            [self popAndSwitchToLevel:_levelToSwitchTo];
        }
    }
    [_startButton update:dt];
    [_backButton update:dt];
}

-(void)dealloc
{
    [_buttons removeAllObjects];
    [_buttons release];
    [_levelToSwitchTo release];
    //[_backButton release];
    [_startButton release];
    //[_levelInfoFront release];
    //[_levelPanelText release];
    [_selector release];
    
    [super dealloc];
}

@end
