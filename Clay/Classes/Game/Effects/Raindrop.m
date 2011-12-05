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
    //IPAD FIX: should be positioned at a random position on the track in front of Tim with enough of a gap that the raindrop disappears before it reaches Tim's position most of the time.
    _position = [[Camera sharedCamera] convertToWorldXY:ccp(180 + rand()%420,0)];
    _position.y = rand()%32 + 42; //world position for y so it stays with the track even when tim is on the ledges
    
    //[_sprite setScreenPosition:_position];
    [_sprite setPosition:_position];
}

-(void)dealloc
{
    [_sprite release];
    [super dealloc];
}

@end
