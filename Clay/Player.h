//
//  PlayerOnScreen.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseClasses.h"
#import "cocos2d.h"

@interface Player : GameObject
{
    bool _isRunning;                
    float _velocity;
    float _xposition;                   
    TimeEquation *_logCalculator;       //uses log to determine velocity
    TimeEquation *_sinCalculator;       //uses sin to add a bit of sway to the runner's gait
}

+(id) playerForLayer:(id)layer;         //create player, attach it to (layer), return it
- (id)initWithLayer:(id)layer;          //constructor

-(float)getVelocity;                    //get the current velocity (read-only, for now)
-(void)update:(float)dt;                //update, dt = seconds since last update

@property(nonatomic,assign) bool isRunning;

@end
