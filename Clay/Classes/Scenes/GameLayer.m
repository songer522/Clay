//
//  HelloWorldLayer.m
//  Clay
//
//  Created by Brian Cable on 8/23/11.
//  Copyright Xecudev, LLC 2011. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "BaseClasses.h"
#import "GCHelper.h"
#import "ComicManager.h"
#import "HudLayer.h"
#import "Battery.h"
#import "GameController.h"
#import "Player.h"
#import "BossFactory.h"
#import "SavePoint.h"
#import "LaserShow.h"
#import "RainyLevelEffects.h"
#import "TextureManager.h"
#import "GameDebugLayer.h"
#import "GameSettings.h"
#import "GameController.h"
#import "Appirater.h"
#import "TrackTimer.h"
#import "RunningSpeed.h"
#import "ChooseLevelScreen.h"
#import "ChooseModeScene.h"
#import "Animator.h"
#import "GCState.h"
#import "GCHelper.h"
#import "CreditsScene.h"
#import "Camera.h"
#import "Level.h"
#import "EndLevelLayer.h"
#import "BestTimes.h"


#define DEBUG_DRAW_BOUNDING_BOXES 0
@interface GameLayer()

-(void)setupLayers;
-(void)initCamera;

-(void)updateTriggers:(float)dt;
-(void)updatePlayerDeath:(float)dt;
-(void)updateLogic:(ccTime)dt;

//the following serve as our pause and unpause functions
//based on code posted at: http://www.cocos2d-iphone.org/forum/topic/1232
-(void)onEnter;
-(void)onExit;

@end

// HelloWorldLayer implementation
@implementation GameLayer

@synthesize player = _player;
@synthesize gameController = _gameController;
@synthesize handledPauseEvent = _handledPauseEvent;
@synthesize inComic = _inComic;
@synthesize hasBeatenLevel = _hasBeatenLevel;
@synthesize isNewRecord =_isNewRecord;


+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
    [[LayerManager sharedLayers] setCurrentScene:scene];
	
	GameLayer *layer = [GameLayer node];
	
    [scene addChild: layer];
    
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        
        [self setVisible:NO];
        
        [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];

        [[LayerManager sharedLayers] setCurrentLayer:self];
        
        [[TextureManager shared] loadMemoryForKey:@"gameScene"];
        
        [[GameSettings shared] setGlobal:@"false" ForKey:@"restarting"];
        
        _gameController = [GameController gameController];
        [_gameController setGameLayer:self];
        
        _inputController = [InputController inputController];
        [self addChild:_inputController];       //need to so its scheduled selectors will be trigger
        
        _player = [Player instance];
        
        _savePoint = [SavePoint instance];
        
        //[self schedule: @selector(update:)];
        [self scheduleUpdateWithPriority:-1];
        
        _paused = true;
        _inComic = false;
        _isNewRecord =false;
        
        self.isTouchEnabled = YES;
        
        time = 0.0f;
        
        [self updateLogic:0.001f];  //done to correctly position the camera and player before
                                    //the first render cycle
        [self setupLayers];
        
        NSString *startingLevel = [[GameSettings shared] getGlobalForKey:@"startingLevel"];
        
        [self startLevel:startingLevel];
        
        
    }
	return self;
}

-(void)setupLayers
{
    // Run the intro Scene    
    [[ComicManager shared] preload];
    
    _hud = [HudLayer instance];
    [self setupHud];
    
#if DEBUG_DRAW_BOUNDING_BOXES
    _debugLayer = [GameDebugLayer debugLayerForScene:[[LayerManager sharedLayers] currentScene] GameLayer:[[LayerManager sharedLayers] currentLayer]];
#endif

}

-(void)restartLevel
{
    
    [[GameSettings shared] setGlobal:@"true" ForKey:@"restarting"];
    [[Camera sharedCamera] reset];
    [_level resetTriggers:true];
    [_level resetObstacles];
    [_boss restartLevel];
    [[ComicManager shared] restartLevel];
    _isNewRecord=false;
}

-(void)startLevel:(NSString*)levelName
{    
    [[LevelManager shared] reset];
   
    [[LevelManager shared] loadLevelNamed:levelName];
    [self initForLevel];
    Level *levelObj = [[LevelManager shared] currentLevel];
    [[ComicManager shared] startComic:levelObj.preComicName StartPhase:COMIC_PHASE_STARTING_VIDEO];
    
    [[GameSettings shared] setGlobal:[NSString stringWithString:levelName] ForKey:@"continueLevelName"];
    _isNewRecord=false;
}

