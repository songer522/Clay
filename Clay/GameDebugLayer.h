//
//  GameDebugLayer.h
//  Clay
//
//  Created by Brian Cable on 9/19/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CollisionDetection.h"
#import "Collidable.h"

@class GameLayer;
@class GameObject;

@interface GameDebugLayer : CCLayer
{
    
}

+(id) debugLayerForScene:(CCScene*)scene GameLayer:(GameLayer*)gameLayer;

-(void)drawBoxForCollidable:(id<Collidable>)object;
-(void)drawBoxForGameObject:(GameObject*)object Collisions:(XDCollision)collisions;

@end