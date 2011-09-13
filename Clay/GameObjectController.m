//
//  GameObjectController.m
//  Clay
//
//  Created by Dustin Werner on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameObjectController.h"
#import "PListLoader.h"
#import "GameObject.h"

@implementation GameObjectController

- (id)init
{
    self = [super init];
    if (self) {
        _objectSettings = [PListLoader loadPlistWithName:@"objects"];
    }
    
    return self;
}

-(CCSprite*)loadGameObjectWithName:(NSString *)objectName {
    CCSprite *gameObject;
    
    NSDictionary *gameobjectSettings = [_objectSettings objectForKey:objectName];
    if (gameobjectSettings == nil) {
        CCLOG(@"Could not locate GameObjectWithName:%@", objectName);
        return nil;
    }
    
    // get animation delay
    float animationDelay = [[gameobjectSettings objectForKey:@"delay"] floatValue];
    // add frames to animation
        

    return gameObject;
}

@end
