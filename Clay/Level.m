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
#import "GameLayer.h"
#import "Collision.h"
#import "Sprite.h"
#import "LayerManager.h"
#import "Player.h"
#import "Trigger.h"
#import "GameObjectController.h"

@implementation Level

@synthesize name = _name;
@synthesize nextLevelName = _nextLevelName;
@synthesize gameObjects = _gameObjects;
@synthesize spawnPoint = _spawnPoint;
@synthesize obstacleSprites = _obstacleSprites;
@synthesize postLevelComicName = _postLevelComicName;
@synthesize musicName = _musicName;
@synthesize collisionHandler = _collisionHandler;
@synthesize playerThirdActionName = _playerThirdActionName;

+(id)levelWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects Player:(Player*)player
{
    return [[self alloc] initWithFilename:filename ObstacleLayer:obstacleLayer LayerList:layerList GameObjectController:gameObjects Player:player];
}


-(id)initWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects Player:(Player*)player
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _gameObjects = gameObjects;
        
        _obstacleSprites = [[NSMutableArray alloc] initWithCapacity:100];
        
        [self initTiledMap:filename ObstacleLayer:obstacleLayer];
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_map];
        
        _scale = [[UIScreen mainScreen] scale] / 2.0f;
        
        _parallaxLayersBack = [CCParallaxNode node];
        _parallaxLayersFront = [CCParallaxNode node];
        
        [self loadLayers:layerList];
        
        _map.scale = _scale;
        _parallaxLayersBack.scale = _scale;
        _parallaxLayersFront.scale = _scale;
        
        [[Camera sharedCamera] setBoundaries:[self getLevelBoundaries]];
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_parallaxLayersBack];
        
        [self scanThroughMapAndAddObjects];
        
        [player resetSprite:[[LayerManager sharedLayers] currentLayer]];
        
        [[[LayerManager sharedLayers] currentLayer] addChild:_parallaxLayersFront];
        
        [_obstacles releaseMap];
        
        _collisionHandler = [CollisionDetection collisionHandlerWithMetaLayer:_meta Map:_map];

        [player setThirdAction:_playerThirdActionName];
        
        //[[[[LayerManager sharedLayers] currentLayer] getHud] setThirdAction:_playerThirdActionName];
        
    }
    
    return self;
}