-(void)initForLevel
{
    [self setVisible:NO]; //let comic manager make it visible
    
    _level = [[LevelManager shared] currentLevel];
    
    [_player setOffsetForX:0 Y:[[LevelManager shared] playerOffsetY]];
    
    [_player setPositionAtX:_level.spawnPoint.x Y:_level.spawnPoint.y];
    
    //check to see if underwater physics should be set
    if ([_level.name isEqualToString:@"level10"]){
        [[_player getSpeed] setIsUnderwater:true];
        _player.isNewUnderwaterPhysics = true;
    } else {
        [[_player getSpeed] setIsUnderwater:false];
        _player.isNewUnderwaterPhysics = false;
    }
    
    _hasBeatenLevel = false;
    
    [_player reset];
    _isNewRecord=false;
    
    [_savePoint setSavePoint:_level.spawnPoint Level:_level.name];
    
    [self initCamera];
    
    [[LevelManager shared] initAfterPlayerAndHudInit];

    bool isRestarting = [[[GameSettings shared] getGlobalForKey:@"restarting"] boolValue];
    if (isRestarting) {        
        [_hud reset:true];
    } else {
        [_hud reset:false];
    }
    
    [[ComicManager shared] resetComicLayer];
    
#if DEBUG_DRAW_BOUNDING_BOXES
    [_debugLayer removeFromParentAndCleanup:NO];
    [[[LayerManager sharedLayers] currentScene] addChild:_debugLayer];
#endif
}

-(void)setupHud
{
    _player.battery = [_hud getBattery];
    [[_hud getBattery] setPlayer:_player];
    
    //pass on the hud to the gamecontroller
    [_gameController setHud:_hud];
}

-(HudLayer*)getHud
{
    return _hud;
}

-(void)initCamera
{
    [[Camera sharedCamera] setTarget:[_player getSprite]];
    [[Camera sharedCamera] snapToTarget];
}

-(void)update:(ccTime)dt
{
    //build #1 method
    //double fixedTimeStep = 1.05f/60.0f;
    //[self updateLogic:fixedTimeStep];   

    // build #2 method
    if( dt > 0.022f )
    {
		dt = 1/60.0f;
    }
    [self updateLogic:dt];
    
    
    //use for simulator
    /*
    
    double fixedTimeStep = 1.00f/60.0f;
    float timeToRun = dt + time;
    
    while(timeToRun >= fixedTimeStep) {
        [self updateLogic:fixedTimeStep];            
        timeToRun = timeToRun - fixedTimeStep;
    }
    time = timeToRun;    
    */
    
}

-(void)pause
{
    _paused = true;
}

-(void)unpause
{
    _paused = false;
}

-(void)updateLogic:(ccTime)dt
{    

    [[ComicManager shared] update:dt];
    
    if (_inComic) {
        _inComic = _inComic;
    }
    [[SoundEngine shared] update:dt];

    
    
    if (!_paused && !_inComic) {
        
        [_level update:dt Velocity:_player.vx];
        
        [_player update:dt Level:_level];
        
        [self updateTriggers:dt];
        
        [_level testCollisions:_player];
        
        [self updatePlayerDeath:dt];
        
        [_hud update:dt];
        
        //[_testAnim updateAnimator:0.5f * dt];
        
        if (_laserShow!=nil) {
            [_laserShow update:dt];
        } else if(_rainyLevelEffects !=nil) {
            [_rainyLevelEffects update:dt];
        }
        
    }
    
    _handledPauseEvent = false;
    [_gameController update];
    
    


}


-(void)updatePlayerDeath:(float)dt
{
    if (![[ComicManager shared] isActive]) {
        if(_player.isDead) {
            [_player reset];
            [self recordTimesdied];
            
            if(_boss){
                [_boss reset];
            }
            
            [_savePoint restoreSavePoint:_player];
            
            //already called in reset
            //[_player rechargeBattery];
            //_player.isDead = false; //needs to be after recharge battery, because it checks this
            
            [_level resetObstacles];
            [_level resetTriggers:false];
        }        
    }
}

