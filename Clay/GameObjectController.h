//
//  GameObjectController.h
//  Clay
//
//  Created by Dustin Werner on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@class GameObject;

@interface GameObjectController : NSObject {
    NSDictionary *_objectSettings;
}

-(GameObject*)loadGameObjectWithName:(NSString*)objectName;
-(GameObject*)loadGameObjectWithName:(NSString *)objectName AddToLayer:(bool)shouldAddToLayer;
-(void)initializeGameObject:(GameObject*)gameObject Name:(NSString*)objectName AddToLayer:(bool)shouldAddToLayer;

@end
