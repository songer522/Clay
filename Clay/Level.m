//
//  Level.m
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Level.h"

#import "Camera.h"
#import "GameObject.h"
#import "Collision.h"
#import "Sprite.h"
#import "LayerManager.h"

@implementation Level

+(id)levelWithFilename:(NSString*)filename
{
    return [[self alloc] initWithFilename:filename];
}

- (id)initWithFilename:(NSString*)filename
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _obstacleSprites = [[NSMutableArray alloc] initWithCapacity:100];
        
        [self initTiledMap:filename];
        
        
        parallaxLayers = [CCParallaxNode node];
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_map];

        NSMutableArray *layerList = [[NSMutableArray alloc] initWithCapacity:20];
        [layerList addObject:[NSString stringWithString:@"background-99"]];
        [layerList addObject:[NSString stringWithString:@"back-5"]];
        [layerList addObject:[NSString stringWithString:@"back-4"]];
        [layerList addObject:[NSString stringWithString:@"back-3"]];
        [layerList addObject:[NSString stringWithString:@"back-2"]];
        [layerList addObject:[NSString stringWithString:@"back-1"]];
        [layerList addObject:[NSString stringWithString:@"main0"]];
        [layerList addObject:[NSString stringWithString:@"front1"]];
        [layerList addObject:[NSString stringWithString:@"front2"]];
        [layerList addObject:[NSString stringWithString:@"front3"]];
        [layerList addObject:[NSString stringWithString:@"meta"]];

        int currentZ = 0;
        for (NSString *layerName in layerList) {
            CCTMXLayer *tmxLayer = [_map layerNamed:layerName];
            if (tmxLayer) {
                float speedx = [[tmxLayer propertyNamed:@"speedx"] floatValue];
                float speedy = [[tmxLayer propertyNamed:@"speedy"] floatValue];
                [tmxLayer removeFromParentAndCleanup:NO];
                [parallaxLayers addChild:tmxLayer z:currentZ parallaxRatio:ccp(speedx,speedy) positionOffset:ccp(0, 0)];
                currentZ++;
            }
        }
        
        _map.scale = [[UIScreen mainScreen] scale] / 2;
        
        [self initSpawnPoint];
        
        [[Camera sharedCamera] setBoundaries:[self getLevelBoundaries]];
        
        [[[LayerManager sharedLayers] currentLayer] addChild:parallaxLayers];
        
        [self initHurdles];

    }
    
    return self;
}

-(CGPoint)tileCoordForPosition:(CGPoint)position
{
    int scaledTileWidth = _map.tileSize.width * _map.scale / 2.0f;
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
    int scaledTileWidth = _map.tileSize.width * _map.scale;
    int scaledTileHeight = _map.tileSize.height * _map.scale;
    
    int tileX = x % scaledTileWidth;
    
    int y = 0;
    if ([property compare:@"none"] == NSOrderedSame) {
        //y position based on coordinates
        y = (coords.y * scaledTileHeight) + scaledTileHeight;
        
        //flip the y position so it's based on screen
        y = (_map.mapSize.height * scaledTileHeight) - y;
    } else if([property compare:@"leftslant"] == NSOrderedSame) {
        y = (coords.y * scaledTileHeight) + (scaledTileWidth - tileX);
        
        //flip the y position so it's based on screen
        y = (_map.mapSize.height * scaledTileHeight) - y;
    } else if([property compare:@"rightslant"] == NSOrderedSame) {
        y = (coords.y * scaledTileHeight) + tileX;
        
        //flip the y position so it's based on screen
        y = (_map.mapSize.height * scaledTileHeight) - y;
    }
    
    NSLog(@"X: %f, Y: %f",coords.x,coords.y);
    
    return y;
}

