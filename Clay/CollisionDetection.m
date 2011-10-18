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

#define COLLISION_DETECTION_TEST_LEFT_COLLISIONS 0

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
    _objectBoundingBox = object.boundingBox;
    
    _currentMidpoints = [self getMidpointCollisionsForPoint:[_currentObject getPosition]];
    
    if(!_currentMidpoints.hasCollision) {
        _testPosition = _desiredPosition;
        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_MIDAIR];
    } else {
        /*if (_currentMidpoints.right) {
            _testPosition = _desiredPosition;
            if ([self pushLeft]) {
                [[_currentObject getCollision] setCurrentState:COLLISION_STATE_BUMPED_WALL];
                NSLog(@"PUSH LEFT");
            } else {
                _testPosition = _desiredPosition;
                if([self pushUp]) {
                    [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
                }
                NSLog(@"PUSH LEFT FAILED");
                [[_currentObject getCollision] setCurrentState:COLLISION_STATE_MIDAIR];
            }
        } else 
        */
        if (_currentMidpoints.bottom) {
            if([self pushUp]) {
                [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
                NSLog(@"PUSH UP");
            }
        }
    }
    
    
    return _testPosition;
}


-(XDCollision)getMidpointCollisionsForPoint:(CGPoint)position
{
    float scale = 1;
    
    float left = position.x - (_objectBoundingBox.origin.x * scale);
    float bottom = position.y + (_objectBoundingBox.origin.y * scale);
    float right = left + (_objectBoundingBox.size.width * scale);
    float top = bottom + (_objectBoundingBox.size.height * scale);
    float middleX = (left + right) / 2.0f;
    float middleY = (top + bottom) / 2.0f;
    
    bool leftCollision = false;
    
#if COLLISION_DETECTION_TEST_LEFT_COLLISIONS
        leftCollision = [self checkCollisionAtPoint:CGPointMake(left, middleY)];
#endif
    
    bool bottomCollision = [self checkCollisionAtPoint:CGPointMake(middleX, bottom)];
    
    bool topCollision = [self checkCollisionAtPoint:CGPointMake(middleX,top)];
    bool rightCollision = [self checkCollisionAtPoint:CGPointMake(right, middleY)];
    
    //want to offset Y position as this test is used for left/right collisions and don't want to do left/right just because it
    //always says true while on the ground
    //bool bottomRightCollision = [self checkCollisionAtPoint:CGPointMake(right, bottom + 3.0f)];
    
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
    CGPoint checkPoint = _testPosition;
    
    bool colliding = true;    
    while (colliding) {
        
        [self prepareDataForPosition:_testPosition BoundingBoxPoint:BOX_BOTTOM_MIDDLE];

        
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

    return true;
}

-(bool)pushLeft
{
    bool returnVal = true;
    bool movedLeftOnce = false;     //most circumstances, if we need to move left more than one block, then we should be testing the top collision instead
    bool colliding = true;
    while (colliding) {
        [self prepareDataForPosition:_testPosition BoundingBoxPoint:BOX_NONE];
        
        float leftOfTile = _coordinates.x * (_tileSize / 2.0f);
        
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
            colliding = false;
            returnVal = false;
        }
    }
    return returnVal;
}
                                 


-(void)prepareDataForPosition:(CGPoint)position BoundingBoxPoint:(BoundingBoxPoint)edge
{
    CGPoint collisionPoint = [self getPointForObject:_currentObject AtPosition:position ForBoundingBoxEdge:edge];
    _testPosition = CGPointMake(position.x, position.y);
    _pointWithinTile = CGPointMake((int)collisionPoint.x % (_tileSize/2), (int)collisionPoint.y % _tileSize/2);
    _coordinates = [self accurateCoords:collisionPoint];
    _tileCollision = [self getCollisionPropertyForTileCoords:_coordinates];
    
}


-(CGPoint)getPointForObject:(GameObject*)object AtPosition:(CGPoint)position ForBoundingBoxEdge:(BoundingBoxPoint)edge
{
    float left = position.x - (_objectBoundingBox.origin.x);
    float bottom = position.y + (_objectBoundingBox.origin.y);
    float right = left + (_objectBoundingBox.size.width);
    float top = bottom + (_objectBoundingBox.size.height);

    float middleX = (left + right) / 2.0f;
    float middleY = (top + bottom) / 2.0f;

    switch (edge) {
        case BOX_BOTTOM_MIDDLE:
            return CGPointMake(middleX, bottom);
            break;
        case BOX_RIGHT_BOTTOM:
            return CGPointMake(right, bottom);
            break;
        case BOX_RIGHT_MIDDLE:
            return CGPointMake(right, middleY);
        default:
            return position;
            break;
    }
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
