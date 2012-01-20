//
//  EndLevelScene.m
//  Clay
//
//  Created by Song Yang on 1/13/12.
//  Copyright (c) 2012 XecuDev. All rights reserved.
//

#import "EndlevelScene.h"
#import "LayerManager.h"
#import "TrackTimer.h"
#import "Sprite.h"
#import "GameLayer.h"
#import "HudLayer.h"
#import "UserData.h"

#import "TextureManager.h"
#import "GameSettings.h"
#import "GCHelper.h"
#import "GCState.h"
#import "ActionButton.h"
#import "SoundEngine.h"
#import "EndGameScene.h"

@implementation EndLevelScene


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	EndLevelScene *layer = [EndLevelScene node];
	
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
        
        
        _state = END_LEVEL_TRANSITION_IN;
        _alpha = 0.0f;
        
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
               
        _endGameComic = [Sprite spriteWithFile:@"Comic_11.png"];
                
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        
        [_endGameComic setAlpha:0.0f];
        
        
        _initialized = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = true;
        
    }
    
    return self;
}



-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    if (_state == END_LEVEL_TRANSITION_IDLE) {
        bool shouldStart = false;
        NSSet *allTouches = [event allTouches];
        for(UITouch *touch in allTouches) {
            shouldStart = true;
        }
        
        if (shouldStart) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[EndGameScene scene]]];
        }
    }
}

-(void)update:(ccTime)dt
{
    float rate = 2.0f * dt;
        

    
    
    
    

    switch (_state) {
        case END_LEVEL_TRANSITION_IN:
            _alpha += rate;
            if (_alpha >= 1.0f) {
                _alpha = 1.0f;
                _state = END_LEVEL_TRANSITION_IDLE;
            }
            [_endGameComic setAlpha:_alpha];
        
            break;
        case END_LEVEL_TRANSITION_OUT:
            break;
        default:
            break;
    }
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)dealloc
{
    //NSLog(@"Dealloc: EndGameScene");
    
    [_endGameComic release];

    
}


@end
