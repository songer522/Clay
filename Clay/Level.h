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
    
    CCParallaxNode *parallaxLayers;
    
    NSMutableArray *_obstacleSprites;
    
    float _x;
    float _y;
}

#pragma mark - inits
+(id)levelWithFilename:(NSString*)filename Background:(NSString*)backgroundImage Layer:(CCLayer*)layer;
-(id)initWithFilename:(NSString*)filename Background:(NSString*)backgroundImage Layer:(CCLayer*)layer;

#pragma mark - public methods
-(CGPoint)checkCollisionForObject:(GameObject*)object AtPoint:(CGPoint)point;
-(void)update:(float)dt Velocity:(float)vx;
-(CGRect)getLevelBoundaries;
-(CGPoint)getSpawnPoint;
-(NSString*)getPropertyForTileCoords:(CGPoint)coords forKey:(NSString*)key;
-(CGPoint)getXYPositionForCoordinates:(CGPoint)coords;
-(void)updateHurdles;
-(void)initHurdles;

#pragma mark - private methods
-(void)initTiledMap:(NSString*)filename;
-(void)initBackgroundImage:(NSString*)filename;
-(CGPoint)tileCoordForPosition:(CGPoint)position;
-(bool)checkIfSameTile:(int)tileId atNewPosition:(CGPoint)point forTileLayer:(CCTMXLayer*)layer;
-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords;
-(void)initObjects;
-(void)setPositionAtX:(float)x Y:(float)y;
@end
