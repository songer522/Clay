//
//  ChooseLevelScreen.m
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseLevelScreen.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "Button.h"

@implementation ChooseLevelScreen


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ChooseLevelScreen *layer = [ChooseLevelScreen layerWithScene:scene];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id)layerWithScene:(CCScene*)scene
{
    return [[self alloc] initWithScene:scene];
}

-(id) initWithScene:(CCScene*)scene
{
    if ((self = [super init])) {
        [[LayerManager sharedLayers] setScene:scene ForKey:@"chooseLevel"];

    }
    return self;
}

-(void)load
{
    [[LayerManager sharedLayers] setWorkingLayer:self];    
    
    blackBackground = [Sprite spriteWithFile:@"black_background-hd.png"];
    
    for (int i=0; i<6; i++) {
        Button *button = [Button buttonWithText:@"test"];
        [_buttons addObject:button];
    }
    
    [[LayerManager sharedLayers] forgetWorkingLayer];
    
    self.isTouchEnabled = true;    
}

-(void)unload
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:@"black_background-hd.png"];
}

@end
