//
//  OptionsScene.h
//  Clay
//
//  Created by Brian Cable on 12/13/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "CCLayer.h"

@class ClippingNode;
@class Sprite;
@class GameLabel;
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
    
    ClippingNode *_musicMask;
    ClippingNode *_sfxMask;
    
    GameLabel *_eraseText;
    GameLabel *_dataText;
    
    GameLabel *_howToText;
    GameLabel *_playText;
    
    GameLabel *_creditsText;
    
    GameLabel *_optionsHeader;
    
    bool _isTransitioning;
    
    ActionButton *_backButton;
}

-(void)load;
-(void)setMusicXPosition:(float)xPos;
-(void)setSfxXPosition:(float)xPos;
-(void)sliderReactionAtPosition:(CGPoint)position;


@end
