//
//  GameLabel.h
//  Clay
//
//  Created by Brian Cable on 11/29/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    TEXT_ALIGN_LEFT = 0,
    TEXT_ALIGN_CENTER = 1,
    TEXT_ALIGN_RIGHT = 2,
    TEXT_ALIGN_TOP = 0,
    TEXT_ALIGN_BOTTOM = 2
} TextAlignment;

@interface GameLabel : NSObject
{
    CCLabelBMFont *_label;
}

+(id)gameLabelWithText:(NSString*)text Scale:(float)scale;
+(id)gameLabelWithText:(NSString*)text Scale:(float)scale Position:(CGPoint)position;
-(id)initWithText:(NSString*)text Scale:(float)scale Width:(int)width Position:(CGPoint)position;

-(void)setPosition:(CGPoint)position;
-(void)setScale:(float)scale;
-(void)setAlpha:(float)alpha;
-(void)setText:(NSString*)text;
-(void)setHorizontalAlignment:(TextAlignment)alignment;
-(void)setVerticalAlignment:(TextAlignment)alignment;
-(void)setMultilineCentered;
-(void)setCentered;

@end
