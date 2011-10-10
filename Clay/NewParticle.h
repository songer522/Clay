//
//  NewParticle.h
//  Clay
//
//  Created by Brian Cable on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewParticle : NSObject
{
    float _vx;
    float _vy;
    float _ax;
    float _ay;
    float _angle;
    float _angleVelocity;
    float _alpha;
}

@property(nonatomic,assign) float vx;
@property(nonatomic,assign) float vy;
@property(nonatomic,assign) float ax;
@property(nonatomic,assign) float ay;
@property(nonatomic,assign) float angle;
@property(nonatomic,assign) float angleVelocity;
@property(nonatomic,assign) float alpha;

@end
