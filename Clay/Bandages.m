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
        sprite = [Sprite spriteWithFile:@"character_health.png"];
        offsetYWhenRunning = [[NSArray alloc] initWithObjects:N(0),N(1),N(0),N(-1),N(-2),N(0),N(2),N(0),N(-1),N(-1), nil];
        [self setFrame:1];
    }
    
    return self;
}

-(void) setFrame:(int)frameNumber
{
    NSString *number = [NSString stringWithFormat:@"%d",frameNumber];
    Animation *anim = [Animation animationFromPlist:@"character_health" forSequence:@"character_health_" FrameList:number];
    [sprite setAnimation:anim Delay:100.0f];
}

-(void)update:(float)dt Player:(Player*)player
{
    int frameNumber = [player.sprite getCurrentFrameNumber];
    float offsetY = [[offsetYWhenRunning objectAtIndex:frameNumber] floatValue] / 2.0f;
    NSLog(@"Frame: %d, OffsetY: %f",frameNumber, offsetY);
    [sprite setPositionAtX:player.x + 37 Y:player.y + offsetY];
    //NSLog(@"Frame: %d",frameNumber);
}

-(CCSprite*)getCCSprite
{
    return [sprite getCCSprite];
}

-(void)dealloc
{
    [sprite release];
    [offsetYWhenRunning release];
    [super dealloc];
}

@end
