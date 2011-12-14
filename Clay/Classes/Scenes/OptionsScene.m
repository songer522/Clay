//
//  OptionsScene.m
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "OptionsScene.h"

@implementation OptionsScene

+(CCScene*)scene
{
    CCScene *scene = [CCScene node];
    OptionsScene *layer = [OptionsScene node];
    [scene addChild:layer];
    return scene;
}

-(id)init
{
    if((self=[super init])) {
        
        
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
    }
    
    return self;
}

-(void)update:(ccTime)dt
{
    
}

-(void)onExit
{
    [self unscheduleUpdate];
    self.isTouchEnabled = false;
}

-(void)dealloc
{
    
}

@end
