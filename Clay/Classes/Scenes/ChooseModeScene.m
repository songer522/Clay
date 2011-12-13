//
//  ChooseModeScene.m
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "ChooseModeScene.h"

@implementation ChooseModeScene

+(CCScene*)scene
{
    CCScene *scene = [CCScene node];
    ChooseModeScene *layer = [ChooseModeScene node];
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