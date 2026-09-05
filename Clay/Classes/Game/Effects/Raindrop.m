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

#define RAINDROP_Z_ABOVE_MAP 5

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

        // The ripples are ground splashes drawn at track height, and Sprite adds them to the
        // GameLayer at the default z == 0. Every TMX map layer is also z == 0 - Level.m's
        // `currentZ += 1` is commented out - so ordering falls back to insertion order, and
        // RainyLevelEffects is constructed part-way through loadLayers (at the `ledges`
        // entry). Everything added after it, including the front-1 foreground art, therefore
        // painted straight over the rain and it was invisible on every device.
        //
        // Lift them above the map. z == 0 for every other node means there is no value that
        // sits above the track art but below the player, so the ripples draw over him too;
        // that is the lesser evil against not rendering at all.
        //
        // The lightning escaped this only by luck: it draws up in the sky, where the layers
        // added after it have no opaque art.
        [[[_sprite getCCSprite] parent] reorderChild:[_sprite getCCSprite] z:RAINDROP_Z_ABOVE_MAP];

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
