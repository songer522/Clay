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
        
    }
    
    return self;
}

//entry point for this class each update
-(CGPoint)checkCollisionForObject:(GameObject *)object
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
        case COLLISION_TYPE_LEDGE_FULL:
            if (_currentObject.isFalling || !_currentObject.isInMidAir) {
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

-(CollisionType)getCollisionTypeForCoords:(CGPoint)coords
{
    CollisionType returnVal = COLLISION_TYPE_NONE;
    
    NSString *property = [self getCollisionPropertyForTileCoords:coords];
    if ([property isEqualToString:@"full"])
    {
        returnVal = COLLISION_TYPE_FULL;
    }
    else if([property isEqualToString:@"leftslant"])
    {
        returnVal = COLLISION_TYPE_LEFT_SLANT;
    }
    else if([property isEqualToString:@"rightslant"])
    {
        returnVal = COLLISION_TYPE_RIGHT_SLANT;
    }
    else if([property isEqualToString:@"rs2tileL"])
    {
        returnVal = COLLISION_TYPE_RIGHT_SLANT_2TILE_L;
    }
    else if([property isEqualToString:@"rs2tileR"])
    {
        returnVal = COLLISION_TYPE_RIGHT_SLANT_2TILE_R;        
    }
    else if([property isEqualToString:@"ledgefull"])
    {
        returnVal = COLLISION_TYPE_LEDGE_FULL;
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

-(bool)pushUp
{
    bool colliding = true;    
    while (colliding) {
        [self prepareDataForPosition:_testPosition];
        
        float topOfTile = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f);
        
        //check if the test position collides with current tile
        if ([_tileCollision isEqualToString:@"full"])
        {
            _coordinates.y-=1;

            //NOTE: the "+1" at the end of the line below prevents an infinite loop
            _testPosition.y = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f) + 1;
            
        }
        else if ([_tileCollision isEqualToString:@"none"])
        {
            _testPosition.y = topOfTile;
            colliding = false;
        }
        else if([_tileCollision isEqualToString:@"leftslant"])
        {
            colliding = false;
            _testPosition.y = topOfTile + _pointWithinTile.x;
            
        }
        else if([_tileCollision isEqualToString:@"rightslant"])
        {
            colliding = false;
            _testPosition.y = topOfTile + (32.0f - _pointWithinTile.x);
        }
        else if([_tileCollision isEqualToString:@"ledgefull"])
        {
            _testPosition.y = topOfTile + 32;
            colliding = false;
        }
        
    }
    NSLog(@"Property: %@",_tileCollision);

    return true;
}

-(void)prepareDataForPosition:(CGPoint)position
{
    _testPosition = CGPointMake(position.x, position.y);
    _pointWithinTile = CGPointMake((int)position.x % (_tileSize/2), (int)position.y % _tileSize/2);
    _coordinates = [self accurateCoords:_testPosition];
    _tileCollision = [self getCollisionPropertyForTileCoords:_coordinates];
    
}

-(void) dealloc
{
    [_collisionData release];
    [_main release];
    [_map release];
    [_currentObject release];
    [_tileCollision release];
    [super dealloc];
}


@end
