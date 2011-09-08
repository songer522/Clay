//
//  Level.m
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Level.h"

#import "Camera.h"

@implementation Level


+(id)levelWithFilename:(NSString*)filename Background:(NSString*)backgroundImage Layer:(CCLayer*)layer
{
    return [[self alloc] initWithFilename:filename Background:backgroundImage Layer:layer];
}

- (id)initWithFilename:(NSString*)filename Background:(NSString*)backgroundImage Layer:(CCLayer*)layer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [self initTiledMap:filename];
        [self initBackgroundImage:backgroundImage];
        
        CCParallaxNode  *voidNode = [CCParallaxNode node];
        
        [voidNode addChild:_background z:-1 parallaxRatio:ccp(5.0f, 0) positionOffset:ccp(0, 0)];
        [voidNode addChild:_map z:1 parallaxRatio:ccp(0.5f, 0) positionOffset:ccp(0, 0)];
        
        _map.scale = 2.0f * [[UIScreen mainScreen] scale];
        
        [self initObjects];
        
        [[Camera sharedCamera] setBoundaries:[self getLevelBoundaries]];
        
        [layer addChild:voidNode];
    }
    
    return self;
}

-(CGPoint)tileCoordForPosition:(CGPoint)position
{
    int scaledTileWidth = _map.tileSize.width * _map.scale;
    int scaledTileHeight = _map.tileSize.height * _map.scale;
    int x = position.x / scaledTileWidth;
    int y = ((_map.mapSize.height * scaledTileHeight) - position.y) / scaledTileHeight;
    
    if (x < 0) {
        x = 0;
    } else if(x > (_map.mapSize.width - 1)) {
        x = _map.mapSize.width - 1;
    }
    
    if (y < 0) {
        y = 0;
    } else if(y > (_map.mapSize.height - 1)) {
        y = _map.mapSize.height - 1;
    }
    
    return ccp(x,y);
}

-(CGRect)getLevelBoundaries
{
    int width = _map.mapSize.width * _map.tileSize.width * _map.scale;
    int height = _map.mapSize.height * _map.tileSize.height * _map.scale;
    return CGRectMake(0, 0, width, height);
}

-(int)getTopYPositionForTileCoords:(CGPoint)coords atX:(int)x ForTileProperty:(NSString*)property
{
    //int scaledTileWidth = _map.tileSize.width * _map.scale;
    int scaledTileHeight = _map.tileSize.height * _map.scale;
    
    int y = 0;
    if ([property compare:@"none"] == NSOrderedSame) {
        //y position based on coordinates
        y = (coords.y * scaledTileHeight) + scaledTileHeight;
        
        //flip the y position so it's based on screen
        y = (_map.mapSize.height * scaledTileHeight) - y;
    }
    
    return y;
}

-(CGPoint)checkCollisionAtPoint:(CGPoint)point
{
    float newX = point.x;
    float newY = point.y;
    
    CGPoint tileCoordinates = [self tileCoordForPosition:point];
    NSString *collisionProperty = [self getCollisionPropertyForTileCoords:tileCoordinates];
    
    bool colliding = true;
    while (colliding) {
        if ([collisionProperty compare:@"none"] == NSOrderedSame || tileCoordinates.y < 0) {
            colliding = false;
        } else {
            tileCoordinates.y -= 1;
            collisionProperty = [self getCollisionPropertyForTileCoords:tileCoordinates];            
        }
    }
    
    newY = [self getTopYPositionForTileCoords:tileCoordinates atX:newX ForTileProperty:collisionProperty];
    
    return CGPointMake(newX,newY);
}

-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords
{
    NSString *returnVal = [NSString stringWithString:@"none"];
    
    int tileGid = [_meta tileGIDAt:coords];
    
    if (tileGid) {
        NSDictionary *properties = [_map propertiesForGID:tileGid];
        
        if (properties) {
            returnVal = [properties valueForKey:@"collision"];
        }
    }
    
    return returnVal;
}

-(void)update:(float)dt Velocity:(float)vx
{
    //float rate = vx * 0.2f;
    //[_map setPosition:CGPointMake(_map.position.x - rate, _map.position.y)];
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



-(void)initTiledMap:(NSString*)filename 
{
    _map = [CCTMXTiledMap tiledMapWithTMXFile:filename];
    _map.scale = 1.0f;
    
    _meta = [_map layerNamed:@"meta"];
    _meta.visible = NO;
    
    _main = [_map layerNamed:@"main"];
    
    
}

-(void)initBackgroundImage:(NSString *)filename
{
    _background = [CCSprite spriteWithFile:filename];
    _background.anchorPoint = ccp(0, 0);
    
}

-(void)initObjects
{
    _objects = [_map objectGroupNamed:@"objects"];
    NSAssert(_objects != nil, @"'objects' object group not found");
    
    NSMutableDictionary *spawnPoint = [_objects objectNamed:@"SpawnPoint"];
    NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
    
    int x = [[spawnPoint valueForKey:@"x"] intValue] * _map.scale;
    int y = [[spawnPoint valueForKey:@"y"] intValue] * _map.scale;
    
    _spawnPoint = CGPointMake(x, y);
    
}



@end
