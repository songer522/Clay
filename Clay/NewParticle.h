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

@property(nonatomic,retain) float vx;
@property(nonatomic,retain) float vy;
@property(nonatomic,retain) float ax;
@property(nonatomic,retain) float ay;
@property(nonatomic,retain) float angle;
@property(nonatomic,retain) float angleVelocity;
@property(nonatomic,retain) float alpha;

@end
