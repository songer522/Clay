//
//  TrackTimer.m
//  Clay
//
//  Created by Brian Cable on 10/10/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "TrackTimer.h"
#import "LayerManager.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Sprite.h"

#define TRACK_TIMER_STARTX 10
#define TRACK_TIMER_STARTY 292
#define TRACK_TIMER_WIDTH 20

@implementation TrackTimer

@synthesize isStopped = _isStopped;

+(TrackTimer*) instance
{
    return [[self alloc] init];    
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _isStopped = false;
        
        [self setupAnimations];
        
    }
    
    return self;
}

-(void)setupAnimations
{
    float _currentX = TRACK_TIMER_STARTX;
    
    _timerAnimations = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i=0; i<5; i++) {
        Sprite *sprite2 = [Sprite spriteWithFile:@"blank.png"];
        [sprite2 getCCSprite].position = ccp(_currentX, TRACK_TIMER_STARTY);
        [[AnimationController sharedController] replaceSprite:sprite2 withAnimationNamed:@"largeTimer"];
        [[sprite2 getAnimation] togglePauseAnimation];
        [_timerAnimations addObject:sprite2];
        
        //[sprite2 setFrame:9];
        
        if (i == 1) {
            _currentX += 14;
        } else if(i == 2) {
            _currentX += 15;
            [sprite2 setFrame:10];
        } else {
            _currentX += TRACK_TIMER_WIDTH;
        }
    }
    
    _currentX -= 3;

    Sprite *sprite = [Sprite spriteWithFile:@"blank.png"];
    [sprite getCCSprite].position = ccp(_currentX, TRACK_TIMER_STARTY);
    [[AnimationController sharedController] replaceSprite:sprite withAnimationNamed:@"smallTimer"];
    [[sprite getAnimation] togglePauseAnimation];
    [_timerAnimations addObject:sprite];
    
    _currentX += 11;
    
    sprite = [Sprite spriteWithFile:@"blank.png"];
    [sprite getCCSprite].position = ccp(_currentX, TRACK_TIMER_STARTY);
    [[AnimationController sharedController] replaceSprite:sprite withAnimationNamed:@"smallTimer"];
    [[sprite getAnimation] togglePauseAnimation];
    [_timerAnimations addObject:sprite];
    
    
    
    
}

-(void)update:(float)dt
{
    if (!_isStopped) {
        _totalTime += dt;
        
        [self setTimerSprites];
        
    }
}

-(void)setTimerSprites
{
    int seconds = ((int)floorf(_totalTime)) % 60;
    int minutes = ((int)floorf(_totalTime)) / 60;
    int milliseconds = floor((_totalTime - (int)_totalTime) * 100);

    //minutes
    if (minutes < 10) {
        [self setSpriteAtIndex:0 withNumber:0];
    } else {
        [self setSpriteAtIndex:0 withNumber:((int)floor(minutes / 10))];
    }
    
    [self setSpriteAtIndex:1 withNumber:(minutes % 10)];
    
    //seconds
    if (seconds < 10) {
        [self setSpriteAtIndex:3 withNumber:0];
    } else {
        [self setSpriteAtIndex:3 withNumber:((int)floor(seconds / 10))];
    }
    
    [self setSpriteAtIndex:4 withNumber:(seconds % 10)];
    
    if (milliseconds < 10) {
        [self setSpriteAtIndex:5 withNumber:0];
    } else {
        [self setSpriteAtIndex:5 withNumber:((int)floor(milliseconds / 10))];
    }
    
    [self setSpriteAtIndex:6 withNumber:(milliseconds % 10)];
    
}

-(void)setSpriteAtIndex:(int)index withNumber:(int)number
{
    Sprite *sprite = [_timerAnimations objectAtIndex:index];
    
    if (number == 0) {
        number = 10;
    }
    
    [[sprite getAnimation] setStaticFrame:number Sprite:sprite];
}

-(void)setOpacity:(int)opacity
{
    for (int i=0; i<7; i++) {
        Sprite *sprite = [_timerAnimations objectAtIndex:i];
        [[sprite getCCSprite] setOpacity:opacity];
    }
    
}

-(void)dealloc
{
    [_timerAnimations removeAllObjects];
    [_timerAnimations release];
    [super dealloc];
}

@end
