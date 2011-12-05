//
//  Battery.m
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Battery.h"
#import "BaseClasses.h"
#import "Player.h"
#import "HudLayer.h"
#import "GameLayer.h"
#import "GameSettings.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
#define N(x) [NSNumber numberWithFloat: x]

@implementation Battery

@synthesize parent = _player;

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        sprite = [Sprite spriteWithFile:@"blank.png"];
        [self setFrame:1];
        
        [sprite setScreenPosition:ccp(412 * MULTIPLIERX,285 * MULTIPLIERY)];
        
        _wasLowBattery = false;
    }
    
    return self;
}

-(void) setFrame:(int)frameNumber
{
    
    NSString *number = [NSString stringWithFormat:@"%d",frameNumber];
    Animation *anim = [Animation animationFromPlist:@"battery" forSequence:@"Battery_" FrameList:number];
    [sprite setAnimation:anim Delay:100.0f];
    _currentFrame = frameNumber;
    if (_currentFrame == 4) {
        _totalTime = 0.0f;
        [[sprite getCCSprite] setOpacity:255];
        _waitToIncrease = 11.0f;
        [[SoundEngine shared] playSound:@"lowBattery"];
        
        //disable sprint button in the hud
        _wasLowBattery = true;
        GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
        
        [[gameLayer getHud] setEnabled:false ForButton:HUD_BUTTON_SPRINT];
    } else {
        
        //re-enable sprint button in the hud
        if (_wasLowBattery) {
            GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
            
            [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_SPRINT];
            _wasLowBattery = false;
        }
        
        [[sprite getCCSprite] setVisible:YES];
        _waitToIncrease = 5.0f;
    }
    
    _wait = 3.0f;
    _alpha = 1.0f;
     
}

-(void)update:(float)dt
{
    if (_isRecharging) {
        [self recharging:dt];
    } else {
        if(![_player getIsTurbo]) {
            _waitToIncrease -= dt;
        }
        if (_waitToIncrease <=0.0f) {
            //automatic recharging is currently disabled
            //[_player changeHealth:1];
        }
        
        if (_currentFrame == 4) {
            [self lowBatteryWarning:dt];
        } else {
            [self normalBattery:dt];
        }
    }
}

-(void)lowBatteryWarning:(float)dt
{
    _totalTime += 6.0f * dt;
    float test = sinf(_totalTime);
    if (test < 0.3f) {
        [[sprite getCCSprite] setVisible:NO];
    } else {
        [[sprite getCCSprite] setVisible:YES];
    }    
}

-(void)normalBattery:(float)dt
{
    _wait -= dt;
    if (_wait <= 0.0f) {
        _alpha -= 1.0f * dt;
        if (_alpha <= 0.3f) {
            _alpha = 0.3f;
        }
    }
    [[sprite getCCSprite] setOpacity:(255 * _alpha)];
}

-(void)startRecharge
{

    if(_player.isDead) {
        [self setFrame:5];
    }
    _isRecharging = true;
    _alpha = 1.0f;
    [[sprite getCCSprite] setVisible:YES];
    [[sprite getCCSprite] setOpacity:255];
    _wait = 0.6f;        

}

-(void)recharging:(float)dt
{
    if (_currentFrame > 1) {
        _wait -= dt;
        if (_wait <= 0.0f) {
            [self setFrame:_currentFrame - 1];
            _wait = 0.15f;
        }
    } else {
        _isRecharging = false;
        _wait = 3.0f;
        _alpha = 1.0f;
    }
}




-(CCSprite*)getCCSprite
{
    return [sprite getCCSprite];
}

-(void)reset
{
    [self setFrame:1];
    _isRecharging = false;
    _wasLowBattery = false;
    [[sprite getCCSprite] setOpacity:255];
    [[sprite getCCSprite] setVisible:YES];
}

-(void)dealloc
{
    [sprite release];
    _player = nil;
    [super dealloc];
}

@end
