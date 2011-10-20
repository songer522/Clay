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
@class CollisionDetection;
@class Player;
@class Trigger;
@class GameObjectController;

@interface Level : NSObject
{
    NSString *_name;
    CCTMXLayer *_main;
    CCTMXLayer *_meta;
    CCTMXLayer *_obstacles;
    
    CCTMXTiledMap *_map;
    
    CCTMXObjectGroup *_objects;
    
    CollisionDetection *_collisionHandler;
    
    CGPoint _spawnPoint;
    
    NSMutableArray *_obstacleMapObjects;
    NSMutableArray *_otherMapObjects;
    NSMutableArray *_parallaxLayers;
    
    NSMutableDictionary *_mapLayers;
    
    NSString *_postLevelComicName;
    
    NSString *_musicName;
    
    NSString *_nextLevelName;           //the name of the level to load after this one is about
                                        //to complete. will be used by the LevelManager
    NSString *_playerThirdActionName;
    
    GameObjectController *_gameObjects;
    
    NSMutableArray *_triggers;
    
    float _x;
    float _y;
    float _scale;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *nextLevelName;
@property (nonatomic,retain) NSString *musicName;
@property (nonatomic,retain) NSString *postLevelComicName;
@property (nonatomic,retain) GameObjectController *gameObjects;
@property (nonatomic,readonly,assign) CGPoint spawnPoint;
@property (nonatomic,readonly,retain) NSMutableArray *obstacleSprites;
@property (nonatomic,readonly,retain) CollisionDetection *collisionHandler;
@property (nonatomic,retain) NSString *playerThirdActionName;

#pragma mark - inits
+(id)levelWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects Player:(Player*)player;

-(id)initWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects Player:(Player*)player;

#pragma mark - public methods
-(CGPoint)checkCollisionForObject:(GameObject*)object;
-(void)update:(float)dt Velocity:(float)vx;
-(CGRect)getLevelBoundaries;
-(CGPoint)getXYPositionForCoordinates:(CGPoint)coords;
-(void)loadLayers:(NSString*)layerList Player:(Player*)player;
-(NSString*)getPropertyForTileCoords:(CGPoint)coords forKey:(NSString*)key;
-(bool)testCollisions:(GameObject*)source;
-(bool)testCollisionsForAggressive:(GameObject*)source;
-(bool)testCollisionWithGameObject:(GameObject*)target Source:(GameObject*)source;
-(void)addMapObjectsAboveLayer:(CCTMXLayer*)layer ParallaxRatio:(CGPoint)ratio;
-(void)addObstaclesToMap;

-(void)resetObstacles;
-(Trigger*)testTriggers:(Player*)player;
-(void)unloadLevel;

-(void)setThirdAction:(NSString*)action;

#pragma mark - private methods
-(void)initTiledMap:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer;
-(void)scanThroughMapAndAddObjects;
-(void)setPositionAtX:(float)x Y:(float)y;
@end
