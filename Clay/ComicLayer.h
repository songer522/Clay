//
//  ComicScene.h
//  Clay
//
//  Created by Brian Cable on 9/2/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCTMXTiledMap.h"
#import "CCTMXLayer.h"

@interface ComicLayer : CCScene
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
}

+(CCScene *) scene; //create and return a Cocos2D scene

@property (nonatomic,retain) CCTMXTiledMap *tileMap;
@property (nonatomic,retain) CCTMXLayer *background;

@end
