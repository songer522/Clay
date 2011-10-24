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
#import "MapObject.h"
#import "MapLayer.h"
#import "GameObjectController.h"
#import "GCState.h"
#import "GCHelper.h"

@implementation Level

@synthesize name = _name;
@synthesize nextLevelName = _nextLevelName;
@synthesize gameObjects = _gameObjects;
@synthesize spawnPoint = _spawnPoint;
@synthesize obstacleSprites = _obstacleMapObjects;
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
        
        _obstacleMapObjects = [[NSMutableArray alloc] initWithCapacity:100];
        _otherMapObjects = [[NSMutableArray alloc] initWithCapacity:100];
        _mapLayers = [[NSMutableDictionary alloc] initWithCapacity:12];
        _parallaxLayers = [[NSMutableArray alloc] initWithCapacity:12];
        
        [self initTiledMap:filename ObstacleLayer:obstacleLayer];
        
        //[[[LayerManager sharedLayers] currentLayer] addChild:_map];
        
        _scale = [[UIScreen mainScreen] scale] / 2.0f;
        
        [self scanThroughMapAndAddObjects];
                
        [self loadLayers:layerList Player:player];
        
        _map.scale = _scale;
        
        [[Camera sharedCamera] setBoundaries:[self getLevelBoundaries]];
        
        [_obstacles releaseMap];
        
        _collisionHandler = [CollisionDetection collisionHandlerWithMetaLayer:_meta Map:_map];

    }
    
    return self;
}

-(void)setThirdAction:(NSString*)action
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    [gameLayer.player setThirdAction:action];
    [[gameLayer getHud] setThirdAction:action];
}

-(void)loadLayers:(NSString*)layerList Player:(Player*)player
{
    int currentZ = 0;

    NSArray *layers = [layerList componentsSeparatedByString:@","];
    for (NSString *layerName in layers) {
        if ([layerName compare:@"actives"] == NSOrderedSame) {
            [self addObstaclesToMap];
            [player resetSprite:[[LayerManager sharedLayers] currentLayer]];
            //currentZ -= 1;
            continue;
        }
        
        CCTMXLayer *tmxLayer = [_map layerNamed:layerName];
        if (tmxLayer) {

            
            CCParallaxNode *node = [CCParallaxNode node];
            
            float speedx = [[tmxLayer propertyNamed:@"speedx"] floatValue] * _scale;
            float speedy = [[tmxLayer propertyNamed:@"speedy"] floatValue] * _scale;
            float offsety = [[tmxLayer propertyNamed:@"offsety"] floatValue];

            CGPoint offsetPoint = ccp(0, 0);
            if (offsety && offsety!= 0.0f && speedy != 0.0f) {
                offsetPoint = ccp(0, offsety * _map.tileSize.width);
            }
            
            [tmxLayer removeFromParentAndCleanup:NO];
            [node addChild:tmxLayer z:currentZ parallaxRatio:ccp(speedx,speedy) positionOffset:offsetPoint];
            
            [_parallaxLayers addObject:node];
            
            
            [[[LayerManager sharedLayers] currentLayer] addChild:node z:currentZ];
            
            [self addMapObjectsAboveLayer:tmxLayer ParallaxRatio:ccp(speedx,speedy)];
            //currentZ += 1;
            
        }
    }
}

