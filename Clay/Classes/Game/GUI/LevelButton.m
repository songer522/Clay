//
//  LevelButton.m
//  Clay
//
//  Created by Brian Cable on 11/8/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "LevelButton.h"
#import "Sprite.h"
#import "GameSettings.h"

#define LEVEL_BUTTON_MAX_LEVEL_NUMBER 13
#define LEVEL_BUTTON_NUMBER_OF_NORMAL_LEVELS 11

@implementation LevelButton

+(id)levelButtonWithId:(int)buttonId
{
    return [[self alloc] initWithId:buttonId];
}
            
-(id)initWithId:(int)buttonId
{
    if ((self=[super init])) {
        _buttonId = buttonId + 1;
        
        [self initButton];
    }        
    return self;    
}


-(void)initButton
{
    NSString *frameName;
    _unlocked = false; //for now, eventually check storage
    
    NSString *showDLC = [[GameSettings shared] getGlobalForKey:@"timedShowDLC"];
    NSString *unlockText = [[GameSettings shared] getGlobalForKey:@"unlockEverything"];
    NSString *difficulty = [[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    
    
    if ([showDLC isEqualToString:@"YES"]) {
        _unlocked = true;
    } else {
        if ([difficulty isEqualToString:@"normal"]) {
            NSString *unlockedValue = [[GameSettings shared] getGlobalForKey:[NSString stringWithFormat:@"level%dTimedNormalUnlocked",_buttonId]];
            if ([unlockedValue isEqualToString:@"YES"]) {
                _unlocked = true;
            }
        } else {
            NSString *unlockedValue = [[GameSettings shared] getGlobalForKey:[NSString stringWithFormat:@"level%dTimedHardUnlocked",_buttonId]];
            if ([unlockedValue isEqualToString:@"YES"]) {
                _unlocked = true;
            }
        }
    }
    
    //if everything unlocked, then override the before
    if ([unlockText isEqualToString:@"YES"]) {
        _unlocked = true;
    }
        
    if (_unlocked && _buttonId <= LEVEL_BUTTON_MAX_LEVEL_NUMBER) {
        frameName = [NSString stringWithFormat:@"LevelSelector_Level%d.png",_buttonId];
    } else {
        frameName = @"LevelSelector_LevelLocked.png";
    }
    
    _buttonGraphic = [Sprite spriteFromFrameCacheWithName:frameName];
    
    _cart = [Sprite spriteCenteredWithFrame:@"LevelSelector_ShoppingCart.png"];
    [[_cart getCCSprite] setVisible:NO];
    
    [self setInitialPosition];
}

-(void)setInitialPosition
{
    int buttonIdPos = (_buttonId > LEVEL_BUTTON_NUMBER_OF_NORMAL_LEVELS) ? (_buttonId - LEVEL_BUTTON_NUMBER_OF_NORMAL_LEVELS) : _buttonId;
    
    //initial position
    float startX = 220; //was 212 for left panel
    float startY = 190; //was 181 for left panel and 11 levels, and 186 without
    float row = floorf((buttonIdPos - 1) / 4);
    
    //for staggered effect, move that one down one
    if (buttonIdPos == 8) {
        row = 2;
    }
    
    float column = (buttonIdPos - 1) % 4;
    if(buttonIdPos == 8) {
        column = 0;
    } else if(buttonIdPos > 8) {
        column +=1;
    }
    
    //offset for 2nd row
    if (row == 1) {
        column += 0.5f;
    }
    
    CGPoint position = ccp(startX + (64 * MULTIPLIERX) * column, startY - (64 * MULTIPLIERY) * row);
    [self setPosition:position];
}

-(void)setPosition:(CGPoint)position
{
    [_buttonGraphic setScreenPosition:position];
    [_cart setScreenPosition:ccp(position.x + 43.0f,position.y + 10.0f)];
    [self setTrophyPosition];
    [self setHitbox:CGRectMake(position.x, position.y, 55 * MULTIPLIERX, 55 * MULTIPLIERY)];
}

-(bool)checkIfSelected:(CGPoint)touch
{
    if (_unlocked && [self testCollision:touch] && _buttonId <= LEVEL_BUTTON_MAX_LEVEL_NUMBER) {
        [self setSelected];
        return true;
    }
    return false;
}

-(bool)checkIfTouched:(CGPoint)touch
{
    if ([self testCollision:touch] && _buttonId <= LEVEL_BUTTON_MAX_LEVEL_NUMBER) {
       // [self setSelected];
        return true;
    }
    return false;
}


-(void)setSelected
{
    CGPoint position = [_buttonGraphic getCCSprite].position;
    //position.x -= 3.5f;
    //position.y -= 4.0f;
    [_selector setScreenPosition:position];
    [[_selector getCCSprite] setVisible:YES];    
}

-(void)setPurchased:(bool)isPurchased
{
    if (isPurchased) {
        [[_cart getCCSprite] setVisible:NO];
        if (_trophy!=nil) {
            [_trophy setVisible:YES];
        }
    } else {
        [[_cart getCCSprite] setVisible:YES];
        if (_trophy!=nil) {
            [_trophy setVisible:NO];
        }
    }
}

-(void)setCursor:(Sprite*)cursor
{
    _selector = cursor;
}

-(void)setTrophy:(int)trophyId
{
    if (trophyId < 1 || trophyId > 3 || !_unlocked) { return; }

    NSString *frameName = [NSString stringWithFormat:@"LevelSelector_Trophy_%d.png",trophyId];
    _trophy = [Sprite spriteFromFrameCacheWithName:frameName];
    [self setTrophyPosition];
}

-(void)setTrophyPosition
{
    if (_trophy!=nil && _unlocked) {
        CGPoint position = [_buttonGraphic getPosition];
        [_trophy setScreenPosition:ccp(position.x + 34.0f * MULTIPLIERX,position.y - 2.0f * MULTIPLIERY)];            
    }
}

-(bool)isUnlocked
{
    return _unlocked;    
}


-(void)dealloc
{
    [_trophy release];
    [_buttonGraphic release];
    _selector = nil;
    [super dealloc];
}

@end
