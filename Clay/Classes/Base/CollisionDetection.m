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
#define COLLISION_PLAYER_GROUND_Y_POSITION 64.0f

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
        
        //do any precalculations for performance
        if ([[GameSettings shared] usingHighResolutionGraphics])
        {
            _preCalculateAccurateCoordsY = (_mapHeight * _halfTileSize) / _halfTileSize;
            _preCalculateTileSize = _halfTileSize;
        }
        else
        {
            _preCalculateAccurateCoordsY = (_mapHeight * _tileSize) / _tileSize;
            _preCalculateTileSize = _tileSize;
        }
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
            desiredPosition.y = (_mapHeight - coords.y - 1) * _preCalculateTileSize  + 32.0f;            
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
    int x;
    int y;
        
    x = position.x / _preCalculateTileSize;
    y = _preCalculateAccurateCoordsY - (position.y / _preCalculateTileSize);
    
    //keep x between 0 and _mapWidth - 1
    x = MAX(0, x);
    x = MIN((_mapWidth - 1),x);
    
    //keep y between 0 and _mapHeight - 1
    y = MAX(0,y);
    y = MIN((_mapHeight - 1),y);
    
    return ccp(x,y -1);
}

-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords
{
    NSString *returnVal;
    
    int tileGid = [_collisionData tileGIDAt:coords];
    
    if (tileGid) {
        NSDictionary *properties = [_map propertiesForGID:tileGid];
        
        if (properties) {
            returnVal = [properties valueForKey:@"collision"];
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
