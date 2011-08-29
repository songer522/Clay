//
//  GameController.m
//  Clay
//
//  Created by Brian Cable on 8/29/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "GameController.h"

@implementation GameController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self changeGameState:GAMESTATE_INITIALIZE];
    }
    
    return self;
}

+(id)gameController
{
    return [[self alloc] init];
}

-(void) initialize
{
    
}

-(void) changeGameState:(GameState)gameState
{
    switch (gameState) {
        case GAMESTATE_INITIALIZE:
            [self initialize];
            break;            
        default:
            break;
    }
    
    //hold off actually switching until later in case
    //some logic above needs to know the previous state
    _currentGameState = gameState;

}



@end