-(void)updateTriggers:(float)dt
{
    //check to see if any triggers have been hit
    Trigger *trigger = [_level testTriggers:_player];
    if (trigger) {
        switch (trigger.type) {
            case TRIGGER_NEXTLEVEL:
                [self endLevel];
                if([_level.name isEqualToString:@"level11"])
                {
                [[self getBoss] stopTrainSound];
                    [[self getBoss] stopHornSound];
                }
                break;
            case TRIGGER_CHECKPOINT:
                [_savePoint setSavePoint:trigger.position Level:_level.name];
                [_level disablePassedTriggers];
                [[SoundEngine shared] playSound:@"checkpoint"];
                [_player rechargeBattery];
                [_player resetSprint];
                break;
            case TRIGGER_BOSS_SHOOT:
                [_boss triggerAttack];
                trigger.triggered=true;
                break;
            case TRIGGER_SHIP_SHOOT_MEGACANNON:
                [_boss triggerAttack2];
                trigger.triggered=true;
                break;
            case TRIGGER_SHIP_SHOOT_COMBO:
                [_boss triggerAttack3];
                trigger.triggered=true;
                break;
            case TRIGGER_WIND_SHORT:
            case TRIGGER_WIND_MEDIUM:
            case TRIGGER_WIND_LONG:
                [_rainyLevelEffects triggerWind:trigger.type];
                break;
            case TRIGGER_SHIP_ENTER:
                [_boss switchToPhase:BOSS_PHASE_ENTERING];
                break;
            case TRIGGER_SHIP_EXIT:
                [_boss switchToPhase:BOSS_PHASE_EXITING];
                break;
            case TRIGGER_BOSS_FINALJIM_SPAWN:
                [_boss switchToPhase:BOSS_PHASE_CHASE_INIT];
                break;
            case TRIGGER_FINAL_BOSS_ENTER:
                [_boss triggerAction:FINAL_BOSS_MOVE_TO_BOMBING];
                break;
            case TRIGGER_FINAL_BOSS_EXITS:
                [_boss triggerAction:FINAL_BOSS_MOVE_TO_LEFT];
                break;
            case TRIGGER_FINAL_BOSS_DIE:
                [_boss triggerAction:FINAL_BOSS_DIE];
                break;
            case TRIGGER_FINAL_BOSS_ATTACK1:
                [_boss triggerAction:FINAL_BOSS_ATTACK_1];
                break;
            case TRIGGER_FINAL_BOSS_ATTACK2:
                [_boss triggerAction:FINAL_BOSS_ATTACK_2];
                break;
            case TRIGGER_FINAL_BOSS_ATTACK3:
                [_boss triggerAction:FINAL_BOSS_ATTACK_3];
                break;
            case TRIGGER_FINAL_BOSS_ATTACK4:
                [_boss triggerAction:FINAL_BOSS_ATTACK_4];
                break;
            default:
                break;
        }
    }
}
                     
-(void)endLevel
{
    NSString *mode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
    NSString *difficulty=[[GameSettings shared] getGlobalForKey:@"gameDifficulty"];
    NSString *levelName = [[LevelManager shared] currentLevel].name;
    int levelNumber = [[levelName substringFromIndex:5] intValue];
    
    //set modes as unlocked if have the right settings
    if([mode isEqualToString:@"story"]) {
        if ([difficulty isEqualToString:@"normal"] && [levelName isEqualToString:@"level11"]) {
            [[GameSettings shared] setUnlockedForKey:@"storyHardUnlocked"];
        }
        [[GameSettings shared] setSerializedGlobal:@"YES" ForKey:[NSString stringWithFormat:@"%@TimedNormalUnlocked",levelName]];
        
        [[GameSettings shared] setUnlockedForKey:@"timedNormalUnlocked"];        
     } else if([mode isEqualToString:@"timed"]) {
         //if timed mode is normal AND the level number is not DLC (we don't want playing dlc levels to unlock insane mode).
         if([difficulty isEqualToString:@"normal"] && levelNumber < 12) {
            [[GameSettings shared] setUnlockedForKey:@"timedHardUnlocked"];
            [[GameSettings shared] setSerializedGlobal:@"YES" ForKey:[NSString stringWithFormat:@"%@TimedHardUnlocked",levelName]];
         }
    }    
    
    _hasBeatenLevel = true;
    
    [[SoundEngine shared] playSound:@"endLevel"];
    float finalLevelTime = [[_hud getTrackTimer] getLevelTime];
    NSString *timerText=[TrackTimer getTimeStringFromFloat:finalLevelTime];
    [[GameSettings shared] setGlobal: timerText ForKey:@"finalLevelTimeText"];
    [[GameSettings shared] setGlobal:[NSString stringWithFormat:@"%f",finalLevelTime] ForKey:@"finalLevelTime"];
    float oldBestTime=[[BestTimes shared]getBestTimeForLevelName:_level.name forDifficulty:difficulty];
    
    if(oldBestTime > finalLevelTime)
    {
        _isNewRecord=true;
    }
    [[LevelManager shared] recordLevelTime:finalLevelTime];
    
    [[ComicManager shared] startComic:_level.postLevelComicName];
    
    if ([mode isEqualToString:@"story"])
    {
    [ComicManager shared].loadNextLevel = true;
    }
    [ComicManager shared].isActive=true;
        
    [[BestTimes shared] saveData];

    //[self saveAndReportToGameCenter];
    [self checkHasBeenHit];
}

