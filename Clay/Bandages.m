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
        [sprite setPositionAtX:625 Y:420];
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
    _waitToFade = 3.0f;
    _alpha = 1.0f;
}

-(void)update:(float)dt Player:(Player*)player
{
    if (_currentFrame == 3) {
        _totalTime += 6.0f * dt;
        float test = sinf(_totalTime);
        if (test < 0.3f) {
            [[sprite getCCSprite] setVisible:NO];
        } else {
            [[sprite getCCSprite] setVisible:YES];
        }        
    } else {
        _waitToFade -= dt;
        if (_waitToFade <= 0.0f) {
            _alpha -= 1.0f * dt;
            if (_alpha <= 0.3f) {
                _alpha = 0.3f;
            }
        }
        [[sprite getCCSprite] setOpacity:(255 * _alpha)];
    }
}

-(CCSprite*)getCCSprite
{
    return [sprite getCCSprite];
}

-(void)reset
{
    [self setFrame:1];
}

-(void)dealloc
{
    [sprite release];
    [super dealloc];
}

@end
