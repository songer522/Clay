//
//  Level.m
//  Clay
//
//  Created by Brian Cable on 9/6/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Level.h"

#import "cocos2d.h"
#import "CollisionDetection.h"
#import "Camera.h"
#import "GameObject.h"
#import "Collision.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "GameObjectController.h"

@implementation Level

@synthesize nextLevelName = _nextLevelName;
@synthesize gameObjects = _gameObjects;

+(id)levelWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects
{
    return [[self alloc] initWithFilename:filename ObstacleLayer:obstacleLayer LayerList:layerList GameObjectController:gameObjects];
}


-(id)initWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _gameObjects = gameObjects;
        
        _obstacleSprites = [[NSMutableArray alloc] initWithCapacity:100];
        
        [self initTiledMap:filename ObstacleLayer:obstacleLayer];
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_map];
        
        _scale = [[UIScreen mainScreen] scale] / 2.0f;

        _parallaxLayers = [CCParallaxNode node];

        [self loadLayers:layerList];
        
        
        _map.scale = _scale;
        _parallaxLayers.scale = _scale;
        
        [self initSpawnPoint];
        
        [[Camera sharedCamera] setBoundaries:[self getLevelBoundaries]];
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_parallaxLayers];
        
        [self initHurdles];
        
        _collisionHandler = [CollisionDetection collisionHandlerWithMetaLayer:_meta Map:_map];


    }
    
    return self;
}

-(void)loadLayers:(NSString*)layerList;
{
    int currentZ = 0;

    NSArray *layers = [layerList componentsSeparatedByString:@","];
    for (NSString *layerName in layers) {
        CCTMXLayer *tmxLayer = [_map layerNamed:layerName];
        if (tmxLayer) {
            float speedx = [[tmxLayer propertyNamed:@"speedx"] floatValue] * _scale;
            float speedy = [[tmxLayer propertyNamed:@"speedy"] floatValue] * _scale;
            [tmxLayer removeFromParentAndCleanup:NO];
            [_parallaxLayers addChild:tmxLayer z:currentZ parallaxRatio:ccp(speedx,speedy) positionOffset:ccp(0, 0)];
            currentZ++;
        }
    }
}

-(CGPoint)tileCoordForPosition:(CGPoint)position
{
    int scaledTileWidth = _map.tileSize.width / 2.0f;
    int scaledTileHeight = _map.tileSize.height;
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
    int width = _map.mapSize.width * _map.tileSize.width;
    int height = _map.mapSize.height * _map.tileSize.height;
    return CGRectMake(0, 0, width, height);
}

-(int)getTopYPositionForTileCoords:(CGPoint)coords atX:(int)x ForTileProperty:(NSString*)property
{
    int scaledTileWidth = _map.tileSize.width;
    int scaledTileHeight = _map.tileSize.height;

    float topOfTileY = (_map.mapSize.height - coords.y) * scaledTileHeight;

    
    int tileX = x % scaledTileWidth;
    
    int y = 0;
    if ([property compare:@"none"] == NSOrderedSame) {
        y = topOfTileY - scaledTileHeight;
    } else if([property compare:@"leftslant"] == NSOrderedSame) {
        y = topOfTileY - scaledTileHeight + tileX;
    } else if([property compare:@"rightslant"] == NSOrderedSame) {
        y = topOfTileY + tileX;
    }
    
    NSLog(@"CX: %.0f, CY: %.0f, X: %.2d, Y: %.2d, Collision: %@",coords.x, coords.y, x,y,property);
    
    return y;
}

-(float) checkRightCollisionAtPoint:(CGPoint)point
{
    
    CGPoint tileCoordinates = [self tileCoordForPosition:point];
    NSString *collisionProperty = [self getCollisionPropertyForTileCoords:tileCoordinates];

    bool colliding = true;
    while (colliding) {
        if ([collisionProperty compare:@"full"] != NSOrderedSame || tileCoordinates.x <=0) {
            colliding = false;
        } else {
            tileCoordinates.x -= 1;
            collisionProperty = [self getCollisionPropertyForTileCoords:tileCoordinates];
        }
    }
    
    return tileCoordinates.x * (_map.tileSize.width/2.0f);
}

-(bool) outOfBoundsTest:(CGPoint)testPosition
{
    return false;
}

