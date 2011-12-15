//
//  OptionsScene.m
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "OptionsScene.h"
#import "Sprite.h"
#import "ActionButton.h"
#import "LayerManager.h"
#import "TextureManager.h"

@implementation OptionsScene

+(CCScene*)scene
{
    CCScene *scene = [CCScene node];
    OptionsScene *layer = [OptionsScene node];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
    if((self=[super init])) {
        
        [self load];
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
    }
    
    return self;
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    [[TextureManager shared] loadMemoryForKey:@"optionsScreen"];

    _background = [Sprite spriteFromFrameCacheWithName:@"Options_Background.png"];
    _musicPanel = [Sprite spriteCenteredWithFrame:@"Options_Panel_L.png" Position:ccp(240,232)];
    _musicVolumeHeader = [Sprite spriteCenteredWithFrame:@"Options_Title_1.png" Position:ccp(97,264)];
    _musicSheetMasked = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeA_2.png" Position:ccp(240,230)];
    _musicSheetTop = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeA_1.png" Position:ccp(240,230)];
    
    _sfxPanel = [Sprite spriteCenteredWithFrame:@"Options_Panel_L.png" Position:ccp(240,152)];
    _sfxVolumeHeader = [Sprite spriteCenteredWithFrame:@"Options_Title_2.png" Position:ccp(391,184)];
    _sfxSheetMasked = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeB_2.png" Position:ccp(240,150)];
    _sfxSheetTop = [Sprite spriteCenteredWithFrame:@"Options_Stave_TypeB_1.png" Position:ccp(240,150)];
    
    _howToPlayButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    [_howToPlayButton setPosition:ccp(240,76)];
    [_howToPlayButton setHitboxBySize:CGSizeMake(143, 70)];

    _eraseDataButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    [_eraseDataButton setPosition:ccp(85,76)];
    [_eraseDataButton setHitboxBySize:CGSizeMake(143, 70)];

    _creditsButton = [ActionButton actionButtonCustomGraphicsForIdle:@"Options_Panel_S.png" Selected:@"Options_Panel_S.png"];
    [_creditsButton setPosition:ccp(395,76)];
    [_creditsButton setHitboxBySize:CGSizeMake(143, 70)];

    
    [[LayerManager sharedLayers] forgetWorkingLayer];
}

-(void)update:(ccTime)dt
{
    
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
    [self release];
}

-(void)dealloc
{
    [_background release];
    [_musicPanel release];
    [_sfxPanel release];
    [_musicSheetTop release];
    [_musicSheetMasked release];
    [_sfxSheetTop release];
    [_sfxSheetMasked release];
    [_musicVolumeHeader release];
    [_sfxVolumeHeader release];
    [_eraseDataButton release];
    [_howToPlayButton release];
    [_creditsButton release];
}

@end
