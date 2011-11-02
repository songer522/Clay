//
//  Laser.h
//  Clay
//
//  Created by Brian Cable on 10/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  For the disco level, (level 4), these are the lasers that get displayed on top of the
//  screen, controlled by LaserShow class.
//
///////

#import <Foundation/Foundation.h>

@class Sprite;

@interface Laser : NSObject
{
    Sprite *_sprite;
    
    float _alpha;
    float _rate;
    float _cooldown;
    
    bool _isActive;
    
    CGPoint _position;
}


#pragma mark - initialize
+(id)laserWithId:(int)num;
-(id)initWithId:(int)num;

#pragma mark - public methods

// called when laser disappears to reposition and redisplay
// as if it were a new laser
-(void)reset;

// called when lasers are updated
-(void)update:(float)dt;


@end
