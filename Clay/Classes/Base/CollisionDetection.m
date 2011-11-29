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
    
    _landedOnLedge = false;
   
    
#if CC_ENABLE_PROFILERS
    CCProfilingTimer *timer2 = [CCProfiler timerWithName:@"collisions" andInstance:self];
    CCProfilingBeginTimingBlock(timer2);
#endif  
    
    _currentMidpoints = [self getMidpointCollisionsForPoint:[_currentObject getPosition]];
    
    
#if CC_ENABLE_PROFILERS
    CCProfilingEndTimingBlock(timer2);
#endif    
    
    if(!_currentMidpoints.hasCollision) {
        _testPosition = _desiredPosition;
        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_MIDAIR];
    } else {
        if (_currentMidpoints.right) {
            _testPosition = _desiredPosition;
            if ([self pushLeft]) {
                [[_currentObject getCollision] setCurrentState:COLLISION_STATE_BUMPED_WALL];
            } else {
                _testPosition = _desiredPosition;
                if([self pushUp]) {
                    if (_landedOnLedge) {
                        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_LEDGE];
                    } else {
                        [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
                    }
                }
                [[_currentObject getCollision] setCurrentState:COLLISION_STATE_MIDAIR];
            }
        }
        if (_currentMidpoints.bottom) {
            if([self pushUp]) {
                if(_landedOnLedge) {
                    [[_currentObject getCollision] setCurrentState:COLLISION_STATE_LEDGE];
                } else {
                    [[_currentObject getCollision] setCurrentState:COLLISION_STATE_GROUNDED];
                }
            }
        }
    }
    

    
    return _testPosition;
}


-(XDCollision)getMidpointCollisionsForPoint:(CGPoint)position
{
    float left = position.x - _objectBoundingBox.origin.x;
    float bottom = position.y + _objectBoundingBox.origin.y;
    float right = left + _objectBoundingBox.size.width;
    float top = bottom + _objectBoundingBox.size.height;
    float middleX = (left + right) / 2.0f;
    float middleY = (top + bottom) / 2.0f;
    
    bool bottomCollision = [self checkCollisionAtPoint:CGPointMake(middleX, bottom) BoundingBoxPoint:BOX_BOTTOM_MIDDLE];
    
    bool rightCollision = [self checkCollisionAtPoint:CGPointMake(right, middleY) BoundingBoxPoint:BOX_RIGHT_MIDDLE];
    
    bool hasCollision = false;
    if (rightCollision||bottomCollision) {
        hasCollision = true;
    }
    
    XDCollision returnVal = XDCollisionMake(hasCollision, false, rightCollision, false, bottomCollision);
    
    return returnVal;
}


-(bool)checkCollisionAtPoint:(CGPoint)point BoundingBoxPoint:(BoundingBoxPoint)edge
{
    bool returnVal = false;
    
    CGPoint coords = [self accurateCoords:point];

    CollisionType collision = [self getCollisionTypeForCoords:coords];
    
    switch (collision) {
        case COLLISION_TYPE_NONE:
            returnVal = false;
            break;
        case COLLISION_TYPE_FULL:
            returnVal = true;
            break;
        case COLLISION_TYPE_LEDGE_FULL:
            //don't want this true unless it's the bottom edge when falling or not in midair.
            if (edge == BOX_BOTTOM_MIDDLE && (_currentObject.isFalling || !_currentObject.isInMidAir)) {
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

-(CollisionType)getCollisionTypeForCoords:(CGPoint)coords
{
    CollisionType returnVal = COLLISION_TYPE_NONE;
    
    NSString *property = [self getCollisionPropertyForTileCoords:coords];
    
    if ([property isEqualToString:@"full"])
    {
        returnVal = COLLISION_TYPE_FULL;
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
        
        [self prepareDataForPosition:_testPosition BoundingBoxPoint:BOX_BOTTOM_MIDDLE];

        
        float topOfTile = (_map.mapSize.height - _coordinates.y - 1) * (_tileSize / 2.0f);
        if ([GameSettings usingHighResolutionGraphics])
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
            
            if ([GameSettings usingHighResolutionGraphics])
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
    _collisionData = nil;
    _main = nil;
    _map = nil;
    _currentObject = nil;
    [_tileCollision release];
    [super dealloc];
}


@end
