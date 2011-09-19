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

@synthesize currentScene = _currentScene;


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

-(void)setCurrentLayer:(id)layer
{
    _currentLayer = layer;
}

-(id)currentLayer
{
    return _currentLayer;
}

@end
