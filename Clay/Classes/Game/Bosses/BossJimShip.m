//
//  BossJimShip.m
//  Clay
//
//  Created by Brian Cable on 11/7/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GameObject.h"
#import "BossJimShip.h"
#import "Animation.h"
#import "AnimationController.h"
#import "Sprite.h"
#import "Camera.h"
#import "LevelManager.h"
#import "Level.h"
#import "LayerManager.h"
#import "SoundEngine.h"
#import "Projectile.h"
#import "Player.h"
#import "PlayerAction.h"
#import "ComboAttack.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

static CGFloat BossShipScreenX(CGFloat value)
{
    return IS_IPAD ? value * 2.133f : value;
}

static CGFloat BossShipScreenY(CGFloat value)
{
    return IS_IPAD ? value * 2.4f : value;
}

static CGFloat BossShipCannonX(CGFloat value)
{
    return IS_IPAD ? value * 2.0f : value;
}

static CGFloat BossShipCannonY(CGFloat value)
{
    return IS_IPAD ? value * 2.26f : value;
}

static CGFloat BossShipMegaY(CGFloat value)
{
    return IS_IPAD ? value * 2.2f : value;
}

// The ship was authored to hold station opposite the player on a 480-wide screen, so its
// station-keeping box and entrance/exit targets were absolute x values measured in that
// space. The player is pinned near the left edge (player.plist cameraTracking x 75), so all
// the extra width of a modern screen appears to his right: a literal 240 or 380 now lands
// the ship on top of him instead of across from him. Measure in from the live right edge.
// On a legacy 480 phone / 1024 iPad these reproduce the original numbers exactly.
static CGFloat BossShipInsetFromRight(CGFloat legacyInset)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return winSize.width - BossShipScreenX(legacyInset);
}

static CGFloat BossShipOffscreenRight(CGFloat legacyValue)
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return winSize.width + BossShipScreenX(legacyValue - 480.0f);
}

// The bullet re-aim cut-off is "around the midsection of the player" (see updateBullets).
// The player's collision box runs from world y 74 - his grounded world y of 64 plus the raw
// bbox.y of -10 - upward by 100*MULTIPLIERY, so the legacy 120 sat 46% up that box on a
// phone. Anchor at the box bottom and scale only the part above it, so the cut-off stays at
// the same point on his body. A flat 120*MULTIPLIERY would put it at 288 on iPad, up near
// the top of his head, and bullets would straighten out far too late.
#define BOSS_SHIP_PLAYER_BOX_BOTTOM 74.0f

static CGFloat BossShipPlayerBandY(CGFloat legacyPhoneY)
{
    return BOSS_SHIP_PLAYER_BOX_BOTTOM + BossShipScreenY(legacyPhoneY - BOSS_SHIP_PLAYER_BOX_BOTTOM);
}

// Matches the widthScale idiom used for the Level 3/4 chase retunes.
static CGFloat BossShipWidthScale(void)
{
    CGFloat scale = [[CCDirector sharedDirector] winSize].width / 480.0f;
    return scale < 1.0f ? 1.0f : scale;
}

@implementation BossJimShip


-(void)startBoss
{
    _level = [[LevelManager shared] currentLevel];
    
    _velocity = CGPointMake(-5.0f, 0.0f);
    // Right-anchored station box; the width was previously left unscaled on iPad.
    _targetOnScreen = CGRectMake(BossShipInsetFromRight(240.0f), BossShipScreenY(100.0f),
                                 BossShipScreenX(140.0f), BossShipScreenY(400.0f));
    
    [_sprite setAlpha:1.0f];
    [[_sprite getCCSprite] setVisible:YES];
    
    _bullets = [[NSMutableArray alloc] initWithCapacity:3];
    _comboAttacks = [[NSMutableArray alloc] initWithCapacity:3];
    
    _waitToShoot = -1.0f;
    xthrust = -1;
    ythrust = 0;
    _waitToMegaCannon = -1.0f;
    _firstUpdate = true;
    
    _isActive = false;
    _hadReset = false;

    _replaceProjectileId = 0;
    [self switchToPhase:BOSS_PHASE_NOT_TRIGGERED];
}

-(void)setSprite:(Sprite *)sprite
{
    _sprite = sprite;
    [[AnimationController sharedController] replaceSprite:_sprite withAnimationNamed:@"jimSpaceshipAnim"];
}


