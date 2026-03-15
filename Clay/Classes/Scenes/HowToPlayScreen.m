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
#import "GameSettings.h"
#import "TextureManager.h"
#import "OptionsScene.h"
#import "GameLayer.h"
#import "SoundEngine.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

static CGPoint HowToPlayLegacyPhoneOffset(void)
{
    if (IS_IPAD) {
        return CGPointZero;
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return ccp(MAX(0.0f, floorf((winSize.width - 480.0f) / 2.0f)), 0.0f);
}

static CGPoint HowToPlayPhonePoint(CGFloat x, CGFloat y)
{
    CGPoint offset = HowToPlayLegacyPhoneOffset();
    return ccp(offset.x + x, offset.y + y);
}

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
        [_background setScreenPosition:HowToPlayLegacyPhoneOffset()];
        
        _tutorial = [[Tutorial alloc] initWithinLayer:self];
        [_tutorial switchToTutorial];
        
        _backButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
        [_backButton setInitialText:@"BACK"];
        [_backButton setPosition:HowToPlayPhonePoint(50 *MULTIPLIERX, 18*MULTIPLIERY)];
        
        _header = [GameLabel gameLabelWithText:@"HOW TO PLAY" Scale:0.65f];
        [_header setPosition:HowToPlayPhonePoint(375.0f*MULTIPLIERX,284.0f*MULTIPLIERY)];
        
        
        
        _startButton = [ActionButton actionButtonCustomGraphicsForIdle:@"UI_GameType_ButtonS_Blue.png" Selected:@"UI_GameType_ButtonS_Green.png"];
        [_startButton setInitialText:@"NEXT"];
        [_startButton setPosition:HowToPlayPhonePoint(430*MULTIPLIERX,18*MULTIPLIERY)];
        
        NSString *preTutorial = [[GameSettings shared] getGlobalForKey:@"preTutorialScreen"];
        if ([preTutorial isEqualToString:@"options"]) {
            [_startButton setEnabled:true];
            _switchToGame = false;
            _startButtonText = [NSString stringWithString:@"AGAIN"];
        } else {
            [_backButton setEnabled:false];
            _switchToGame = true;
            _startButtonText = [NSString stringWithString:@"START"];
        }
        
        [[LayerManager sharedLayers] forgetWorkingLayer];
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;

        
        _currentScreen = 0;
        
        _canStart = false;
        
        _hasSwitched = false;
        
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
            [[SoundEngine shared] playSound:@"guiSelectionBack"];     
        } else if([_startButton checkIfSelected:position]) {
            if (_canStart) {
                [self cueStartAction];                
            } else {
                [self nextPage];
            }
        }
    }
}

-(void)nextPage
{
    int currentPage = [_tutorial currentPage] + 1;
    [_tutorial switchToPage:currentPage];
    [[SoundEngine shared] playSound:@"guiSelectionForward"];
}

-(void)updateStartButton
{
    int currentPage = [_tutorial currentPage];
    int maxPage = ([_tutorial totalPages] - 1);
    
    if (_canStart) {
        if (currentPage < maxPage) {
            [_startButton setText:@"NEXT"];
            _canStart = false;
        }
    } else {
        if (currentPage >= maxPage) {
            
            [_startButton setText:_startButtonText];
            _canStart = true;
        }
    }
}

-(void)cueStartAction
{
    if ([_startButtonText isEqualToString:@"START"]) {
        [[SoundEngine shared] playSound:@"buttonPressed"];    
        _switchToGame = true;        
        _waitToSwitch = 0.25f;
    } else {
        _switchToGame = false;
        [_tutorial switchToPage:0];
        [[SoundEngine shared] playSound:@"guiSelectionForward"];
    }
    
}

-(void)update:(ccTime)dt
{
    [_backButton update:dt];
    [_startButton update:dt];
    
    [self updateStartButton];
    
    [_tutorial update:dt];
    
    if (!_hasSwitched && _waitToSwitch>0.0f) {
        _waitToSwitch-=dt;
        if(_waitToSwitch<=0.0f){
            _waitToSwitch = 0.0f;
            if (_switchToGame) {
                [self switchToGameScreen];
                _hasSwitched = true;
            } else {
                [self switchToOptionsScreen];
                _hasSwitched = true;
            }
        }
    }
}

-(void)switchToGameScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GameLayer scene]]];
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
