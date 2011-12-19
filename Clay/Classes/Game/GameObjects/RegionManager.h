//
//  RegionManager.h
//  Clay
//
//  Created by Brian Cable on 11/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Stores the game objects in the level into specific regions, which helps group them together and minimizes unneccesary hit detection or calls to update loops. In order to allow for smooth transitions, we actually need to have two regions active at any given time, a left region and a right region. Once the left region travels off the left side of the screen, then it can be replaced by a new right region, and the right region becomes the left. When the hit detection loops are called, it needs to be called with both regions joined together, so each object can be tested against every other active object.

#import <Foundation/Foundation.h>

@class GameObject;

@interface RegionManager : NSObject
{
    NSMutableArray *_regions;
    
    NSMutableArray *_leftRegion; //weak reference
    NSMutableArray *_rightRegion; //weak reference
    NSMutableSet *_combinedRegion;
    NSMutableSet *_persistentObjects;
    
    NSArray *_activeGameObjectList;
    
    int _currentIndex;
}

-(void)prepareArrays:(int)mapWidthInTiles;

-(void)addGameObject:(GameObject*)object;

-(int)getRegionIndex:(float)xPosition;

-(void)changeRegionsBasedOnX:(float)x;

-(NSMutableArray*)getActiveGameObjectList;

-(void)resetCurrentRegion;

-(void)printDescription; //better to call after game objects are added

-(void)resetPersistentObjects;

@end