-(CGPoint)checkCollisionForObject:(GameObject*)object AtPoint:(CGPoint)point
{
    float newX = point.x;
    float newY = point.y;
    
    CGPoint tileCoordinates = [self tileCoordForPosition:point];
    NSString *collisionProperty = [self getCollisionPropertyForTileCoords:tileCoordinates];
    
    bool colliding = true;
    while (colliding) {
        if ([collisionProperty compare:@"full"] != NSOrderedSame || tileCoordinates.y < 0) {
            colliding = false;
        } else {
            tileCoordinates.y -= 1;
            collisionProperty = [self getCollisionPropertyForTileCoords:tileCoordinates];            
        }
    }
    
    float topY = [self getTopYPositionForTileCoords:tileCoordinates atX:newX ForTileProperty:collisionProperty];
    
    //if the top of the course is higher than the current Y position, then change the Y  pos.
    //otherwise, the guy is jumping or falling and should be left alone.
    if (topY > newY) {
        newY = topY;
        [[object getCollision] processNewTile:collisionProperty CollisionState:COLLISION_STATE_GROUNDED];
    } else if(topY != newY) {
        [[object getCollision] processNewTile:collisionProperty CollisionState:COLLISION_STATE_MIDAIR];
    }
    
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
    [self setPositionAtX:_x Y:_y];
    [self updateHurdles];
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

-(void)setPositionAtX:(float)x Y:(float)y
{
    _x = x;
    _y = y;
    //[parallaxLayers setPosition:CGPointMake(_x, _y)];
    [parallaxLayers setPosition:[[Camera sharedCamera] convertToScreenXY:CGPointMake(_x, _y)]];
}

-(void)initTiledMap:(NSString*)filename 
{
    
    [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
    _map = [CCTMXTiledMap tiledMapWithTMXFile:filename];
    
    _map.scale = 1.0f;
    
    _meta = [_map layerNamed:@"meta"];
    _meta.visible = NO;
    
    _main = [_map layerNamed:@"main0"];
    _main.visible = YES;
    
    _obstacles = [_map layerNamed:@"front3"];
    _obstacles.visible = NO;
}

-(void)initBackgroundImage:(NSString *)filename
{
    _background = [CCSprite spriteWithFile:filename];
    _background.anchorPoint = ccp(0, 0);
    
}

-(void)initSpawnPoint
{
    _objects = [_map objectGroupNamed:@"objects"];
    NSAssert(_objects != nil, @"'objects' object group not found");
    
    NSMutableDictionary *spawnPoint = [_objects objectNamed:@"SpawnPoint"];
    NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
    
    int x = [[spawnPoint valueForKey:@"x"] intValue] * _map.scale;
    int y = [[spawnPoint valueForKey:@"y"] intValue] * _map.scale;
    
    _spawnPoint = CGPointMake(x, y);
    
}

-(void)initHurdles
{
    for (int i=0; i<_map.mapSize.width; i++) {
        for (int j=0; j<_map.mapSize.height;j++) {
            CGPoint coords = CGPointMake(i, j);
            NSString *obstacle = [self getObstaclePropertyForTileCoords:coords forKey:@"obstacle"];
            if (obstacle) {
                if ([obstacle compare:@"hurdle"] == NSOrderedSame) {
                    GameObject *hurdle = [GameObject objectWithSprite:[Sprite spriteWithFile:@"hurdle.png" toLayer:[[LayerManager sharedLayers] currentLayer]]];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [[hurdle getCCSprite] setAnchorPoint:ccp(0, 0.75f)];
                    [hurdle setPositionAtX:position.x Y:position.y];
                    [_obstacleSprites addObject:hurdle];
                }
            }
        }
    }
                                          
}

-(void)updateHurdles
{
    for(GameObject *hurdle in _obstacleSprites) {
        [hurdle setPosition:[hurdle getPosition]];
    }
    
}
                
-(CGPoint)getXYPositionForCoordinates:(CGPoint)coords
{
    //TODO: not sure why these need to be divided by 2 to get the right position yet
    //should make it clear what the 2.0 represents once figured out
    int scaledTileWidth = _map.tileSize.width * _map.scale / 2.0f;
    int scaledTileHeight = _map.tileSize.height * _map.scale / 2.0f;
    
    float x = coords.x * scaledTileWidth;
    float y = (_map.mapSize.height * scaledTileHeight) - coords.y * scaledTileHeight;

    return CGPointMake(x, y);
}

-(NSString*)getObstaclePropertyForTileCoords:(CGPoint)coords forKey:(NSString*)key
{
    NSString *returnVal = nil;
    
    int tileGid = [_obstacles tileGIDAt:coords];
    
    if (tileGid) {
        NSDictionary *properties = [_map propertiesForGID:tileGid];
        
        if (properties) {
            returnVal = [properties valueForKey:key];
        }
    }
    
    return returnVal;
}


-(CGPoint)getSpawnPoint
{
    return _spawnPoint;
}


@end
