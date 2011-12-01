//
//  RainyLevelEffects.h
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sprite;

@interface RainyLevelEffects : NSObject
{
    NSMutableArray *_raindrops;
    
    Sprite *_rainBehindTim;
    
    Sprite *_lightning;
}

+(id)instance;
-(void)update:(float)dt;

@end
