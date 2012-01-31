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
#import "Appirater.h"
#import "GameSettings.h"
#import "SoundEngine.h"

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
            break;
        case BLACKBOX_PLAY_COMIC_FADE_IN:
            _comicAlpha += 2.0f * dt;
            if (_comicAlpha >= 1.0f) {
                _comicAlpha = 1.0f;
                _transition = BLACKBOX_PLAY_COMIC_WAIT;
            }
            [_comicPanel setOpacity:floor(255 * _comicAlpha)];
            break;
        case BLACKBOX_PLAY_COMIC_WAIT:
            _timeToWait-=dt;
            if (_timeToWait<=0.0f) {
                _transition = BLACKBOX_PLAY_COMIC_FADE_OUT;
                _comicAlpha = 1.0f;
                [[SoundEngine shared] cueFastFadeOut];
            }
            break;
        case BLACKBOX_PLAY_COMIC_FADE_OUT:
            _comicAlpha -= 2.0f * dt;
            if (_comicAlpha <= 0.0f) {
                _comicAlpha = 0.0f;
                [_comicPanel removeFromParentAndCleanup:YES];
                _comicPanel = nil;
                [_skipButton removeFromParentAndCleanup:YES];
                _skipButton = nil;
                [_comicManager finishedAction];
            }
            [_comicPanel setOpacity:floor(255 * _comicAlpha)];
            [_skipButton setOpacity:floor(255 * _comicAlpha)];
            break;
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


-(void)cueComic:(NSString*)comicName
{
    bool showComic = false;
    //int durations[] = {5,10,6,7,14,7,9,10,6,8,8,6,10};
    int durations[] = {7,12,8,9,16,9,11,12,8,10,10,8,12};    
    int durationNumber = 0;
    NSString *_imageName;
    
    
    int comicNumber = [[comicName substringFromIndex:5] intValue];
    if (comicNumber <= 12) { 
        _imageName = [NSString stringWithFormat:@"Comic_%d.png",comicNumber];
        durationNumber = comicNumber;
        showComic = true;
    }
    else if(comicNumber > 20) {
        _imageName = [NSString stringWithFormat:@"Comic_%d.png",comicNumber];
        durationNumber = comicNumber - 9;
        showComic = true;
    }
    else {
        [_comicManager finishedAction];
    }

     if (showComic) {            
        _comicPanel = [CCSprite spriteWithFile:_imageName];
        _comicPanel.anchorPoint = ccp(0,0);
        [_comicPanel setOpacity:0];
        [self addChild:_comicPanel];

        _skipButton = [CCSprite spriteWithFile:@"Comic_Button_Skip.png"];
        _skipButton.position = ccp(460,20);
        _skipButton.anchorPoint = ccp(0.5f,0.5f);
        [self addChild:_skipButton];
        
        _transition = BLACKBOX_PLAY_COMIC_FADE_IN;
        _timeToWait = durations[durationNumber];
        _comicAlpha = 0.0f;
        [[SoundEngine shared] cueFadeIn];
        [[SoundEngine shared] playMusic:@"cutscene"];
    }
}

-(bool)skipComic
{
    bool couldSkip = false;
    
    if (_transition == BLACKBOX_PLAY_COMIC_WAIT) {
        _transition = BLACKBOX_PLAY_COMIC_FADE_OUT;
        couldSkip = true;
        [[SoundEngine shared] playSound:@"buttonPressed"];
        [[SoundEngine shared] cueFastFadeOut];
    }
    return couldSkip;
}

-(void)draw
{
    [self drawBars:_position];
}

-(void)drawBars:(float)position
{
    //if (_transition == BLACKBOX_IN || _transition == BLACKBOX_OUT || _transition == BLACKBOX_IDLE || _transition == BLACKBOX_PLAY_COMIC_FADE_IN) {
        float scale = 1.0f;
        if ([[GameSettings shared] usingHighResolutionGraphics]) {
            scale = 2.0f;        
        }
        [self ccDrawFilledRectFrom:ccp(0,0) To:ccp(960,position * scale)];
        [self ccDrawFilledRectFrom:ccp(0,640) To:ccp(960,(320.0f - position) * scale)];    
    //}
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
    _comicManager = nil; //weak
    [super dealloc];
}


@end
