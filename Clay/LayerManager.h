//
//  LayerManager.h
//  Clay
//
//  Created by Brian Cable on 9/8/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCScene;

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
-(CCScene*)getSceneForKey:(NSString*)key;


@end
