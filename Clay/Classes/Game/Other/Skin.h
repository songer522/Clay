//
//  Skin.h
//  Clay
//
//  Created by Brian Cable on 11/2/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Skin : NSObject
{
    NSString *_filename;
    
    //animations
    NSString *_running;
    NSString *_jumping;
    NSString *_falling;
    NSString *_sprinting;
    NSString *_tripping;
    NSString *_hurting;
    
    //action animations
    NSString *_wooAction;
    NSString *_kickAction;
    NSString *_dodgeAction;
    NSString *_shootAction;
}

-(void)setSkin:(NSString*)name;

//-(void)setAnimationByName:(NSString*)name ForSprite:(Sprite*)sprite;


@end
