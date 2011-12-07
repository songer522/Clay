//
//  Skin.m
//  Clay
//
//  Created by Brian Cable on 11/2/11.z
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Skin.h"
#import "PListLoader.h"
#import "Sprite.h"
#import "AnimationController.h"

@implementation Skin

+(id)instance
{
    return [[self alloc] init];
}

-(id)init
{
    if((self=[super init])) {
        
    }
    return self;
}

-(void)setSkin:(NSString*)name
{
    NSDictionary *skins = [PListLoader loadPlistWithName:@"skins"];
    
    NSDictionary *skin = [skins objectForKey:name];
    
    _filename = [[NSString stringWithString:[skin objectForKey:@"filename"]] retain];
    
    _currentAnimation = PLAYER_ANIM_RUNNING;
    _previousAnimation = PLAYER_ANIM_RUNNING;
    
    NSDictionary *anims = [skin objectForKey:@"animations"];
    
    @try
    {
        _running = [[NSString stringWithString:[anims objectForKey:@"running"]] retain];
        _jumping = [[NSString stringWithString:[anims objectForKey:@"jumping"]] retain];
        _falling = [[NSString stringWithString:[anims objectForKey:@"falling"]] retain];
        _sprinting = [[NSString stringWithString:[anims objectForKey:@"sprinting"]] retain];
        _tripping = [[NSString stringWithString:[anims objectForKey:@"tripping"]] retain];
        _hurting = [[NSString stringWithString:[anims objectForKey:@"hurting"]] retain];
        _wooAction = [[NSString stringWithString:[anims objectForKey:@"wooAction"]] retain];
        _kickAction = [[NSString stringWithString:[anims objectForKey:@"kickAction"]] retain];
        _dodgeAction = [[NSString stringWithString:[anims objectForKey:@"dodgeAction"]] retain];
        _shootAction = [[NSString stringWithString:[anims objectForKey:@"shootAction"]] retain];
        _blowAction = [[NSString stringWithString:[anims objectForKey:@"blowAction"]] retain];
        _spinAction = [[NSString stringWithString:[anims objectForKey:@"spinDown"]] retain];
        _spinUp = [[NSString stringWithString:[anims objectForKey:@"spinUp"]] retain];
        _slowTimeAction = [[NSString stringWithString:[anims objectForKey:@"slowTimeAction"]] retain];
        _floating = [[NSString stringWithString:[anims objectForKey:@"floating"]] retain];
        
        if (![_filename isEqualToString:@"characterAnims"]) {
            
            AnimationController *controller = [AnimationController sharedController];
            [controller addAnimationForSkinFromFile:_filename UsingBaseAnim:@"runningAnim" ForSequence:_running];
            [controller addAnimationForSkinFromFile:_filename UsingBaseAnim:@"turboAnim" ForSequence:_sprinting];
            [controller addAnimationForSkinFromFile:_filename UsingBaseAnim:@"trippedAnim" ForSequence:_tripping];
            [controller addAnimationForSkinFromFile:_filename UsingBaseAnim:@"hurtAnim" ForSequence:_hurting];
            [controller addAnimationForSkinFromFile:_filename UsingBaseAnim:@"jumpingAnim" ForSequence:_jumping];
            [controller addAnimationForSkinFromFile:_filename UsingBaseAnim:@"fallingAnim" ForSequence:_falling];
        }
    }
    
    @catch (NSException *ex) {
        NSLog(@"ERROR: Skin.m - Check skins.plist under '%@'. There appears to be some missing values for required values.",name);
    }
}



-(void)setPlayerAnimation:(PlayerAnimation)type ForSprite:(Sprite*)sprite
{
    //guard
    //if ([self isCurrentAnimationOfType:type]) { return; }
    
    NSString *animName;
    bool switchAnimation= true;
    switch (type) {
        case PLAYER_ANIM_RUNNING:
            animName = _running;
            break;
        case PLAYER_ANIM_SPRINTING:
            animName = _sprinting;
            break;
        case PLAYER_ANIM_TRIPPING:
            animName = _tripping;
            break;
        case PLAYER_ANIM_JUMPING:
            animName = _jumping;
            break;
        case PLAYER_ANIM_FALLING:
            if(_currentAnimation == PLAYER_ANIM_JUMPING)
            {
            animName = _falling;
            }
            else
            {
                switchAnimation =false;
            }
           
            break;
        case PLAYER_ANIM_WOO:
            animName = _wooAction;
            break;
        case PLAYER_ANIM_KICK:
            animName = _kickAction;
            break;
        case PLAYER_ANIM_DODGE:
            animName = _dodgeAction;
            break;
        case PLAYER_ANIM_HURTING:
            animName = _hurting;
            break;
        case PLAYER_ANIM_SHOOT:
            animName = _shootAction;
            break;
        case PLAYER_ANIM_BLOW:
            animName = _blowAction;
            break;
        case PLAYER_ANIM_SPIN:
            animName = _spinAction;
            break;
        case PLAYER_ANIM_SPIN_UP:
            animName = _spinUp;
            break;
        case PLAYER_ANIM_SLOWTIME:
            animName = _slowTimeAction;
            break;
        case PLAYER_ANIM_FLOATING:
            animName = _floating;
            break;
        default:
            break;
    }
    if(switchAnimation){ 
        _previousAnimation = _currentAnimation;
        _currentAnimation = type;
        _currentSprite = sprite;
        
        if(animName !=nil) {
            [[AnimationController sharedController] replaceSprite:sprite withAnimationNamed:animName];
        } else {
            //NSLog(@"ERROR! Player animation not available for skin: %@",_filename);
        }
    }
}

-(bool)isCurrentAnimationOfType:(PlayerAnimation)type
{
    if (type == _currentAnimation) {
        return true;
    } else {
        return false;
    }
}

-(void)restorePreviousAnimation
{
    [self setPlayerAnimation:_previousAnimation ForSprite:_currentSprite];
}


-(void)dealloc
{
    [_running release];
    [_jumping release];
    [_falling release];
    [_sprinting release];
    [_tripping release];
    [_wooAction release];
    [_kickAction release];
    [_dodgeAction release];
    [_shootAction release];
    [_blowAction release];
    [_spinAction release];
    [_spinUp release];
    [_slowTimeAction release];
    [super dealloc];
}

@end
