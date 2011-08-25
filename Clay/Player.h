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
    TimeEquation *_logCalculator;
    TimeEquation *_sinCalculator;
}

+(id) playerForScene:(id)scene;
- (id)initWithScene:(id)scene;

-(void)updatePlayer:(float)dt;

@end
