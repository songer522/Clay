//
//  MainMenuScene.m
//  Clay
//
//  Created by Brian Cable on 10/7/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "MainMenuScene.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "ComicLayer.h"

@implementation MainMenuScene


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuScene *layer = [MainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        _trackBackground = [Sprite spriteWithFile:@"Menu_Background.png"];
        [_trackBackground getCCSprite].position = ccp(0,0);
        [_trackBackground setAlpha:1.0f];
        
        _rain1 = [Sprite spriteWithFile:@"Menu_Rain_01.png"];
        [_rain1 getCCSprite].position = ccp(0, 0);
        [_rain1 setAlpha:0.0f];
        
        _rain2 = [Sprite spriteWithFile:@"Menu_Rain_02.png"];
        [_rain2 getCCSprite].position = ccp(0, 0);
        [_rain2 setAlpha:0.0f];
        
        _logo = [Sprite spriteWithFile:@"Menu_Logo.png"];
        [_logo setAlpha:0.0f];
        [_logo getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_logo getCCSprite].position = ccp(240, 258); //final 240, 262
        
        _playButtonBlue = [Sprite spriteWithFile:@"Menu_PlayBlue.png"];
        [_playButtonBlue setAlpha:0.0f];
        [_playButtonBlue getCCSprite].anchorPoint = ccp(0.5f,0.5f);
        [_playButtonBlue getCCSprite].position = ccp(240, 142);
        
        _playButtonOrange = [Sprite spriteWithFile:@"Menu_PlayOrange.png"];
        [_playButtonOrange getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_playButtonOrange getCCSprite].position = ccp(240,142);
        [[_playButtonOrange getCCSprite] setVisible:NO];
        
        _copyright = [Sprite spriteWithFile:@"Menu_Copyright.png"];
        [_copyright setAlpha:0.0f];
        [_copyright getCCSprite].anchorPoint = ccp(0.5f, 0.5f);
        [_copyright getCCSprite].position = ccp(240,24); //final 240,20
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        
        _totalTime = 0.0f;
        _time = 0.0f;
        _transition = MAINMENU_TRANSITION_IN;
        
        
        _reinit = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
        
        _comics = [ComicLayer instance];
        
    }
    
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_transition == MAINMENU_TRANSITION_IDLE) {
        bool shouldStart = false;
        NSSet *allTouches = [event allTouches];
        for(UITouch *touch in allTouches) {
            shouldStart = true;
        }
        
        if (shouldStart) {
            [self switchToTransitionOut];
        }
    }
}

-(void)switchToTransitionIn
{
    _time = 0.0f;
    _totalTime = 0.0f;
    
    _transition = MAINMENU_TRANSITION_IN;
    [[_playButtonOrange getCCSprite] setVisible:YES];
    
    [_trackBackground setAlpha:1.0f];
    
    [_rain1 setAlpha:0.0f];
    
    [_rain2 setAlpha:0.0f];
    
    [_logo setAlpha:0.0f];

    [_playButtonBlue setAlpha:0.0f];
    [_playButtonOrange setAlpha:0.0f];
    
    [_copyright setAlpha:0.0f];
}


-(void)switchToTransitionOut
{
    _time = 0.0f;
    _transition = MAINMENU_TRANSITION_OUT;
    [_playButtonOrange setAlpha:0.0f];
    [[_playButtonOrange getCCSprite] setVisible:YES];
}

-(void)reinit
{
    [self switchToTransitionIn];    
    _reinit = false;
}

-(void)update:(ccTime)dt
{
    float rate = 6.0f * dt;
    
    _totalTime += rate;
    _time += 0.75f * dt;
    
    float rainFrame = _totalTime - ((int)_totalTime);
    if (rainFrame <= 0.5f) {
        [[_rain1 getCCSprite] setVisible:YES];
        [[_rain2 getCCSprite] setVisible:NO];
    } else {
        [[_rain1 getCCSprite] setVisible:NO];
        [[_rain2 getCCSprite] setVisible:YES];
    }
    
    switch (_transition) {
        case MAINMENU_TRANSITION_IN:
            if (_time>=1.0f) {
                _time = 1.0f;
                _transition = MAINMENU_TRANSITION_IDLE;
            }
            [_logo move:ccp(0, rate)];
            [_logo setAlpha:_time];
            [_playButtonBlue setAlpha:_time];
            [_copyright move:ccp(0,-0.5f * rate)];
            [_copyright setAlpha:_time];
            [_rain1 setAlpha:_time];
            [_rain2 setAlpha:_time];
            break;
        case MAINMENU_TRANSITION_OUT:
            [_logo setAlpha:(1.0f - _time)];
            [_rain1 setAlpha:(1.0f - _time)];
            [_rain2 setAlpha:(1.0f - _time)];
            [_copyright setAlpha:(1.0f - _time)];
            [_playButtonOrange setAlpha:(MAX(1.0f - 8.0f * _time, 0.0f))];
            [_playButtonBlue setAlpha:(MIN(1.0f,1.0f - 1.0f * _time))];
            if (_time >=1.0f) {
                _reinit = true;
                [self unscheduleUpdate];
                [[LayerManager sharedLayers] popAndPushSceneNamed:@"game"];
            }
            
            float position = 160.0f * _time;
            [_comics drawBars:position];
        default:
            break;
    }
}

-(void)dealloc
{
    [_trackBackground release];
    [_rain1 release];
    [_rain2 release];
    [_logo release];
    [_playButtonBlue release];
    [_playButtonOrange release];
    [_copyright release];
    [super dealloc];
}

@end
