//
//  GameObject.h
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sprite;

@interface GameObject : NSObject
{
    Sprite *_sprite;
    //Animation *_animation;
}

+(id) objectWithSprite:(Sprite*)sprite;
-(id) initWithSprite:(Sprite*)initSprite;
-(void) setPositionAtX:(int)x Y:(int)y;
-(void) setSprite:(Sprite*)sprite;
-(void) update:(float)dt;

@end
