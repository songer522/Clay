//
//  PlayerActionBlow.m
//  Clay
//
//  Created by Brian Cable on 11/22/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "PlayerActionBlow.h"
#import "Sprite.h"
#import "Skin.h"
#import "Projectile.h"
#import "Player.h"
#import "LevelManager.h"
#import "RunningSpeed.h"
#import "AnimationController.h"
#import "GCState.h"
#import "GameSettings.h"
#import "GCHelper.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define MULTIPLIERX (IS_IPAD ? 2.133 : 1)
#define MULTIPLIERY (IS_IPAD ? 2.4 : 1)

// Put the wind plume at Tim's mouth.
//
// The wind sprite is anchored bottom-left, and the developed puff (BlowingWind_5..7) fills
// almost the whole 170px-tall frame, so its visual centre sits ~87px above the anchor. The
// legacy offset of 50 (x MULTIPLIERY) put that centre above Tim's forehead - the plume read
// as coming out of his head rather than his mouth.
//
// Measuring off the art: Tim's visible height is 278px of his 300px frame, and his mouth is
// ~52% up that. Solving for "plume centre == mouth" gives an offset of ~0.28 x his rendered
// height on both phone (139pt -> 39) and iPad (278pt -> 78), so derive it from the sprite
// instead of a per-device constant. Same idiom as BlockShieldOffsetY in PlayerActionBlock.
#define BLOW_WIND_MOUTH_FRACTION 0.28f

static CGFloat BlowWindOffsetY(Player *player)
{
    CGFloat playerHeight = [[player getSprite] getHeight];

    if (playerHeight > 0.0f) {
        return floorf(playerHeight * BLOW_WIND_MOUTH_FRACTION);
    }

    return 39.0f * MULTIPLIERY; //fallback if the sprite has no frame yet
}

@implementation PlayerActionBlow
-(void)initialize
{
    _cooldown = 0.0f;
    _cooldownStart = 0.3f;
    _wind = [Sprite spriteWithFile:@"blank.png"];
    _windProjectile = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_PLAYER_BLOWING];
    
    // iPad is checked first on purpose. This used to test currentRenderScale first, which only
    // reached the iPad box because SceneDelegate force-disables retina on iPad - so enabling
    // retina there would have silently halved the Level 8 wind hitbox from 280x200 to 140x140
    // and blowing at a fire demon would quietly stop working.
    if([[GameSettings shared] isIpad])
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 75, 280, 200)];
    }
    else if ([GameSettings currentRenderScale] >= 2.0f)
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 30, 140, 140)];
    }
    else
    {
        [_windProjectile setBoundingBox:CGRectMake(0, 75, 140, 140)];
    }
    [super initialize];    
}

-(void)startAction
{
    if (!_inAction && _canTrigger) {
        [super startAction];
        
        [_parent endTurbo:false];
        [_parent setPlayerAnimation:PLAYER_ANIM_BLOW];

        _duration = 0.78f;
        _startedWindAnimation = false;

        _hasKilledEnemy = false;
        _hasKilledSuperEnemy = false;
        
        _windOffsetY = BlowWindOffsetY(_parent);

        [[_parent getSpeed] startBlow];
        [[_parent getSpeed] stop];
    }
}

-(void)endAction
{
    [[_wind getCCSprite] setVisible:NO];
    [[_parent getSpeed] start];
    [_windProjectile disable];
    [[_parent getSpeed] endBlow];
    [super endAction];
}

-(void)cancelAction
{
    //[_parent setPlayerAnimation:PLAYER_ANIM_RUNNING];
    [[_parent getSpeed] start];
    [[_parent getSpeed] endBlow];
    [[_wind getCCSprite] setVisible:NO];
    [_windProjectile disable];    
    [super cancelAction];
}

-(void)freezeFireDemon:(GameObject *)obstacle
{
    int maxFireDemon = 200;
     //NSLog(@"%d",[GCState sharedInstance].demonsFreezed);
    if ([GCState sharedInstance].demonsFreezed < maxFireDemon) {
        [GCState sharedInstance].demonsFreezed++;
        obstacle.hasAppeared=true;
        double pctComplete3 = ((double) [GCState sharedInstance].demonsFreezed / (int)maxFireDemon) * 100.0;
        if(pctComplete3 == 100.0)
        {
            //[[GCState sharedInstance] save];
            [[GCHelper sharedInstance] reportAchievement:gcAchievementFreeze200demon percentComplete:pctComplete3];
        }
    }
    
}



-(void)testBlowCollisions
{
    NSMutableArray *obstacles = [[[LevelManager shared] currentLevel] getActiveGameObjectList];
    for (GameObject *object in obstacles) {
        if(![object hasBeenHit] && [object getCollisionBehavior] == COLLISION_BEHAVIOR_FIRE_DEMON)
        {
            if([[[LevelManager shared] currentLevel] testCollisionWithGameObject:object Source:_windProjectile])
            {
                [object startCollision:true];
                if(!object.hasAppeared)
                    [self freezeFireDemon:object];
            }
        } else if(![object hasBeenHit] && [object getCurrentCollisionBehavior] == COLLISION_BEHAVIOR_FIREFOX_PREATTACK) {
            if([[[LevelManager shared] currentLevel] testCollisionWithGameObject:object Source:_windProjectile])
            {
                [object startCollision:true];
            }
        }
    }
}



-(void)update:(float)dt
{
    if (!_inAction) {
        _isActive = false;
    } else {
        _isActive = true;
        
        if (!_startedWindAnimation) {
            if (_duration <= 0.58) {
                _startedWindAnimation = true;
                [_windProjectile reset];

                [[SoundEngine shared] playSound:@"blowAction"];
                [[AnimationController sharedController] replaceSprite:_wind withAnimationNamed:@"blowingWindAnim"];
                [[_wind getCCSprite] setVisible:YES];            
                CGPoint position = [_parent getPosition];
                [_wind setPosition:CGPointMake(position.x + 15*MULTIPLIERX, position.y + _windOffsetY)];
                [_windProjectile setPosition:CGPointMake(position.x + 15*MULTIPLIERX, position.y + _windOffsetY)];
            }
        } else {
            CGPoint position = [_parent getPosition];
            [_wind setPosition:CGPointMake(position.x + 15*MULTIPLIERX, position.y + _windOffsetY)];            
            [_windProjectile setPosition:CGPointMake(position.x + 15*MULTIPLIERX, position.y + _windOffsetY)];
        }
        
        if (_duration <= 0.37f) { //was 0.27f
            [self testBlowCollisions];
        }
    }
    [super update:dt];
}




-(NSMutableArray*)getProjectiles
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:_windProjectile, nil];
    return array;
}


-(bool) shouldActionStopPlayer
{
    return true;
}


-(bool)canStartInMidAir
{
    return false;
}

-(void)dealloc
{
    [_wind release];
    [_windProjectile release];
    [super dealloc];
}

@end
