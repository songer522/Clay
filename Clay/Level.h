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


@interface Level : NSObject
{
    NSString *_name;
    CCSprite *_background;
    
    CCTMXLayer *_main;
    CCTMXLayer *_meta;
    
    CCTMXTiledMap *_map;
}

#pragma mark - inits
+(id)levelWithFilename:(NSString*)filename Background:(NSString*)backgroundImage Layer:(CCLayer*)layer;
-(id)initWithFilename:(NSString*)filename Background:(NSString*)backgroundImage Layer:(CCLayer*)layer;

#pragma mark - public methods
-(CGPoint)checkCollisionAtPoint:(CGPoint)point;
-(void)update:(float)dt Velocity:(float)vx;


#pragma mark - private methods
-(void)initTiledMap:(NSString*)filename;
-(void)initBackgroundImage:(NSString*)filename;
-(CGPoint)tileCoordForPosition:(CGPoint)position;
-(bool)checkIfSameTile:(int)tileId atNewPosition:(CGPoint)point forTileLayer:(CCTMXLayer*)layer;
-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords;
@end
