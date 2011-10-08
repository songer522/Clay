//
//  ComicLayer.m
//  Clay
//
//  Created by Brian Cable on 9/26/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "ComicLayer.h"
#import "ComicManager.h"
#import "LayerManager.h"

@implementation ComicLayer

@synthesize parent = _parent;

+(id)instance
{
    return [[self alloc] init];
}

-(id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        //[self scheduleUpdate];
        [[[LayerManager sharedLayers] currentScene] addChild:self];
        
        self.isTouchEnabled = YES;
        _transition = BLACKBOX_IDLE;
        _targetPosition = 0.0f;
        _atTarget = false;
    }
    
    return self;
}

-(void)startTransition:(BlackBoxTransition)transition
{
    _transition = transition;
    if (transition == BLACKBOX_IN) {
        _targetPosition = 35.0f;
        _timeToWait = 1.5f;
    } else {
        _targetPosition = 0.0f;
        _timeToWait = 1.0f;
    }
    _atTarget = false;
}





-(void)update:(ccTime)dt
{
    switch (_transition) {
        case BLACKBOX_IN:
            [self blackBoxIn:dt];
            break;
        case BLACKBOX_OUT:
            [self blackBoxOut:dt];
        default:
            break;
    }
}

-(void)blackBoxIn:(ccTime)dt
{
    if (!_atTarget) {
        [self moveBars:dt];
    } else {
        _timeToWait -= dt;
        if (_timeToWait<=0.0f) {
            _transition = BLACKBOX_IDLE;
            [_parent finishedAction];
        }
    }
}

-(void)blackBoxOut:(ccTime)dt
{
    _timeToWait -= dt;
    if (_timeToWait <= 0.0f) {
        [self moveBars:dt];
        if (_atTarget) {
            _transition = BLACKBOX_IDLE;
            [_parent finishedAction];
        }
    }
    
}

-(void)moveBars:(ccTime)dt
{
    float dx = _targetPosition - _position;
    float magnitude = sqrtf(dx * dx);
    
    
    if (_transition == BLACKBOX_IN) {
        _position += 5.0f * magnitude * dt;
    } else {
        _position -= 5.0f * magnitude * dt;
    }
    
    if (fabsf(_position - _targetPosition) < 0.02f) {
        _position = _targetPosition;
        _atTarget = true;
    }
}


-(void)draw
{
    float scale = [[UIScreen mainScreen] scale];
    [self ccDrawFilledRectFrom:ccp(0,0) To:ccp(960,_position * scale)];
    [self ccDrawFilledRectFrom:ccp(0,640) To:ccp(960,(320.0f - _position) * scale)];
}

-(void) ccDrawFilledRectFrom:(CGPoint)v1 To:(CGPoint)v2
{
    CGPoint poli[] = {v1, CGPointMake(v1.x,v2.y),v2,CGPointMake(v2.x,v1.y)};
    
    glColor4ub(0, 0, 0, 255);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glVertexPointer(2, GL_FLOAT, 0, poli);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
}

-(void)dealloc
{
    [_parent release];
    
}


@end
