//
//  PassengerCar.h
//  Clay
//
//  Created by Brian Cable on 1/11/12.
//  Copyright (c) 2012 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sprite;

@interface PassengerCar : NSObject
{
    Sprite *_boxcar;
    Sprite *_wheels;
    
    CGPoint _boxcarPosition;
    CGPoint _wheelsPosition;
}

+(id)instance;

-(void)changeAnimationSpeed:(float)speed;


-(void)addToLayer:(id)layer;
-(void)setPosition:(CGPoint)position;
-(void)updatePosition:(CGPoint)attachedPosition;

@end
