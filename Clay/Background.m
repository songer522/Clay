//
//  Background.m
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "Background.h"

@implementation Background

- (id)initForLayer:(id)layer
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _bkg1 = [Sprite spriteWithFile:@"background.bmp" toLayer:layer];
        _bkg2 = [Sprite spriteWithFile:@"background.bmp" toLayer:layer];
        [_bkg1 setPositionAtX:-160 Y:0];
        [_bkg2 setPositionAtX:320 Y:0];
    }
    
    return self;
}

+(id)backgroundForLayer:(id)layer
{
    return [[self alloc] initForLayer:layer];
}



@end
