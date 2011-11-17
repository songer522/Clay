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

@synthesize comicManager = _comicManager;

+(id)instance
{
    return [[self alloc] init];
}

-(id) init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        CCScene *scene = [[LayerManager sharedLayers] currentScene];
        [scene addChild:self];
        
        self.isTouchEnabled = YES;
        _transition = BLACKBOX_IDLE;
        _targetPosition = 0.0f;
        _rate = 1.0f;
        _atTarget = false;
    }
    
    return self;
}

-(void)startTransition:(BlackBoxTransition)transition
{
    _transition = transition;
    _phase = 1;
    if (transition == BLACKBOX_IN) {
        _position = 0.0f;
        _targetPosition = 35.0f;
        _timeToWait = 1.0f;
    } else {
        _position = 240.0f;
        _targetPosition = 35.0f;
        _timeToWait = 0.00f;
    }
    _rate = 0.9f;
    _atTarget = false;
}


-(void)waitToPlayVideo:(float)time
{
    _timeToWait = time;
    _transition = BLACKBOX_WAIT;
}


-(void)update:(ccTime)dt
{
    switch (_transition) {
        case BLACKBOX_IN:
            [self blackBoxIn:dt];
            break;
        case BLACKBOX_OUT:
            [self blackBoxOut:dt];
            break;
        case BLACKBOX_WAIT:
            _timeToWait-=dt;
            if (_timeToWait<=0.0f) {
                _transition = BLACKBOX_IDLE;
                [_comicManager finishedAction];
            }
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
            if (_phase == 1) {
                [self secondTierBars];
            } else {
                _transition = BLACKBOX_IDLE;
                [_comicManager finishedAction];
            }
        }
    }
}

-(void)blackBoxOut:(ccTime)dt
{
    if (!_atTarget) {
        [self moveBars:dt];
    } else {
        _timeToWait -= dt;
        if (_timeToWait<=0.0f) {
            if (_phase == 1) {
                [self secondTierBars];
            } else {
                _transition = BLACKBOX_IDLE;
                [_comicManager finishedAction];                
            }
        }
    }
}

//bars open up twice, once to cinematic, 2nd to full screen (open or closed).
//this function is when it's time to change target positions for the 2nd phase of this
//animation, which will be all black if bar phase is coming in, or no black if bars are going out
-(void)secondTierBars
{
    _phase = 2;
    _rate = 1.0f;
    if (_transition == BLACKBOX_IN) {
        _targetPosition = 240.0f;
        _timeToWait = 0.0f;
        _atTarget = false;
    } else {
        _targetPosition = 0.0f;
        _timeToWait = 0.0f;
        _atTarget = false;
    }
    
}

-(void)moveBars:(ccTime)dt
{
    float dx = _targetPosition - _position;
    float magnitude = sqrtf(dx * dx);
    
    
    if (_transition == BLACKBOX_IN) {
        _position += 5.0f * _rate * magnitude * dt;
    } else {
        _position -= 5.0f * _rate * magnitude * dt;
    }
    
    if (fabsf(_position - _targetPosition) < 1.0f) {
        _position = _targetPosition;
        _atTarget = true;
    }
}


-(void)draw
{
    [self drawBars:_position];
}

-(void)drawBars:(float)position
{
    float scale = [[UIScreen mainScreen] scale];
    [self ccDrawFilledRectFrom:ccp(0,0) To:ccp(960,position * scale)];
    [self ccDrawFilledRectFrom:ccp(0,640) To:ccp(960,(320.0f - position) * scale)];    
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

-(void)resetLayer
{
    [[[LayerManager sharedLayers] currentScene] removeChild:self cleanup:NO];
    [[[LayerManager sharedLayers] currentScene] addChild:self];
}

-(void)dealloc
{
    [_comicManager release];
    [super dealloc];
}


@end
