//
//  GameController.h
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GAMESTATE_INITIALIZE,
    GAMESTATE_PRE_RACE,
    GAMESTATE_RACING,
    GAMESTATE_PRE_DAYDREAM,
    GAMESTATE_IN_DAYDREAM,
    GAMESTATE_POST_DAYDREAM,
    GAMESTATE_POST_RACE
} GameState;

@interface GameController : NSObject
{
    GameState _currentGameState;
}

+(id)gameController;

-(void)changeGameState:(GameState)gameState;
-(void)reactToTouchAt:(CGPoint)location;

@end
