//
//  Button.m
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Button.h"

@implementation Button

@synthesize buttonId = _buttonId;

+(id)buttonWithText:(NSString*)text AtPoint:(CGPoint)point
{
    return [[self alloc] initWithText:text AtPoint:point];
}

-(id)initWithText:(NSString*)text AtPoint:(CGPoint)point
{
    if ((self=[super init])) {
        _buttonLabel = [CCLabelTTF labelWithString:text fontName:@"Marker Felt" fontSize:22];
        _buttonLabel.position = ccp(point.x, point.y);
    }
    return self;
}

-(CCLabelTTF*)getLabel
{
    return _buttonLabel;
}

-(void)setHitbox:(CGRect)rect
{
    _hitbox = rect;
}

-(bool)testCollision:(CGPoint)position
{
    float left = _position.x - _hitbox.origin.x;
    float right = left + _hitbox.size.width;
    float bottom = _position.y - _hitbox.origin.y;
    float top = bottom + _hitbox.origin.y;
    
    if (position.x < right && position.x > left && position.y > bottom && position.y < top) {
        return true;
    } else {
        return false;
    }

}

@end
