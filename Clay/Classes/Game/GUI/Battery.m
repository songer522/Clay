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
#import "HealthIcon.h"

#define N(x) [NSNumber numberWithFloat: x]

//IPAD FIX: these numbers got moved and the battery was shifted a few pixels to the left
#define BATTERY_X 410.0f
#define BATTERY_Y 285.0f

@implementation Battery

@synthesize parent = _player;
@synthesize x = _x;
@synthesize y = _y;

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
        
        _healthIcons = [[NSMutableArray alloc] initWithCapacity:6];
        
        //set up health icons
        for (int i=0; i<6; i++) {
            HealthIcon *icon = [HealthIcon instance];
            [icon setHealthAnimTypeById:i];
            [icon setBattery:self];
            [_healthIcons addObject:icon];
        }
        
        [self setFrame:1];
        
        _x = BATTERY_X;
        _y = BATTERY_Y;
        
        [sprite setScreenPosition:ccp(BATTERY_X,BATTERY_Y)];
        
        _wasLowBattery = false;
    }
    
    return self;
}

-(void) changeValueBy:(int)amount
{
    //range for current frame is 1 - 5 (1 being full, 5 being killed), so positive amount = smaller frame
    int final = _currentFrame - amount;
    if (final < 1) {
        final = 1; //full
    } else if(final > 5) {
        final = 5; //empty
    }
    
    int diff = _currentFrame - final;
    
    if (diff > 0) {
        for (int i=0; i<(3 + diff); i++) {
            HealthIcon *icon = [_healthIcons objectAtIndex:i];
            [icon startHealthAnimWithSprite:HEALTHICON_POSITIVE];
        }
    } else if(diff < 0) {
        for (int i=0; i<(3 - diff); i++) {
            HealthIcon *icon = [_healthIcons objectAtIndex:i];
            [icon startHealthAnimWithSprite:HEALTHICON_NEGATIVE];
        }        
    }
}


-(void) adjustFrame:(int)amount
{
    [self setFrame:(_currentFrame - amount)];
}


-(void) setFrame:(int)frameNumber
{
    
    NSString *frameName = [NSString stringWithFormat:@"Battery_%d.png",frameNumber];
    [[sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
    
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
    
    for (HealthIcon *icon in _healthIcons) {
        [icon update:dt];
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

-(void)setPlayer:(Player*)player
{
    _player = player;
    for (HealthIcon *icon in _healthIcons) {
        [icon setPlayer:player];
    }
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