-(void)loadLayers:(NSString*)layerList;
{
    int currentZ = 0;
    CCParallaxNode *currentNode = _parallaxLayersBack;
    
    NSArray *layers = [layerList componentsSeparatedByString:@","];
    for (NSString *layerName in layers) {
        if ([layerName compare:@"actives"] == NSOrderedSame) {
            currentNode = _parallaxLayersFront;
            currentZ = 0;
            continue;
        }
        
        CCTMXLayer *tmxLayer = [_map layerNamed:layerName];
        if (tmxLayer) {
            float speedx = [[tmxLayer propertyNamed:@"speedx"] floatValue] * _scale;
            float speedy = [[tmxLayer propertyNamed:@"speedy"] floatValue] * _scale;
            float offsety = [[tmxLayer propertyNamed:@"offsety"] floatValue];

            CGPoint offsetPoint = ccp(0, 0);
            if (offsety && offsety!= 0.0f && speedy != 0.0f) {
                offsetPoint = ccp(0, offsety * _map.tileSize.width);
            }
            
            [tmxLayer removeFromParentAndCleanup:NO];
            [currentNode addChild:tmxLayer z:currentZ parallaxRatio:ccp(speedx,speedy) positionOffset:offsetPoint];
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

-(CGPoint)checkCollisionForObject:(GameObject*)object
{
    return [_collisionHandler checkCollisionForObject:object];
}
-(CGPoint)checkCollisionForObject2:(GameObject*)object
{
    return [_collisionHandler checkCollisionForObject2:object];
}

-(void)setPositionAtX:(float)x Y:(float)y
{
    _x = x;
    _y = y;
    [_parallaxLayersBack setPosition:[[Camera sharedCamera] convertToScreenXY:CGPointMake(_x, _y)]];
    [_parallaxLayersFront setPosition:[[Camera sharedCamera] convertToScreenXY:CGPointMake(_x, _y)]];
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

-(void)unloadLevel
{
    [[[LayerManager sharedLayers] currentLayer] removeChild:_map cleanup:YES];
    [[[LayerManager sharedLayers] currentLayer] removeChild:_parallaxLayersBack cleanup:YES];
    [[[LayerManager sharedLayers] currentLayer] removeChild:_parallaxLayersFront cleanup:YES];
}

-(void)scanThroughMapAndAddObjects
{
    _obstacleSprites = [[NSMutableArray alloc] initWithCapacity:100];
    _triggers = [[NSMutableArray alloc] initWithCapacity:30];
    
    for (int i=0; i<_map.mapSize.width; i++) {
        for (int j=0; j<_map.mapSize.height;j++) {
            CGPoint coords = CGPointMake(i, j);
            
            NSString *special = [self getPropertyForTileCoords:coords forKey:@"special"];
            if (special) {
                if ([special compare:@"nextlevelNE"] == NSOrderedSame) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.direction = CGPointMake(1,-1);
                    trigger.type = TRIGGER_NEXTLEVEL;
                    [_triggers addObject:trigger];
                } else if([special compare:@"checkpoint"] == NSOrderedSame) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.direction = CGPointMake(1, -1);
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                } else if([special compare:@"spawnpoint"] == NSOrderedSame) {
                    _spawnPoint = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                }
            }
            
            NSString *obstacle = [self getPropertyForTileCoords:coords forKey:@"obstacle"];
            if (obstacle) {
                GameObject *object = [_gameObjects loadGameObjectWithName:obstacle];
                CGPoint position = [self getXYPositionForCoordinates:coords];
                
                [object setPositionAtX:position.x Y:position.y];
                [object setStartingPosition:position];
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
    int scaledTileHeight = _map.tileSize.height / 2;
    
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

-(void)resetObstacles
{
    for (GameObject *obstacle in _obstacleSprites) {
        [obstacle reset];
    }
}

-(bool)testCollisions:(GameObject*)source
{
    bool collision = false;
    
    for (GameObject *obstacle in _obstacleSprites) {
        if(!obstacle.collided) {
            collision = [self testCollisionWithGameObject:obstacle Source:source];
            if (collision) {
                GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
                [gameLayer.player startCollision:[obstacle startCollision] Obstacle:obstacle];
                break;
            } else {
                if (obstacle.isAggressive) {
                    [self testCollisionsForAggressive:obstacle];
                }
            }
        }        
    }
    return collision;
}

-(bool)testCollisionsForAggressive:(GameObject*)source
{
    bool collision = false;
    
    for (GameObject *obstacle in _obstacleSprites) {
        if(obstacle!=source && !obstacle.collided && !obstacle.isAggressive) {
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
    
    //both of these are wrong in the same way, so they seem right, but they wouldn't match with the world
    
    float targetLeft = [[target getCCSprite] position].x - (target.boundingBox.origin.x * scale);
    float targetRight = targetLeft + (target.boundingBox.size.width * scale);
    float targetTop = [[target getCCSprite] position].y + (target.boundingBox.origin.y * scale);
    float targetBottom = targetTop + (target.boundingBox.size.height * scale);
    
    float sourceLeft = [[source getCCSprite] position].x - (source.boundingBox.origin.x * scale);
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


//TODO: only supporting one trigger per update, for now. not ideal though and we will eventually need to extend this
//TODO: also only assumes each trigger will be triggered whenever the player goes to the right and above the trigger point. eventually support more directions.
-(Trigger*)testTriggers:(Player*)player
{
    Trigger *returnTrigger = nil;
    
    for (Trigger *trigger in _triggers) {
        if (!trigger.triggered) {
            if (player.x < trigger.position.x ^ trigger.direction.x == 1) {
                if(player.y < trigger.position.y ^ trigger.direction.y == 1) {
                    returnTrigger = trigger;
                    trigger.triggered = true;                    
                }
            }            
        }
        
    }
    
    return returnTrigger;
}

-(void)update:(float)dt Velocity:(float)vx
{
    [self setPositionAtX:_x Y:_y];
    for(GameObject *obstacle in _obstacleSprites) {
        [obstacle update:dt];
    }
}

-(void)dealloc
{
    [_main release];
    [_meta release];
    [_obstacles release];
    [_map release];
    [_objects release];
    [_parallaxLayersBack release];
    [_parallaxLayersFront release];
    [_postLevelComicName release];
    [_musicName release];
    [_gameObjects release];
    [_triggers removeAllObjects];
    [_triggers release];
    [_obstacleSprites removeAllObjects];
    [_obstacleSprites release];
    [_triggers removeAllObjects];
    [_triggers release];
    [_collisionHandler release];
    [_nextLevelName release];
    [super dealloc];
}


@end
