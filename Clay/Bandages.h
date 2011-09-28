//
//  Bandages.h
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Sprite;
@class Player;

@interface Bandages : NSObject
{
    Sprite *sprite;
    int _currentFrame;
    float _totalTime;
    float _waitToFade;
    float _alpha;
}

+(id)instance;

-(void) setFrame:(int)frameNumber;
-(void)update:(float)dt Player:(Player*)player;
-(CCSprite*)getCCSprite;
-(void)reset;
@end
