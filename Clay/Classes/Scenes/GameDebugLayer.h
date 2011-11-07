//
//  GameDebugLayer.h
//  Clay
//
//  Created by Brian Cable on 9/19/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  This layer is only created by the AppDelegate class when DRAW_DEBUG_BOXES constant is set to 1 (true). This layer overlays everything and draws the hitboxes in bright green over the player, projectiles, and obstacles. Better performance if this isn't created when not needed.

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