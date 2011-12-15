//
//  OptionsScene.h
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"

@class Sprite;
@class ActionButton;

@interface OptionsScene : CCLayer
{
    Sprite *_background;
    
    Sprite *_musicPanel;
    Sprite *_sfxPanel;
    
    Sprite *_musicSheetTop;
    Sprite *_musicSheetMasked;
    
    Sprite *_sfxSheetTop;
    Sprite *_sfxSheetMasked;
    
    Sprite *_musicVolumeHeader;
    Sprite *_sfxVolumeHeader;
    
    ActionButton *_eraseDataButton;
    ActionButton *_howToPlayButton;
    ActionButton *_creditsButton;
}

-(void)load;

@end