-(void)triggerAttack
{
    if (_isActive) {
        [[_cannonAnim getCCSprite] setVisible:YES];
        [[AnimationController sharedController] replaceSprite:_cannonAnim withAnimationNamed:@"jimSpaceshipWarningAnim"];
        _waitToShoot = 0.55f;
        [[SoundEngine shared] playSound:@"jimShipCharge"];        
    }
}

-(void)triggerAttack2 //giant cannon
{
    if (_isActive) {
        [[_megaCannonAnim getCCSprite] setVisible:YES];
        [[AnimationController sharedController] replaceSprite:_megaCannonAnim withAnimationNamed:@"computerMegaCannonAnim"];
        _waitToMegaCannon = 1.1f;
        [[SoundEngine shared] playSound:@"jimShipCharge"];        
    }
}

-(void)triggerAttack3 //combo attack
{
    if (_isActive) {
        for (ComboAttack *attack in _comboAttacks) {
            [attack startAttack];
        }
        [[SoundEngine shared] playSound:@"jimShipCharge"];        
    }
}

-(void)shootBullet
{
    [[SoundEngine shared] playSound:@"jimShipShoot"];
    
    Projectile *bullet = [_bullets objectAtIndex:_replaceProjectileId];
    _replaceProjectileId = (_replaceProjectileId + 1) % 3;
    
    [[_cannonAnim getCCSprite] setVisible:NO];
    
    CGPoint shipWorldPos = [[Camera sharedCamera] convertToWorldXY:[_sprite getScreenPosition]];    
    [bullet setPosition:CGPointMake(shipWorldPos.x - BossShipScreenX(120.0f), shipWorldPos.y + BossShipScreenY(20.0f))];
    [bullet reset];
}

-(void)shootMegaCannon
{
    [[SoundEngine shared] playSound:@"jimShipShoot"];

    [[_megaCannonAnim getCCSprite] setVisible:NO];
    
    CGPoint shipWorldPos = [[Camera sharedCamera] convertToWorldXY:[_sprite getScreenPosition]];    
    [_megaCannonBullet setPosition:CGPointMake(shipWorldPos.x + BossShipScreenX(73.0f), shipWorldPos.y + BossShipScreenY(28.0f))];
    [_megaCannonBullet reset];
    
}

-(void)shootComboAttack
{
    [[SoundEngine shared] playSound:@"jimShipShoot"];
    
    [[_megaCannonAnim getCCSprite] setVisible:NO];
    
    CGPoint shipWorldPos = [[Camera sharedCamera] convertToWorldXY:[_sprite getScreenPosition]];    
    [_megaCannonBullet setPosition:CGPointMake(shipWorldPos.x - BossShipScreenX(120.0f), shipWorldPos.y + BossShipScreenY(20.0f))];
    [_megaCannonBullet reset];
}

-(void)update:(float)dt
{
    _frame = [[_sprite getAnimation] getCurrentFrameNumber];
    
    if (_hadReset) {
        [[_sprite getCCSprite] setVisible:YES];
        _hadReset = false;
    }

    
    //have to reposition for now because the position gets set like three times in gameobject, but for the time being we need to call it
    //so we can put it under the right layers
    if (_firstUpdate) {
        _firstUpdate = false;
        _velocity = CGPointMake(0.0f, 0.0f);
        [_sprite getCCSprite].position = ccp(BossShipOffscreenRight(1500.0f), BossShipScreenY(160.0f));
        _cannonAnim = [Sprite spriteWithFile:@"blank.png"];
        _megaCannonAnim = [Sprite spriteWithFile:@"blank.png"];
        _comboAttackAnim = [Sprite spriteWithFile:@"blank.png"];
        
        for (int i=0; i<3; i++) {
            ComboAttack *combo = [ComboAttack comboAttackWithId:i Ship:_sprite];
            [_comboAttacks addObject:combo];
        }

        for (int i=0; i<3; i++) {
            Projectile *_bullet = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_BOSS_SHIP_BULLET];
            [_bullet setActive:NO];
            [_bullets addObject:_bullet];
        }
        
        _megaCannonBullet = [Projectile projectileWithBehavior:PROJECTILE_BEHAVIOR_BOSS_SHIP_MEGACANNON];
        [_megaCannonBullet setActive:NO];
        
    }
    
    if (_phase == BOSS_PHASE_ATTACKING) {
        [self updateVelocity:dt];
        [self updateCannon:dt];
        [self updateMegaCannon:dt];
        [self updateMegaBullet:dt];
        
        
        CGPoint position = [_sprite getPosition];        
        [_sprite setScreenPosition:CGPointMake(position.x + _velocity.x, position.y + _velocity.y)];
        [self updateBullets:dt];
        
    } else if(_phase != BOSS_PHASE_IDLE && _phase != BOSS_PHASE_NOT_TRIGGERED) {
        // fabsf, not the integer abs() this used to call on a float difference.
        CGFloat approachSpeed = 300.0f * BossShipWidthScale();
        if (fabsf(_target.x - _x)<8.0f) {
            _x = _target.x;
            [self finishedPhase];
        } else if(_x > _target.x) {
            _x -= approachSpeed * dt;
        } else {
            _x += approachSpeed * dt;
        }
        [_sprite setScreenPosition:ccp(_x,_y)];
    }
}

