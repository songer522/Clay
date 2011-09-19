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

@implementation CollisionDetection

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



-(bool) outOfBoundsTest:(CGPoint)testPosition
{
    return false;
}


-(CGPoint)tileCoordForPosition:(CGPoint)position
{
    int scaledTileWidth = _tileSize / 2.0f;
    int scaledTileHeight = _tileSize;
    int x = position.x / scaledTileWidth;
    int y = ((_tileSize * scaledTileHeight) - position.y) / scaledTileHeight;
    
    if (x < 0) {
        x = 0;
    } else if(x > (_tileSize - 1)) {
        x = _tileSize - 1;
    }
    
    if (y < 0) {
        y = 0;
    } else if(y > (_tileSize - 1)) {
        y = _tileSize - 1;
    }
    
    return ccp(x,y);
}


-(CGPoint)newCheckCollisionForObject:(GameObject*)object
{
    _desiredPosition = [object getPosition];
    _testPosition = [object getPosition];
    _currentObject = object;
    _amountToReachGround = 100000.0f;
    
    if([self tryGoingFullVxAndVy])
    {
        return _testPosition;
    }
    else if([self tryGoingFullVx])
    {
        return CGPointMake(_desiredPosition.x, _testPosition.y);
    }
    else if([self getOutOfCollision])
    {
        return _testPosition;
    }
    else
    {
        return [object getPreviousPosition];
    }
}

-(void)prepareDataForPosition:(CGPoint)position
{
    _testPosition = CGPointMake(position.x, position.y);
    _pointWithinTile = CGPointMake((int)position.x % _tileSize, (int)position.y % _tileSize);
    _coordinates = [self tileCoordForPosition:_testPosition];
    _tileCollision = [self getCollisionPropertyForTileCoords:_coordinates];
    
}

-(bool)tryGoingFullVxAndVy
{
    [self prepareDataForPosition:_desiredPosition];
    
    if ([_tileCollision compare:@"none"]) {
        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_MIDAIR];
        return true;
    } else if([_tileCollision compare:@"leftslant"]) {
        if (_pointWithinTile.y < _pointWithinTile.x) {
            _pointWithinTile.y += (_pointWithinTile.x - _pointWithinTile.y);
        }
        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
        return true;
    } else if([_tileCollision compare:@"full"]) {
        //CGPointMake(<#CGFloat x#>, <#CGFloat y#>)
    }
    
    return true;
}

-(bool)tryGoingFullVx
{
    return true;
}

-(bool)getOutOfCollision
{
    return true;
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


-(CGPoint)checkCollisionForObject:(GameObject*)object AtPoint:(CGPoint)point
{
    CGPoint startPosition = CGPointMake(point.x, point.y);    
    CGPoint testPosition = CGPointMake(point.x, point.y);
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
                //                testPosition.y += pointWithinTile.x
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
}


@end
