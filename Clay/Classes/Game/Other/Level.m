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
#import "Projectile.h"
#import "HudLayer.h"
#import "GameSettings.h"
#import "RegionManager.h"

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
@synthesize preComicName = _preComicName;

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
        
        _obstacleManager = [[RegionManager alloc] init];
        //_backgroundManager = [[RegionManager alloc] init];
        
        [self initTiledMap:filename ObstacleLayer:obstacleLayer];
       
        
        [_obstacleManager prepareArrays:_map.mapSize.width];
        //[_backgroundManager prepareArrays:_map.mapSize.width];
        
        //[[[LayerManager sharedLayers] currentLayer] addChild:_map];
    
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)
        {
            _divide = 2.0f;
        }
        else
        {
            _divide = 1.0f;
        }
            
        _scale = [[UIScreen mainScreen] scale] / _divide;
        
        if ([GameSettings usingHighResolutionGraphics])
        {
            _divide = 2.0f;
        }
        else
        {
            _divide = 1.0f;
        }
        
        [self scanThroughMapAndAddObjects];
                
        [self loadLayers:layerList Player:player];
        
        _map.scale = _scale;
        
        [[Camera sharedCamera] setBoundaries:[self getLevelBoundaries]];
        
        [_obstacles releaseMap];
        
        _collisionHandler = [CollisionDetection collisionHandlerWithMetaLayer:_meta Map:_map];

    }
    
    return self;
}

-(void)setHudButtonsAndThirdAction:(NSString*)action
{
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    [gameLayer.player setThirdAction:action];
    [[gameLayer getHud] setHudButtonsAndThirdAction:action];
}

-(void)loadLayers:(NSString*)layerList Player:(Player*)player
{
    int currentZ = 0;

    NSArray *layers = [layerList componentsSeparatedByString:@","];
    for (NSString *layerName in layers) {
        if ([layerName compare:@"actives"] == NSOrderedSame) {
            [player setLedgeSprite:[[LayerManager sharedLayers] currentLayer]];
            
            [self addObstaclesToMapAndRegion];
            //[_obstacleManager printDescription];
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
            bool isOpaque = [[tmxLayer propertyNamed:@"opaque"] boolValue];
            
            CGPoint offsetPoint = ccp(0, 0);
            if (offsety && offsety!= 0.0f && speedy != 0.0f) {
                offsetPoint = ccp(0, offsety * _map.tileSize.width);
            }
            
            [tmxLayer removeFromParentAndCleanup:NO];
            [node addChild:tmxLayer z:currentZ parallaxRatio:ccp(speedx,speedy) positionOffset:offsetPoint];
            
            [_parallaxLayers addObject:node];
            
            if (isOpaque) {
                //so far nothing i know that we can do to cctmxlayer to change it opaque, but the code
                //to gain speed for it (with ccsprites) is: [background setBlendFunc:(ccBlendFunc) {GL_ONE,GL_ZERO}];
                //according to: http://www.cocos2d-iphone.org/forum/topic/9910
            }
            
            
            [[[LayerManager sharedLayers] currentLayer] addChild:node z:currentZ];
            
            [self addMapObjectsAboveLayer:tmxLayer ParallaxRatio:ccp(speedx,speedy)];
            //currentZ += 1;
            
        }
    }
    
}

