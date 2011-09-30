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

@synthesize midpointCollisions = _currentMidpoints;

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
        
        [self setupDebugText:map Layer:collisionLayer];
        
    }
    
    return self;
}

-(void) setupDebugText:(CCTMXTiledMap*)map Layer:(CCTMXLayer*)layer
{
    //_main = [_map layerNamed:@"meta"];
    _main = layer;
    
    /*
    for (int i=0; i<_map.mapSize.width; i++) {
        for (int j=0; j<_map.mapSize.height; j++) {
            CGPoint coords = CGPointMake(i, j);
            CCSprite *spriteAttach = [_main tileAt:coords];
            CCSprite *fontSprite = [CCSprite spriteWithFile:@"blank.png"];
            NSString *property = [self getCollisionPropertyForTileCoords:coords];
            if([property compare:@"none"] != NSOrderedSame) {
                CCLabelTTF *label = [CCLabelTTF labelWithString:property dimensions:CGSizeMake([spriteAttach contentSize].width, [spriteAttach contentSize].height) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:10];
                //fontSprite.texture.name = spriteAttach.texture.name;
                [fontSprite addChild:label];
                [spriteAttach addChild:fontSprite];
            }
                                
        }
    }*/

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
    int y = ((_map.mapSize.height * scaledTileHeight) - position.y) / scaledTileHeight;
    
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

-(CGPoint)accurateCoords:(CGPoint)position
{
    int scaledTileWidth = _tileSize / 2.0f;
    int scaledTileHeight = _tileSize / 2.0f;
    int x = position.x / scaledTileWidth;
    int y = ((_map.mapSize.height * scaledTileHeight) - position.y) / scaledTileHeight;
    
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

-(XDCollision)getMidpointCollisions
{
    float scale = 1;
    
    CGPoint pos = [_currentObject getPosition];
    float leftMidpoint = pos.x - (_objectBoundingBox.origin.x * scale);
    float bottomMidpoint = pos.y + (_objectBoundingBox.origin.y * scale);
    float rightMidpoint = leftMidpoint + (_objectBoundingBox.size.width * scale);
    float topMidpoint = bottomMidpoint + (_objectBoundingBox.size.height * scale);
    
    bool bottomCollision = [self checkCollisionAtPoint:CGPointMake(pos.x, bottomMidpoint)];
    bool leftCollision = [self checkCollisionAtPoint:CGPointMake(leftMidpoint, pos.y)];
    bool topCollision = [self checkCollisionAtPoint:CGPointMake(pos.x,topMidpoint)];
    bool rightCollision = [self checkCollisionAtPoint:CGPointMake(rightMidpoint, pos.y)];
    
    bool hasCollision = false;
    if (leftCollision||rightCollision||topCollision||bottomCollision) {
        hasCollision = true;
    }
    
    XDCollision returnVal = XDCollisionMake(hasCollision, leftCollision, rightCollision, topCollision, bottomCollision);
    
    return returnVal;
}

-(void)showCollisions
{
    _currentMidpoints = [self getMidpointCollisions];
    
}

-(bool)checkCollisionAtPoint:(CGPoint)point
{
    bool returnVal = false;
    
    CGPoint coords = [self accurateCoords:point];
    _pointWithinTile = CGPointMake((int)point.x % (_tileSize/2), (int)point.y % (_tileSize/2));

    CollisionType collision = [self getCollisionTypeForCoords:coords];
    
    switch (collision) {
        case COLLISION_TYPE_NONE:
            returnVal = false;
            break;
        case COLLISION_TYPE_FULL:
            returnVal = true;
            break;
        case COLLISION_TYPE_LEFT_SLANT:
            if (_pointWithinTile.y < _pointWithinTile.x) {
                returnVal = true;
            } else {
                returnVal = false;
            }
            break;
        case COLLISION_TYPE_RIGHT_SLANT:
            if (_pointWithinTile.y < _pointWithinTile.x) {
                returnVal = true;
            } else {
                returnVal = false;
            }
            break;
        default:
            break;
    }
    
    return returnVal;
    
}

-(CGPoint)checkCollisionForObject2:(GameObject *)object
{
    _desiredPosition = [object getPosition];
    _testPosition = [object getPosition];
    _currentObject = object;
    
    _currentMidpoints = [self getMidpointCollisions];
    
    if(!_currentMidpoints.hasCollision) {
        _testPosition = _desiredPosition;
        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_MIDAIR];
    } else {
        if (_currentMidpoints.bottom) {
            if([self pushUp]) {
                [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
            }
        }
    }
    
    
    return _testPosition;
}

-(bool)pushUp
{
    bool colliding = true;    
    while (colliding) {
        [self prepareDataForPosition2:_testPosition];
        
        
        //check if the test position collides with current tile
        if ([_tileCollision compare:@"full"] == NSOrderedSame) {
            _coordinates.y-=1;
            _testPosition.y = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f) + 1;
            // the "+1" at the end prevents an infinite loop here
        } else if ([_tileCollision compare:@"none"] == NSOrderedSame) {
            _testPosition.y = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f);
            colliding = false;
        } else if([_tileCollision compare:@"leftslant"] == NSOrderedSame) {
            colliding = false;
            _testPosition.y = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f) + _pointWithinTile.x;
            
        } else if([_tileCollision compare:@"rightslant"] == NSOrderedSame) {
            colliding = false;
            _testPosition.y = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f) + (32.0f - _pointWithinTile.x);
        }
        
    }
    NSLog(@"Property: %@",_tileCollision);

    return true;
}

