//
//  ActionButton.h
//  Clay
//
//  Created by Brian Cable on 11/9/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "Button.h"
#import "GameSettings.h"

@class Sprite;
@class GameLabel;



@interface ActionButton : Button
{
    Sprite *_buttonIdle;
    Sprite *_buttonSelected;
    Sprite *_lockingGraphic;
    
    CCLabelBMFont *_textLabel;
    float _selectedAlpha;
    bool _hasText;
    bool _facebookOrTwitter;
    bool _facebookOrTwitterEndStroy;
    bool _isEnabled;
    
    LockType _lockType;
}
@property (assign)bool facebookOrTwitter;
@property (assign)bool facebookOrTwitterEndStroy;

+(id)actionButtonWithText:(NSString*)text;
+(id)actionButtonInGameWithText:(NSString*)text;
+(id)actionButtonCustomGraphicsForIdle:(NSString*)idleName Selected:(NSString*)selectedName;
+(id)actionButtonManualSetup; //use this when you want to set everything yourself

-(void)setPosition:(CGPoint)position;
-(void)setAlpha:(float)alpha;
-(void)setSelectedAlpha:(float)alpha;

-(void)setIdleSpriteFrame:(NSString*)name;
-(void)setSelectedSpriteFrame:(NSString*)name;
-(void)setInitialText:(NSString*)text;
-(void)setEnabled:(bool)isEnabled;
-(void)setInitialMultilineText:(NSString*)text Width:(int)width;
-(void)setMultilineCentered;
-(void)setRelativeHitbox:(CGRect)rect;
-(void)setHitboxBySize:(CGSize)size;
-(bool)checkIfSelected:(CGPoint)touch;
-(CCLabelBMFont*)getLabel;
-(void)update:(float)dt;
-(void)setLocked:(LockType)newType;
-(LockType)getLocked;
-(void)setText:(NSString *)text;

@end
