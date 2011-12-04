//
//  LayerManager.h
//  Clay
//
//  Created by Brian Cable on 9/8/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  This is a singleton class that allows any class that needs access the current layer, or scene to be able to get to it. Also includes the ability to set a "working scene" or "working layer" that is just used for initialization, while not destroying the previous layer (like for example wanting to keep the gamelayer the current layer but have

#import <Foundation/Foundation.h>

@class CCScene;
@class Player;

@interface LayerManager : NSObject
{
    id          _currentLayer;
    id          _workingLayer;
    CCScene     *_currentScene;
    id          _workingScene;
    NSMutableDictionary *_scenes;
}

+(LayerManager*)sharedLayers;
-(void)setCurrentLayer:(id)layer;
-(id)currentLayer;

-(void)setWorkingLayer:(id)layer;
-(void)forgetWorkingLayer;

-(void)setWorkingScene:(id)scene;
-(void)forgetWorkingScene;
-(id)currentScene;
-(void)setCurrentScene:(CCScene*)scene;

-(void)setScene:(CCScene*)scene ForKey:(NSString*)key;
-(id)getSceneForKey:(NSString*)key;

-(void)pushSceneNamed:(NSString*)pushScene;
-(void)popAndPushSceneNamed:(NSString*)pushScene;

-(Player*)getPlayer; //this class is used so often for this just get it directly



@end