-(CGPoint)checkCollisionForObject:(GameObject*)object
{
    _desiredPosition = [object getPosition];
    _testPosition = [object getPosition];
    _currentObject = object;
    _amountToReachGround = 100000.0f;
    _objectBoundingBox = _currentObject.boundingBox;
    
    [self showCollisions];
    
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

-(void)prepareDataForPosition2:(CGPoint)position
{
    _testPosition = CGPointMake(position.x, position.y);
    _pointWithinTile = CGPointMake((int)position.x % (_tileSize/2), (int)position.y % _tileSize/2);
    _coordinates = [self accurateCoords:_testPosition];
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
            _testPosition.y -= 2;
        }
    }
    
    return returnVal;
}

-(bool)tryGoingFullVx
{
    [self prepareDataForPosition:_desiredPosition];
    
    
    
    return false;
}

-(CollisionType)getCollisionTypeForCoords:(CGPoint)coords
{
    CollisionType returnVal = COLLISION_TYPE_NONE;
    
    NSString *property = [self getCollisionPropertyForTileCoords:coords];
    if ([property compare:@"full"] == NSOrderedSame) {
        returnVal = COLLISION_TYPE_FULL;
    } else if([property compare:@"leftslant"] == NSOrderedSame) {
        returnVal = COLLISION_TYPE_LEFT_SLANT;
    } else if([property compare:@"rightslant"] == NSOrderedSame) {
        returnVal = COLLISION_TYPE_RIGHT_SLANT;
    } else if([property compare:@"rs2tileL"] == NSOrderedSame) {
        returnVal = COLLISION_TYPE_RIGHT_SLANT_2TILE_L;
    } else if([property compare:@"rs2tileR"] == NSOrderedSame) {
        returnVal = COLLISION_TYPE_RIGHT_SLANT_2TILE_R;        
    }
    
    return returnVal;
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


-(bool)getOutOfCollision
{
    [self prepareDataForPosition:_desiredPosition];
    CGPoint prevPosition = [_currentObject getPreviousPosition];
    
    float dx = _testPosition.x - prevPosition.x;
    float dy = _testPosition.y - prevPosition.y;
    
    float dist = sqrtf(dx*dx + dy*dy);
    float testDist = dist;
    float angle = atan2f(dy, dx);
    
    bool colliding = true;    
    while (colliding) {
        
        //check if the test position collides with current tile
        if ([_tileCollision compare:@"full"] == NSOrderedSame) {
            //NSLog(@"test");
        } else if ([_tileCollision compare:@"none"] == NSOrderedSame) {
            colliding = false;
            break;
        } else if([_tileCollision compare:@"leftslant"] == NSOrderedSame) {
            if (_pointWithinTile.y > _pointWithinTile.x) {
                colliding = false;
                break;
            }
        } else if([_tileCollision compare:@"rightslant"] == NSOrderedSame) {
            if (_pointWithinTile.y > (_map.tileSize.width - _pointWithinTile.x)) {
                colliding = false;
                break;
            }
        }

        if (colliding) {
            testDist-=1;
            _testPosition.x = prevPosition.x + testDist * cosf(angle);                    
            _testPosition.y = prevPosition.y - testDist * sin(angle);                
            [self prepareDataForPosition:_testPosition];
            [[_currentObject getCollision] processNewCollisionState:COLLISION_STATE_BUMPED_WALL];
        }
    }
    
    
    return true;
}


@end
