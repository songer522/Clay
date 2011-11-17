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
#import "Level.h"
#import "SoundEngine.h"
#import "TextureManager.h"
#import "GameSettings.h"
#import "GameLayer.h"

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
         _buttons = [[NSMutableArray alloc] initWithCapacity:4];        
        _levelToSwitchTo = @"level1";
        _buttons = [[NSMutableArray alloc] initWithCapacity:7];
        _alpha = 1.0f;
        _selected = 1;
        _waitToSwitch = 0.0f;
        self.isTouchEnabled = YES;
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
                if (button.buttonId!=_selected) {
                    [[SoundEngine shared] playSound:@"chooseSelection"];
                }
                _selected = button.buttonId;
                
                if(_levelToSwitchTo) {
                    [_levelToSwitchTo release];
                    _levelToSwitchTo = nil;
                }
                _levelToSwitchTo = [[NSString alloc] initWithFormat:@"level%d",_selected];
            }
        }
        
        if([_startButton checkIfSelected:position]) {
            _waitToSwitch = 0.05f;
            [[SoundEngine shared] playSound:@"buttonPressed"];
            //self.isTouchEnabled = NO; //NOTE: CHOOSE LEVEL SCREEN STILL ACTIVE IN GAME???
            
        }
        
        if([_backButton checkIfSelected:position]) {
            NSLog(@"want to go back!");
        }        
    }
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    

    [[TextureManager shared] loadMemoryForKey:@"chooseLevel"];
    
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
    
    
    for (int i=0; i<7; i++) {
        LevelButton *button = [LevelButton levelButtonWithId:i];
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
    [[GameSettings shared] setGlobal:level ForKey:@"startingLevel"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameLayer scene]]];
}

-(void)transitionOut
{
}

-(void)unload
{
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;

    [self release];
}

-(void)update:(ccTime)dt
{
    [_startButton update:dt];
    [_backButton update:dt];

    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        if(_waitToSwitch<=0.0f){
            _waitToSwitch = 0.0f;
            [self popAndSwitchToLevel:_levelToSwitchTo];
        }
    }
}

-(void)dealloc
{
    NSLog(@"Dealloc: ChooseLevelScreen");
    
    [_buttons removeAllObjects];
    _buttons = nil;
    [_background release];
    [_levelToSwitchTo release];
    [_levelSelectText release];
    [_startButton release];
    [_selector release];
    
    [[TextureManager shared] unloadMemoryForKey:@"chooseLevel"];
}

@end
