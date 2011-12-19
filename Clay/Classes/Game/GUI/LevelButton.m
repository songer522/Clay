//
//  LevelButton.m
//  Clay
//
//  Created by Brian Cable on 11/8/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "LevelButton.h"
#import "Sprite.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

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
    bool unlocked = true; //for now, eventually check storage
    if (unlocked && _buttonId <= 11) {
        frameName = [NSString stringWithFormat:@"LevelSelector_Level%d.png",_buttonId];
    } else {
        frameName = @"LevelSelector_LevelLocked.png";
    }
    
    _buttonGraphic = [Sprite spriteFromFrameCacheWithName:frameName];
    
    [self setInitialPosition];
}

-(void)setInitialPosition
{
    //initial position
    float startX = 220; //was 212 for left panel
    float startY = 190; //was 181 for left panel and 11 levels, and 186 without
    float row = floorf((_buttonId - 1) / 4);
    
    //for staggered effect, move that one down one
    if (_buttonId == 8) {
        row = 2;
    }
    
    float column = (_buttonId - 1) % 4;
    if(_buttonId == 8) {
        column = 0;
    } else if(_buttonId > 8) {
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
    [self setTrophyPosition];
    [self setHitbox:CGRectMake(position.x, position.y, 55 * MULTIPLIERX, 55 * MULTIPLIERY)];
}

-(bool)checkIfSelected:(CGPoint)touch
{
    if ([self testCollision:touch] && _buttonId <= 11) {
        [self setSelected];
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

-(void)setCursor:(Sprite*)cursor
{
    _selector = cursor;
}

-(void)setTrophy:(int)trophyId
{
    NSString *frameName = [NSString stringWithFormat:@"LevelSelector_Trophy_%d.png",trophyId];
    _trophy = [Sprite spriteFromFrameCacheWithName:frameName];
    [self setTrophyPosition];
}

-(void)setTrophyPosition
{
    if (_trophy!=nil) {
        CGPoint position = [_buttonGraphic getPosition];
        [_trophy setScreenPosition:ccp(position.x + 34.0f,position.y - 2.0f)];            
    }
}


-(void)dealloc
{
    [_buttonGraphic release];
    [_selector release];
    [_trophy release];
    [super dealloc];
}

@end
