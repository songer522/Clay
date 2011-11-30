//
//  CollisionDetection.m
//  Clay
//
//  Created by Brian Cable on 9/16/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "CollisionDetection.h"
#import "Collision.h"
#import "GameObject.h"
#import "GameSettings.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)
#define COLLISION_DETECTION_TEST_LEFT_COLLISIONS 0

@implementation CollisionDetection

+(id) collisionHandlerWithMetaLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map
{
    return [[self alloc] initWithCollisionLayer:collisionLayer Map:map];
}

- (id)initWithCollisionLayer:(CCTMXLayer*)collisionLayer Map:(CCTMXTiledMap*)map
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _collisionData = collisionLayer;
        _map = map;
        
        //bring these local to optimize a bit
        _tileSize = _map.tileSize.width;
        _halfTileSize = _tileSize / 2.0f;
        _mapHeight = _map.mapSize.height;
        _mapWidth = _map.mapSize.width;
    }
    
    return self;
}


-(CGPoint)checkCollisionForObject:(GameObject *)object
{
    CGPoint desiredPosition = [object getPosition];
    CGPoint testPosition = CGPointMake(desiredPosition.x - 4.0f, desiredPosition.y); //the bottom middle point of the character is at object.x - 4, object.y
   
    //if on the ground, test if a deathpit or not.
    if (testPosition.y < COLLISION_PLAYER_GROUND_Y_POSITION) {
        testPosition.y -= 4.0f; //bump the position a bit lower just to make sure we're grabbing the tile below and not the tile above
        CGPoint coords = [self accurateCoords:testPosition];
        NSString *tileCollision = [self getCollisionPropertyForTileCoords:coords];
        if ([tileCollision isEqualToString:@"none"]) {
            //we're in a death pit
            [[object getCollision] setCurrentState:COLLISION_STATE_DEATHPIT];
        } else {
            //otherwise assume we're on the ground and ground the player
            desiredPosition.y = COLLISION_PLAYER_GROUND_Y_POSITION;         
            [[object getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
        }
    } else {
        //in the air, test to see if they landed on a ledge
        CGPoint coords = [self accurateCoords:testPosition];
        NSString *tileCollision = [self getCollisionPropertyForTileCoords:coords];
        
        //if landed on the ledge, put them on top of that ledge
        if ([tileCollision isEqualToString:@"ledgefull"]) {
            if ([GameSettings usingHighResolutionGraphics])
            {
                desiredPosition.y = (_mapHeight - coords.y - 1) * _halfTileSize  + 32.0f;
            }
            else
            {
                desiredPosition.y = (_mapHeight - coords.y - 1) * _tileSize + 32.0f;
            }
            
            [[object getCollision] setCurrentState:COLLISION_STATE_LEDGE];
        } else {
            //otherwise they're in midair, don't change their position
            [[object getCollision] setCurrentState:COLLISION_STATE_MIDAIR];
        }
        
    }
    
    return desiredPosition;
    
}

-(CGPoint)accurateCoords:(CGPoint)position
{
    int scaledTileWidth = _tileSize / 2.0f;
    int scaledTileHeight = _tileSize / 2.0f;
    if (IS_IPAD)
    {
        scaledTileWidth = _tileSize;
        scaledTileHeight = _tileSize;
    }
    else if ([GameSettings usingHighResolutionGraphics])
    {
        x = position.x / _halfTileSize;
        y = ((_mapHeight * _halfTileSize) - position.y) / _halfTileSize;
    }
    else
    {
        x = position.x / _tileSize;
        y = ((_mapHeight * _tileSize) - position.y) / _tileSize;
    }
    
    //keep x between 0 and _mapWidth - 1
    x = MAX(0, x);
    x = MIN((_mapWidth - 1),x);

    //keep y between 0 and _mapHeight - 1
    y = MAX(0,y);
    y = MIN((_mapHeight - 1),y);
        
    return ccp(x,y);
}

-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords
{
    NSString *returnVal;
    
    int tileGid = [_collisionData tileGIDAt:coords];
    
    if (tileGid) {
        NSDictionary *properties = [_map propertiesForGID:tileGid];
        
        if (properties) {
            returnVal = [properties valueForKey:@"collision"];
        }
    }
    
    return returnVal;
}

-(bool)pushUp
{
    bool colliding = true;    
    while (colliding) {
        
        [self prepareDataForPosition:_testPosition BoundingBoxPoint:BOX_BOTTOM_MIDDLE];

        
        float topOfTile = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f);
        if (IS_IPAD) {
            topOfTile = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize);
        }
        else if ([GameSettings usingHighResolutionGraphics])
        {
            topOfTile = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f);
        }
        else
        {
            topOfTile = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize);
        }
        //check if the test position collides with current tile
        if ([_tileCollision isEqualToString:@"full"])
        {
            _coordinates.y-=1;

            //NOTE: the "+1" at the end of the line below prevents an infinite loop
            if (IS_IPAD)
            {
                _testPosition.y = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize) + 2;                
            }
            else if ([GameSettings usingHighResolutionGraphics])
            {
                _testPosition.y = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f) + 2;
            }
            else
            {
                _testPosition.y = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize) + 2;
            
            }
            
        }
        else if ([_tileCollision isEqualToString:@"none"])
        {
            _testPosition.y = topOfTile;
            colliding = false;
        }
        else if([_tileCollision isEqualToString:@"ledgefull"])
        {
            _testPosition.y = topOfTile + 32;
            colliding = false;
            _landedOnLedge = true;
        }
        
    }

    return true;
}

-(bool)pushLeft
{
    bool returnVal = true;
    bool movedLeftOnce = false;     //most circumstances, if we need to move left more than one block, then we should be testing the top collision instead
    bool colliding = true;
    while (colliding) {
        [self prepareDataForPosition:_testPosition BoundingBoxPoint:BOX_RIGHT_MIDDLE];
        
        float leftOfTile = _coordinates.x * (_tileSize / 2.0f) + 6.0f;
        
        if ([_tileCollision isEqualToString:@"full"]) {
            if (!movedLeftOnce) {
                movedLeftOnce = true;
                _coordinates.x -= 1;
                _testPosition.x = _coordinates.x * (_tileSize / 2.0f) -1;                
            } else {
                colliding = false;
                returnVal = false;
            }
        } else if([_tileCollision isEqualToString:@"none"]) {
            colliding = false;
            _testPosition.x = leftOfTile;
        } else {
            returnVal = [NSString stringWithString:@"none"];
        }
    } else {
        returnVal = [NSString stringWithString:@"none"];
    }
    
    return returnVal;
}
-(void) dealloc
{
    _collisionData = nil;
    _map = nil;
    [super dealloc];
}


@end
