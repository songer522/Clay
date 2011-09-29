//
//  Bandages.m
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Bandages.h"
#import "BaseClasses.h"
#import "Player.h"

#define N(x) [NSNumber numberWithFloat: x]

@implementation Bandages

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
        sprite = [Sprite spriteWithFile:@"Battery_v1_s.png"];
        [self setFrame:1];
        [sprite setPositionAtX:625 Y:343];

    }
    
    return self;
}

-(void) setFrame:(int)frameNumber
{
    NSString *number = [NSString stringWithFormat:@"%d",frameNumber];
    Animation *anim = [Animation animationFromPlist:@"Battery_v2_s" forSequence:@"Battery_" FrameList:number];
    [sprite setAnimation:anim Delay:100.0f];
    _currentFrame = frameNumber;
    if (_currentFrame == 3) {
        _totalTime = 0.0f;
        [[sprite getCCSprite] setOpacity:255];
    } else {
        [[sprite getCCSprite] setVisible:YES];
    }
    _wait = 3.0f;
    _alpha = 1.0f;
    _waitToIncrease = 7.0f;
}

-(void)update:(float)dt
{
    if (_isRecharging) {
        [self recharging:dt];
    } else {
        _waitToIncrease -= dt;
        if (_waitToIncrease <=0.0f) {
            [_player changeHealth:1];
            _waitToIncrease = 6.0f;
        }
        
        if (_currentFrame == 3) {
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
    [self setFrame:4];
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
            _wait = 0.2f;
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
    [[sprite getCCSprite] setOpacity:255];
    [[sprite getCCSprite] setVisible:YES];
}

-(void)dealloc
{
    [sprite release];
    [super dealloc];
}

@end
