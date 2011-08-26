//
//  Background.h
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseClasses.h"

@class GameLayer;

@interface Background : NSObject
{
    GameLayer *_layer;
    Sprite *_bkg1;
    Sprite *_bkg2;
    float _backgroundPosition;
}

+(id)backgroundForLayer:(id)layer;
-(id)initForLayer:(id)layer;
-(void)update:(float)dt;

@end
