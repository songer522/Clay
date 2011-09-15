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
#import "Sprite.h"

@implementation GameObjectController

- (id)init
{
    self = [super init];
    if (self) {
        _objectSettings = [PListLoader loadPlistWithName:@"objects"];
    }
    
    return self;
}

-(GameObject*)loadGameObjectWithName:(NSString *)objectName {
    
    NSDictionary *gameobjectSettings = [_objectSettings objectForKey:objectName];
    if (gameobjectSettings == nil) {
        CCLOG(@"Could not locate GameObjectWithName:%@", objectName);
        return nil;
    }
    Sprite *gameSprite = [Sprite spriteWithFile:[gameobjectSettings objectForKey:@"imageName"]];

    GameObject *gameObject = [GameObject objectWithSprite:gameSprite];
    [gameObject setOffsetForX:[[gameobjectSettings objectForKey:@"offsetx"] floatValue] Y:[[gameobjectSettings objectForKey:@"offsety"] floatValue]];
    NSDictionary *anchorPoint = [gameobjectSettings objectForKey:@"anchorPoint"];
    [[gameObject getCCSprite] setAnchorPoint:ccp([[anchorPoint objectForKey:@"x"] floatValue], [[anchorPoint objectForKey:@"y"] floatValue])];
    NSDictionary *boundingBox = [gameobjectSettings objectForKey:@"boundingBox"];
    gameObject.boundingBox = CGRectMake([[boundingBox objectForKey:@"x"] floatValue], [[boundingBox objectForKey:@"y"] floatValue], [[boundingBox objectForKey:@"width"] floatValue], [[boundingBox objectForKey:@"height"] floatValue]);
    
    return gameObject;
}

@end