-(CGPoint)checkCollisionForObject:(GameObject*)object
{
    return [_collisionHandler checkCollisionForObject:object];
}
/*
-(CGPoint)checkCollisionForObject:(GameObject*)object
    CGPoint startPosition = [object getPosition];   
    CGPoint testPosition = startPosition;
    CGPoint prevPosition = [object getPreviousPosition];
    
    float dx = startPosition.x - prevPosition.x;
    float dy = startPosition.y - prevPosition.y;
    
    float dist = sqrtf(dx*dx + dy*dy);
    float testDist = dist;
    float angle = atan2f(dy, dx);
    
    bool colliding = true;
    bool singleCollision = false;
    bool groundCollision = false;
    bool testYOnlyFirst = true;
    
    while (colliding) {
        if ([self outOfBoundsTest:testPosition]) {
            colliding = false;
            break;
        }
        
        CGPoint coords = [self tileCoordForPosition:testPosition];
        NSString *collisionProperty = [self getCollisionPropertyForTileCoords:coords];
        
        CGPoint pointWithinTile = CGPointMake((int)testPosition.x % (int)_map.tileSize.width, (int)testPosition.y % (int)_map.tileSize.height);
        
        if (!singleCollision) {
            NSLog(@"CoordX: %.0f, PointInTileX: %.2f,DX: %.2f",coords.x,pointWithinTile.x,dx);
        }
        
        //NSLog(@"Property: %@",collisionProperty);
        
        //check if the test position collides with current tile
        if ([collisionProperty compare:@"full"] == NSOrderedSame) {
            singleCollision = true;
            groundCollision = true;
        } else if ([collisionProperty compare:@"none"] == NSOrderedSame) {
            colliding = false;
            break;
        } else if([collisionProperty compare:@"leftslant"] == NSOrderedSame) {
            if (pointWithinTile.y > pointWithinTile.x) {
                colliding = false;
                break;
            } else {
                singleCollision = true;
                testPosition.y += pointWithinTile.x - pointWithinTile.y;
                colliding = false;
                break;                
            }
        } else if([collisionProperty compare:@"rightslant"] == NSOrderedSame) {
            if (pointWithinTile.y > (_map.tileSize.width - pointWithinTile.x)) {
                colliding = false;
                break;
            } else {                
                singleCollision = true;
            }
        }
        
        if (colliding) {
            if (testDist < 0.01f) {
                if (testYOnlyFirst) {
                    testDist = dist;
                    testYOnlyFirst = false;
                } else {
                    colliding = false;
                    testPosition.x = prevPosition.x;
                    testPosition.y = prevPosition.y;                    
                }
            } else {
                if(testDist > 1.0f) {
                    testDist-=1;
                } else {
                    testDist = testDist / 2.0f;
                }
                if (!testYOnlyFirst) {
                    testPosition.x = prevPosition.x + testDist * cosf(angle);                    
                }
                testPosition.y = prevPosition.y - testDist * sin(angle);                
            }
        }
    }
    
    if (groundCollision || testYOnlyFirst) {
        [[object getCollision] processNewCollisionState:COLLISION_STATE_GROUNDED];
    } else if (singleCollision) {
        [[object getCollision] processNewCollisionState:COLLISION_STATE_BUMPED_WALL];
    } else {
        [[object getCollision] processNewCollisionState:COLLISION_STATE_MIDAIR];
    }
    
    return CGPointMake(testPosition.x,testPosition.y);
}*/


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
    [self updateHurdles:dt];
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
    [_parallaxLayers setPosition:[[Camera sharedCamera] convertToScreenXY:CGPointMake(_x, _y)]];
}

-(void)initTiledMap:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer
{
    
    [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
    _map = [CCTMXTiledMap tiledMapWithTMXFile:filename];
    
    _meta = [_map layerNamed:@"meta"];
    _meta.visible = NO;
        
    _obstacles = [_map layerNamed:obstacleLayer];
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
                    GameObject *hurdle = [_gameObjects loadGameObjectWithName:@"hurdle"];
                    
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [hurdle setPositionAtX:position.x Y:position.y];
                    
                    [[hurdle getCCSprite] setScale:_scale];
                    
                    [_obstacleSprites addObject:hurdle];
                }
            }
        }
    }
                                          
}

-(void)updateHurdles:(float)dt
{
    for(GameObject *hurdle in _obstacleSprites) {
        [hurdle update:dt];
    }
    
}
                
-(CGPoint)getXYPositionForCoordinates:(CGPoint)coords
{
    //TODO: not sure why these need to be divided by 2 to get the right position yet
    //should make it clear what the 2.0 represents once figured out
    int scaledTileWidth = _map.tileSize.width;
    int scaledTileHeight = _map.tileSize.height;
    
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

-(NSMutableArray*)getGameObjectsList
{
    return _obstacleSprites;
}

-(bool)testCollisions:(GameObject*)source
{
    bool collision = false;
    
    for (GameObject *obstacle in _obstacleSprites) {
        if(!obstacle.collided) {
            collision = [self testCollisionWithGameObject:obstacle Source:source];
            if (collision) {
                [obstacle startCollision];
                break;
            }
        }        
    }
    return collision;
}

-(bool)testCollisionWithGameObject:(GameObject*)target Source:(GameObject*)source
{
    bool collision = true;
    
    float targetLeft = target.x + target.boundingBox.origin.x;
    float targetRight = target.x + target.boundingBox.size.width;
    float targetTop = target.y + target.boundingBox.origin.y;
    float targetBottom = target.y + target.boundingBox.size.height;
    
    float sourceLeft = source.x + source.boundingBox.origin.x;
    float sourceRight = source.x + source.boundingBox.size.width;
    float sourceTop = source.y + source.boundingBox.origin.y;
    float sourceBottom = source.y + source.boundingBox.size.height;
    
    
    //assume that a collision happened unless the sides of the
    //target object indicate there can't possibly be
    //an intersection. by checking all four sides this gives
    //full detection, and is more efficient than other methods
    if (sourceBottom < targetTop) { collision = false; }
    if (sourceTop > targetBottom) { collision = false; }
    if (sourceRight < targetLeft) { collision = false; }
    if (sourceLeft > targetRight) { collision = false; }
    
    return collision;
}

-(CGPoint)getSpawnPoint
{
    return _spawnPoint;
}


@end
