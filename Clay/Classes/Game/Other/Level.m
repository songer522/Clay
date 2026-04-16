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
#import "TextureManager.h"
#import "RegionManager.h"
#import "PlayerAction.h"
#import "Boss.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

static CGRect CollisionRectForObject(id<Collidable> object)
{
    // Most legacy obstacles are visually placed with sprite offsets, so collisions
    // need to follow the rendered sprite position instead of the raw world origin.
    CGPoint position = [object getCCSprite].position;
    CGRect boundingBox = [object getBoundingBox];
    CGRect rect = CGRectMake(position.x - boundingBox.origin.x,
                             position.y - boundingBox.origin.y,
                             boundingBox.size.width,
                             boundingBox.size.height);
    
    // Some very low legacy phone-era obstacles need a little extra overlap on
    // modern phones so the player's feet still enter the intended effect area.
    if (!IS_IPAD && [object isKindOfClass:[GameObject class]]) {
        GameObject *gameObject = (GameObject *)object;
        NSString *spriteName = [[gameObject getSprite] name];

        if (gameObject.isHurdle && boundingBox.size.height <= 15.0f && boundingBox.size.width <= 15.0f) {
            rect.origin.x -= 36.0f;
            rect.size.width += 42.0f;
            rect.size.height += 10.0f;
        } else if ([spriteName isEqualToString:@"Track_Sandpit_1.png"]) {
            rect.origin.x -= 18.0f;
            rect.size.width += 36.0f;
            rect.origin.y -= 10.0f;
            rect.size.height += 18.0f;
        }
    }
    
    return rect;
}

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

+(id)levelWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects Player:(Player*)player Name:(NSString*)levelName
{
    return [[self alloc] initWithFilename:filename ObstacleLayer:obstacleLayer LayerList:layerList GameObjectController:gameObjects Player:player Name:levelName];
}


-(id)initWithFilename:(NSString*)filename ObstacleLayer:(NSString*)obstacleLayer LayerList:(NSString*)layerList GameObjectController:(GameObjectController*)gameObjects Player:(Player*)player Name:(NSString*)levelName
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        _gameLayer = [[LayerManager sharedLayers] currentLayer];
        _player = player;

        _gameObjects = gameObjects;
        
        _obstacleMapObjects = [[NSMutableArray alloc] initWithCapacity:100];
        _otherMapObjects = [[NSMutableArray alloc] initWithCapacity:100];
        _mapLayers = [[NSMutableDictionary alloc] initWithCapacity:7];
        _parallaxLayers = [[NSMutableArray alloc] initWithCapacity:7];
        //_obstacleSpriteBatch = [CCSpriteBatchNode batchNodeWithTexture:
        
        _obstacleManager = [[RegionManager alloc] init];
        //_backgroundManager = [[RegionManager alloc] init];
        
        NSString *fullFileName = [NSString stringWithString:[self getFullMapFilename:filename]];
        [self initTiledMap:fullFileName ObstacleLayer:obstacleLayer];
        //[self initTiledMap:filename ObstacleLayer:obstacleLayer];
        
        [_obstacleManager prepareArrays:_map.mapSize.width];
        //[_backgroundManager prepareArrays:_map.mapSize.width];
        
        //[[[LayerManager sharedLayers] currentLayer] addChild:_map];
        if (IS_IPAD)
        {
            _divide = 1.0f;
        }
        else if ([[GameSettings shared] usingHighResolutionGraphics])
        {
            _divide = 2.0f;
        }
        else
        {
            _divide = 1.0f;
        }
        
        
        _scale = [GameSettings currentRenderScale] / _divide;
        
        [self scanThroughMapAndAddObjects];
                
        [self loadLayers:layerList Player:player Name:levelName];
        
        _map.scale = _scale;
        
        [_obstacles releaseMap];
        
        _collisionHandler = [CollisionDetection collisionHandlerWithMetaLayer:_meta Map:_map];
        
        _levelNumber = [[levelName substringFromIndex:5] intValue];
        
        NSString *mode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
        if([mode isEqualToString:@"timed"]) {
            _isTimedMode = true;
        } else {
            _isTimedMode = false;
        }

    }
    
    return self;
}

