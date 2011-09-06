//
//  Level.h
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Background;

@interface Level : NSObject
{
    NSString *_name;
    Background *_background;
    
    CCTMXLayer *_main;
    CCTMXLayer *_meta;
    
    CCTMXTiledMap *_map;
}

#pragma mark - inits
+(id)levelWithFilename:(NSString*)filename Layer:(CCLayer*)layer;
-(id)initWithFilename:(NSString*)filename Layer:(CCLayer*)layer;

#pragma mark - public methods
-(CGPoint)checkCollisionAtPoint:(CGPoint)point;

#pragma mark - private methods
-(CGPoint)tileCoordForPosition:(CGPoint)position;
-(bool)checkIfSameTile:(int)tileId atNewPosition:(CGPoint)point forTileLayer:(CCTMXLayer*)layer;

@end