-(void)setBoss:(Boss*)boss
{
    _boss = boss;
}

-(Boss*)getBoss
{
    return _boss;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        InputEvent *event = [InputEvent inputEventWithType:INPUT_EVENT_TYPE_TOUCHES_BEGAN];
        [event setReceiver:_gameController];
        [event setTotalTouches:[allTouches count]];
        [event setTouchLocation:[self convertTouchToNodeSpace:touch]];
        [_inputController interpretAndReactToInputEvent:event];
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        InputEvent *event = [InputEvent inputEventWithType:INPUT_EVENT_TYPE_TOUCHES_ENDED];
        [event setReceiver:_gameController];
        [event setTotalTouches:[allTouches count]];
        [event setTouchLocation:[self convertTouchToNodeSpace:touch]];
        [_inputController interpretAndReactToInputEvent:event];
    }
}


-(NSMutableArray*)getGameObjectsList
{
    return _level.obstacleSprites;    
}


-(void)onExit
{
    if (!_gameController.isHandlingPause) {
        [self unscheduleUpdate];
        self.isTouchEnabled = false;
    } else if(!_paused) {
        _paused = true;
        [super onExit];
    }
    
    _handledPauseEvent = true;
    //[self saveAndReportToGameCenter];
}

-(void)onEnter
{
    _paused = false;
    [super onEnter];
    _handledPauseEvent = true;
}

-(void)initializeLaserShow
{
    //_laserShow = [LaserShow instance];
}
-(void)stopLaserShow
{
    if (_laserShow!=nil) {
        [_laserShow release];
        _laserShow = nil;
    }
}

-(void)initializeRainyLevel
{
    _rainyLevelEffects = [RainyLevelEffects instance];
}

-(void)stopRainyLevel
{
    if (_rainyLevelEffects!=nil) {
        [_rainyLevelEffects release];
        _rainyLevelEffects = nil;
    }
}

-(void)switchToChooseLevel
{
    [[GameSettings shared] setGlobal:@"gameScreen" ForKey:@"previousScreenName"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ChooseLevelScreen scene]]];
}

-(void)switchToChooseMode
{
    [[GameSettings shared] setGlobal:@"gameScreen" ForKey:@"previousScreenName"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[ChooseModeScene scene]]];    
}

-(void)switchToCreditsScreen
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:[CreditsScene scene]]];
}

