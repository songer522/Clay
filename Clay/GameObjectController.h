//
//  GameObjectController.h
//  Clay
//
//  Created by Dustin Werner on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface GameObjectController : NSObject {
    NSDictionary *_objectSettings;
}

-(CCSprite*)loadGameObjectWithName:(NSString*)objectName;

@end
