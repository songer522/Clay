//
//  Laser.h
//  Clay
//
//  Created by Brian Cable on 10/21/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

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

+(id)laserWithId:(int)num;
-(id)initWithId:(int)num;
-(void)reset;
-(void)update:(float)dt;


@end
