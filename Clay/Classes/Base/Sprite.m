//
//  Sprite.m
//  Clay
//
//  Created by Brian Cable on 8/25/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import "cocos2d.h"
#import "Sprite.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Camera.h"
#import "LayerManager.h"
#import "Animator.h"
#import "GameSettings.h"

@implementation Sprite

@synthesize x = _x;
@synthesize y = _y;
@synthesize name = _frameName;

- (id)init
{
    //super init already called within initWithFile under sprite
    if ((self=[super init])) {
        sprite_cc = nil;
        _animation = nil;
        //_animator = [Animator instance]; //has significant memory leaks anyway
        _camera = [Camera sharedCamera];
        
        _isLowRes = true;
        if ([[GameSettings shared] usingHighResolutionGraphics]) {
            _isLowRes = false;
        }
    }    
    return self;
}

+(id) spriteFromFrameCacheWithName:(NSString*)frameName
{
    return [[self alloc] initFromFrameCacheWithName:frameName AddToLayer:YES];
}
           

+(id) spriteFromFrameCacheWithName:(NSString*)frameName AddToLayer:(bool)shouldAddToLayer
{
    return [[self alloc] initFromFrameCacheWithName:frameName AddToLayer:shouldAddToLayer];
}

+(id) spriteCenteredWithFrame:(NSString*)frame
{
    return [[self alloc] initFromFrameCacheWithName:frame AddToLayer:YES Position:ccp(0,0) AnchorPoint:ccp(0.5f,0.5f)];
}

+(id) spriteCenteredWithFrame:(NSString*)frame AddToLayer:(bool)addToLayer
{
    return [[self alloc] initFromFrameCacheWithName:frame AddToLayer:addToLayer Position:ccp(0,0) AnchorPoint:ccp(0.5f,0.5f)];
}

+(id) spriteCenteredWithFrame:(NSString*)frame Position:(CGPoint)position
{
    return [[self alloc] initFromFrameCacheWithName:frame AddToLayer:YES Position:position AnchorPoint:ccp(0.5f,0.5f)];
}

+(id) spriteNotCenteredWithFrame:(NSString*)frame Position:(CGPoint)position
{
    return [[self alloc] initFromFrameCacheWithName:frame AddToLayer:YES Position:position AnchorPoint:ccp(0,0)];
}


-(id) initFromFrameCacheWithName:(NSString *)frameName AddToLayer:(_Bool)shouldAddToLayer Position:(CGPoint)position AnchorPoint:(CGPoint)anchorPoint
{
    if((self = [self initFromFrameCacheWithName:frameName AddToLayer:shouldAddToLayer])) {
        sprite_cc.position = position;
        sprite_cc.anchorPoint = anchorPoint;
    }
    return self;
}

-(id) initFromFrameCacheWithName:(NSString*)frameName AddToLayer:(bool)shouldAddToLayer
{
    if((self = [self init]))
    {
        sprite_cc = [CCSprite spriteWithSpriteFrameName:frameName];

        _frameName = [[NSString stringWithString:frameName] retain];
        
        [self initializeSpriteOnceLoaded];
        
        if (shouldAddToLayer) {
            [[[LayerManager sharedLayers] currentLayer] addChild:sprite_cc];            
        }
    }
    return self;
}

+(id) instance
{
    return [[self alloc] initWithFile:@"blank.png" AddToLayer:YES];
}

+(id) spriteWithFile:(NSString*)filename
{
    return [[self alloc] initWithFile:filename AddToLayer:YES];
}

+(id) spriteWithFile:(NSString *)filename AddToLayer:(bool)shouldAddToLayer
{
    return [[self alloc] initWithFile:filename AddToLayer:shouldAddToLayer];
}

-(id) initWithFile:(NSString *)filename AddToLayer:(bool)shouldAddToLayer
{
    NSAssert(filename!=nil, @"Invalid filename");
    
    if((self = [self init]))
    {
        sprite_cc = [[CCSprite spriteWithFile:filename] retain];
        
        [self initializeSpriteOnceLoaded];
        
        if (shouldAddToLayer) {
            [[[LayerManager sharedLayers] currentLayer] addChild:sprite_cc];
        }
    }
    return self;
}

