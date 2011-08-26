//
//  GameLayer.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "GameClasses.h"
#import "BaseClasses.h"
#import <Foundation/Foundation.h>

@class Sprite;

@interface GameLayer : CCLayer
{
    //Sprite *background;
    
    Player *_player;
    
    Background *_background;
    
    Animation *_playerAnimation;
    
    CCSprite *_test;
    CCAction *_running;
}

+(CCScene *) scene;


@property(nonatomic,retain) Player *_player;

@end
