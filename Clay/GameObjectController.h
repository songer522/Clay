//
//  GameObjectController.h
//  Clay
//
//  Created by Dustin Werner on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  Currently used factory class for building GameObjects, called by the Level class whenever objects are needed. Extracts the necessary data from 'objects.plist', and builds a new GameObject based on those properties. Eventually going to be replaced with GameObjectFacty class.


#import "CCSprite.h"
#import "cocos2d.h"

@class GameObject;

@interface GameObjectController : NSObject {
    NSDictionary *_objectSettings;
}

-(GameObject*)loadGameObjectWithName:(NSString*)objectName;
-(GameObject*)loadGameObjectWithName:(NSString *)objectName AddToLayer:(bool)shouldAddToLayer;
-(void)initializeGameObject:(GameObject*)gameObject Name:(NSString*)objectName AddToLayer:(bool)shouldAddToLayer;
-(NSString*)getRandomImageFromList:(NSString*)list;

@end
