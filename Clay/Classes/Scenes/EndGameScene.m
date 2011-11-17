//
//  EndGameScene.m
//  Clay
//
//  Created by Brian Cable on 10/12/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "EndGameScene.h"
#import "LayerManager.h"
#import "TrackTimer.h"
#import "Sprite.h"
#import "GameLayer.h"
#import "HudLayer.h"
#import "UserData.h"
#import "MainMenuScene.h"
#import "TextureManager.h"
#import "GameSettings.h"

@implementation EndGameScene


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	EndGameScene *layer = [EndGameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        
        _state = END_GAME_TRANSITION_IN;
        _alpha = 0.0f;
        
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"endGame"];
        
        _endGame = [Sprite spriteFromFrameCacheWithName:@"Menu_Ending_Temp.png"];
        _bestTime = [Sprite spriteFromFrameCacheWithName:@"Menu_Ending_BestTime.png"];
        [_bestTime getCCSprite].position = ccp(350.0f, 145.0f);
        _timer = [TrackTimer instance];
        [_timer setupAnimationsAtX:232.0f Y:125.0f];
        
        _besttimer = [TrackTimer instance];
        [_besttimer setupAnimationsAtX:232.0f Y:145.0f];
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        
        [_endGame setAlpha:0.0f];
        [_bestTime setAlpha:0.0f];
        [_timer setAlpha:0.0f];
        [_besttimer setAlpha:0.0f];
        
        _initialized = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = true;
        
    }
    
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (_state == END_GAME_TRANSITION_IDLE) {
        bool shouldStart = false;
        NSSet *allTouches = [event allTouches];
        for(UITouch *touch in allTouches) {
            shouldStart = true;
        }
        
        if (shouldStart) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[MainMenuScene scene]]];
        }
    }
}

-(void)update:(ccTime)dt
{
    float rate = 2.0f * dt;
    
    if (!_initialized) {
        float finalTime = [[[GameSettings shared] getGlobalForKey:@"finalTime"] floatValue];
        if ([[UserData sharedInstance] bestTime] > finalTime)
        {
            [UserData sharedInstance].bestTime = finalTime;
            [[UserData sharedInstance] save];
        }
        else if ([[UserData sharedInstance] bestTime] == 0.0f)
        {
            [UserData sharedInstance].bestTime = finalTime;
            [[UserData sharedInstance] save];
        }
        [_timer setTime:finalTime];
        [_besttimer setTime:[[UserData sharedInstance] bestTime]];
        _initialized = true;
    }
    
    switch (_state) {
        case END_GAME_TRANSITION_IN:
            _alpha += rate;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                _state = END_GAME_TRANSITION_IDLE;
            }
            [_endGame setAlpha:_alpha];
            [_bestTime setAlpha:_alpha];
            [_timer setAlpha:_alpha];
            [_besttimer setAlpha:_alpha];
            break;
        case END_GAME_TRANSITION_OUT:
            break;
        default:
            break;
    }
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;

    [self release];
}

-(void)dealloc
{
    NSLog(@"Dealloc: EndGameScene");
    
    [_endGame release];
    [_bestTime release];
    [_timer release];
    [_besttimer release];
    [[TextureManager shared] unloadMemoryForKey:@"endGame"];
}


@end
