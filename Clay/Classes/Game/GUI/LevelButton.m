//
//  LevelButton.m
//  Clay
//
//  Created by Brian Cable on 11/8/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "LevelButton.h"
#import "Sprite.h"

@implementation LevelButton

+(id)levelButtonWithCache:(CCSpriteFrameCache*)cache andId:(int)buttonId
{
    return [[self alloc] initWithCache:cache andId:buttonId];
}
            
-(id)initWithCache:(CCSpriteFrameCache*)cache andId:(int)buttonId
{
    if ((self=[super init])) {
        _buttonId = buttonId;
        
        [self initButton];
        
        _selector = [Sprite spriteFromFrameCacheWithName:@"CL_LevelSelected.png"];
    }        
    return self;    
}
                          
-(void)initButton
{
    NSString *frameName;
    bool unlocked = true; //for now, eventually check storage
    if (unlocked) {
        frameName = [NSString stringWithFormat:@"CL_Level%f.png",_buttonId];
    } else {
        frameName = @"CL_LevelLocked.png";
    }
    
    _buttonGraphic = [Sprite spriteFromFrameCacheWithName:frameName];
    
    [frameName release];
}

-(void)setTrophy:(int)trophyId
{
    NSString *frameName = [NSString stringWithFormat:@"CL_Trophy_%f.png",trophyId];
    _trophy = [Sprite spriteFromFrameCacheWithName:frameName];
    [frameName release];
}

@end
