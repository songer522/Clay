//
//  Lightning.h
//  Clay
//
//  Created by Brian Cable on 12/1/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sprite;

@interface Lightning : NSObject
{
    Sprite *_sprite;
    float _timeIntoAnimation;
    float _waitUntilNewStrike;
}

+(id)instance;

-(void)startStrike;
-(void)endStrike;

-(void)update:(float)dt;
-(void)repositionSprite;

@end
