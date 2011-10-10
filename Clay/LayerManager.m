//
//  LayerManager.m
//  Clay
//
//  Created by Brian Cable on 9/8/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "LayerManager.h"

@implementation LayerManager


static LayerManager *_sharedLayers = nil;

+(LayerManager*)sharedLayers
{
	if (!_sharedLayers) {
        _sharedLayers = [[self alloc] init];
	}
	return _sharedLayers;
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)setWorkingLayer:(id)layer
{
    _workingLayer = layer;
}

-(void)forgetWorkingLayer
{
    _workingLayer = nil;
}

-(void)setCurrentLayer:(id)layer
{
    _currentLayer = layer;
}

-(id)currentLayer
{
    if (_workingLayer!=nil) {
        return _workingLayer;
    } else {
        return _currentLayer;        
    }
}

-(void)dealloc
{
    [_currentScene release];
    [super dealloc];
}

-(void)setWorkingScene:(id)scene
{
    _workingScene = scene;
}

-(void)forgetWorkingScene
{
    _workingScene = nil;
}

-(id)currentScene
{
    if (_workingScene!=nil) {
        return _workingScene;
    } else {
        return _currentScene;
    }
}

-(void)setCurrentScene:(CCScene*)scene
{
    _currentScene = scene;
}

@end
