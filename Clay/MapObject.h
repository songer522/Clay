//
//  MapObject.h
//  Clay
//
//  Created by Brian Cable on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameObject;
@class Sprite;

@interface MapObject : NSObject
{
    GameObject *_object;
    NSString *_layerAbove;
    bool _placed;
    CGPoint _parallaxRatio;
    CGPoint _position;
}

@property(nonatomic,retain)NSString *layerAbove;
@property(nonatomic,retain)GameObject *object;
@property(nonatomic,assign)bool placed;
@property(nonatomic,assign)CGPoint parallaxRatio;

+(id)mapObjectWithSprite:(GameObject*)object AboveLayer:(NSString*)layerAbove;

-(id) initWithSprite:(GameObject*)object AboveLayer:(NSString*)layerAbove;

-(void)addUsingLayers:(NSMutableDictionary*)layers;

-(void)reset;

-(void)setPosition:(CGPoint)pos;

@end
