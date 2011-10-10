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
        
        _rain1 = [Sprite spriteWithFile:@"Menu_Rain_01.png"];
        [_rain1 getCCSprite].position = ccp(0, 0);
        
        _rain2 = [Sprite spriteWithFile:@"Menu_Rain_02.png"];
        [_rain2 getCCSprite].position = ccp(0, 0);
        
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
        
        _comics = [ComicLayer instance];
        
        
        
        
        _totalTime = 0.0f;
        _transitionTime = 0.0f;
        _transition = MAINMENU_TRANSITION_IN;
        
        
        
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
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

-(void)switchToTransitionOut
{
    _transitionTime = 0.0f;
    _transition = MAINMENU_TRANSITION_OUT;
    [_playButtonOrange setAlpha:0.0f];
    [[_playButtonOrange getCCSprite] setVisible:YES];
}

-(void)update:(ccTime)dt
{
    float rate = 4.0f * dt;
    
    _totalTime += rate;
    _transitionTime += 0.75f * dt;
    
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
            if (_transitionTime>=1.0f) {
                _transitionTime = 1.0f;
                _transition = MAINMENU_TRANSITION_IDLE;
            }
            [_logo move:ccp(0, rate)];
            [_logo setAlpha:_transitionTime];
            [_playButtonBlue setAlpha:_transitionTime];
            [_copyright move:ccp(0,-0.5f * rate)];
            [_copyright setAlpha:_transitionTime];
            break;
        case MAINMENU_TRANSITION_OUT:
            [_logo setAlpha:(1.0f - _transitionTime)];
            [_playButtonOrange setAlpha:(MAX(1.0f - 8.0f * _transitionTime, 0.0f))];
            [_playButtonBlue setAlpha:(MIN(1.0f,2.0f - 2.0f * _transitionTime))];
            if (_transitionTime >=1.0f) {
                [[CCDirector sharedDirector] popScene];
            }
            
            float position = 160.0f * _transitionTime;
            float scale = [[UIScreen mainScreen] scale];
            [self ccDrawFilledRectFrom:ccp(0,0) To:ccp(960,position * scale)];
            [self ccDrawFilledRectFrom:ccp(0,640) To:ccp(960,(320.0f - position) * scale)];
        default:
            break;
    }
}

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2
{
    CGPoint poli[] = {v1, CGPointMake(v1.x,v2.y),v2,CGPointMake(v2.x,v1.y)};
    
    glColor4ub(0, 0, 0, 255);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glVertexPointer(2, GL_FLOAT, 0, poli);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
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
