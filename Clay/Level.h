//
//  Level.h
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class TrackBackground;

@class GameObject;

@class GameObjectController;

@interface Level : NSObject
{
    NSString *_name;
    CCSprite *_background;
    
    CCTMXLayer *_main;
    CCTMXLayer *_meta;
    CCTMXLayer *_obstacles;
    
    CCTMXTiledMap *_map;
    
    CCTMXObjectGroup *_objects;
    
    CGPoint _spawnPoint;
    
    CCParallaxNode *_parallaxLayers;
    
    NSMutableArray *_obstacleSprites;
    
    NSString *_nextLevelName;           //the name of the level to load after this one is about
                                        //to complete. will be used by the LevelManager
    GameObjectController *_gameObjects;
    
    float _x;
    float _y;
}

@property (nonatomic,retain) NSString *nextLevelName;
@property (nonatomic,retain) GameObjectController *gameObjects;

#pragma mark - inits
+(id)levelWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList;

-(id)initWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList;

#pragma mark - public methods
-(CGPoint)checkCollisionForObject:(GameObject*)object AtPoint:(CGPoint)point;
-(void)update:(float)dt Velocity:(float)vx;
-(CGRect)getLevelBoundaries;
-(CGPoint)getSpawnPoint;
-(CGPoint)getXYPositionForCoordinates:(CGPoint)coords;
-(void)loadLayers:(NSString*)layerList;
-(void)updateHurdles:(float)dt;
-(NSString*)getObstaclePropertyForTileCoords:(CGPoint)coords forKey:(NSString*)key;
-(bool)testCollisions:(GameObject*)source;
-(bool)testCollisionWithGameObject:(GameObject*)target Source:(GameObject*)source;

#pragma mark - private methods
-(void)initTiledMap:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer;
-(void)initBackgroundImage:(NSString*)filename;
-(CGPoint)tileCoordForPosition:(CGPoint)position;
-(bool)checkIfSameTile:(int)tileId atNewPosition:(CGPoint)point forTileLayer:(CCTMXLayer*)layer;
-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords;
-(void)initHurdles;
-(void)initSpawnPoint;
-(void)setPositionAtX:(float)x Y:(float)y;
@end
