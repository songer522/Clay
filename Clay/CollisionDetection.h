//
//  CollisionDetection.h
//  Clay
//
//  Created by Brian Cable on 9/16/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameObject;

typedef enum {
    COLLISION_TYPE_FULL,
    COLLISION_TYPE_LEFT_SLANT,
    COLLISION_TYPE_RIGHT_SLANT,
    COLLISION_TYPE_RIGHT_SLANT_2TILE_L,
    COLLISION_TYPE_RIGHT_SLANT_2TILE_R,
    COLLISION_TYPE_LEDGE_FULL,
    COLLISION_TYPE_NONE
}CollisionType;

typedef enum {
    BOX_RIGHT_MIDDLE,
    BOX_RIGHT_BOTTOM,
    BOX_LEFT_MIDDLE,
    BOX_BOTTOM_MIDDLE,
    BOX_TOP_MIDDLE,
    BOX_NONE
}BoundingBoxPoint;

struct XDCollision {
    bool left;
    bool right;
    bool top;
    bool bottom;
    bool hasCollision;
};
typedef struct XDCollision XDCollision;

CG_INLINE XDCollision
XDCollisionMake(bool hasCollision, bool left, bool right, bool top, bool bottom)
{
    XDCollision c; c.hasCollision = hasCollision; c.left = left; c.right = right; c.top = top; c.bottom = bottom; return c;
}

@interface CollisionDetection : NSObject
{
    CCTMXLayer *_collisionData;
    CCTMXLayer *_main;
    CCTMXTiledMap *_map;
    int _tileSize;
    
    float _amountToReachGround;
    
    GameObject *_currentObject;
    
    CGPoint _desiredPosition;
    CGPoint _testPosition;
    CGPoint _pointWithinTile;
    
    CGPoint _coordinates;
    
    CGRect _objectBoundingBox;
    
    NSString *_tileCollision;
    
    XDCollision _currentMidpoints;
}

@property(nonatomic,assign) XDCollision midpointCollisions;

+(id) collisionHandlerWithMetaLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map;
- (id)initWithCollisionLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map;

-(CGPoint)checkCollisionForObject:(GameObject*)object;

-(XDCollision)getMidpointCollisionsForPoint:(CGPoint)position;

-(bool)checkCollisionAtPoint:(CGPoint)point BoundingBoxPoint:(BoundingBoxPoint)edge;
-(CGPoint)accurateCoords:(CGPoint)position;
-(CollisionType)getCollisionTypeForCoords:(CGPoint)coords;
-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords;



-(bool)pushUp;
-(bool)pushLeft;
-(void)prepareDataForPosition:(CGPoint)position BoundingBoxPoint:(BoundingBoxPoint)edge;
-(CGPoint)getPointForObject:(GameObject*)object AtPosition:(CGPoint)position ForBoundingBoxEdge:(BoundingBoxPoint)edge;
@end