-(void) initializeSpriteOnceLoaded
{
    NSAssert(sprite_cc!=nil, @"Do not call before sprite is loaded");
    sprite_cc.position = ccp(0,0);
    sprite_cc.anchorPoint = ccp(0,0);    
}
                     
-(void) setCentered
{
    sprite_cc.anchorPoint = ccp(0.5,0.5);
}

-(void) setPosition:(CGPoint)position
{
    [self setPositionAtX:position.x Y:position.y];
}

-(void) setScreenPosition:(CGPoint)position
{
    _x = position.x;
    _y = position.y;
    sprite_cc.position = ccp(position.x,position.y);
}

-(void) setPositionAtX:(float)x Y:(float)y
{
    CGPoint position;
    
    _x = x;
    _y = y;

    
    if(_isLowRes) {
        position = [_camera convertToScreenXY:CGPointMake(x, y)];
        position.x = roundf((position.x * 2.0f)) / 2.0f;
        position.y = roundf((position.y * 2.0f)) / 2.0f;
    } else {
        position = [_camera convertToScreenXY:CGPointMake(round(x), round(y))];
    } 
    
    //CGPoint position = [[Camera sharedCamera] convertToScreenXY:CGPointMake((int)x, (int)y)];
    //sprite_cc.position = ccp(position.x,position.y);
    sprite_cc.position = position;
}

-(void)replaceSpriteWithFile:(NSString*)filename
{
    //sprite_cc setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
}

-(CGPoint) getPosition
{
    return CGPointMake(_x, _y);
}

-(CGPoint) getScreenPosition
{
    return CGPointMake(sprite_cc.position.x, sprite_cc.position.y);
}

-(void)move:(CGPoint)amount
{
    CCSprite *sprite = [self getCCSprite];
    sprite.position = ccp(sprite.position.x + amount.x, sprite.position.y + amount.y);
}

-(CCSprite*) getCCSprite
{
    return sprite_cc;
}

-(void)setAlpha:(float)alpha
{
    if (alpha == 0.0f) {
        alpha = 0.0f;
        _alpha = 0.0f;
    } else if(alpha >= 1.0f) {
        //set it before modifying it for the ccsprite
        _alpha = alpha;
        alpha = 1.0f;
    } else {
        _alpha = alpha;
    }
    
    int opacity = (int)(alpha * 255);
    [[self getCCSprite] setOpacity:opacity];
}

-(float) getWidth
{
    return [sprite_cc boundingBox].size.width;
}

-(float) getHeight
{
    return [sprite_cc boundingBox].size.height;
}

-(void)setAnimationByName:(NSString*)animName
{
    [[AnimationController sharedController] replaceSprite:self withAnimationNamed:animName];
}

-(void)setAnimation:(Animation*)animation Delay:(float)delay
{
    _animation = animation;
    _animation.delay = delay;
    [_animation useAnimationToReplaceSprite:self];
}

-(void)setAnimation:(Animation*)animation Delay:(float)delay StartingFrameNumber:(int)frameNumber
{
    _animation = animation;
    _animation.delay = delay;
    [_animation useAnimationToReplaceSprite:self FrameNumber:frameNumber];
}

-(int)getTotalFramesCount
{
    return [_animation getTotalFramesCount];
}

-(void)setFrame:(int)frame
{
    [_animation setFrame:frame];    
}

-(void)setImageByName:(NSString*)frameName
{
    [sprite_cc setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName]];
}

-(int)getCurrentFrameNumber
{
    return [_animation getCurrentFrameNumber];
}

-(Animation*)getAnimation
{
    return _animation;
}

-(Animator*)getAnimator
{
    return _animator;
}

-(void)updateAnimator:(float)dt
{
    //[_animator update:dt];
}

-(bool)reachedMinAfterModifyAlpha:(float)amount
{
    bool returnVal = false;

    _alpha += amount;
    if (_alpha<=0.0f) {
        _alpha = 0.0f;
        returnVal = true;
    }
    
    [self setAlpha:_alpha];
    
    return returnVal;
}


-(void)dealloc
{
    //[_animator release];
    [_frameName release];
    [_animation release];
    [sprite_cc removeFromParentAndCleanup:YES];
    sprite_cc = nil;
    [super dealloc];
}

@end
