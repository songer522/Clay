//
//  Runner.h
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RUNNER_STATE_PRERACE,
    RUNNER_STATE_RUNNING,
    RUNNER_STATE_FINISHING,
    RUNNER_STATE_POSTRACE
} RunnerState;

@interface Runner : NSObject
{
    RunnerState _state;
    
    float _vx;                  //velocity in the x plane
    float _vy;                  //velocity in the y plane (only used by player for now)
    
    float _x;
    float _y;
    
    bool _isRunning;
    bool _isJumping;
}






@property(nonatomic,assign) float vx;
@property(nonatomic,assign) float vy;
@property(nonatomic,assign) float x;
@property(nonatomic,assign) float y;
@property(nonatomic,assign) RunnerState state;

@property(nonatomic,assign) bool isRunning;
@property(nonatomic,assign) bool isJumping;

-(void)changeToRunnerState:(RunnerState)state;
//-(id)initWithLayer:(id)layer;

@end
