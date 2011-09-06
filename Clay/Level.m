//
//  Level.m
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Level.h"

@implementation Level


+(id)levelWithFilename:(NSString*)filename Layer:(CCLayer*)layer
{
    return [[self alloc] initWithFilename:filename Layer:layer];
}

- (id)initWithFilename:(NSString*)filename Layer:(CCLayer*)layer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _map = [CCTMXTiledMap tiledMapWithTMXFile:filename];
        _map.scale = 3.0f;
        
        [layer addChild:_map];
        
        _meta = [_map layerNamed:@"meta"];
        _meta.visible = NO;
        
        _main = [_map layerNamed:@"main"];
        
    }
    
    return self;
}

-(CGPoint)tileCoordForPosition:(CGPoint)position
{
    int x = position.x / _map.tileSize.width;
    int y = ((_map.mapSize.height * _map.tileSize.height) - position.y) / _map.tileSize.height;
    return ccp(x,y);
}

-(CGPoint)checkCollisionAtPoint:(CGPoint)point
{
    float newX = point.x;
    float newY = point.y;
    
    CGPoint tileCoordinates = [self tileCoordForPosition:point];
    NSLog(@"Coords: %f,%f",tileCoordinates.x,tileCoordinates.y);
    
    int tileGid = [_meta tileGIDAt:tileCoordinates];
    if (tileGid) {
        NSDictionary *properties = [_map propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = [properties valueForKey:@"collision"];
            if(collision) {
                if([collision compare:@"full"] == NSOrderedSame ) {
                    bool colliding = true;
                    while (colliding) {
                        newY -= 1;
                        bool sameTile = [self checkIfSameTile:tileGid atNewPosition:CGPointMake(point.x, newY) forTileLayer:_meta];
                        if(!sameTile) {
                            colliding = false;
                        }
                    }
                }
            }
        }
    }
    
    return CGPointMake(newX,newY);
}

-(bool)checkIfSameTile:(int)tileId atNewPosition:(CGPoint)point forTileLayer:(CCTMXLayer*)layer
{
    bool returnVal = false;
    CGPoint coordinates = [self tileCoordForPosition:point];
    int tileGid = [layer tileGIDAt:coordinates];
    if (tileGid && tileGid == tileId) {
        returnVal = true;
    }
    return returnVal;
}


@end
