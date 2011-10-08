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
#import "AnimationController.h"

@implementation GameObjectController

- (id)init
{
    self = [super init];
    if (self) {
        _objectSettings = [[PListLoader loadPlistWithName:@"objects"] retain];
    }
    
    return self;
}

-(GameObject*)loadGameObjectWithName:(NSString *)objectName {
    
    GameObject *gameObject = [GameObject instance];
    [self initializeGameObject:gameObject Name:objectName];
    return gameObject;
    
}

-(void)initializeGameObject:(GameObject*)gameObject Name:(NSString*)objectName {
    NSDictionary *gameobjectSettings = [_objectSettings objectForKey:objectName];
    if (gameobjectSettings == nil) {
        CCLOG(@"Could not locate GameObjectWithName:%@", objectName);
        return;
    }
    
    Sprite *gameSprite = [Sprite spriteWithFile:[gameobjectSettings objectForKey:@"imageName"]];
    [gameObject setSprite:gameSprite];
    
    NSString *animation = [gameobjectSettings objectForKey:@"animationName"];
    if (animation && [animation compare:@""] != NSOrderedSame) {
        [[AnimationController sharedController] replaceSprite:gameSprite withAnimationNamed:animation];
    }
    
    [gameObject setOffsetForX:[[gameobjectSettings objectForKey:@"offsetx"] floatValue] Y:[[gameobjectSettings objectForKey:@"offsety"] floatValue]];
    
    NSString *collideBehavior = [gameobjectSettings objectForKey:@"collideBehavior"];
    [gameObject setCollideBehavior:collideBehavior];
    
    NSString *playerEffect = [gameobjectSettings objectForKey:@"playerEffect"];
    [gameObject setPlayerEffect:playerEffect];
    
    NSDictionary *anchorPoint = [gameobjectSettings objectForKey:@"anchorpoint"];
    [[gameObject getCCSprite] setAnchorPoint:ccp([[anchorPoint objectForKey:@"x"] floatValue], [[anchorPoint objectForKey:@"y"] floatValue])];
    NSDictionary *boundingBox = [gameobjectSettings objectForKey:@"boundingBox"];
    gameObject.boundingBox = CGRectMake([[boundingBox objectForKey:@"x"] floatValue], [[boundingBox objectForKey:@"y"] floatValue], [[boundingBox objectForKey:@"width"] floatValue], [[boundingBox objectForKey:@"height"] floatValue]);
}

-(void)dealloc
{
    [_objectSettings release];
    [super dealloc];
}

@end
