//
//  HowToPlayScreen.m
//  Clay
//
//  Created by Brian Cable on 12/20/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "HowToPlayScreen.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "Tutorial.h"
#import "GameLabel.h"
#import "TextureManager.h"
#import "OptionsScene.h"
#import "SoundEngine.h"

@implementation HowToPlayScreen

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HowToPlayScreen *layer = [HowToPlayScreen layerWithScene:scene];
	
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
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"howtoplayScreen"];
        
        _background = [Sprite spriteFromFrameCacheWithName:@"HTP_Background.png"];
        
        _tutorial = [[Tutorial alloc] initWithinLayer:self];
        [_tutorial switchToTutorial];
            
        _backButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
        [_backButton setInitialText:@"BACK"];
        [_backButton setPosition:ccp(50, 18)];
        
        _header = [GameLabel gameLabelWithText:@"HOW TO PLAY" Scale:0.65f];
        [_header setPosition:ccp(375.0f,284.0f)];
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
        
        _waitToSwitch = 0.0f;
    }
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        if([_backButton checkIfSelected:position]) {
            _waitToSwitch = 0.25f;
            [[SoundEngine shared] playSound:@"buttonPressed"];     
        }
    }
}

-(void)update:(ccTime)dt
{
    [_backButton update:dt];
    
    [_tutorial update:dt];
    
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        if(_waitToSwitch<=0.0f){
            _waitToSwitch = 0.0f;
            [self switchToOptionsScreen];
        }
    }
}

-(void)switchToOptionsScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[OptionsScene scene]]];
}

-(void)dealloc
{
    [_background release];
    
    [_tutorial release];
    
    [[TextureManager shared] unloadMemoryForKey:@"howtoplayScreen"];
    
    [super dealloc];
}

@end
