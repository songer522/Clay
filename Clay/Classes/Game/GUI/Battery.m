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

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
#define N(x) [NSNumber numberWithFloat: x]
#define LEGACY_PHONE_WIDTH 480.0f
#define LEGACY_PHONE_HEIGHT 320.0f
#define LEGACY_IPAD_WIDTH 1024.0f
#define LEGACY_IPAD_HEIGHT 768.0f

//IPAD FIX: these numbers got moved and the battery was shifted a few pixels to the left
#define BATTERY_X 397.0f //was 410.0f
#define BATTERY_Y 285.0f

static CGPoint BatteryScreenPosition(void)
{
    if (IS_IPAD) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGFloat x = winSize.width - (LEGACY_IPAD_WIDTH - (BATTERY_X * MULTIPLIERX));
        CGFloat yOffset = MAX(winSize.height - LEGACY_IPAD_HEIGHT, 0.0f);
        return ccp(x, (BATTERY_Y * MULTIPLIERY) + yOffset);
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float x = winSize.width - (LEGACY_PHONE_WIDTH - BATTERY_X);
    float y = BATTERY_Y + MAX((winSize.height - LEGACY_PHONE_HEIGHT) * 0.5f, 0.0f);
    return ccp(x, y);
}

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
        
        _healthIcons = [[NSMutableArray alloc] initWithCapacity:8];
        _batterySpriteFrames = [[NSMutableArray alloc] initWithCapacity:7];
        
        for (int i=0; i<7;i++) {
            //starts at 0 just so we can directly access the object quickly
            NSString *frameName = [NSString stringWithFormat:@"Battery_%d.png",i];
            [_batterySpriteFrames addObject:frameName];
        }
        
        //set up health icons
        for (int i=0; i<8; i++) {
            HealthIcon *icon = [HealthIcon instance];
            [icon setHealthAnimTypeById:i];
            [icon setBattery:self];
            [_healthIcons addObject:icon];
        }
        
        [self setFrame:1 Resetting:NO];
        
        CGPoint screenPosition = BatteryScreenPosition();
        _x = screenPosition.x;
        _y = screenPosition.y;
        [sprite setScreenPosition:screenPosition];
        
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
    } else if(final > 6) {
        final = 6; //empty
    }
    
    int diff = _currentFrame - final;

    if (diff > 0) {
        int start = MAX((3 - diff),0);
        for (int i=start; i<(3 + diff); i++) {
            @try {
                HealthIcon *icon = [_healthIcons objectAtIndex:i];
                [icon startHealthAnimWithSprite:HEALTHICON_POSITIVE];                
            }
            @catch (NSException *exception) {
                CCLOG(@"ERROR! Battery.m - Health Icon index: #%d",i);
            }

        }
    } else if(diff < 0) {
        int lessThan = MAX((3 - diff),0);
        for (int i=3; i<lessThan; i++) { //don't start from 0 because we don't want it to appear on Tim anymore for negative
            @try {
                HealthIcon *icon = [_healthIcons objectAtIndex:i];
                [icon startHealthAnimWithSprite:HEALTHICON_NEGATIVE];
                _isRecharging = false;
            }
            @catch (NSException *exception) {
                CCLOG(@"ERROR! Battery.m - Health Icon index: #%d",i);
            }
        }
    }
    [[sprite getCCSprite] setVisible:YES];

}


-(void) adjustFrame:(int)amount
{
    [self setFrame:(_currentFrame - amount) Resetting:NO];
}


-(void) setFrame:(int)frameNumber Resetting:(bool)resetting
{
    //guard
    if (frameNumber < 1 || frameNumber > 6) {
        return;
    }
    
    
    //should fix any lingering calls for displaying the battery on frame 6
    if (frameNumber == 6 && !resetting) {
        _player.isDead = true;
    }
    
    @try {
        [[sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[_batterySpriteFrames objectAtIndex:frameNumber]]];
    }
    @catch (NSException *exception) {
        CCLOG(@"ERROR! Battery.m - Battery Frame index: #%d",frameNumber);
    }
    
    
    _currentFrame = frameNumber;
    if (_currentFrame == 5) {
        if (!_isRecharging) {
            _totalTime = 0.0f;
            [[sprite getCCSprite] setOpacity:255];
            [[SoundEngine shared] playSound:@"lowBattery"];
            //disable sprint button in the hud
            _wasLowBattery = true;
            GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];            
            [[gameLayer getHud] setEnabled:false ForButton:HUD_BUTTON_SPRINT];
        } else {
            [[sprite getCCSprite] setVisible:YES];            
            [[sprite getCCSprite] setOpacity:255];
        }
    } else {
        
        //re-enable sprint button in the hud
        if (_wasLowBattery) {
            GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
            
            [[gameLayer getHud] setEnabled:true ForButton:HUD_BUTTON_SPRINT];
            _wasLowBattery = false;
        }
        
        [[sprite getCCSprite] setVisible:YES];
    }
    
    _wait = 3.0f;
    _alpha = 1.0f;
    
}

-(void)update:(float)dt
{
    if (_isRecharging) {
        [self recharging:dt];
    } else {
        if (_currentFrame == 5) {
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
    _totalTime += 14.0f * dt;
    float test = sinf(_totalTime);
    if (test < 0.3f) {
        [[sprite getCCSprite] setVisible:NO];
    } else {
        [[sprite getCCSprite] setVisible:YES];
    }
}

-(void)normalBattery:(float)dt
{
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
        [self setFrame:6 Resetting:YES];
        [self resetHealthIcons];
        [self changeValueBy:5];
    } else {
        [self changeValueBy:5];
    }
    _isRecharging = true;
    _alpha = 1.0f;
    [[sprite getCCSprite] setVisible:YES];
    [[sprite getCCSprite] setOpacity:255];
    _wait = 0.6f;
    _wasLowBattery = true;
}

-(void)recharging:(float)dt
{    
    if (_currentFrame<=1) {
        _isRecharging = false;
        _alpha = 1.0f;
    }
}




-(CCSprite*)getCCSprite
{
    return [sprite getCCSprite];
}

-(void)reset
{
    //[self setFrame:1];
    [self startRecharge];
    _wasLowBattery = false;
    [[sprite getCCSprite] setOpacity:255];
    [[sprite getCCSprite] setVisible:YES];
}

-(void)resetHealthIcons
{
    for (HealthIcon *icon in _healthIcons) {
        [icon reset];
    }
}

-(void)dealloc
{
    [_healthIcons removeAllObjects];
    [_healthIcons release];
    [_batterySpriteFrames removeAllObjects];
    [_batterySpriteFrames release];
    [sprite release];
    _player = nil;
    [super dealloc];
}

@end
