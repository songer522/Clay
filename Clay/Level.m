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
#import "Player.h"
#import "Trigger.h"
#import "GameObjectController.h"

@implementation Level

@synthesize nextLevelName = _nextLevelName;
@synthesize gameObjects = _gameObjects;
@synthesize spawnPoint = _spawnPoint;
@synthesize obstacleSprites = _obstacleSprites;

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
        _switchingToNextLevel = false;
        
        [self initTiledMap:filename ObstacleLayer:obstacleLayer];
                
        [self loadLayers:layerList];

        _scale = [[UIScreen mainScreen] scale] / 2.0f;
        _map.scale = _scale;
        _parallaxLayers.scale = _scale;
        
        [self initSpawnPoint];
        
        [[Camera sharedCamera] setBoundaries:[self getLevelBoundaries]];
        
        [self scanThroughMapAndAddObjects];
        
        
        _collisionHandler = [CollisionDetection collisionHandlerWithMetaLayer:_meta Map:_map];


    }
    
    return self;
}

-(void)loadLayers:(NSString*)layerList;
{
    int currentZ = 0;
    
    _parallaxLayers = [CCParallaxNode node];
    
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
    
    [[[LayerManager sharedLayers] currentLayer] addChild:_parallaxLayers];
    
}

-(CGRect)getLevelBoundaries
{
    int width = _map.mapSize.width * _map.tileSize.width;
    int height = _map.mapSize.height * _map.tileSize.height;
    return CGRectMake(0, 0, width, height);
}

-(CGPoint)checkCollisionForObject:(GameObject*)object
{
    return [_collisionHandler checkCollisionForObject:object];
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
    
    [[[LayerManager sharedLayers] currentLayer] addChild:_map];
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

-(void)unloadLevel
{
    [_obstacleSprites release];
    [_nextLevelTrigger release];
    
}

-(void)scanThroughMapAndAddObjects
{
    _obstacleSprites = [[NSMutableArray alloc] initWithCapacity:100];
    _nextLevelTrigger = [[Trigger alloc] init];
    
    for (int i=0; i<_map.mapSize.width; i++) {
        for (int j=0; j<_map.mapSize.height;j++) {
            CGPoint coords = CGPointMake(i, j);
            
            NSString *special = [self getPropertyForTileCoords:coords forKey:@"special"];
            if (special) {
                if ([special compare:@"nextlevelNE"] == NSOrderedSame) {
                    _nextLevelTrigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    _nextLevelTrigger.direction = CGPointMake(1,-1);
                    _nextLevelTrigger.type = TRIGGER_NEXTLEVEL;
                } else if([special compare:@"checkpoint"] == NSOrderedSame) {
                    
                }
            }
            
            NSString *obstacle = [self getPropertyForTileCoords:coords forKey:@"obstacle"];
            if (obstacle) {
                GameObject *object = [_gameObjects loadGameObjectWithName:obstacle];
                CGPoint position = [self getXYPositionForCoordinates:coords];
                
                [object setPositionAtX:position.x Y:position.y];                
                [[object getCCSprite] setScale:_scale];                
                [_obstacleSprites addObject:object];
            }
        }
    }
                                          
}
                
-(CGPoint)getXYPositionForCoordinates:(CGPoint)coords
{
    //TODO: not sure why these need to be divided by 2 to get the right position yet
    //should make it clear what the 2.0 represents once figured out
    int scaledTileWidth = _map.tileSize.width / 2;
    int scaledTileHeight = _map.tileSize.height;
    
    float x = coords.x * scaledTileWidth;
    float y = (_map.mapSize.height * scaledTileHeight) - coords.y * scaledTileHeight;

    return CGPointMake(x, y);
}

-(NSString*)getPropertyForTileCoords:(CGPoint)coords forKey:(NSString*)key
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

-(bool)nextLevelTriggerCheck:(Player*)player
{
    bool returnVal = false;
    
    if (!_switchingToNextLevel) {
        if (player.x < _nextLevelTrigger.position.x ^ _nextLevelTrigger.direction.x == 1) {
            if(player.y < _nextLevelTrigger.position.x ^ _nextLevelTrigger.direction.y == 1) {
                _switchingToNextLevel = true;
                [[LevelManager shared] loadNextLevel];
                returnVal = true;
            }
        }
    }
    return returnVal;
}

-(void)update:(float)dt Velocity:(float)vx
{
    [self setPositionAtX:_x Y:_y];
    for(GameObject *obstacle in _obstacleSprites) {
        [obstacle update:dt];
    }
}


@end
