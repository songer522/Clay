//
//  Button.m
//  Clay
//
//  Created by Brian Cable on 10/24/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Button.h"
#import "LayerManager.h"
#import "GameLabel.h"

//private methods
@interface Button()

-(id)initWithText:(NSString*)text AtPoint:(CGPoint)point;
-(id)initWithText:(NSString*)text AtPoint:(CGPoint)point inLayer:(CCLayer *)layer;
-(id)initWithGameLabelText:(NSString*)text AtPoint:(CGPoint)point;

@end

@implementation Button

@synthesize buttonId = _buttonId;

+(id)buttonWithText:(NSString*)text AtPoint:(CGPoint)point
{
    return [[self alloc] initWithText:text AtPoint:point];
}

+(id)buttonWithText:(NSString*)text AtPoint:(CGPoint)point inLayer:(CCLayer *)layer
{
    return [[self alloc] initWithText:text AtPoint:point inLayer:(CCLayer *)layer];
}

+(id)buttonWithGameLabelText:(NSString*)text AtPoint:(CGPoint)point
{
    return [[self alloc] initWithGameLabelText:text AtPoint:point];
}

-(id)initWithGameLabelText:(NSString*)text AtPoint:(CGPoint)point
{
    if ((self=[super init])) {
        _gameLabel = [GameLabel gameLabelWithText:text Scale:1.0f];
        [_gameLabel setPosition:point];
    }
    
    return self;
}


-(id)initWithText:(NSString*)text AtPoint:(CGPoint)point
{
    if ((self=[super init])) {
        _buttonLabel=[CCLabelBMFont labelWithString:text fntFile:@"GraphicFont.fnt"];
        _buttonLabel.position=ccp(point.x, point.y);
    
        [[[LayerManager sharedLayers] currentLayer] addChild:_buttonLabel];
    }
    
    return self;
}




-(id)initWithText:(NSString*)text AtPoint:(CGPoint)point inLayer:(CCLayer *)layer
{
    if ((self=[super init])) {
        
        _buttonLabel=[CCLabelBMFont labelWithString:text fntFile:@"GraphicFont.fnt"];
        _buttonLabel.position=ccp(point.x, point.y);
        
        [layer addChild:_buttonLabel];
    }
    
    return self;
}


-(CCLabelBMFont*)getLabel
{
    return _buttonLabel;
}
-(void)setLabel:(NSString*)text
{
    CGPoint labelPosition=_buttonLabel.position;
    [[[LayerManager sharedLayers] currentLayer] removeChild:_buttonLabel cleanup:NO];
    _buttonLabel=[CCLabelBMFont labelWithString:text fntFile:@"GraphicFont.fnt"];
    _buttonLabel.position=labelPosition;
    [[[LayerManager sharedLayers] currentLayer] addChild:_buttonLabel];
}

-(void)setHitbox:(CGRect)rect
{
    _hitbox = rect;
}

-(bool)testCollision:(CGPoint)position
{
    float left,right,top,bottom;
    
    if (_usingRelativeHitbox) {
        left = _position.x + _hitbox.origin.x;
        bottom = _position.y + _hitbox.origin.y;
    } else {
        left = _hitbox.origin.x;
        bottom = _hitbox.origin.y;
    }
    
    right = left + _hitbox.size.width;
    top = bottom + _hitbox.size.height;
    
    if (position.x < right && position.x > left && position.y > bottom && position.y < top) {
        return true;
    } else {
        return false;
    }

}

-(CGPoint)getPosition
{
    return _position;
}

-(void)setPosition:(CGPoint)position
{
    _position = position;
}

-(void)setText:(NSString*)text
{
    [_buttonLabel setString:text];
}

-(GameLabel*)getGameLabel
{
    return _gameLabel;
}

-(void)dealloc
{
    [_buttonLabel release];
    [_gameLabel release];
    [super dealloc];
}

@end
