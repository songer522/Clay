//
//  ChooseModeScene.m
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseModeScene.h"
#import "LayerManager.h"
#import "TextureManager.h"
#import "Sprite.h"
#import "GameLabel.h"
#import "ModePanel.h"

@implementation ChooseModeScene

@synthesize isTransitioning = _isTransitioning;

+(CCScene*)scene
{
    CCScene *scene = [CCScene node];
    ChooseModeScene *layer = [ChooseModeScene node];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
    if((self=[super init])) {
        
        [self load];
        
        _isTransitioning = false;
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
    }
    
    return self;
}


-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    for(UITouch *touch in allTouches)
    {
        CGPoint position = [self convertTouchToNodeSpace:touch];
        if ([_storyModePanel testCollision:position]) {
            [_storyModePanel transitionToActive];
            [_timedModePanel transitionToInactive];
            [_extrasPanel transitionToInactive];
        } else if ([_timedModePanel testCollision:position]) {
            [_timedModePanel transitionToActive];
            [_storyModePanel transitionToInactive];
            [_extrasPanel transitionToInactive];
        } else if ([_extrasPanel testCollision:position]) {
            [_extrasPanel transitionToActive];
            [_timedModePanel transitionToInactive];
            [_storyModePanel transitionToInactive];
        }
    }
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    [[TextureManager shared] loadMemoryForKey:@"chooseMode"];
    
    _background = [Sprite spriteFromFrameCacheWithName:@"UI_GameType_Background.png"];
    
    _storyModePanel = [ModePanel panelAtPosition:ccp(80,154)];
    [_storyModePanel setHeaderFrame:@"UI_GameType_StoryModeC.png" Inactive:@"UI_GameType_StoryModeG.png"];
    [_storyModePanel addButtons:[NSArray arrayWithObjects:@"KIDS",@"NORMAL",@"INSANE", nil]];
    [_storyModePanel setParent:self];
    [_storyModePanel makeActive];
    
    _timedModePanel = [ModePanel panelAtPosition:ccp(240,154)];
    [_timedModePanel setHeaderFrame:@"UI_GameType_TimeModeC.png" Inactive:@"UI_GameType_TimeModeG.png"];
    [_timedModePanel addButtons:[NSArray arrayWithObjects:@"NORMAL",@"INSANE", nil]];
    [_timedModePanel setParent:self];
    
    _extrasPanel = [ModePanel panelAtPosition:ccp(400,154)];
    [_extrasPanel setHeaderFrame:@"UI_GameType_ExtrasC.png" Inactive:@"UI_GameType_ExtrasG.png"];
    [_extrasPanel addButtons:[NSArray arrayWithObjects:@"SKINS",@"LEVELS",@"WEB", nil]];
    [_extrasPanel setParent:self];
    
    _selectModeText = [GameLabel gameLabelWithText:@"SELECT GAME TYPE" Scale:0.65f];
    [_selectModeText setPosition:ccp(240.0f,290.0f)];

    [[LayerManager sharedLayers] forgetWorkingLayer];
}

-(void)update:(ccTime)dt
{
    [_storyModePanel update:dt];
    [_timedModePanel update:dt];
    [_extrasPanel update:dt];
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)dealloc
{
    
    [[TextureManager shared] unloadMemoryForKey:@"chooseMode"];
}

@end