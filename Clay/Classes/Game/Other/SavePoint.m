//
//  SavePoint.m
//  Clay
//
//  Created by Brian Cable on 9/20/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "SavePoint.h"
#import "Player.h"

@implementation SavePoint

+(id)instance
{
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)setSavePoint:(CGPoint)position Level:(NSString*)level
{
    _position = position;
    _levelName = [[NSString alloc] initWithString:level];
}

-(void)restoreSavePoint:(Player*)player
{
    [player setPosition:_position];
    //TODO: tell game layer to switch to load/switch levels (if needed) and reset obstacles
}

-(void)dealloc
{
    [_levelName release];
    [super dealloc];
}

@end
