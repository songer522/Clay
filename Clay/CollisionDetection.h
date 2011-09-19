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

@interface CollisionDetection : NSObject
{
    CCTMXLayer *_collisionData;
    CCTMXTiledMap *_map;
    int _tileSize;
    
    float _amountToReachGround;
    
    GameObject *_currentObject;
    
    CGPoint _desiredPosition;
    CGPoint _testPosition;
    CGPoint _pointWithinTile;
    
    CGPoint _coordinates;
    
    NSString *_tileCollision;
}

-(bool)tryGoingFullVxAndVy;
-(bool)tryGoingFullVx;
-(bool)getOutOfCollision;

-(void)prepareDataForPosition:(CGPoint)position;

- (id)initWithCollisionLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map;
-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords;
@end
