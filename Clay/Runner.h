//
//  Runner.h
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseClasses.h"

typedef enum {
    RUNNER_STATE_PRERACE,
    RUNNER_STATE_RUNNING,
    RUNNER_STATE_FINISHING,
    RUNNER_STATE_POSTRACE
} RunnerState;

@class RunningSpeed;

@interface Runner : GameObject
{
    RunnerState _state;
    
    float _distance;            //how much distance travelled in the race so far. used to determine
                                //onscreen position relative to the main player
    bool _isRunning;
    
    RunningSpeed *_speed;
    
}


-(id)initWithSprite:(Sprite *)sprite;
+(id)runnerWithSprite:(Sprite*)sprite;


@property(nonatomic,assign) RunnerState state;

@property(nonatomic,assign) bool isRunning;
@property(nonatomic,assign) bool isJumping;

-(void)changeToRunnerState:(RunnerState)state;

-(Sprite*)getSprite;

@end
