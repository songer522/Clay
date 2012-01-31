//
//  GameLabel.m
//  Clay
//
//  Created by Brian Cable on 11/29/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GameLabel.h"
#import "LayerManager.h"
#import "GameSettings.h"

@implementation GameLabel


+(id)gameLabelWithText:(NSString*)text Scale:(float)scale
{
    return [[self alloc] initWithText:text Scale:scale Width:1024 Position:ccp(0,0)];
}

+(id)gameLabelWithText:(NSString*)text Scale:(float)scale Position:(CGPoint)position
{
    return [[self alloc] initWithText:text Scale:scale Width:1024 Position:position];
}

+(id)gameLabelMultilineWithText:(NSString*)text Scale:(float)scale Width:(int)width Position:(CGPoint)position
{
    return [[self alloc] initWithText:text Scale:scale Width:width Position:position];
}

-(id)initWithText:(NSString*)text Scale:(float)scale Width:(int)width Position:(CGPoint)position
{
    if((self=[super init])) {
        if ([[GameSettings shared] usingHighResolutionGraphics]) {
            _label = [CCLabelBMFont labelWithString:text fntFile:@"GraphicFont.fnt" width:width alignment:UITextAlignmentLeft];            
        } else {
            _label = [CCLabelBMFont labelWithString:text fntFile:@"GraphicFont_LowRes22.fnt" width:width alignment:UITextAlignmentLeft];            
        }
        [self setScale:scale];
        [self setPosition:position];
        [[[LayerManager sharedLayers] currentLayer] addChild:_label];
    }
    return self;
}

-(void)setPosition:(CGPoint)position
{
    _label.position = position;
}

-(void)setScale:(float)scale
{
    if ([[GameSettings shared] usingHighResolutionGraphics])
    {
        [_label setScale:scale];
    }
    else
    {
        [_label setScale:scale];
        //[_label setScale:(scale/2.0f)];
    }
}

-(void)setMultilineCentered
{
    _label.alignment = UITextAlignmentCenter;
}

-(void)setHorizontalAlignment:(TextAlignment)alignment
{
    float anchorValue = alignment / 2.0f;
    CGPoint currentAnchorPoint = _label.anchorPoint;
    _label.anchorPoint = ccp(anchorValue, currentAnchorPoint.y);
}

-(void)setVerticalAlignment:(TextAlignment)alignment
{
    float anchorValue = alignment / 2.0f;
    CGPoint currentAnchorPoint = _label.anchorPoint;
    _label.anchorPoint = ccp(currentAnchorPoint.x, anchorValue);    
}

-(void)setCentered
{
    [self setHorizontalAlignment:TEXT_ALIGN_CENTER];
    [self setVerticalAlignment:TEXT_ALIGN_CENTER];
}


-(void)setText:(NSString*)text
{
    [_label setString:text];
}

-(void)setAlpha:(float)alpha
{
    GLubyte opacity = floor(alpha * 255);
    [_label setOpacity:opacity];
}

-(void)setVisible:(bool)isVisible
{
    [_label setVisible:isVisible];
}

-(void)dealloc
{
    [_label removeFromParentAndCleanup:YES];
    _label = nil;
    [super dealloc];
}

@end
