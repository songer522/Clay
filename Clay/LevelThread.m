//
//  LevelThread.m
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "LevelThread.h"

@implementation LevelThread

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(void)test:(id)param
{
    int x;
    for (x=0; x<250; ++x) {
        printf("Object Thread says x is %i\n",x);
        usleep(1);
    }
}
@end
