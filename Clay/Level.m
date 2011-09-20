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

-(CGRect)getLevelBoundaries
{
    int width = _map.mapSize.width * _map.tileSize.width;
    int height = _map.mapSize.height * _map.tileSize.height;
    return CGRectMake(0, 0, width, height);
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

-(CGPoint)checkCollisionForObject:(GameObject*)object
{
    return [_collisionHandler checkCollisionForObject:object];
}

-(void)update:(float)dt Velocity:(float)vx
{
    [self setPositionAtX:_x Y:_y];
    [self updateHurdles:dt];
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
    
    float scale = 1;
    
    
    float targetLeft = [[target getCCSprite] position].x + (target.boundingBox.origin.x * scale);
    float targetRight = targetLeft + (target.boundingBox.size.width * scale);
    float targetTop = [[target getCCSprite] position].y + (target.boundingBox.origin.y * scale);
    float targetBottom = targetTop + (target.boundingBox.size.height * scale);
    
    float sourceLeft = [[source getCCSprite] position].x + (source.boundingBox.origin.x * scale);
    float sourceRight = sourceLeft + (source.boundingBox.size.width * scale);
    float sourceTop = [[source getCCSprite] position].y + (source.boundingBox.origin.y * scale);
    float sourceBottom = sourceTop + (source.boundingBox.size.height * scale);
    
    
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
