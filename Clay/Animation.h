//
//  Animation.h
//  Clay
//
//  Created by Brian Cable on 8/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>

@interface Animation : NSObject
{
    NSMutableArray *_frames;
    CCSpriteBatchNode *_spriteSheet;
}

+(id)animationFromPlist:(NSString*)name forSequence:(NSString*)sequence withFrameCount:(int)count onLayer:(id)layer;
-(id)initWithPlist:(NSString*)name forSequence:(NSString*)sequence withFrameCount:(int)count onLayer:(id)layer;
-(void)useAnimationToReplaceSprite:(Sprite*)sprite;

@end