-(NSString*)getFullMapFilename:(NSString*)basename
{
    NSString *mode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
    NSString *difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    
    return [NSString stringWithFormat:@"%@_%@_%@",mode,difficulty,basename];
}

-(void)setHudButtonsAndThirdAction:(NSString*)action
{
    [_player setThirdAction:action];
    [[_gameLayer getHud] setHudButtonsAndThirdAction:action];
}

-(void)loadLayers:(NSString*)layerList Player:(Player*)player Name:(NSString*)levelName
{
    int currentZ = 0;

    [_gameLayer stopRainyLevel];

    
    NSArray *layers = [layerList componentsSeparatedByString:@","];
    for (NSString *layerName in layers) {
        if([layerName isEqualToString:@"front-1"]) 
        {
            if([levelName isEqualToString:@"level11"]) 
            {
                [self addObstaclesToMapWithBehavior:COLLISION_BEHAVIOR_DARK_SPIKES];
            }
        }  
         if([layerName isEqualToString:@"front-1"]) 
        {
            if([levelName isEqualToString:@"level4"]) 
            {
                [self addObstaclesToMapWithBehavior:COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_BD];
                 [self addObstaclesToMapWithBehavior:COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST_BD];
            }
        }
        
        if ([layerName isEqualToString:@"front-1"]) 
        {
            //stop existing rainylevel, and start new one if right level
            if([levelName isEqualToString:@"level9"]) 
            {
                [self addObstaclesToMapWithBehavior:COLLISION_BEHAVIOR_RAINY_SQUIRREL];
                //[self addObstaclesToMapWithBehavior:COLLISION_BEHAVIOR_FROG_SQUASH];
            }
        } 
        else if ([layerName isEqualToString:@"ledges"]) 
        {
            //stop existing rainylevel, and start new one if right level
            if([levelName isEqualToString:@"level9"]) 
            {
                [_gameLayer initializeRainyLevel];
            }
        } 
        else if ([layerName compare:@"actives"] == NSOrderedSame) 
        {
            
            //[player setLedgeSprite:[[LayerManager sharedLayers] currentLayer]];
            
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
            
            CGPoint offsetPoint = ccp(0, 5);//It was (0,0), changed to(0,5) to fixed iPad version's top empty bar 
            
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

-(void)addObstaclesToMapWithBehavior:(CollisionBehavior)behavior
{
    for (MapObject *mapObject in _obstacleMapObjects) {
        GameObject *obstacle = mapObject.object;
        if ([obstacle getCollisionBehavior] == behavior) {
            //it's possible the obstacle has already been placed. if it has, we need to remove and re-add it.
            if (mapObject.placed) {
                [[obstacle getCCSprite] removeFromParentAndCleanup:NO];
            }
            [[[LayerManager sharedLayers] currentLayer] addChild:[obstacle getCCSprite]];
            [[obstacle getCCSprite] setVisible:NO];
            [_obstacleManager addGameObject:obstacle];
            mapObject.placed = true;
        }
    }    
}

-(void)addObstaclesToMapAndRegion
{

    //_obstacleSpriteBatch = [[CCSpriteBatchNode batchNodeWithFile:[[TextureManager shared] getBatchObstacleFilename]] retain];
    
   // [[[LayerManager sharedLayers] currentLayer] addChild:_obstacleSpriteBatch];
    
   // [[LayerManager sharedLayers] setWorkingLayer:_obstacleSpriteBatch];
    
    for (MapObject *mapObject in _obstacleMapObjects) {
        GameObject *obstacle = mapObject.object;
        if (!mapObject.placed) {
            
            @try {
                if (obstacle.useDefaultBatchNode) {
                    Projectile *proj = [obstacle getProjectile];
                    
                    if (proj!=nil && proj.isBehindObstacle) {
                        [[[LayerManager sharedLayers] currentLayer] addChild:[proj getCCSprite]];
                    }
                    
                    [[[LayerManager sharedLayers] currentLayer] addChild:[obstacle getCCSprite]];
                    [[obstacle getCCSprite] setBatchNode:_obstacleSpriteBatch];
                    
                    if (proj!=nil && !proj.isBehindObstacle) {
                        [[[LayerManager sharedLayers] currentLayer] addChild:[proj getCCSprite]];
                    }
                    
                } else {
                    //do nothing regarding the batchnode; it will create its own if one is not already assigned, when the animation is initialized
                    [_gameLayer addChild:[obstacle getCCSprite]];
                }
            }
            @catch (NSException *exception) {
                CCLOG(@"could not add obstacle: %@",[obstacle getSprite].name);
            }
            
            [[obstacle getCCSprite] setVisible:NO];
            [_obstacleManager addGameObject:obstacle];
            mapObject.placed = true;            
        }
    }
    
   // [[LayerManager sharedLayers] forgetWorkingLayer];
 }

-(CGRect)getLevelBoundaries
{
    int width = _map.mapSize.width * _map.tileSize.width;
    int height = _map.mapSize.height * _map.tileSize.height;
    return CGRectMake(0, 0, width, height);
}

-(CGPoint)checkCollisionForObject:(GameObject*)object
{
#if CC_ENABLE_PROFILERS
    CCProfilingTimer *timer2 = [CCProfiler timerWithName:@"collisions" andInstance:self];
    CCProfilingBeginTimingBlock(timer2);
#endif 
    
    CGPoint position = [_collisionHandler checkCollisionForObject:object];
    
#if CC_ENABLE_PROFILERS
    CCProfilingEndTimingBlock(timer2);
#endif  

    return position;

}

-(void)setPositionAtX:(float)x Y:(float)y
{
    _x = x;
    _y = y;
    
    CGPoint position = [[Camera sharedCamera] convertToScreenXY:CGPointMake(_x * MULTIPLIERX,_y * MULTIPLIERY)];
    
    //round position to eliminate white artifacts (note, this is in points, so with retina, we want to round based
    //on pixels, so round based on double the size first, then half the size for point pixel value
    if (IS_IPAD)
    {
        position.x = roundf(position.x);
        position.y = roundf(position.y); 
    }
    else if ([[GameSettings shared] usingHighResolutionGraphics]) {
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
    
    /*
    for (MapObject *mapObject in _obstacleMapObjects) {
        if (mapObject!=nil) {
            [[mapObject.object getCCSprite] removeFromParentAndCleanup:YES];
        }
    }
    
    for (MapObject *mapObject in _otherMapObjects) {
        if (mapObject!=nil) {
            [[mapObject.object getCCSprite] removeFromParentAndCleanup:YES];
        }
    }*/
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
            
            if (!layerBelow) {
                layerBelow = @"main0";
            }
            
            if (special) {
                if ([special compare:@"nextlevelNE"] == NSOrderedSame) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_NEXTLEVEL;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"checkpoint"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpoint" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                    
                }else if([special isEqualToString:@"checkpoint8bit"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
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
                else if([special isEqualToString:@"checkpoint100"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpoint100" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                    
                }
                else if([special isEqualToString:@"checkpoint120"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpoint120" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                    
                }
                else if([special isEqualToString:@"checkpoint140"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpoint140" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                    
                }
                else if([special isEqualToString:@"checkpoint160"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpoint160" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                    
                }
                else if([special isEqualToString:@"checkpoint180"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpoint180" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
                    [_otherMapObjects addObject:mapObject];
                    
                }
                else if([special isEqualToString:@"checkpointDojo"]) { //checkpoint trigger
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];
                    trigger.type = TRIGGER_CHECKPOINT;
                    [_triggers addObject:trigger];
                    
                    //SHOULD work by giving it an object property, but stupidly isn't. so doing manually
                    GameObject *object = [_gameObjects loadGameObjectWithName:@"checkpointDojo" AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:layerBelow];
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
                } else if([special isEqualToString:@"finalBossSpawn"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_BOSS_FINALJIM_SPAWN;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"shootTrigger"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_BOSS_SHOOT;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"shootMegaCannon"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_SHIP_SHOOT_MEGACANNON;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];                    
                } else if([special isEqualToString:@"shootCombo"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_SHIP_SHOOT_COMBO;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"bossShipExits"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_SHIP_EXIT;
                    trigger.canBeReset = false;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"wind"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i,j)];

                    NSString *duration = [self getPropertyForTileCoords:coords forKey:@"duration"];
                    if ([duration isEqualToString:@"short"]) {
                        trigger.type = TRIGGER_WIND_SHORT;
                    } else if([duration isEqualToString:@"medium"]) {
                        trigger.type = TRIGGER_WIND_MEDIUM;
                    } else if([duration isEqualToString:@"long"]) {
                        trigger.type = TRIGGER_WIND_LONG;
                    }
                    
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"finalBossEnters"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_FINAL_BOSS_ENTER;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"finalBossExits"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_FINAL_BOSS_EXITS;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"finalBossDies"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_FINAL_BOSS_DIE;
                    trigger.canBeReset = false;
                    [_triggers addObject:trigger];                    
                } else if([special isEqualToString:@"finalBossAttack1"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_FINAL_BOSS_ATTACK1;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"finalBossAttack2"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_FINAL_BOSS_ATTACK2;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];
                } else if([special isEqualToString:@"finalBossAttack3"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_FINAL_BOSS_ATTACK3;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];                    
                } else if([special isEqualToString:@"finalBossAttack4"]) {
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_FINAL_BOSS_ATTACK4;
                    trigger.canBeReset = true;
                    [_triggers addObject:trigger];                    
                }    
            }

            NSString *obstacle = [self getPropertyForTileCoords:coords forKey:@"obstacle"];
            
            @try {
                if (obstacle) {
                    GameObject *object = [_gameObjects loadGameObjectWithName:obstacle AddToLayer:NO];
                    CGPoint position = [self getXYPositionForCoordinates:coords];
                    [object setPositionAtX:position.x Y:position.y];
                    [object setStartingPosition:position];
                    [[object getCCSprite] setScale:_scale];                
                    
                    MapObject *mapObject = [MapObject mapObjectWithSprite:object AboveLayer:@"main0"];
                    [_obstacleMapObjects addObject:mapObject];
                }

            }
            @catch (NSException *exception) {
                CCLOG(@"ERROR! Level.m - error loading obstacle named '%@' from objects.plist",obstacle);
            }
            
            
            NSString *objectName = [self getPropertyForTileCoords:coords forKey:@"object"];
            
            if (objectName && ![objectName isEqualToString:@"tvAnimation"]) {
                
                
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
                    Trigger *trigger = [[Trigger alloc] init];
                    trigger.position = [self getXYPositionForCoordinates:CGPointMake(i, j)];
                    trigger.type = TRIGGER_SHIP_ENTER;
                    trigger.canBeReset = false;
                    [_triggers addObject:trigger];

                } else if([objectName isEqualToString:@"finalJimBoss"]) {
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
            
            //add the rest of the train parts here
            if ([mapObject.object getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_FINAL_BOSS) {
                [[mapObject.object getBoss] addSpritesToLayer:[[LayerManager sharedLayers] currentLayer] SpriteBatch:_obstacleSpriteBatch];
            }
            
            mapObject.placed = true;
            
            //add to background regionmanager
            //[_backgroundManager addGameObject:mapObject.object];
            //[[mapObject.object getCCSprite] pauseSchedulerAndActions];
        }
    }
}

-(void)removeAndReplaceObstacleWithBehavior:(CollisionBehavior)behavior
{
    for (MapObject *mapObject in _obstacleMapObjects) {
        GameObject *object = mapObject.object;
        if([object getCollisionBehavior] == behavior){
            [[mapObject.object getCCSprite] removeFromParentAndCleanup:NO];
            [[[LayerManager sharedLayers] currentLayer] addChild:[mapObject.object getCCSprite]];
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
    
    for (MapObject *object in _otherMapObjects) {
        [object reset];
    }
    
    CGPoint playerPos = [_player getPosition];
    [_obstacleManager resetCurrentRegion];
    [_obstacleManager changeRegionsBasedOnX:(playerPos.x - 384)];
}

-(void)resetTriggers:(bool)isRestartingLevel
{
    for (Trigger *trigger in _triggers) {
        if ((trigger.canBeReset && !trigger.disabled) || isRestartingLevel) {
            trigger.triggered = false;
            trigger.disabled = false;
        }
    }
}

-(void)disablePassedTriggers
{
    for (Trigger *trigger in _triggers) {
        if (trigger.triggered) {
            trigger.disabled=true;
        }
    }
}

-(bool)testCollisions:(GameObject*)source
{
    bool collision = false;

    //prepare source bounding box, so we don't have to build it for every object
    NSMutableArray *obstacles = [_obstacleManager getActiveGameObjectList];
    
    //guard
    if ([obstacles count] <= 0) {
        return false;
    }

    CGRect sourceBoundingBox = CollisionRectForObject(source);
    
    for (GameObject *obstacle in obstacles) {
        if(!obstacle.collided && !obstacle.isInvincible) {
            int dist = [source getPosition].x - [obstacle getPosition].x;
            if (abs(dist) < 250) //don't do the full collision detection if they're not even close to each other.
            { 
                collision = [self testCollisionWithGameObject:obstacle BoundingBox:sourceBoundingBox];
                if (collision) {
                    [_player startCollision:[obstacle startCollision:false] Source:obstacle];
                    [self obstacleGotHitBy:obstacle];
                    
                }
                else if(!obstacle.collided && dist > 200) //if tim has passed the obstacle and it hasn't been hit yet
                {

                    if(_isTimedMode && !obstacle.hasAppeared){
                        [self obstacleJumpedOver:obstacle];
                    }
                }
                else if([obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_DISCO_TRIXTER_DANCING && !obstacle.collided)
                {
                    if(dist > -20)
                    {
                        [[AnimationController sharedController] replaceSprite:[obstacle getSprite] withAnimationNamed:@"discoTrixterPassedAnim"];
                        [obstacle setOriginalAnimation:@"discoTrixterAnim"];
                        obstacle.collided = true;
                        [[_player getThirdAction] setIsNear:false];
                        
                    } else if (dist > -100) {
                        [[_player getThirdAction] setIsNear:true];
                    }
                    
                }
            }
                

            if(abs(dist) < 900) {
                
                //if aggressive, test the object against the non-aggressive objects (example of aggressive: chickens in barn level)
                if (!collision && obstacle.isAggressive) {
                    [self testCollisionsForAggressive:obstacle Obstacles:obstacles];
                }
            }
        }    
        
        //test the gameobject's active projectile, if any (example: zombie heads)
        Projectile *projectile = [obstacle getProjectile];
        if (projectile!=nil && [projectile getActive] && projectile.hurtsPlayer) {
            if([self testCollisionWithGameObject:projectile Source:source]) {
                [_player startCollision:PLAYER_EFFECT_COLLIDE Source:projectile];
                [projectile startCollision];
            }                    
        }
    }
    return collision;
}

-(bool)testCollisionsForAggressive:(id<Collidable>)source Obstacles:(NSMutableArray*)obstacles
{
    bool collision = false;
    
    //prepare source bounding box, so we don't have to build it for every object
    CGRect sourceBoundingBox = CollisionRectForObject(source);
    
    for (GameObject *obstacle in obstacles) {
        if(![obstacle hasBeenHit] && [obstacle canAggressiveHit]) {
            collision = [self testCollisionWithGameObject:obstacle BoundingBox:sourceBoundingBox];
            if (collision) {
                NSString *mode = [[GameSettings shared] getGlobalForKey:@"gameMode"];

                if ([source getCollisionBehavior] == COLLISION_BEHAVIOR_HEN_DEAD && [mode isEqualToString:@"timed"]) {
                    //NSLog(@"Counting Chicken Kicked Into Cow");
                    int maxKicksIntoCow = 100;
                    
                    if ([GCState sharedInstance].chickensKickedIntoCows < maxKicksIntoCow) {
                        [GCState sharedInstance].chickensKickedIntoCows++;
                        
                        
                        double pctComplete = ((double) [GCState sharedInstance].chickensKickedIntoCows / (int)maxKicksIntoCow) * 100.0;
                        if(pctComplete == 100.0)
                        {
                        //[[GCState sharedInstance] save];
                        [[GCHelper sharedInstance] reportAchievement:gcAchievementChickensKickedIntoCows percentComplete:pctComplete];
                        }
                        //NSLog(@"Pct Complete - Chickens Kicked Into Cows: %f", pctComplete);
                    }
                    
                }
                [obstacle startCollision:true];
                break;
            }
        }        
    }
    return collision;
}

-(bool)testCollisionWithGameObject:(id<Collidable>)target BoundingBox:(CGRect)source
{
    CGRect targetBounds = CollisionRectForObject(target);
    
    float targetLeft = CGRectGetMinX(targetBounds);
    float targetRight = CGRectGetMaxX(targetBounds);
    float targetBottom = CGRectGetMinY(targetBounds);
    float targetTop = CGRectGetMaxY(targetBounds);
    
    float sourceLeft = CGRectGetMinX(source);
    float sourceRight = CGRectGetMaxX(source);
    float sourceBottom = CGRectGetMinY(source);
    float sourceTop = CGRectGetMaxY(source);    
    
    //assume that a collision happened unless the sides of the
    //target object indicate there can't possibly be
    //an intersection. by checking all four sides this gives
    //full detection, and is more efficient than other methods
    if (sourceBottom > targetTop) { return false; }
    if (sourceTop < targetBottom) { return false; }
    if (sourceRight < targetLeft) { return false; }
    if (sourceLeft > targetRight) { return false; }
    
    return true;
}

-(bool)testCollisionWithGameObject:(id<Collidable>)target Source:(id<Collidable>)source
{
    CGRect targetBounds = CollisionRectForObject(target);
    CGRect sourceBounds = CollisionRectForObject(source);
    float targetLeft = CGRectGetMinX(targetBounds);
    float targetRight = CGRectGetMaxX(targetBounds);
    float targetBottom = CGRectGetMinY(targetBounds);
    float targetTop = CGRectGetMaxY(targetBounds);
    
    float sourceLeft = CGRectGetMinX(sourceBounds);
    float sourceRight = CGRectGetMaxX(sourceBounds);
    float sourceBottom = CGRectGetMinY(sourceBounds);
    float sourceTop = CGRectGetMaxY(sourceBounds);
    
    
    //assume that a collision happened unless the sides of the
    //target object indicate there can't possibly be
    //an intersection. by checking all four sides this gives
    //full detection, and is more efficient than other methods
    if (sourceBottom > targetTop) { return false; }
    if (sourceTop < targetBottom) { return false; }
    if (sourceRight < targetLeft) { return false; }
    if (sourceLeft > targetRight) { return false; }
    
    return true;
}


//TODO: only supporting one trigger per update, for now. not ideal though and we will eventually need to extend this
-(Trigger*)testTriggers:(Player*)player
{
    Trigger *returnTrigger = nil;
    
    for (Trigger *trigger in _triggers) {
        if (!trigger.triggered) {
            if (player.x >= trigger.position.x) {
                returnTrigger = trigger;
                trigger.triggered = true;                    
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

-(NSMutableArray*)getBackgroundObjectsList
{
    return _otherMapObjects;
}

-(void)update:(float)dt Velocity:(float)vx
{
    [self setPositionAtX:_x Y:_y];
    
    CGPoint playerPos = [[[LayerManager sharedLayers] getPlayer] getPosition];
    [_obstacleManager changeRegionsBasedOnX:(playerPos.x - 384)];
    //[_backgroundManager changeRegionsBasedOnX:(playerPos.x - 128)];
    
    /*
    NSMutableArray *obstacles = [_obstacleManager getActiveGameObjectList];
    for (GameObject *obstacle in obstacles) {
        [obstacle update:dt];
    }*/
    
    //NSMutableArray *objects = [_backgroundManager getActiveGameObjectList];
    //for (GameObject *object in objects) {
    //    [object update:dt];
    //}

    for (MapObject *object in _obstacleMapObjects) {
        [object.object update:dt];
    }

    
    for (MapObject *object in _otherMapObjects) {
        [object.object update:dt];
    }
    
}

-(void)obstacleJumpedOver:(GameObject *)obstacle
{
    
    if(obstacle.isHurdle)
    {
        int maxHurdles = 400;
        
        if ([GCState sharedInstance].hurdlesJumpedOver < maxHurdles) {
            [GCState sharedInstance].hurdlesJumpedOver++;
            obstacle.hasAppeared=true;
            //NSLog(@"hurdles jumped over:%d" ,[GCState sharedInstance].hurdlesJumpedOver);
            
            
            double pctComplete = ((double) [GCState sharedInstance].hurdlesJumpedOver / (int)maxHurdles) * 100.0;
            if(pctComplete == 100.0)
            {
                //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementJumpOver400hurdles percentComplete:pctComplete];
            }
        }
    }
    else if([obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_MAD_DOG)
    {
        int maxDogs = 100;
        
        if ([GCState sharedInstance].dogsJumpedOver < maxDogs) {
            [GCState sharedInstance].dogsJumpedOver++;
            obstacle.hasAppeared = true;
            
            double pctComplete2 = ((double) [GCState sharedInstance].dogsJumpedOver / (int)maxDogs) * 100.0;
            if(pctComplete2 == 100.0)
            {
               // [[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementJumpOver100dogs percentComplete:pctComplete2];
            }
        }
        
    }
    else if([obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_FROG_SQUASH)
    {
        int maxFrogs = 50;
        
        if ([GCState sharedInstance].frogsJumpedOver < maxFrogs) {
            [GCState sharedInstance].frogsJumpedOver++;
            obstacle.hasAppeared = true;
            
            double pctComplete3 = ((double) [GCState sharedInstance].frogsJumpedOver / (int)maxFrogs) * 100.0;
            if(pctComplete3 == 100.0)
            {
                //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementJumpOver50frogs percentComplete:pctComplete3];
            }
        }
    }
    
}

-(void)obstacleGotHitBy:(GameObject *)obstacle
{
    int maxHit = 10;
    
    if(obstacle.isHurdle)
    {
       // NSLog(@"%d",[GCState sharedInstance].hurdlesHit );
        
        if ([GCState sharedInstance].hurdlesHit < maxHit) {
            [GCState sharedInstance].hurdlesHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].hurdlesHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
               //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10hurdles percentComplete:pctComplete];
            }
        }
    }
    
    else if([obstacle getCollisionBehavior]==COLLISION_BEHAVIOR_COW_COLLAPSE)
    {
        
        if ([GCState sharedInstance].cowsHit < maxHit) {
            [GCState sharedInstance].cowsHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].cowsHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
              //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10cows percentComplete:pctComplete];
            }
        }

    }
    else if([obstacle getCollisionBehavior]==COLLISION_BEHAVIOR_FLYER_DEAD)
    {
        if ([GCState sharedInstance].birdsHit < maxHit) {
            [GCState sharedInstance].birdsHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].birdsHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
               // [[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10birds percentComplete:pctComplete];
            }
        }
        
    }
    /*
    else if(obstacle.CollidableBehavior == COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_BD || obstacle.CollidableBehavior == COLLISION_BEHAVIOR_CHARGE_AT_PLAYER_FAST_BD || obstacle.CollidableBehavior == COLLISION_BEHAVIOR_DANCIN_MAN_COLLAPSE)
    {
        if ([GCState sharedInstance].dancersHit < maxHit) {
            [GCState sharedInstance].dancersHit++;
            
            double pctComplete7 = ((double) [GCState sharedInstance].dancersHit / (int)maxHit) * 100.0;
            if(pctComplete7 == 100.0)
            {
                [[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10dancers percentComplete:pctComplete7];
            }
        }
        
    }
     */
    else if([obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_MAD_DOG)
    {
        //NSLog(@"%d",[GCState sharedInstance].dogsHit);
        if ([GCState sharedInstance].dogsHit < maxHit) {
            [GCState sharedInstance].dogsHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].dogsHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
                //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10dogs percentComplete:pctComplete];
            }
        }
        
    }
    /*
    else if(obstacle.CollidableBehavior == COLLISION_BEHAVIOR_ZOMBIE_HEADLESS || obstacle.CollidableBehavior == COLLISION_BEHAVIOR_ZOMBIE_FADE)
    {
        if ([GCState sharedInstance].zombiesHit < maxHit) {
            [GCState sharedInstance].zombiesHit++;
            
            double pctComplete9 = ((double) [GCState sharedInstance].zombiesHit / (int)maxHit) * 100.0;
            if(pctComplete9 == 100.0)
            {
                [[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10zombies percentComplete:pctComplete9];
            }
        }
        
    }
     */
    else if(_levelNumber == 7)
    {
        if ([GCState sharedInstance].viruesHit < maxHit) {
            [GCState sharedInstance].viruesHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].viruesHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
               // [[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10virues percentComplete:pctComplete];
            }
        }
        
    }
    else if([obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_FIRE_DEMON)
    {
        if ([GCState sharedInstance].fireDemonHit < maxHit) {
            [GCState sharedInstance].fireDemonHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].fireDemonHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
                //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10firedemon percentComplete:pctComplete];
            }
        }
        
    }

    else if([obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_FROG_SQUASH)
    {
        if ([GCState sharedInstance].frogsHit < maxHit) {
            [GCState sharedInstance].frogsHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].frogsHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
                //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10frogs percentComplete:pctComplete];
            }
        }
        
    }
    else if([obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_WATER_ANGLERFISH || [obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_WATER_PUFFERFISH || [obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_WATER_SEAHORSE)
    {
        if ([GCState sharedInstance].fishHit < maxHit) {
            [GCState sharedInstance].fishHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].fishHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
                //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10fish percentComplete:pctComplete];
            }
        }
        
    }
    
    else if([obstacle getCollisionBehavior] == COLLISION_BEHAVIOR_BAT)
    {
        if ([GCState sharedInstance].batHit < maxHit) {
            [GCState sharedInstance].batHit++;
            
            double pctComplete = ((double) [GCState sharedInstance].batHit / (int)maxHit) * 100.0;
            if(pctComplete == 100.0)
            {
               //[[GCState sharedInstance] save];
                [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10bats percentComplete:pctComplete];
            }
        }
        
    }

        



}

-(bool)isLevelNumber:(int)number
{
    return (number == _levelNumber);
}

-(int)getLevelNumber
{
    return _levelNumber;
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
