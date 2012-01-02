//
//  RegionManager.m
//  Clay
//
//  Created by Brian Cable on 11/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Stores the game objects in the level into specific regions, which helps group them together and minimizes unneccesary hit detection or calls to update loops. In order to allow for smooth transitions, we actually need to have two regions active at any given time, a left region and a right region. Once the left region travels off the left side of the screen, then it can be replaced by a new right region, and the right region becomes the left. When the hit detection loops are called, it needs to be called with both regions joined together, so each object can be tested against every other active object.

#import "RegionManager.h"
#import "MapObject.h"
#import "GameObject.h"
#import "GameSettings.h"

#define REGION_MANAGER_TILES_PER_REGION 26 //should allow for ipad as well, plus some bleeding

@implementation RegionManager

-(id)init
{
    if ((self=[super init])) {
        _regions = [[NSMutableArray alloc] initWithCapacity:30];
        _leftRegion = nil;
        _rightRegion = nil;
        _combinedRegion = nil;
        _currentIndex = -1;
        [self resetPersistentObjects];
    }
    return self;
}

-(void)prepareArrays:(int)mapWidthInTiles
{
    int numberOfRegions = mapWidthInTiles / REGION_MANAGER_TILES_PER_REGION;
    for (int i=0; i<numberOfRegions*2;i++) {
        NSMutableArray *region = [[NSMutableArray alloc] initWithCapacity:3];
        [_regions addObject:region];
    }
}

-(void)addGameObject:(GameObject*)object
{
    int regionIndex = [self getRegionIndex:object.x];
    NSMutableArray *region = [_regions objectAtIndex:regionIndex];
    [region addObject:object];    
}

-(void)resetCurrentRegion
{
    _currentIndex = -1;
    
    if (_leftRegion !=nil) {
        for (GameObject *object in _leftRegion) {
            [object moveToStartingPosition];
        }        
    }

    if (_rightRegion !=nil) {
        for (GameObject *object in _leftRegion) {
            [[object getCCSprite] setVisible:NO];
            [object moveToStartingPosition];
        }        
    }

    [self resetPersistentObjects];
    //note, allows for and requires 'changeregionsbasedonx' to be called afterwards to get the right region again
    
}
    

-(void)changeRegionsBasedOnX:(float)x
{
    
    int newIndex = [self getRegionIndex:x];

    if (newIndex < 0) newIndex = 0; //force it to always be at least the minimum.
    
    if (newIndex == _currentIndex || newIndex<0) { return; }

    if (_leftRegion !=nil) {
        for (GameObject *object in _leftRegion) {
            [[object getCCSprite] setVisible:NO];
        }        
    }
    
    if (_combinedRegion!=nil) {
        [_combinedRegion release];
    }
    

    _currentIndex = newIndex;
    
    //NSLog(@"REGION MANAGER -> NEW INDEX: %d",newIndex);
    
    _leftRegion = [_regions objectAtIndex:newIndex];
    _rightRegion = [_regions objectAtIndex:(newIndex+1)];
    
    //create combined region from left and right region
    _combinedRegion = [[NSMutableSet alloc] initWithCapacity:10];    
    for (GameObject *object in _leftRegion) {
        [[object getCCSprite] setVisible:YES];
        [_combinedRegion addObject:object];
        if (object.persistsBetweenRegions) {
            [_persistentObjects addObject:object];
        }
    }
    for(GameObject *object in _rightRegion) {
        [[object getCCSprite] setVisible:YES];
        [_combinedRegion addObject:object];
        if (object.persistsBetweenRegions) {
            [_persistentObjects addObject:object];
        }
    }
    
    for (GameObject *object in _persistentObjects) {
        [_combinedRegion addObject:object];
    }
    
    if (_activeGameObjectList!=nil) {
        [_activeGameObjectList release];
        _activeGameObjectList = nil;
    }
    _activeGameObjectList = [[_combinedRegion allObjects] retain];
}

-(int)getRegionIndex:(float)xPosition
{
    return floor(xPosition / (32 * REGION_MANAGER_TILES_PER_REGION));
}

-(NSArray*)getActiveGameObjectList
{
    if ([[GameSettings shared] isStutterMode]) {
        return [_combinedRegion allObjects];        
    } else {
        return _activeGameObjectList;
    }
}

-(void)resetPersistentObjects
{
    if (_persistentObjects!=nil) {
        [_persistentObjects release];
    }
    _persistentObjects = [[NSMutableSet alloc] initWithCapacity:4];
}

-(void)printDescription
{
    NSLog(@"*** REGION MANAGER ***");
    NSLog(@"Number of regions: %d",[_regions count]);
    
    int numRegions = [_regions count];
    int totalObjects = 0;
    for (int i=0; i<numRegions; i++) {
        NSMutableArray *region = [_regions objectAtIndex:i];
        totalObjects += [region count];
        NSLog(@"REGION %d, Objects: %d",(i+1),[region count]);
    }
    NSLog(@"Total Number of Objects: %d",totalObjects);
    NSLog(@"*** REGION MANAGER ***");
}

-(void)dealloc
{
    
    [super dealloc];
}

@end
