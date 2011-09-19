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
        
        [self setupDebugText:map];
        
    }
    
    return self;
}

-(void) setupDebugText:(CCTMXTiledMap*)map
{
    _main = [_map layerNamed:@"meta"];
    
    for (int i=0; i<_map.mapSize.width; i++) {
        for (int j=0; j<_map.mapSize.height; j++) {
            CGPoint coords = CGPointMake(i, j);
            CCSprite *sprite = [_main tileAt:coords];
            NSString *property = [self getCollisionPropertyForTileCoords:coords];
            if([property compare:@"none"] != NSOrderedSame) {
                CCLabelTTF *label = [CCLabelTTF labelWithString:property dimensions:CGSizeMake([sprite contentSize].width, [sprite contentSize].height) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:10];
                [sprite addChild:label z:10];
            }
                                
        }
    }

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
    int y = ((_map.mapSize.height * _tileSize) - position.y) / scaledTileHeight;
    
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
    
    return ccp(x,y);
}


-(CGPoint)checkCollisionForObject:(GameObject*)object
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
    _pointWithinTile = CGPointMake((int)position.x % (_tileSize/2), (int)position.y % _tileSize);
    _coordinates = [self tileCoordForPosition:_testPosition];
    _tileCollision = [self getCollisionPropertyForTileCoords:_coordinates];
    
}

-(bool)tryGoingFullVxAndVy
{
    bool returnVal = false;
    [self prepareDataForPosition:_desiredPosition];
    
    
    if ([_tileCollision compare:@"none"] == NSOrderedSame) {
        //we don't need to change position and we're in midair
        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_MIDAIR];
        returnVal = true;
    } else if([_tileCollision compare:@"leftslant"] == NSOrderedSame) {
        
        if (_pointWithinTile.y < _pointWithinTile.x) {
            
            //if on the slant, shift the position up 
            float upAmount = - _pointWithinTile.y + _pointWithinTile.x;
            _testPosition.y += upAmount;
            [self tileCoordForPosition:CGPointMake(_testPosition.x, _testPosition.y)];
            //_testPosition.y += 2 * _pointWithinTile.x - _pointWithinTile.y;
        }
        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
        returnVal = true;
    } else if([_tileCollision compare:@"full"] == NSOrderedSame) {
        CGPoint newPoint = CGPointMake(_testPosition.x,(_testPosition.y + _tileSize - _pointWithinTile.y));
        [self prepareDataForPosition:newPoint];
        
        if ([_tileCollision compare:@"none"] == NSOrderedSame) {
            [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
            returnVal = true;
        } else if([_tileCollision compare:@"leftslant"] == NSOrderedSame) {
            [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
            returnVal = true;
            _testPosition.y += _pointWithinTile.x;
        }
    }
    
    return returnVal;
}

-(bool)tryGoingFullVx
{
    [self prepareDataForPosition:_desiredPosition];
    
    
    
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

/*
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
}*/


@end
