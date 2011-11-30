//
//  CollisionDetection.h
//  Clay
//
//  Created by Brian Cable on 9/16/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Handles the player collisions with the world, and designed to eventually allow for game objects to have collision detection as well (although so far it hasn't been necessary, and it's better for performance if this doesn't have to be calculated.

//  NOTE: there's some quirks to how the CCTMXTiledMap class works with Retina displays, and there's some dead code in here from when we were going to make the levels more dynamic (slopes, ability to hit head on something above him, etc.) that we don't really need anymore. Could use cleaning up or rewriting at some point. Also not terribly efficient right now, as a lot of this collision detection is overkill for how often Tim is on a flat surface. Needs to be rewritten so it's a simple check if he's below a certain Y value, except for when he's reached death pits.


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameObject;

@interface CollisionDetection : NSObject
{
    CCTMXLayer *_collisionData;
    CCTMXTiledMap *_map;
    int _tileSize;
    
    GameObject *_currentObject;
}

+(id) collisionHandlerWithMetaLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map;
- (id)initWithCollisionLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map;

-(CGPoint)checkCollisionForObject:(GameObject*)object;
-(CGPoint)accurateCoords:(CGPoint)position;
-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords;

@end
