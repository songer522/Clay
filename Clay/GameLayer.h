//
//  GameLayer.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  This class is the main layer on which Clay will take place.

#import "cocos2d.h"
#import "GameClasses.h"
#import "BaseClasses.h"
#import <Foundation/Foundation.h>

@class Sprite;

@interface GameLayer : CCLayer
{
    Player *_player;                //the player character in the game
    
    Background *_background;        //the background layer
    
    Animation *_playerAnimation;    //the animation for the player. TODO: integrate within player,
                                    //create AnimationManager class
    GameController *_gameController;
    
    InputController *_inputController;
    
    //TODO: create a GameController class to link here, and any game logic into it.
}

+(CCScene *) scene; //create and return a Cocos2D scene

@property(nonatomic,retain) Player *player;

@end
