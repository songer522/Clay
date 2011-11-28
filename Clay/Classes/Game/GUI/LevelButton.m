//
//  LevelButton.m
//  Clay
//
//  Created by Brian Cable on 11/8/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "LevelButton.h"
#import "Sprite.h"

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
    if (unlocked && _buttonId < 9) {
        frameName = [NSString stringWithFormat:@"CL_Level%d.png",_buttonId];
    } else {
        frameName = @"CL_LevelLocked.png";
    }
    
    _buttonGraphic = [Sprite spriteFromFrameCacheWithName:frameName];
    
    [self setInitialPosition];
}

-(void)setInitialPosition
{
    //initial position
    float startX = 119; //was 212 for left panel
    float startY = 186; //was 181 for left panel and 11 levels, and 152
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

    CGPoint position = ccp(startX + 64 * column, startY - 64 * row);
    [self setPosition:position];    
}

-(void)setPosition:(CGPoint)position
{
    [_buttonGraphic setScreenPosition:position];
    [self setTrophyPosition];
    [self setHitbox:CGRectMake(position.x, position.y, 55, 55)];
}

-(bool)checkIfSelected:(CGPoint)touch
{
    if ([self testCollision:touch] && _buttonId < 9) {
        [self setSelected];
        return true;
    }
    return false;
}

-(void)setSelected
{
    CGPoint position = [_buttonGraphic getCCSprite].position;
    position.x -= 3.5f;
    position.y -= 4.0f;
    [_selector setScreenPosition:position];
    [[_selector getCCSprite] setVisible:YES];    
}

-(void)setCursor:(Sprite*)cursor
{
    _selector = cursor;
}

-(void)setTrophy:(int)trophyId
{
    NSString *frameName = [NSString stringWithFormat:@"CL_Trophy_%d.png",trophyId];
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
