//
//  Level.h
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  Stores the data for the level, including all the obstacles and background objects. The level is stored in layers, and moves at different rates based on the player's world position.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "Collidable.h"

@class GameObject;
@class CollisionDetection;
@class Player;
@class Trigger;
@class RegionManager;
@class GameObjectController;
@class GameLayer;
@class Player;

@interface Level : NSObject
{

    //map references
    CCTMXTiledMap *_map;
    NSMutableDictionary *_mapLayers;    //stores references to map layers after removed from map by parallaxLayers
    NSMutableArray *_parallaxLayers;    //stores CCParallaxNodes built from the map so the map can have parallax scrolling
    
    //convenient references to certain layers in the map
    CCTMXLayer *_main;
    CCTMXLayer *_meta;
    CCTMXLayer *_obstacles;
    
    //handles the collision detection between the player and the ground
    CollisionDetection *_collisionHandler;
    
    
    //obstacle mapobjects
    NSMutableArray *_obstacleMapObjects;
    RegionManager *_obstacleManager;
    
    //background mapobjects, usually attached to a layer
    NSMutableArray *_otherMapObjects;
    //RegionManager *_backgroundManager;
    
    CCSpriteBatchNode *_obstacleSpriteBatch;
    
    //any triggers in the level
    NSMutableArray *_triggers;
    
    
    
    //external properties
    CGPoint _spawnPoint;            //the world coordinates for where the player starts in the map
    NSString *_name;                //name of the level as per the key name in levels.plist
    NSString *_postLevelComicName;  //name of the comic to load after level complete
    NSString *_preComicName;        //name of the comic to load before the level starts
    NSString *_musicName;           //name of the music to play
    NSString *_nextLevelName;           //the name of the level to load after this one is about
                                        //to complete. will be used by the LevelManager
    NSString *_playerThirdActionName;   //the name of the third action (woo, shoot, dodge, etc)
    

    GameObjectController *_gameObjects; //reference to the factory for building gameobjects
    
    
    //weak references
    GameLayer *_gameLayer;
    Player *_player;
    
    
    float _x;
    float _y;
    float _scale;
    float _divide;
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
@property (nonatomic,retain) NSString *preComicName;

#pragma mark - inits
+(id)levelWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects Player:(Player*)player Name:(NSString*)levelName;

-(id)initWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects Player:(Player*)player Name:(NSString*)levelName;

#pragma mark - public methods
-(CGPoint)checkCollisionForObject:(GameObject*)object;
-(void)update:(float)dt Velocity:(float)vx;
-(CGRect)getLevelBoundaries;
-(CGPoint)getXYPositionForCoordinates:(CGPoint)coords;
-(void)loadLayers:(NSString*)layerList Player:(Player*)player Name:(NSString*)levelName;
-(NSString*)getPropertyForTileCoords:(CGPoint)coords forKey:(NSString*)key;
-(bool)testCollisions:(GameObject*)source;


-(bool)testCollisionsForAggressive:(id<Collidable>)source;
-(bool)testCollisionWithGameObject:(id<Collidable>)target Source:(id<Collidable>)source;
-(bool)testCollisionWithGameObject:(id<Collidable>)target BoundingBox:(CGRect)boundingBox;

-(void)addObstaclesToMapWithBehavior:(CollisionBehavior)behavior;

-(void)addMapObjectsAboveLayer:(CCTMXLayer*)layer ParallaxRatio:(CGPoint)ratio;
-(void)addObstaclesToMapAndRegion;

-(void)disablePassedTriggers;
-(void)resetObstacles;
-(void)resetTriggers:(bool)isRestartingLevel;
-(Trigger*)testTriggers:(Player*)player;
-(void)unloadLevel;

-(void)setHudButtonsAndThirdAction:(NSString*)action;

-(GameObject*)addObstacleNamed:(NSString*)name;

-(NSString*)getFullMapFilename:(NSString*)basename;

#pragma mark - private methods
-(void)initTiledMap:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer;
-(void)scanThroughMapAndAddObjects;
-(void)setPositionAtX:(float)x Y:(float)y;

-(NSMutableArray*)getActiveGameObjectList;
-(NSMutableArray*)getBackgroundObjectsList;

@end
