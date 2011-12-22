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
#import "Battery.h"

@implementation HealthIcon

+(id) instance 
{
    return [[self alloc] init];
}

-(id)init
{
    if ((self=[super init])) {
        
        _sprite = [Sprite spriteCenteredWithFrame:@"Health_Sign_P.png"];
        [_sprite setAlpha:0.0f];
        _alpha = 0.0f;
        _waitToStart = 0.0f;
        _animating = false;
    }
    return self;
}

-(void)startHealthAnimWithSprite:(HealthIconType)healthType
{
    _position = ccp(0,0);
    _angle = 0.0f;
    _animating = true;
    _duration = 1.0f;
    _alpha = 0.0f;
    [_sprite setAlpha:0.0f];
    
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
            _position.x += 19.0f;
            _position.y += 12.0f;
            _waitToStart = 0.05f;
            break;
        case HEALTHANIM_PLAYER_MID_LEFT:
            _position.x -= 12.0f;
            _position.y += 45.0f;
            _waitToStart = 0.15f;
            break;
        case HEALTHANIM_PLAYER_UP_RIGHT:
            _position.x += 25.0f;
            _position.y += 77.0f;
            _waitToStart = 0.35f;
            break;
        case HEALTHANIM_INTO_BATTERY_1:
            _position.x = -10.0f;
            _position.y = 13.0f;
            _waitToStart = 0.05f;
            break;
        case HEALTHANIM_INTO_BATTERY_2:
            _position.x = -10.0f;
            _position.y = 13.0f;
            _waitToStart = 0.5f;
            break;
        case HEALTHANIM_INTO_BATTERY_3:
            _position.x = -10.0f;
            _position.y = 13.0f;
            _waitToStart = 0.95f;            
            break;
        default:
            break;
    }
}

-(void)setHealthAnimTypeById:(int)number
{
    _animType = number;
    iconId = number;
}

-(void)update:(float)dt
{
    float rate = 20.0f * dt;
    float angleRate = 2.0f * rate;
    float batteryRate = 4.5f * rate;
    
    //guard
    if (!_animating) { return; }
    
    //guard
    _waitToStart -= dt;
    if (_waitToStart > 0.0f) { return; }
    
    
    bool _moveIcon = false;
    
    _duration -= 1.75f * dt;
    if (_duration <= 0.25f) {
        _alpha = _duration * 4.0f;
        if (_duration <= 0.0f) {
            _animating = false;
            _alpha = 0.0f;
        }
    } else {
        _alpha += (1.0f - _duration) * 4.0f;
        if(_alpha >= 1.0f) {
            _alpha = 1.0f;
        }
        _moveIcon = true;
    }
    
    [_sprite setAlpha:_alpha];

    
    switch (_animType) {
        case HEALTHANIM_PLAYER_LOW_RIGHT:
            if (_moveIcon) {
                _angle += angleRate;
                _position.y += rate;
                _position.x += 0.5f * rate;
            }
            [_sprite setPosition:CGPointMake(_player.x + _position.x, _player.y + _position.y)];
            break;
        case HEALTHANIM_PLAYER_MID_LEFT:
            if (_moveIcon) {
                _angle -= angleRate;
                _position.y += rate;                
                _position.x -= 0.5f * rate;
            }
            [_sprite setPosition:CGPointMake(_player.x + _position.x, _player.y + _position.y)];
            break;
        case HEALTHANIM_PLAYER_UP_RIGHT:
            if (_moveIcon) {
                _angle += angleRate;
                _position.y += rate;                
                _position.x += 0.5f * rate;
            }
            [_sprite setPosition:CGPointMake(_player.x + _position.x, _player.y + _position.y)];
            break;
        case HEALTHANIM_INTO_BATTERY_1:
            if (_duration<=0.75f) {
                _position.x += batteryRate;                
            }
            [_sprite setScreenPosition:CGPointMake(_battery.x + _position.x, _battery.y + _position.y)];
            break;
        case HEALTHANIM_INTO_BATTERY_2:
            if (_duration<=0.75f) {
                _position.x += 3.0f * rate;
            }
            [_sprite setScreenPosition:CGPointMake(_battery.x + _position.x, _battery.y + _position.y)];
            break;
        case HEALTHANIM_INTO_BATTERY_3:
            if (_duration<=0.75f) {
                _position.x += 3.0f * rate;
            }
            [_sprite setScreenPosition:CGPointMake(_battery.x + _position.x, _battery.y + _position.y)];
            break;
        default:
            break;
    }
    
    [[_sprite getCCSprite] setRotation:_angle];
    
}

-(void)setBattery:(Battery*)battery
{
    _battery = battery;
}

-(void)setPlayer:(Player*)player
{
    _player = player;
}


@end
