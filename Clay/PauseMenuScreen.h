//
//  PauseMenuScreen.h
//  Clay
//
//  Created by Brian Cable on 9/21/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameController;
@class Sprite;

@interface PauseMenuScreen : CCLayer
{
    float _alpha;
    GameController *_gameController;
    CCLabelTTF *_label;
    Sprite *_bkg;
}

@property(nonatomic,retain) GameController *gameController;

+(id)instance;
//- (id)initWithColor:(ccColor4B)color;

@end
