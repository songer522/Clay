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
#import "Appirater.h"
#import "MainMenuScene.h"



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
        _backToMainMenu = false;
        _backToLevelSelect =false;
        _inTutorial=false;
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
            _waitToSwitch = 0.25f;
            [[SoundEngine shared] playSound:@"buttonPressed"]; 
            
            //[[SoundEngine shared] cueFadeOut];
        }
        
        if([_backButton checkIfSelected:position]) {
            _waitToSwitch = 0.25f;
            _backToMainMenu = true;
            [[SoundEngine shared] playSound:@"buttonPressed"];     
        }
        
            }
}

-(void)loadTutorial
{
    CCLayer *pageOne = [[CCLayer alloc] init];
    CCSprite *image1=[CCSprite spriteWithFile:@"image1.png"];
    [image1 setPosition:ccp(240,160)];
    [pageOne addChild:image1];
    
    CCLayer *pageTwo = [[CCLayer alloc] init];
    CCSprite *image2=[CCSprite spriteWithFile:@"image2.png"];
    [image2 setPosition:ccp(240,160)];
    [pageTwo addChild:image2];
    
    CCLayer *pageThree = [[CCLayer alloc] init];
    CCSprite *image3=[CCSprite spriteWithFile:@"image3.png"];
    [image3 setPosition:ccp(240,160)];
    [pageThree addChild:image3];
    _closeTutorial=[ActionButton buttonWithText:@"Done" AtPoint:ccp(320,70) inLayer:pageThree];
    
    
 
        
    scroller = [[CCScrollLayer alloc] initWithLayers:[NSMutableArray arrayWithObjects: pageOne,pageTwo,pageThree,nil] widthOffset: 200];
    
    [self addChild:scroller];
    [scroller setVisible:NO];
    scroller.showPagesIndicator=NO;
    

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
    
    _backButton = [ActionButton actionButtonWithText:@"BACK"];
    [_backButton setPosition:ccp(50, 18)];
    
    
    for (int i=0; i<11; i++) {
        LevelButton *button = [LevelButton levelButtonWithId:i];
        [button setCursor:_selector];
        
        if(i==0) {
            [button setSelected];
        }
        
        [_buttons addObject:button];
        
       
    }
    
    
    _levelSelectText = [CCLabelBMFont labelWithString:@"LEVEL SELECT" fntFile:@"GraphicFont.fnt"];
    if ([GameSettings usingHighResolutionGraphics])
    { [_levelSelectText setScale:0.75f];}
    else
    { [_levelSelectText setScale:0.375f];}
    
    _levelSelectText.position = ccp(365.0f,278.0f);
    [[[LayerManager sharedLayers] currentLayer] addChild:_levelSelectText];


    /*
    _levelPanelText = [CCLabelBMFont labelWithString:@"LEVEL 1" fntFile:@"GraphicFont.fnt"];
    [_levelPanelText setScale:0.5f];
    _levelPanelText.position = ccp(158,34.5f);
    [[[LayerManager sharedLayers] currentLayer] addChild:_levelPanelText];
    */
    [self loadTutorial];
    [[LayerManager sharedLayers] forgetWorkingLayer];
    [self scheduleUpdate];
    self.isTouchEnabled = true;    
    
}


-(void)popAndSwitchToLevel:(NSString*)level
{
    [[GameSettings shared] setGlobal:@"NO" ForKey:@"titleMusicStarted"];
    [[GameSettings shared] setGlobal:level ForKey:@"startingLevel"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameLayer scene]]];
}

-(void)switchToMainMenu
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[MainMenuScene scene]]];
}

-(void)switchToTutorial
{
    if(!_inTutorial){
    [scroller setVisible:YES];
    scroller.showPagesIndicator=YES;
        _inTutorial=true;
    }
    else
    {
        [scroller setVisible:NO];
        scroller.showPagesIndicator=NO;
        _inTutorial=false;
    }
}

-(void)transitionOut
{
}

-(void)unload
{
}

-(void)onExit
{
    [self release];
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)update:(ccTime)dt
{
    [[SoundEngine shared] update:dt];

    [_startButton update:dt];
    [_backButton update:dt];
    [_closeTutorial update:dt];

    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        if(_waitToSwitch<=0.0f){
            _waitToSwitch = 0.0f;
            if (_backToMainMenu) {
                //[self switchToMainMenu];
                
                [self switchToTutorial];
            }  else {
                [self popAndSwitchToLevel:_levelToSwitchTo]; 
                            }
        }
    }
}

-(void)dealloc
{
    NSLog(@"Dealloc: ChooseLevelScreen");
    
    [_buttons removeAllObjects];
    _buttons = nil;
    [scroller release];
    [_closeTutorial release];
    [_background release];
    [_levelToSwitchTo release];
    [_levelSelectText release];
    [_startButton release];
    [_backButton release];
    [_selector release];
    
    [[TextureManager shared] unloadMemoryForKey:@"chooseLevel"];
}

@end