-(void)updateBullets:(float)dt
{
    for (Projectile *_bullet in _bullets) {
        if ([_bullet isActive]) {
            
            //redirect the bullet towards the player unless the bullet drops below a certain Y point (around the midsection of the player)
            CGPoint bulletPos = [_bullet getPosition];
            if (bulletPos.y > BossShipPlayerBandY(120.0f)) {
                [_bullet pointTowardPlayerMaxAngle:-1.0f];
            }
            
            [_bullet update:dt];
            [self testCollisionsWithSource:_bullet];
        }
    }
    
    for (ComboAttack *attack in _comboAttacks) {
        if ([attack getActive]) {
            [attack update:(float)dt];
            [self testCollisionsWithSource:attack];
        }
    }
}

-(bool)testCollisionsWithSource:(id<Collidable>)source
{
    Player *_player = [[LayerManager sharedLayers] getPlayer];
    Level *currentLevel = [[LevelManager shared] currentLevel];
    
    bool collision = [currentLevel testCollisionWithGameObject:source Source:_player];
    if (collision) {
        if(![[_player getThirdAction] isActive]) {
           if([source isMemberOfClass:[_megaCannonBullet class]])
           {
               Projectile *projectile = (Projectile*)source;
               if (projectile.projectileBehavior == PROJECTILE_BEHAVIOR_BOSS_SHIP_MEGACANNON ) {
                   _player.isDoubleDamage=true;                   
               }
           }
            [_player startCollision:PLAYER_EFFECT_COLLIDE Source:source];
        } else {
            [[_player getThirdAction] setKilledEnemy:YES];
            [[SoundEngine shared] playSound:@"deflected"];
        }
        [source disable];
    }
    return collision;
}

-(void)updateMegaBullet:(float)dt
{
    if ([_megaCannonBullet isActive]) {
        [_megaCannonBullet pointTowardPlayerCannon];
        [_megaCannonBullet update:dt];
        [self testCollisionsWithSource:_megaCannonBullet];
    }
}



-(void)updateCannon:(float)dt
{
    CGPoint shipPos = [_sprite getScreenPosition];
    if(_frame == 1) {
        [_cannonAnim setScreenPosition:CGPointMake(shipPos.x - BossShipCannonX(136.0f), shipPos.y + BossShipCannonY(16.0f))];
    } else {
        [_cannonAnim setScreenPosition:CGPointMake(shipPos.x - BossShipCannonX(136.0f), shipPos.y + BossShipCannonY(10.0f))];
    }
    
    if (_waitToShoot > 0.0f) {
        _waitToShoot -= dt;
        if (_waitToShoot<=0.0f) {
            [self shootBullet];
        }
    }
}

-(void)updateMegaCannon:(float)dt
{
    CGPoint shipPos = [_sprite getScreenPosition];
    
    if (_frame == 1) {
        [_megaCannonAnim setScreenPosition:ccp(shipPos.x + BossShipCannonX(73.0f), shipPos.y + BossShipMegaY(28.0f))];
    } else {
        [_megaCannonAnim setScreenPosition:ccp(shipPos.x + BossShipCannonX(73.0f), shipPos.y + BossShipMegaY(31.0f))];
    }
    
    if (_waitToMegaCannon > 0.0f) {
        _waitToMegaCannon -= dt;
        if (_waitToMegaCannon <= 0.0f) {
            [self shootMegaCannon];
        }
    }
}

