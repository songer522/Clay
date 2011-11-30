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
        _tileSize = _map.tileSize.width;
        
    }
    
    return self;
}


-(CGPoint)checkCollisionForObject:(GameObject *)object
{
    CGPoint desiredPosition = [object getPosition];
    CGPoint testPosition = CGPointMake(desiredPosition.x - 4.0f, desiredPosition.y); //the bottom middle point of the character is at object.x - 4, object.y
   
    //if on the ground, test if a deathpit or not.
    if (testPosition.y < 64) {
        testPosition.y -= 4.0f; //just to make sure we're on the tile below
        CGPoint coords = [self accurateCoords:testPosition];
        NSString *tileCollision = [self getCollisionPropertyForTileCoords:coords];
        if ([tileCollision isEqualToString:@"none"]) {
            //we're in a death pit
            [[object getCollision] setCurrentState:COLLISION_STATE_DEATHPIT];
        } else {
            //otherwise assume we're on the ground and ground the player
            desiredPosition.y = 64;         
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
                desiredPosition.y = (_map.mapSize.height - coords.y - 1) * (_tileSize / 2.0f)  + 32.0f;
            }
            else
            {
                desiredPosition.y = (_map.mapSize.height - coords.y - 1) * (_tileSize) + 32.0f;
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
    if ([GameSettings usingHighResolutionGraphics])
    {
        scaledTileWidth = _tileSize / 2.0f;
        scaledTileHeight = _tileSize / 2.0f;
    }
    else
    {
        scaledTileWidth = _tileSize;
        scaledTileHeight = _tileSize;
        
    }
    
    //NSLog(@"tilewidth: %d tileheight: %d", scaledTileWidth, scaledTileHeight);
    int x = position.x / scaledTileWidth;
    int y = ((_map.mapSize.height * scaledTileHeight) - position.y) / scaledTileHeight;
    
    //NSLog(@"X: %d Y: %d", x, y);
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
    //NSLog(@"X: %d Y: %d", x, y);
    return ccp(x,y);
}

-(NSString*)getCollisionPropertyForTileCoords:(CGPoint)coords
{
    NSString *returnVal = [NSString stringWithString:@"none"];
    
    int tileGid = [_collisionData tileGIDAt:coords];
    
    if (tileGid) {
        NSDictionary *properties = [_map propertiesForGID:tileGid];
        
        if (properties) {
            returnVal = [properties valueForKey:@"collision"];
        }
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
