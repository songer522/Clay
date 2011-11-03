//
//  Skin.m
//  Clay
//
//  Created by Brian Cable on 11/2/11.z
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Skin.h"
#import "PListLoader.h"
#import "Sprite.h"
#import "AnimationController.h"

@implementation Skin

-(void)setSkin:(NSString*)name
{
    NSDictionary *skin = [PListLoader loadPlistWithName:@"skins.plist"];
    
    _filename = [skin valueForKey:@"filename"];
    
    NSDictionary *animations = [skin valueForKey:@"animations"];
    
    _running = [animations valueForKey:@"running"];
    _jumping = [animations valueForKey:@"jumping"];
    _falling = [animations valueForKey:@"falling"];
    _sprinting = [animations valueForKey:@"sprinting"];
    _tripping = [animations valueForKey:@"tripping"];
    _hurting = [animations valueForKey:@"hurting"];
    _wooAction = [animations valueForKey:@"wooAction"];
    _kickAction = [animations valueForKey:@"kickAction"];
    _dodgeAction = [animations valueForKey:@"dodgeAction"];
    _shootAction = [animations valueForKey:@"shootAction"];
}
/*
-(void)setPlayerAnimation:(PlayerAnimation)type ForSprite:(Sprite*)sprite
{
    [[AnimationController sharedController] replaceSprite:sprite withAnimationNamed:@"jumpingAnim"];
}*/



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
    
    [super dealloc];
}

@end
