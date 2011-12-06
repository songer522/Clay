//
//  PauseMenuScreen.m
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "PauseMenuScreen.h"
#import "LayerManager.h"
#import "GameController.h"
#import "GameLabel.h"
#import "Button.h"
#import "ActionButton.h"
#import "Sprite.h"
#import "SoundEngine.h"

@implementation PauseMenuScreen

@synthesize gameController = _gameController;

+(id)instance
{
    return [[self alloc] init];
}

//- (id)initWithColor:(ccColor4B)color
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
        
        _alpha = 0.0;
        [self scheduleUpdate];
        [[[LayerManager sharedLayers] currentScene] addChild:self];
        
        [[LayerManager sharedLayers] setWorkingLayer:self];

        _pausedText = [GameLabel gameLabelWithText:@"PAUSED" Scale:0.9f];
        [_pausedText setPosition:ccp(240,220)];
        
        _resumeButton = [ActionButton actionButtonInGameWithText:@"RESUME"];
        [_resumeButton setPosition:ccp(140,130)];
        
        
        _restartButton = [ActionButton actionButtonInGameWithText:@"RESTART"];
        [_restartButton setPosition:ccp(240,130)];
        
        _menuButton = [ActionButton actionButtonInGameWithText:@"MENU"];
        [_menuButton setPosition:ccp(340,130)];
        
        _waitToSwitch = -1.0f;
        
         [[LayerManager sharedLayers] forgetWorkingLayer];
         
        self.isTouchEnabled = YES;
    }

    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        
        if([_resumeButton checkIfSelected:position]) {
            [[SoundEngine shared] playSound:@"buttonPressed"];
            _action = PAUSE_ACTION_RESUME;
            _waitToSwitch = 0.25f;
        } else if([_restartButton checkIfSelected:position]) {
            //[_gameController pauseGame];
            [[SoundEngine shared] playSound:@"buttonPressed"];
        } else if([_menuButton checkIfSelected:position]) {
            [[SoundEngine shared] playSound:@"buttonPressed"];
        }
        
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
    
    GLubyte rectAlpha = floor(_alpha * 75);
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
    [self release];
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}


-(void)update:(ccTime)dt
{
    
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        
        
        if (_waitToSwitch<=0.0f) {
            _waitToSwitch = 0.0f;
            switch (_action) {
                case PAUSE_ACTION_RESUME:
                    [_gameController pauseGame];
                    break;
                default:
                    break;
            }
        }
        
        _alpha = 4.0f * _waitToSwitch;
        
    } else {
        _alpha += 3.0f * dt;
        if (_alpha > 1.0f) {
            _alpha = 1.0f;
        }        
    }
    
    [_label setOpacity:(int)(255 * _alpha)];
    
    [_resumeButton update:dt];
    [_restartButton update:dt];
    [_menuButton update:dt];
}

-(void)dealloc
{
    [_pausedText release];
    [_label release];
    _gameController = nil;
    //[super dealloc];
}

@end
