//
//  Raindrop.m
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Raindrop.h"
#import "Sprite.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Camera.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERY (IS_IPAD ? 2.4f : 1.0f)

// Drops were spread over a hardcoded 180..940 screen span - a 940pt range authored for the
// iPad - so on a phone most of them spawned off the right edge. Spread them across the live
// width instead, keeping the legacy span exactly at 1024.
static CGFloat RaindropSpanStart(void)
{
    return 180.0f * ([[CCDirector sharedDirector] winSize].width / 1024.0f);
}

static CGFloat RaindropSpanWidth(void)
{
    return 760.0f * ([[CCDirector sharedDirector] winSize].width / 1024.0f);
}

@implementation Raindrop


+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _sprite = [Sprite spriteWithFile:@"blank.png"];
        [self repositionSprite];
        [_sprite setAlpha:1.0f];

        _waitToLoadAnim = ((float)rand() / RAND_MAX) + 0.1f;
    }
    
    return self;
}


-(void)update:(float)dt
{
    int currentFrame = [[_sprite getAnimation] getCurrentFrameNumber];
    
    if (_waitToLoadAnim > 0.0f) {
        _waitToLoadAnim -= dt;
        if (_waitToLoadAnim<=0.0f) {
            [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"rainyRaindropAnim"];
        }
    } else {
        //if the animation has restarted, reposition the sprite
        if (currentFrame == 1 && _prevFrame != 1) {
            [self repositionSprite];            
        } else {
            [_sprite setPosition:_position];
        }
    }
    
    
    _prevFrame = currentFrame;
}

-(void)repositionSprite
{
    //a random position on the track in front of Tim with enough of a gap that the raindrop
    //disappears before it reaches Tim's position most of the time.
    int span = (int)RaindropSpanWidth();
    if (span < 1) { span = 1; }
    _position = [[Camera sharedCamera] convertToWorldXY:ccp(RaindropSpanStart() + (rand() % span),0)];
    //world position for y so it stays with the track even when tim is on the ledges. The 2.4
    //was MULTIPLIERY applied on every device, which floated the drops ~40-70pt above a
    //phone's track.
    _position.y = rand()%32 + 42*MULTIPLIERY;
    
    //[_sprite setScreenPosition:_position];
    [_sprite setPosition:_position];
}

-(void)dealloc
{
    [_sprite release];
    [super dealloc];
}

@end
