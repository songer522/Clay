//
//  HealthIcon.m
//  Clay
//
//  Created by Brian Cable on 12/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "HealthIcon.h"
#import "Sprite.h"
#import "Player.h"

@implementation HealthIcon

+(id)healthIconWithPlayer:(Player*)player
{
    return [[self alloc] initWithPlayer:player];
}

-(id)initWithPlayer:(Player*)player
{
    if ((self=[super init])) {
        
        _sprite = [Sprite spriteCenteredWithFrame:@"Health_Sign_P.png"];
        _waitToStart = 0.0f;
        _animating = false;
    }
    return self;
}

-(void)startHealthAnimWithSprite:(HealthIconType)healthType AnimType:(HealthAnimType)healthAnimType
{
    _position = ccp(0,0);
    _angle = 0.0f;
    _animType = healthAnimType;
    _animating = true;
    _duration = 1.0f;
    
    switch (healthType) {
        case HEALTHICON_POSITIVE:
            [[_sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Health_Sign_P.png"]];
            break;
        case  HEALTHICON_NEGATIVE:
            [[_sprite getCCSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Health_Sign_P.png"]];
        default:
            CCLOG(@"HealthIcon.m - ERROR! Invalid health icon selected.");
            break;
    }
    
    switch (_animType) {
        case HEALTHANIM_PLAYER_LOW_RIGHT:
            _position.x += 10.0f;
            _position.y += 10.0f;
            _waitToStart = 0.05f;
            break;
        case HEALTHANIM_PLAYER_MID_LEFT:
            _position.x -= 10.0f;
            _position.y += 25.0f;
            _waitToStart = 0.15f;
            break;
        case HEALTHANIM_PLAYER_UP_RIGHT:
            _position.x -= 10.0f;
            _position.y += 50.0f;
            _waitToStart = 0.25f;
            break;
            
        default:
            break;
    }
}

-(void)update:(float)dt
{
    float rate = 2.0f * dt;
    
    //guard
    if (!_animating) { return; }
    
    //guard
    _waitToStart -= dt;
    if (_waitToStart > 0.0f) { return; }
    
    
    
    switch (_animType) {
        case HEALTHANIM_PLAYER_LOW_RIGHT:
            _angle += rate;
            _position.y += rate;
            break;
        case HEALTHANIM_PLAYER_MID_LEFT:
            _angle -= rate;
            _position.y += rate;
            break;
        case HEALTHANIM_PLAYER_UP_RIGHT:
            _angle += rate;
            _position.y += rate;
            break;
        default:
            break;
    }
    
    [_sprite setPosition:CGPointMake(_player.x + _position.x, _player.y + _position.y)];
    [[_sprite getCCSprite] setRotation:_angle];
    
    if (_duration <= 0.25f) {
        _duration -= dt;
        _alpha = _duration * 4.0f;
        if (_duration <= 0.0f) {
            _animating = false;
            _alpha = 0.0f;
        }
        
        [_sprite setAlpha:_alpha];
    }
}

@end
