//
//  PlayerOnScreen.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//
//  The main player and runner in the game.

#import <Foundation/Foundation.h>
#import "BaseClasses.h"
#import "cocos2d.h"

typedef enum {
    JUMP_HIGH = 3,
    JUMP_MEDIUM = 2,
    JUMP_SHORT = 1
} RunnerJump;

@interface Player : GameObject
{
    bool _isRunning;                    //will be used for starting gun, and will be used for gamestate for the time being
    bool _isJumping;
    float _velocityY;
    float _velocityX;                    //current velocity of the runner
    
    float _yPosition;
    
    TimeEquation *_logCalculator;       //uses log to determine velocity
    TimeEquation *_sinCalculator;       //uses sin to add a bit of sway to the runner's gait
}

+(id) playerForLayer:(id)layer;         //create player, attach it to (layer), return it
- (id)initWithLayer:(id)layer;          //constructor

-(float)getVelocityX;                    //get the current velocity (read-only, for now)
-(void)update:(float)dt;                //update, dt = seconds since last update

-(void)startJump:(RunnerJump)height;
-(void)updateJump:(float)dt;

@property(nonatomic,assign) bool isRunning;
@property(nonatomic,assign) bool isJumping;

@end