-(void)addObstaclesToMap
{
    for (MapObject *mapObject in _obstacleMapObjects) {
        GameObject *obstacle = mapObject.object;
        [[[LayerManager sharedLayers] currentLayer] addChild:[obstacle getCCSprite]];
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

-(void)setPositionAtX:(float)x Y:(float)y
{
    _x = x;
    _y = y;
    for (CCParallaxNode *node in _parallaxLayers) {
        [node setPosition:[[Camera sharedCamera] convertToScreenXY:CGPointMake(_x,_y)]];
    }
    
    for (MapObject *mapObject in _otherMapObjects) {
        //[mapObject setPosition:CGPointMake(_x, _y)];
    }
}

-(void)initTiledMap:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer
{
    
    [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];
    _map = [[CCTMXTiledMap tiledMapWithTMXFile:filename] retain];
    
    _meta = [_map layerNamed:@"meta"];
    _meta.visible = NO;
        
    _obstacles = [_map layerNamed:obstacleLayer];
    _obstacles.visible = NO;
}

-(void)unloadLevel
{
    [[[LayerManager sharedLayers] currentLayer] removeChild:_map cleanup:YES];
    for (CCParallaxNode *node in _parallaxLayers) {
        [[[LayerManager sharedLayers] currentLayer] removeChild:node cleanup:YES];
    }
}

-(void)scanThroughMapAndAddObjects
{
    _obstacleMapObjects = [[NSMutableArray alloc] initWithCapacity:100];
    _triggers = [[NSMutableArray alloc] initWithCapacity:30];
    
    for (int i=0; i<_map.mapSize.width; i++) {
        for (int j=0; j<_map.mapSize.height;j++) {
            CGPoint coords = CGPointMake(i, j);
            
            NSString *special = [self getPropertyForTileCoords:coords forKey:@"special"];
            NSString *layerBelow = [self getPropertyForTileCoords:coords forKey:@"layerBelow"];
            
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
                } else if([special compare:@"jimAppearance1"] == NSOrderedSame) {
                    CGPoint position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    GameObject *jim = [_gameObjects loadGameObjectWithName:@"jim" AddToLayer:NO];
                    [jim setPosition:position];
                    [jim setStartingPosition:position];
                    [jim getCCSprite].scale = 0.75f;
                    MapObject *mapObject = [MapObject mapObjectWithSprite:jim AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                }
            }
            
            NSString *obstacle = [self getPropertyForTileCoords:coords forKey:@"obstacle"];
            if (obstacle) {
                GameObject *object = [_gameObjects loadGameObjectWithName:obstacle AddToLayer:NO];
                CGPoint position = [self getXYPositionForCoordinates:coords];
                [object setPositionAtX:position.x Y:position.y];
                [object setStartingPosition:position];
                [[object getCCSprite] setScale:_scale];                
                
                MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:@"main0"];
                [_obstacleMapObjects addObject:mapObject];
            }
            
            NSString *objectName = [self getPropertyForTileCoords:coords forKey:@"object"];
            
            if (objectName) {
                if (![objectName isEqualToString:@"lighting"]) {  //TEMPORARY: disabling lights until we decide we don't want them
                    
                    GameObject *object = [_gameObjects loadGameObjectWithName:objectName AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    
                    if (!layerBelow) {
                        layerBelow = @"main0";
                    }
                    
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                                        
                }
            }
        }
    }
                                          
}


-(void)addMapObjectsAboveLayer:(CCTMXLayer*)layer ParallaxRatio:(CGPoint)ratio
{
    for (MapObject *mapObject in _otherMapObjects) {
        if (!mapObject.placed && [mapObject.layerAbove isEqualToString:layer.layerName]) {
            mapObject.parallaxRatio = ratio;
            [[[LayerManager sharedLayers] currentLayer] addChild:[mapObject.object getCCSprite]];
            mapObject.placed = true;
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
    for (GameObject *obstacle in _obstacleMapObjects) {
        [obstacle reset];
    }
}

-(bool)testCollisions:(GameObject*)source
{
    bool collision = false;
    
    for (MapObject *mapObject in _obstacleMapObjects) {
        GameObject *obstacle = mapObject.object;
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
    
    for (MapObject *mapObject in _obstacleMapObjects) {
        GameObject *obstacle = mapObject.object;
        if(obstacle!=source && !obstacle.collided && !obstacle.isAggressive) {
            collision = [self testCollisionWithGameObject:obstacle Source:source];
            if (collision) {
                if (source.CurrentBehavior == COLLISION_BEHAVIOR_HEN_KICKED) {
                    NSLog(@"Counting Chicken Kicked Into Cow");
                    int maxKicksIntoCow = 10;
                    
                    if ([GCState sharedInstance].chickensKickedIntoCows < maxKicksIntoCow) {
                        [GCState sharedInstance].chickensKickedIntoCows++;
                        [[GCState sharedInstance] save];
                        
                        double pctComplete = ((double) [GCState sharedInstance].chickensKickedIntoCows / (int)maxKicksIntoCow) * 100.0;
                        [[GCHelper sharedInstance] reportAchievement:gcAchievementChickensKickedIntoCows percentComplete:pctComplete];
                        
                        NSLog(@"Pct Complete - Chickens Kicked Into Cows: %f", pctComplete);
                    }
                    
                    if ([GCState sharedInstance].chickensKickedIntoCows >= maxKicksIntoCow) {
                        //ADD CODE TO DISPLAY ACHIEVEMENT
                        NSLog(@"DISPLAY Chicken Kick Achievement");
                    }
                
                }
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
    for(MapObject *obstacle in _obstacleMapObjects) {
        [obstacle.object update:dt];
    }
    
    for (MapObject *objects in _otherMapObjects) {
        [objects.object update:dt];
    }
}

-(void)dealloc
{
    [_main release];
    [_meta release];
    [_obstacles release];
    [_map release];
    [_objects release];
    [_parallaxLayers removeAllObjects];
    [_parallaxLayers release];
    [_postLevelComicName release];
    [_musicName release];
    [_gameObjects release];
    [_triggers removeAllObjects];
    [_triggers release];
    [_obstacleMapObjects removeAllObjects];
    [_obstacleMapObjects release];
    [_otherMapObjects removeAllObjects];
    [_otherMapObjects release];
    [_triggers removeAllObjects];
    [_triggers release];
    [_collisionHandler release];
    [_nextLevelName release];
    [super dealloc];
}


@end
