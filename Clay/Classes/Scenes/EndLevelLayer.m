//
//  EndLevelLayer.m
//  Clay
//
//  Created by Brian Cable on 1/11/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "EndLevelLayer.h"
#import "LayerManager.h"
#import "GameController.h"
#import "GameLabel.h"
#import "GameLayer.h"
#import "Button.h"
#import "ActionButton.h"
#import "Sprite.h"
#import "SoundEngine.h"
#import "GameSettings.h"
#import "Camera.h"
#import "LevelManager.h"
#import "SoundEngine.h"
#import "HudLayer.h"

@interface EndLevelLayer()

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2;
-(void) doButtonAction;

@end

@implementation EndLevelLayer

@synthesize gameController = _gameController;


+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {      

        _alpha = 0.0;
        _buttonPressed=false;
        [self scheduleUpdate];
        [[[LayerManager sharedLayers] currentScene] addChild:self];
        
        [[LayerManager sharedLayers] setWorkingLayer:self];
        
        _replayButton = [ActionButton actionButtonInGameWithText:@"REPLAY"];
        _menuButton = [ActionButton actionButtonInGameWithText:@"MENU"];
        
        //IPAD FIX: reposition so paused text is centered on x, and slightly above center on y, and buttons are side by side, with the middle button centered on x, and each one slightly below center on y
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float centerX = winSize.width/2.0f;
        float centerY = winSize.height/2.0f;
        [_replayButton setPosition:ccp(centerX,centerY - 30.0f)];
        [_menuButton setPosition:ccp(centerX + 115.0f,centerY - 30.0f)];
        
        
        _action = END_LEVEL_NONE;
        _waitToSwitch = -1.0f;
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        //[[SoundEngine shared] cueFadeOut];
        
        self.isTouchEnabled = YES;
    }
    
    return self;
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        
        if([_replayButton checkIfSelected:position]) {
            [[SoundEngine shared] playSound:@"buttonPressed"];
            _action = END_LEVEL_REPLAY;
            _waitToSwitch = 0.35f;
        } else if([_menuButton checkIfSelected:position]) {
            [[SoundEngine shared] playSound:@"buttonPressed"];
            _action = END_LEVEL_BACK;
            _waitToSwitch = 0.35f;
        }
        
        break;
    }
}

-(void) doButtonAction
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    NSString *gameMode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
    
    switch (_action) {
        case END_LEVEL_REPLAY:
            [self setVisible:false];
            [gameLayer unpause];
            [gameLayer initForLevel];
            gameLayer.inComic = false;
            gameLayer.visible = true;
            gameLayer.gameController.isInputEnabled = false;
            
            [[gameLayer getHud] fadeIn];
            _buttonPressed=true;
            
           // [gameLayer restartLevel];

                        
            break;
        case END_LEVEL_NONE:
            [_gameController pauseGame];
            
            if([gameMode isEqualToString:@"story"]) {
                [gameLayer switchToChooseMode];
            } else {
                [gameLayer switchToChooseLevel];
            }
            break;            
        default:
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
    
    GLubyte rectAlpha = floor(_alpha * 180);
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
    [[SoundEngine shared] update:dt];
    
    if (_waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        
        
        if (_waitToSwitch<=0.0f) {
            _waitToSwitch = 0.0f;
            if(!_buttonPressed)
            [self doButtonAction];
        }
        
        if (_action != END_LEVEL_BACK && _waitToSwitch<=0.20f) {
            _alpha = 5.0f * _waitToSwitch;            
        }
        
    } else {
        _alpha += 3.0f * dt;
        if (_alpha > 1.0f) {
            _alpha = 1.0f;
        }        
    }
    
    //set alpha for all elements
    
    [_replayButton setAlpha:_alpha];
    [_menuButton setAlpha:_alpha];
    
    [_replayButton update:dt];
    [_menuButton update:dt];
}

-(void)dealloc
{
    _gameController = nil;
    //[super dealloc];
}

@end
