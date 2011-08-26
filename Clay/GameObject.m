//
//  GameObject.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "GameObject.h"

#import "Sprite.h"

@implementation GameObject

+ (id) objectWithSprite:(Sprite*)sprite
{
    return [[self alloc] initWithSprite:sprite];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id) initWithSprite:(Sprite*)initSprite
{
    if((self=[self init])) {
        _sprite = initSprite;
    }
    return self;
}


-(void)setPositionAtX:(int)x Y:(int)y
{
    [_sprite setPositionAtX:x Y:y];
}

-(void)setSprite:(Sprite *)sprite
{
    _sprite = sprite;
}

-(Sprite*) getSprite
{
    return _sprite;
}

-(void)update:(float)dt
{
}


@end
