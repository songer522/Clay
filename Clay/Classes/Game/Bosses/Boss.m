//
//  Boss.m
//  Clay
//
//  Created by Brian Cable on 10/19/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Boss.h"
#import "Sprite.h"

@implementation Boss

@synthesize isActive = _isActive;

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _isActive = false;
    }
    
    return self;
}

-(void)changeAnimationSpeed:(float)modifier
{
    
}

-(void)update:(float)dt
{
    
}

-(void)reset
{
    //NSLog(@"reset got called");
}

-(void)restartLevel
{
    
}

-(void)setSprite:(Sprite *)sprite
{
    
}

-(void) startBoss
{
    
}

-(void)switchToPhase:(BossPhase)phase
{
    
}

-(void)triggerAttack
{
    
}

-(void)triggerAttack2
{
    
}

-(void)triggerAttack3
{
    
}

-(void)triggerFallBack
{
    
}

-(void)triggerGetCloser
{
    
}


@end
