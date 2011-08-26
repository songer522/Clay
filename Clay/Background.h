//
//  Background.h
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseClasses.h"

@interface Background : NSObject
{
    Sprite *_bkg1;
    Sprite *_bkg2;
}

+(id)backgroundForLayer:(id)layer;

@end