-(void)recordTimesdied
{
    int maxTimesToDie = 200;
    //NSLog(@"times died is :%d",[GCState sharedInstance].timesDied);
    if([GCState sharedInstance].timesDied < maxTimesToDie)
    {
        [GCState sharedInstance].timesDied++;
        
        double pctComplete = ((double)[GCState sharedInstance].timesDied / (int)maxTimesToDie) * 100.0;
        if(pctComplete == 100.0)
        {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementTimesDied percentComplete:pctComplete];
        }
    }
}
-(void)saveAndReportToGameCenter
{
    int maxTimesToDie = 200;
    int maxHurdles = 400;
    int maxChickenIntoCows = 100;
    int maxShuffled = 200;
    int maxDogs=100;
    int maxFrogs = 50;
    int maxDemon =200;
    int maxZombies = 300;
    int maxBlocks = 75;
    int maxBubbles=50;
    int maxGetHit =10;
    int maxDeathPitFalling = 10;
    int maxTripping = 50;
    int maxWhooed = 100;
    int maxTotalHit = 500;
    double pctComplete = ((double)[GCState sharedInstance].timesDied / (int)maxTimesToDie) * 100.0;
    //NSLog(@"diedTimes:%d",[GCState sharedInstance].timesDied );
    //NSLog(@"complete percent %f",pctComplete);

    if(pctComplete < 100.0 )
    {
    //[[GCState sharedInstance] save];
    [[GCHelper sharedInstance] reportAchievement:gcAchievementTimesDied percentComplete:pctComplete];
    }
    //NSLog(@"hurdles:%d",[GCState sharedInstance].hurdlesJumpedOver );
    double pctComplete2 = ((double) [GCState sharedInstance].hurdlesJumpedOver / (int)maxHurdles) * 100.0;
  
    if(pctComplete2 < 100.0 && [_level.name isEqualToString:@"level1"])
    {
    //[[GCState sharedInstance] save];
    [[GCHelper sharedInstance] reportAchievement:gcAchievementJumpOver400hurdles percentComplete:pctComplete2];
     }
    double pctComplete3 = ((double) [GCState sharedInstance].chickensKickedIntoCows / (int)maxChickenIntoCows) * 100.0;
   
    if(pctComplete3 < 100.0 && [_level.name isEqualToString:@"level2"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementChickensKickedIntoCows percentComplete:pctComplete3];
    }
    double pctComplete4 = ((double) [GCState sharedInstance].peopleShuffled / (int)maxShuffled) * 100.0;
  
    if(pctComplete4 < 100.0 && [_level.name isEqualToString:@"level4"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementShuffled200people percentComplete:pctComplete4];
    }
    double pctComplete5 = ((double) [GCState sharedInstance].frogsJumpedOver / (int)maxFrogs) * 100.0;
    
    if(pctComplete5 < 100.0 && [_level.name isEqualToString:@"level9"])
    {
       // [[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementJumpOver50frogs percentComplete:pctComplete5];
    }
    double pctComplete6 = ((double) [GCState sharedInstance].demonsFreezed / (int)maxDemon) * 100.0;
    
    if(pctComplete6 < 100.0 && [_level.name isEqualToString:@"level8"])
    {
       // [[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementFreeze200demon percentComplete:pctComplete6];
    }
    double pctComplete7 = ((double) [GCState sharedInstance].zombiesShot / (int)maxZombies) * 100.0;
    
    if(pctComplete7 < 100.0 && [_level.name isEqualToString:@"level6"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementShoot300zombies percentComplete:pctComplete7];
    }
    double pctComplete8 = ((double) [GCState sharedInstance].attacksBlocked / (int)maxBlocks) * 100.0;
    
    if(pctComplete8 < 100.0 && [_level.name isEqualToString:@"level7"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementBlock75attack percentComplete:pctComplete8];
    }
    double pctComplete9 = ((double) [GCState sharedInstance].hurdlesHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete9 < 100.0 && [_level.name isEqualToString:@"level1"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10hurdles percentComplete:pctComplete9];
    }
    double pctComplete10 = ((double) [GCState sharedInstance].cowsHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete10 < 100.0 && [_level.name isEqualToString:@"level2"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10hurdles percentComplete:pctComplete10];
    }
    double pctComplete11 = ((double) [GCState sharedInstance].birdsHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete11 < 100.0 && [_level.name isEqualToString:@"level3"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10birds percentComplete:pctComplete11];
    }
    double pctComplete12 = ((double) [GCState sharedInstance].dancersHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete12 < 100.0 && [_level.name isEqualToString:@"level4"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10dancers percentComplete:pctComplete12];
    }
    double pctComplete13 = ((double) [GCState sharedInstance].dogsHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete13 < 100.0 && [_level.name isEqualToString:@"level5"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10dogs percentComplete:pctComplete13];
    }
    double pctComplete14 = ((double) [GCState sharedInstance].zombiesHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete14 < 100.0 && [_level.name isEqualToString:@"level6"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10zombies percentComplete:pctComplete14];
    }
    double pctComplete15 = ((double) [GCState sharedInstance].viruesHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete15 < 100.0 && [_level.name isEqualToString:@"level7"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10virues percentComplete:pctComplete15];
    }
    double pctComplete16 = ((double) [GCState sharedInstance].fireDemonHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete16 < 100.0 && [_level.name isEqualToString:@"level8"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10firedemon percentComplete:pctComplete16];
    }
    double pctComplete17 = ((double) [GCState sharedInstance].frogsHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete17 < 100.0 && [_level.name isEqualToString:@"level9"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10frogs percentComplete:pctComplete17];
    }
    double pctComplete18 = ((double) [GCState sharedInstance].fishHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete18 < 100.0 && [_level.name isEqualToString:@"level10"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10fish percentComplete:pctComplete18];
    }
    double pctComplete19 = ((double) [GCState sharedInstance].batHit / (int)maxGetHit) * 100.0;
    
    if(pctComplete19 < 100.0 && [_level.name isEqualToString:@"level11"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHitby10bats percentComplete:pctComplete19];
    }
    
    double pctComplete20 = ((double) [GCState sharedInstance].timesFellIntoDeathPit / (int)maxDeathPitFalling) * 100.0;
    
    if(pctComplete20 < 100.0)
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementFallIntoDeathPit10times percentComplete:pctComplete20];
    }
    double pctComplete21 = ((double) [GCState sharedInstance].timesFellDown / (int)maxTripping) * 100.0;
    
    if(pctComplete21 < 100.0)
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementFalldown50times percentComplete:pctComplete21];
    }
    double pctComplete22 = ((double) [GCState sharedInstance].timesFellDown / (int)maxWhooed) * 100.0;
    
   // if(pctComplete22 < 100.0 && ([_level.name isEqualToString:@"level1"] || [_level.name isEqualToString:@"level3"]||[_level.name isEqualToString:@"level5"]||[_level.name isEqualToString:@"level9"]))
    if (pctComplete22 < 100.0)
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementFalldown50times percentComplete:pctComplete22];
    }
    double pctComplete23 = ((double) [GCState sharedInstance].dogsJumpedOver / (int)maxDogs) * 100.0;
    
    // if(pctComplete22 < 100.0 && ([_level.name isEqualToString:@"level1"] || [_level.name isEqualToString:@"level3"]||[_level.name isEqualToString:@"level5"]||[_level.name isEqualToString:@"level9"]))
    if (pctComplete23 < 100.0)
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementJumpOver100dogs percentComplete:pctComplete23];
    }

    
    double pctComplete24 = ((double) [GCState sharedInstance].gotHit / (int)maxTotalHit) * 100.0;
    
  
    if (pctComplete24 < 100.0)
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementGetHit500times percentComplete:pctComplete24];
    }

    double pctComplete25 = ((double) [GCState sharedInstance].bubblesPoked / (int)maxBubbles) * 100.0;
    
    if(pctComplete25 < 100.0 && [_level.name isEqualToString:@"level10"])
    {
        //[[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementKnock50Bubbles percentComplete:pctComplete25];
    }
    
    
    if([[[GCHelper sharedInstance] getAchievementByID:gcAchievementBeatStoryAll] isCompleted] && [[[GCHelper sharedInstance] getAchievementByID:gcAchievementAllGoldInIM] isCompleted] && [[[GCHelper sharedInstance] getAchievementByID:gcAchievementAllGoldInNM] isCompleted])
    {
        if(![GCState sharedInstance].beatStoryAndAllGold)
        {
            
            [GCState sharedInstance].beatStoryAndAllGold =true;
            [[GCHelper sharedInstance] reportAchievement:gcAchievementAllGoldInNM percentComplete:100.0];
        }
    }



    
    
}

-(GameDebugLayer*)getDebugLayer
{
    return _debugLayer;
}

-(void)checkHasBeenHit
{
     NSString *mode = [[GameSettings shared] getGlobalForKey:@"gameMode"];
    if(!_player.gotHit && ![GCState sharedInstance].flawlessRun &&[_level.name isEqualToString:@"level3"] && [mode isEqualToString:@"timed"])
    {
        [GCState sharedInstance].flawlessRun = true;
       // [[GCState sharedInstance] save];
        [[GCHelper sharedInstance] reportAchievement:gcAchievementFlawlessRun percentComplete:100.0];
    }
}

- (void) dealloc
{
    //can't put these in onexit like the others for some reason
    [self stopLaserShow];
    [self stopRainyLevel];
    
    [_level release];
    [_player release];
    [_gameController release];
    [_inputController release];
    [_savePoint release];
    [_hud release];
    
    [[TextureManager shared] unloadMemoryForKey:@"gameScene"];
    
	[super dealloc];
}

@end
