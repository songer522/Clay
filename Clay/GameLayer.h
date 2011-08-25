//
//  GameLayer.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "GameClasses.h"
#import <Foundation/Foundation.h>

@class Sprite;

@interface GameLayer : CCLayer
{
    Sprite *background;
    
    Player *_player;
}

+(CCScene *) scene;



@end