-(void)switchToPhase:(BossPhase)phase
{
    _phase = phase;
    
    switch (phase) {
        case BOSS_PHASE_NOT_TRIGGERED:
            _x = BossShipOffscreenRight(1500.0f);
            _y = BossShipScreenY(230.0f);
            _target = ccp(BossShipOffscreenRight(1500.0f), BossShipScreenY(230.0f));
            [_sprite getCCSprite].position = ccp(BossShipOffscreenRight(1500.0f), BossShipScreenY(230.0f));
            [[_sprite getCCSprite] setVisible:NO];
            _isActive = false;
            break;
        case BOSS_PHASE_ENTERING:
            [[_sprite getCCSprite] setVisible:YES];
            _target = ccp(BossShipInsetFromRight(100.0f), BossShipScreenY(230.0f));
            _isActive = false;
            break;
        case BOSS_PHASE_EXITING:
            _target = ccp(BossShipOffscreenRight(1500.0f), BossShipScreenY(230.0f));
            _isActive = false;
            break;
        case BOSS_PHASE_ATTACKING:
            _isActive = true;
            break;
        default:
            break;
    }
}

-(void)finishedPhase
{
    switch (_phase) {
        case BOSS_PHASE_ENTERING:
            [self switchToPhase:BOSS_PHASE_ATTACKING];
            break;
        case BOSS_PHASE_EXITING:
            [self switchToPhase:BOSS_PHASE_IDLE];
            break;
        default:
            break;
    }
}

-(void)reset
{
    if (_phase == BOSS_PHASE_NOT_TRIGGERED) {
    //if hasn't been triggered, do nothing
    } else {
        [self resetProjectiles];
        [[_sprite getCCSprite] setVisible:YES]; //probably set not visible during gameobject reset
        _hadReset = true;
    }
}

// Without this the base Boss implementation returns nil, so DEBUG_DRAW_BOUNDING_BOXES drew
// nothing at all for Level 7 - which is why the ComboAttack hitbox mismatch went unnoticed.
// Caller (GameDebugLayer) releases the array, so hand back a +1 retained one like BossFinal.
-(NSMutableArray*)getProjectilesForDebugDraw
{
    NSMutableArray *objects = [[NSMutableArray alloc] initWithArray:_bullets];
    if (_megaCannonBullet != nil) {
        [objects addObject:_megaCannonBullet];
    }
    [objects addObjectsFromArray:_comboAttacks];
    return objects;
}

-(void)resetProjectiles
{
    _waitToShoot = -1.0f;
    for (Projectile *_bullet in _bullets)
    {[_bullet disable];}
    _waitToMegaCannon = -1.0f;
    [_megaCannonBullet disable];
    for (ComboAttack *combo in _comboAttacks) {
        [combo disable];
    }
    [[_cannonAnim getCCSprite] setVisible:NO];
    [[_megaCannonAnim getCCSprite] setVisible:NO];
}

-(void)restartLevel
{
    [self switchToPhase:BOSS_PHASE_NOT_TRIGGERED];
    [self resetProjectiles];
}

-(void)updateVelocity:(float)dt
{
    float rate = 6.0f * dt;
    float iterations = 10;
    
    CGPoint position = [_sprite getPosition];
    
    float futureXPosition = position.x + (_velocity.x * rate * iterations);
    if (futureXPosition < _targetOnScreen.origin.x) {
        xthrust = 1;
    } else if(futureXPosition > (_targetOnScreen.origin.x + _targetOnScreen.size.width)) {
        xthrust = -1;
    }
    
    if (position.y > BossShipScreenY(260.0f)) {
        ythrust = 0;
    } else if (position.y < BossShipScreenY(200.0f)) {
        ythrust = 1;
    }
    
    float dragX = 0.95f;
    float gravity = 5.0f;
    _velocity.y = dragX * (_velocity.y + (ythrust * 7.0f - gravity) * rate);
    _velocity.x = (_velocity.x + (xthrust * 15.0f) * 0.4f * rate);
    
    float max = 0.5f;
    if (_velocity.x < -max) {
        _velocity.x = -max;
    } else if(_velocity.x > max) {
        _velocity.x = max;
    }
    
    if (_velocity.y < -max) {
        _velocity.y = -max;
    } else if(_velocity.y > max) {
        _velocity.y = max;
    }
    
}

-(void)dealloc
{
    _sprite = nil; //deallocated by gameobject
    [_cannonAnim release];
    [_megaCannonAnim release];
    [_comboAttackAnim release];
    [_comboAttackWarningAnim release];
    [_comboAttacks removeAllObjects];
    [_comboAttacks release];
    [_bullets removeAllObjects];
    [_bullets release];
    [_megaCannonBullet release];
    
    _level = nil;
    [super dealloc];
}


@end
