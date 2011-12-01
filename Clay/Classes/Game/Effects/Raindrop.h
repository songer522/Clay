//
//  Raindrop.h
//  Clay
//
//  Created by Brian Cable on 11/30/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sprite;

@interface Raindrop : NSObject
{
    Sprite *_sprite;
    
    CGPoint _position;
    
    float _waitToLoadAnim; //don't want to load immediately so it's not always on the same frame of animation as the other raindrops
    
    int _prevFrame;
}

+(id)instance;

-(void)update:(float)dt;
-(void)repositionSprite;

@end
