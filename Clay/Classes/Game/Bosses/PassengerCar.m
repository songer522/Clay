//
//  PassengerCar.m
//  Clay
//
//  Created by Brian Cable on 1/11/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import "PassengerCar.h"
#import "Sprite.h"
#import "AnimationController.h"
#import "Animation.h"
#import "GameSettings.h"


@implementation PassengerCar

+(id)instance
{
    return [[self alloc] init];
}

-(id)init
{
    if((self = [super init])) {
        _boxcar = [Sprite spriteCenteredWithFrame:@"FinalBoss_1_Main_2.png" AddToLayer:NO];
        _wheels = [Sprite spriteWithFile:@"blank.png" AddToLayer:NO];
        [[AnimationController sharedController] replaceSprite:_wheels withAnimationNamed:@"darkBossPassengerWheelAnim"];
    }
    return self;
}

-(void)addToLayer:(id)layer
{
    [layer addChild:[_boxcar getCCSprite]];
    [layer addChild:[_wheels getCCSprite]];
}

-(void)setPosition:(CGPoint)position
{
    if ([[GameSettings shared] isIpad]) {
        _boxcarPosition = CGPointMake(position.x + 190.0f, position.y + 189.0f);
        _wheelsPosition = CGPointMake(position.x - 345.0f, position.y - 43.0f);
    } else {
        _boxcarPosition = CGPointMake(position.x, position.y);
        _wheelsPosition = CGPointMake(position.x - 265.0f, position.y - 118.0f);
    }
}

-(void)updatePosition:(CGPoint)attachedPosition
{
    [_boxcar setScreenPosition:ccpAdd(attachedPosition, _boxcarPosition)];
    [_wheels setScreenPosition:ccpAdd(attachedPosition, _wheelsPosition)];
}

-(void)changeAnimationSpeed:(float)speed
{
    [[_wheels getAnimation] changeAnimationSpeed:speed];
}

-(void)dealloc
{
    [_boxcar release];
    [_wheels release];
    [super dealloc];
}

@end
