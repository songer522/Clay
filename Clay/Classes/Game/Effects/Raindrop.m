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
        }
    }
    
    
    _prevFrame = currentFrame;
}

-(void)repositionSprite
{
    [_sprite setScreenPosition:ccp(140 + rand()%420, rand()%16 + 20)];
}

-(void)dealloc
{
    [_sprite release];
    [super dealloc];
}

@end
