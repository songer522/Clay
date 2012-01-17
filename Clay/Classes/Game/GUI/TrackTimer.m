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
#import "TextureManager.h"


#define TRACK_TIMER_STARTX 10
#define TRACK_TIMER_STARTY 288.5
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
       // [[TextureManager shared] loadMemoryForKey:@"hud"];
        
        _levelTime = 0.0f;
        _isStopped = false;
        _totalTime = 0.0f;
        _totalTimeBeforeLevel = 0.0f;
        
        //instantiate frame numbers
        for(int i=0;i<7;i++)
        {
            _currentTimerFrameNumbers[i] = -1;
        }
    }
    
    return self;
}

-(void)setupAnimationsAtX:(float)x Y:(float)y
{
    float _currentX = x;
    
    _timerAnimations = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i=0; i<5; i++) {
        Sprite *sprite2 = [Sprite spriteWithFile:@"blank.png"];
        [sprite2 getCCSprite].position = ccp(_currentX, y);
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
    [sprite getCCSprite].position = ccp(_currentX, y);
    [[AnimationController sharedController] replaceSprite:sprite withAnimationNamed:@"smallTimer"];
    [[sprite getAnimation] togglePauseAnimation];
    [_timerAnimations addObject:sprite];
    
    _currentX += 11;
    
    sprite = [Sprite spriteWithFile:@"blank.png"];
    [sprite getCCSprite].position = ccp(_currentX, y);
    [[AnimationController sharedController] replaceSprite:sprite withAnimationNamed:@"smallTimer"];
    [[sprite getAnimation] togglePauseAnimation];
    [_timerAnimations addObject:sprite];
    
    
    
    
}

-(void)update:(float)dt
{
    if (!_isStopped) {
        _totalTime += dt;
        _levelTime += dt;
        [self setTimerSprites];
        
    }
}

-(void)setTime:(float)time
{
    _totalTime = time;
    [self setTimerSprites];
}

-(float)getTime
{
    return _totalTime;
}

-(void)setAlpha:(float)alpha
{
    for (Sprite *sprite in _timerAnimations) {
        [sprite setAlpha:alpha];
    }
}

-(void)startLevel
{
    _levelTime = 0.0f;
    _totalTimeBeforeLevel = _totalTime;
}

-(void)restartLevel
{
    _levelTime = 0.0f;
    _totalTime = _totalTimeBeforeLevel;
}

-(float)getLevelTime
{
    return _levelTime;
}

//TODO: milliseconds should be 3 characters, not 2
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

//TODO: milliseconds should be 3 characters, not 2
+(NSString*)getTimeStringFromFloat:(float)time
{
    int seconds = ((int)floorf(time)) % 60;
    int minutes = ((int)floorf(time)) / 60;
    int milliseconds = floor((time - (int)time) * 100);
    
    NSMutableString *timeString = [[NSMutableString alloc] initWithCapacity:10];
    
    //minutes
    if (minutes < 10) {
        [timeString appendString:@"0"];
    }
    [timeString appendFormat:@"%d:",minutes];
    
    //seconds
    if (seconds < 10) {
        [timeString appendString:@"0"];
    }
    [timeString appendFormat:@"%d:",seconds];
    
    //milliseconds
    if (milliseconds < 10) {
        [timeString appendString:@"0"];
    }
    [timeString appendFormat:@"%d",milliseconds];

    return timeString;
}

-(void)setSpriteAtIndex:(int)index withNumber:(int)number
{
    if (_currentTimerFrameNumbers[index] == number) { return; }

    _currentTimerFrameNumbers[index] = number;
    
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
   // [[TextureManager shared] unloadMemoryForKey:@"hud"];
    [super dealloc];
}

@end
