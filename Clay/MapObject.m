//
//  MapObject.m
//  Clay
//
//  Created by Brian Cable on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "MapObject.h"
#import "Sprite.h"
#import "MapLayer.h"
#import "GameObject.h"


@implementation MapObject

@synthesize object = _object;
@synthesize layerAbove = _layerAbove;
@synthesize placed = _placed;
@synthesize parallaxRatio = _parallaxRatio;
@synthesize zOrder = _zOrder;

+(id)mapObjectWithSprite:(GameObject*)object AboveLayer:(NSString*)layerAbove
{
    return [[[self alloc] initWithSprite:object AboveLayer:layerAbove] autorelease];
}

-(id) initWithSprite:(GameObject*)object AboveLayer:(NSString*)layerAbove
{
    self = [super init];
    if (self) {
        _object = object;
        _layerAbove = [NSString stringWithString:layerAbove]; 
        _placed = false;
    }
    
    return self;
}

-(void)addUsingLayers:(NSMutableDictionary*)layers
{
    MapLayer *mapLayer = [layers objectForKey:_layerAbove];
    CCTMXLayer *layer = mapLayer.layer;
    [layer addChild:[_object getCCSprite]];
}

-(void)reset
{
    [_object reset];
}

-(void)setPosition:(CGPoint)pos
{
    //should try to match how ccparallaxnode handles the position, since it should move with the layer
    float x = -pos.x + pos.x * _parallaxRatio.x;
    float y = -pos.y + pos.y * _parallaxRatio.y;
    
    [self.object getCCSprite].position = ccp(x,y);
    
}

-(void)dealloc
{
    [_object release];
    [_layerAbove release];
    [super dealloc];
}

@end
