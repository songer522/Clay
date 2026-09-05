//
//  Lightning.m
//  Clay
//
//  Created by Brian Cable on 12/1/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Lightning.h"
#import "Sprite.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Camera.h"
#import "SoundEngine.h"
#import "LayerManager.h"
#import "Player.h"

#define LIGHTNING_PARALLAX_RATIO 0.9f

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERY (IS_IPAD ? 2.4f : 1.0f)

// Strikes were spread over a hardcoded 480-wide span, so on iPad every bolt landed in the
// left 380pt of a 1024pt screen. Spread them across the live width instead, keeping the
// legacy 50..380 span exactly at 480.
static CGFloat LightningSpanStart(void)
{
    return 50.0f * ([[CCDirector sharedDirector] winSize].width / 480.0f);
}

static CGFloat LightningSpanWidth(void)
{
    return 330.0f * ([[CCDirector sharedDirector] winSize].width / 480.0f);
}

@implementation Lightning


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
        
        _inLightning = false;
        //[self repositionSprite];
        [_sprite setAlpha:0.0f];
        
        
        _waitUntilNewStrike = 4.0f + rand()%5;
        
        _player = [[LayerManager sharedLayers] getPlayer];
    }
    
    return self;
}


-(void)update:(float)dt
{
    if (_waitUntilNewStrike >0.0f) {
        _waitUntilNewStrike-=dt;
        if (_waitUntilNewStrike<=0.0f) {
            [self startStrike];
        }
    } else {
        _timeIntoAnimation+=dt;
        
        //full alpha until 0.7seconds, then 50% opacity for 0.1 seconds, then 100% opacity for 0.1 seconds, then 50% opacity for 0.1 seconds.
        
        if(_timeIntoAnimation>=1.0f) {
            [self endStrike];
        } else if (_timeIntoAnimation>=0.9f) {
            [_sprite setAlpha:0.5f];
        } else if (_timeIntoAnimation>=0.8f) {
            [_sprite setAlpha:1.0f];
        } else if (_timeIntoAnimation>=0.7f) {
            [_sprite setAlpha:0.5f];
        } 
    }
    
    if (_inLightning) {
        
        float camPositionX = [[Camera sharedCamera] xPosition];
        float newPosX = (camPositionX - _originalCamPositionX) * LIGHTNING_PARALLAX_RATIO;
        
        // The 2.4 here was MULTIPLIERY applied on every device, so on a phone the bolt was
        // drawn at 2.4x its own world y.
        CGPoint lightningParallaxPosition = CGPointMake(_position.x + newPosX, _position.y * MULTIPLIERY);
        //NSLog(@"LX: %.2f, PLX: %.2f, RAX: %.2f",_position.x,playerPosition.x,lightningParallaxPosition.x);
        [_sprite setPosition:lightningParallaxPosition];
    }
}

-(void)startStrike
{
    [[SoundEngine shared] playSound:@"lightning"];
    
    int lightningAnim = rand()%3;
    
    if (lightningAnim == 0) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"rainyLightning1Anim"];
    } else if(lightningAnim == 1) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"rainyLightning2Anim"];
    } else if(lightningAnim == 2) {
        [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"rainyLightning3Anim"];
    }
    
    _inLightning = true;
    [self repositionSprite];
    [_sprite setAlpha:1.0f];
    [[_sprite getCCSprite] setVisible:YES];
    _timeIntoAnimation = 0.0f;
    
}

-(void)endStrike
{
    [[_sprite getCCSprite] setVisible:NO];
    _waitUntilNewStrike = 6.0f + rand()%6;
    _inLightning = false;
}

-(void)repositionSprite
{
    //a random position in the background at a height where the top of the lightning bolt is
    //just off the top of the screen. Was a hardcoded 50 + rand()%330, a 480-wide span.
    int span = (int)LightningSpanWidth();
    if (span < 1) { span = 1; }
    _position = [[Camera sharedCamera] convertToWorldXY:ccp(LightningSpanStart() + (rand() % span), 193)];
    _originalCamPositionX = [[Camera sharedCamera] xPosition];
    [_sprite setPosition:_position];
}

-(void)dealloc
{
    [_sprite release];
    [super dealloc];
}

@end