-(void)addObstaclesToMapAndRegion
{
    for (MapObject *mapObject in _obstacleMapObjects) {
        GameObject *obstacle = mapObject.object;
        [[[LayerManager sharedLayers] currentLayer] addChild:[obstacle getCCSprite]];
        [[obstacle getCCSprite] setVisible:NO];
        [_obstacleManager addGameObject:obstacle];
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
    
    CGPoint position = [[Camera sharedCamera] convertToScreenXY:CGPointMake(_x,_y)];
    
    //round position to eliminate white artifacts (note, this is in points, so with retina, we want to round based
    //on pixels, so round based on double the size first, then half the size for point pixel value
    if ([GameSettings usingHighResolutionGraphics]) {
        position.x = roundf(position.x * 2.0f) / 2.0f;
        position.y = roundf(position.y * 2.0f) / 2.0f;
    } else {
        position.x = roundf(position.x);
        position.y = roundf(position.y);        
    }
    
    for (CCParallaxNode *node in _parallaxLayers) {
        [node setPosition:position];
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
    
    for (MapObject *mapObject in _obstacleMapObjects) {
        if (mapObject!=nil) {
            [[mapObject.object getCCSprite] removeFromParentAndCleanup:YES];
        }
    }
    
    for (MapObject *mapObject in _otherMapObjects) {
        if (mapObject!=nil) {
            [[mapObject.object getCCSprite] removeFromParentAndCleanup:YES];
        }
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
                } else if([special isEqualToString:@"checkpoint"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.direction = CGPointMake(1, -1);
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpoint" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:@"main0"];
                    [_otherMapObjects addObject:mapObject];
                    
                }else if([special isEqualToString:@"checkpoint8bit"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.direction = CGPointMake(1, -1);
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpoint8bit" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:@"main0"];
                    [_otherMapObjects addObject:mapObject];
                    
                } 
                else if([special compare:@"spawnpoint"] == NSOrderedSame) {
                    _spawnPoint = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                } else if([special compare:@"jimAppearance1"] == NSOrderedSame) {
                    CGPoint position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    GameObject *jim = [_gameObjects loadGameObjectWithName:@"jim" AddToLayer:NO];
                    [jim setPosition:position];
                    [jim setStartingPosition:position];
                    [jim getCCSprite].scale = 0.75f;
                    MapObject *mapObject = [MapObject mapObjectWithSprite:jim AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                } else if([special isEqualToString:@"shootTrigger"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.direction = CGPointMake(1, -1);
                    trigger.type = TRIGGER_BOSS_SHOOT;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
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
                
                
                GameObject *object = [_gameObjects loadGameObjectWithName:objectName AddToLayer:NO];
                
                
                CGPoint position = [self getXYPositionForCoordinates:coords];
                [object setPositionAtX:position.x Y:position.y];
                [object setStartingPosition:position];
                [[object getCCSprite] setScale:_scale];
                
                if (!layerBelow) {
                    layerBelow = @"main0";
                }

                
                if ([objectName isEqualToString:@"jimSpaceShip"]) {
                    [[LevelManager shared] receiveBoss:[object getBoss]];
                }
                
                MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
                [_otherMapObjects addObject:mapObject];
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
            
            //add to background regionmanager
            //[_backgroundManager addGameObject:mapObject.object];
            [[mapObject.object getCCSprite] pauseSchedulerAndActions];
        }
    }
}
                
-(CGPoint)getXYPositionForCoordinates:(CGPoint)coords
{
    //TODO: not sure why these need to be divided by 2 to get the right position yet
    //should make it clear what the 2.0 represents once figured out
    
    int scaledTileWidth = _map.tileSize.width / _divide;
    int scaledTileHeight = _map.tileSize.height / _divide;
    
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
    for (MapObject *obstacle in _obstacleMapObjects) {
        [obstacle reset];
        
    }
    /*
    for (MapObject *object in _otherMapObjects) {
        [object reset];
    }*/
}

-(void)resetTriggers
{
    for (Trigger *trigger in _triggers) {
        if (trigger.canBeReset) {
            trigger.triggered = false;
        }
    }
}

-(bool)testCollisions:(GameObject*)source
{
    bool collision = false;
    GameLayer *gameLayer = [[LayerManager sharedLayers] currentLayer];
    
    NSMutableArray *obstacles = [_obstacleManager getActiveGameObjectList];
    for (GameObject *obstacle in obstacles) {
        if(!obstacle.collided) {
            
            int dist = abs([source getPosition].x - [obstacle getPosition].x);
            if (dist < 250) { //don't do the full collision detection if they're not even close to each other.
                collision = [self testCollisionWithGameObject:obstacle Source:source];
                if (collision) {
                    [gameLayer.player startCollision:[obstacle startCollision] Source:obstacle];
                }
            }

            if(dist < 900) {
                
                //if aggressive, test the object against the non-aggressive objects (example of aggressive: chickens in barn level)
                if (!collision && obstacle.isAggressive) {
                    [self testCollisionsForAggressive:obstacle];
                }
            }
        }    
        
        //test the gameobject's active projectile, if any (example: zombie heads)
        Projectile *projectile = [obstacle getProjectile];
        if (projectile!=nil && [projectile getActive]) {
            if([self testCollisionWithGameObject:projectile Source:source]) {
                [gameLayer.player startCollision:PLAYER_EFFECT_COLLIDE Source:projectile];
                [projectile startCollision];
            }                    
        }
    }
    return collision;
}

-(bool)testCollisionsForAggressive:(id<Collidable>)source
{
    bool collision = false;
    
    NSMutableArray *obstacles = [_obstacleManager getActiveGameObjectList];
    for (GameObject *obstacle in obstacles) {
        if(![obstacle hasBeenHit] && [obstacle canAggressiveHit]) {
            collision = [self testCollisionWithGameObject:obstacle Source:source];
            if (collision) {
                if ([source getCollisionBehavior] == COLLISION_BEHAVIOR_HEN_KICKED) {
                    //NSLog(@"Counting Chicken Kicked Into Cow");
                    int maxKicksIntoCow = 10;
                    
                    if ([GCState sharedInstance].chickensKickedIntoCows < maxKicksIntoCow) {
                        [GCState sharedInstance].chickensKickedIntoCows++;
                        [[GCState sharedInstance] save];
                        
                        double pctComplete = ((double) [GCState sharedInstance].chickensKickedIntoCows / (int)maxKicksIntoCow) * 100.0;
                        [[GCHelper sharedInstance] reportAchievement:gcAchievementChickensKickedIntoCows percentComplete:pctComplete];
                        
                        //NSLog(@"Pct Complete - Chickens Kicked Into Cows: %f", pctComplete);
                    }
                    
                    if ([GCState sharedInstance].chickensKickedIntoCows >= maxKicksIntoCow) {
                        //ADD CODE TO DISPLAY ACHIEVEMENT
                        //NSLog(@"DISPLAY Chicken Kick Achievement");
                    }
                
                }
                [obstacle startCollision];
                break;
            }
        }        
    }
    return collision;
}

-(bool)testCollisionWithGameObject:(id<Collidable>)target Source:(id<Collidable>)source
{
    bool collision = true;
    
    float scale = 1;
    
    //both of these are wrong in the same way, so they seem right, but they wouldn't match with the world
    
    CGPoint position = [target getCCSprite].position;
    CGRect boundingBox = [target getBoundingBox];
    float targetLeft = position.x - (boundingBox.origin.x * scale);
    float targetRight = targetLeft + (boundingBox.size.width * scale);
    float targetBottom = position.y - (boundingBox.origin.y * scale);
    float targetTop = targetBottom + (boundingBox.size.height * scale);
    
    position = [source getCCSprite].position;
    boundingBox = [source getBoundingBox];
    float sourceLeft = position.x - (boundingBox.origin.x * scale);
    float sourceRight = sourceLeft + (boundingBox.size.width * scale);
    float sourceBottom = position.y - (boundingBox.origin.y * scale);
    float sourceTop = sourceBottom + (boundingBox.size.height * scale);
    
    
    //assume that a collision happened unless the sides of the
    //target object indicate there can't possibly be
    //an intersection. by checking all four sides this gives
    //full detection, and is more efficient than other methods
    if (sourceBottom > targetTop) { collision = false; }
    if (sourceTop < targetBottom) { collision = false; }
    if (sourceRight < targetLeft) { collision = false; }
    if (sourceLeft > targetRight) { collision = false; }
    
    return collision;
}


//TODO: only supporting one trigger per update, for now. not ideal though and we will eventually need to extend this
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


-(GameObject*)addObstacleNamed:(NSString*)name
{
    GameObject *obstacle = [_gameObjects loadGameObjectWithName:name];                          
    MapObject *mapObject = [MapObject mapObjectWithSprite:obstacle AboveLayer:@"main0"];
    [_obstacleMapObjects addObject:mapObject];
    return obstacle;
}

-(NSMutableArray*)getActiveGameObjectList
{
    return [_obstacleManager getActiveGameObjectList];
}

-(void)update:(float)dt Velocity:(float)vx
{
    [self setPositionAtX:_x Y:_y];
    
    CGPoint playerPos = [[[LayerManager sharedLayers] getPlayer] getPosition];
    [_obstacleManager changeRegionsBasedOnX:(playerPos.x - 256)];
    //[_backgroundManager changeRegionsBasedOnX:(playerPos.x - 128)];
    
    NSMutableArray *obstacles = [_obstacleManager getActiveGameObjectList];
    for (GameObject *obstacle in obstacles) {
        [obstacle update:dt];
    }
    
    //NSMutableArray *objects = [_backgroundManager getActiveGameObjectList];
    //for (GameObject *object in objects) {
    //    [object update:dt];
    //}
    
    for (MapObject *objects in _otherMapObjects) {
        [objects.object update:dt];
    }
}

-(void)dealloc
{
    _main = nil;
    _meta = nil;
    _obstacles = nil;
    
    [self unloadLevel];
    
    [_map release];
    
    [_name release];
    [_collisionHandler release];
    
    [_obstacleMapObjects removeAllObjects];
    [_obstacleMapObjects release];
    [_otherMapObjects removeAllObjects];
    [_otherMapObjects release];
    [_triggers removeAllObjects];
    [_triggers release];
    
    [_parallaxLayers removeAllObjects];
    [_parallaxLayers release];
    [_mapLayers removeAllObjects];
    [_mapLayers release];
    
    [_preComicName release];
    [_postLevelComicName release];
    [_musicName release];
    [_nextLevelName release];
    [_playerThirdActionName release];
    
    [_obstacleManager release];

    _gameObjects = nil; //is maintained throughout the game, so keep.
    
    [_nextLevelName release];
    
    [super dealloc];
}


@end
