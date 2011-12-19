//
//  Laser.m
//  Clay
//
//  Created by Brian Cable on 10/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Laser.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "GameLayer.h"
#import "Player.h"
#import "GameSettings.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
@implementation Laser

+(id)laserWithId:(int)num
{
    return [[self alloc] initWithId:num];
}

-(id)initWithId:(int)num
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        NSString *filename = [NSString stringWithFormat:@"Disco_Laser_%d.png",num];
        _sprite = [Sprite spriteFromFrameCacheWithName:filename];
        _alpha = 0.0f;
        [[_sprite getCCSprite] setAnchorPoint:ccp(0.5f,0.5f)];
        [self reset];
    }
    
    return self;
}

-(void)update:(float)dt
{
    if (_isActive) {
        _alpha -= 1.0f * _rate * dt;
        if (_alpha<=0.0f) {
            _isActive = false;
            [[_sprite getCCSprite] setVisible:NO];
        }
        [_sprite setPosition:_position];
        [_sprite setAlpha:_alpha];
    } else {
        _cooldown -= dt;
        if (_cooldown <= 0.0f) {
            [self reset];
        }        
    }
}

-(void)reset
{
    _alpha = 1.0f;
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    CGPoint playerPosition = [gameLayer.player getPosition];    
    
    //IPAD FIX: want to place the laser at a random position in front of the player to the edge of the screen,
    //also make sure they are not going off the top of the screen. *may* require either taller lasers drawn by tian
    //or less extreme of a sprite rotation located at ("[_sprite getCCSprite].rotation = (rand() % 80) - 40;" below).
    if (IS_IPAD)
    {
        _position = CGPointMake(playerPosition.x + rand()%600, 500.0f);  
    }
    else if ([[GameSettings shared] usingHighResolutionGraphics]) {
        _position = CGPointMake(playerPosition.x + rand()%600, 200.0f);        
    } else {
        _position = CGPointMake(playerPosition.x + rand()%600, 200.0f);
    }

    
    
    [_sprite setPosition:_position];
    [_sprite getCCSprite].rotation = (rand() % 60) - 40;
    [_sprite setAlpha:_alpha];
    [[_sprite getCCSprite] setVisible:YES];    
    
    _rate = rand() % 4 + 1;
    _cooldown = ((rand() % 300) + 200) / 100.0f;
    _cooldown = 0.0f;
    _isActive = true;
}

-(void)dealloc
{
    [_sprite release];
    [super dealloc];
}


@end
