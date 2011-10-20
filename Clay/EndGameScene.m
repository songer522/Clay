//
//  EndGameScene.m
//  Clay
//
//  Created by Brian Cable on 10/12/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "EndGameScene.h"
#import "LayerManager.h"
#import "ComicLayer.h"
#import "TrackTimer.h"
#import "Sprite.h"
#import "GameLayer.h"
#import "HudLayer.h"
#import "UserData.h"

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
        
        _endGame = [Sprite spriteWithFile:@"Menu_Ending_Temp.png"];
        
        _timer = [TrackTimer instance];
        [_timer setupAnimationsAtX:232.0f Y:145.0f];
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        
        [_endGame setAlpha:0.0f];
        [_timer setAlpha:0.0f];
        
        _initialized = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = true;
        
    }
    
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
    if (_state == END_GAME_TRANSITION_IDLE) {
        bool shouldStart = false;
        NSSet *allTouches = [event allTouches];
        for(UITouch *touch in allTouches) {
            shouldStart = true;
        }
        
        if (shouldStart) {
            _state = END_GAME_TRANSITION_OUT;
        }
    }
     */
}

-(void)update:(ccTime)dt
{
    float rate = 2.0f * dt;
    
    if (!_initialized) {
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        float _finalTime = [[[gameLayer getHud] getTrackTimer] getTime];
        if ([[UserData sharedInstance] bestTime] > _finalTime)
        {
            [UserData sharedInstance].bestTime = _finalTime;
            [[UserData sharedInstance] save];
        }
        [_timer setTime:_finalTime];
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
            [_timer setAlpha:_alpha];
            break;
        case END_GAME_TRANSITION_OUT:
            _alpha -= rate;
            if (_alpha <= 0.0f) {
                _alpha = 0.0f;
                [[LayerManager sharedLayers] popAndPushSceneNamed:@"menu"];
                [self unscheduleUpdate];
            }
            [_endGame setAlpha:_alpha];
            [_timer setAlpha:_alpha];
            break;
        default:
            break;
    }
}


@end
