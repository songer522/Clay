//
//  CollisionDetection.h
//  Clay
//
//  Created by Brian Cable on 9/16/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Handles the player collisions with the world. Detects whether the player is on the ground, on a ledge, in midair, or has fallen into a death pit, and adjusts the player's position as necessary. Theoretically can be used for other game objects, but we can't do it for performance reasons, for now.

//  NOTE: there's some quirks to how the CCTMXTiledMap class works with Retina displays


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameObject;

@interface CollisionDetection : NSObject
{
    CCTMXLayer *_collisionData; //the layer that contains the collision properties (usually 'meta'). weak reference.
    CCTMXTiledMap *_map; //weak reference to the loaded map
    
    int _tileSize; //the tilesize for the map
    int _halfTileSize;
    int _mapHeight; //height of the map
    int _mapWidth; //width of the map
}

+(id) collisionHandlerWithMetaLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map;
- (id)initWithCollisionLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map;

-(CGPoint)checkCollisionForObject:(GameObject*)object; //entry point for the class, what gets called every update to check the player's collision with the level

-(CGPoint)accurateCoords:(CGPoint)position; //determine which coordinate needs to be checked, bounded by the edges of the map
-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords; //get the value stored under the "collision" tile property on the Tiled map at these coordinates. default to 'none', but can also return 'ground' or 'ledge'.

@end
