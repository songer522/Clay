//
//  GCState.m
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//

#import "GCState.h"
#import "Database.h"

@implementation GCState
@synthesize chickensKickedIntoCows;
@synthesize hurdlesJumpedOver,peopleShuffled,dogsJumpedOver,zombiesShot,attacksBlocked,demonsFreezed,frogsJumpedOver,bubblesPoked;
@synthesize timesDied,hurdlesHit,cowsHit,dancersHit,birdsHit,dogsHit,zombiesHit,viruesHit,fireDemonHit,frogsHit,fishHit,batHit;
@synthesize completeStoryAll,completeStoryEasy,completeStoryHard,completeStoryNormal,flawlessRun;
@synthesize timesWhooed,timesFellDown,timesFellIntoDeathPit;
@synthesize gotHit,facebook,twitter,allGoldInInsane,allGoldInNormal,beatStoryAndAllGold,watchCredit,rateOurGame;

static GCState *sharedInstance = nil;

+(GCState*)sharedInstance {
    @synchronized([GCState class])
    {
        if (!sharedInstance) {
            sharedInstance = [loadData(@"GCState") retain];
            if (!sharedInstance) {
                [[self alloc] init];
            }
        }
        return sharedInstance;
    }
    return nil;
}

+(id)alloc {
    @synchronized([GCState class])
    {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of the GCState singleton");
        sharedInstance = [super alloc];
        return sharedInstance;
    }
    return nil;
}

-(void)save {
    if(!_enabled) { return; }
    
    saveData(self, @"GCState");
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    if(!_enabled) { return; }
    
    [encoder encodeInt:chickensKickedIntoCows forKey:@"ChickensKickedIntoCows"];
    [encoder encodeInt:timesDied forKey:@"timesDied"];
    [encoder encodeInt:hurdlesJumpedOver forKey:@"hurdlesJumpedOver"];
    [encoder encodeInt:peopleShuffled forKey:@"peopleShuffled"];
    [encoder encodeInt:dogsJumpedOver forKey:@"dogsJumpedOver"];
    [encoder encodeInt:zombiesShot forKey:@"zombiesShot"];
    [encoder encodeInt:attacksBlocked forKey:@"attacksBlocked"];
    [encoder encodeInt:demonsFreezed forKey:@"demonsFreezed"];
    [encoder encodeInt:frogsJumpedOver forKey:@"frogsJumpedOver"];
    [encoder encodeInt:bubblesPoked forKey:@"bubblesPoked"];
    
    
    [encoder encodeInt:hurdlesHit forKey:@"hurdlesHit"];
    [encoder encodeInt:cowsHit forKey:@"cowsHit"];
    [encoder encodeInt:dancersHit forKey:@"dancersHit"];
    [encoder encodeInt:birdsHit forKey:@"birdsHit"];
    [encoder encodeInt:dogsHit forKey:@"dogsHit"];
    [encoder encodeInt:zombiesHit forKey:@"zombiesHit"];
    [encoder encodeInt:viruesHit forKey:@"viruesHit"];
    [encoder encodeInt:fireDemonHit forKey:@"fireDemonHit"];
    [encoder encodeInt:frogsHit forKey:@"frogsHit"];
    [encoder encodeInt:fishHit forKey:@"fishHit"];
    [encoder encodeInt:batHit forKey:@"batHit"];
    
      [encoder encodeInt:gotHit forKey:@"gotHit"];
    
    [encoder encodeInt:timesWhooed forKey:@"timesWhooed"];
    [encoder encodeInt:timesFellIntoDeathPit forKey:@"timesFellIntoDeathPit"];
    [encoder encodeInt:timesFellDown forKey:@"timesFellDown"];
   
     
     
     
    [encoder encodeBool:completeStoryEasy forKey:@"completeStoryEasy"];
    [encoder encodeBool:completeStoryNormal forKey:@"completeStoryNormal"];
    [encoder encodeBool:completeStoryHard forKey:@"completeStoryHard"];
    [encoder encodeBool:completeStoryAll forKey:@"completeStoryAll"];
    [encoder encodeBool:flawlessRun forKey:@"flawlessRun"];
    
    [encoder encodeBool:facebook forKey:@"facebook"];
    [encoder encodeBool:twitter forKey:@"twitter"];
    [encoder encodeBool:allGoldInNormal forKey:@"allGoldInNormal"];
    [encoder encodeBool:allGoldInInsane forKey:@"allGoldInInsane"];
    [encoder encodeBool:beatStoryAndAllGold forKey:@"beatStoryAndAllGold"];
    [encoder encodeBool:watchCredit forKey:@"watchCredit"];
    [encoder encodeBool:rateOurGame forKey:@"rateOurGame"];
    
    
    
    
    

}

-(id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super  init])) {
        _enabled = true;
        
        if (_enabled) {
            chickensKickedIntoCows = [decoder decodeIntForKey:@"ChickensKickedIntoCows"];
            timesDied = [decoder decodeIntForKey:@"timesDied"];
            hurdlesJumpedOver = [decoder decodeIntForKey:@"hurdlesJumpedOver"];
            peopleShuffled = [decoder decodeIntForKey:@"peopleShuffled"];
            dogsJumpedOver = [decoder decodeIntForKey:@"dogsJumpedOver"];
            zombiesShot = [decoder decodeIntForKey:@"zombiesShot"];
            attacksBlocked = [decoder decodeIntForKey:@"attacksBlocked"];
            demonsFreezed = [decoder decodeIntForKey:@"demonsFreezed"];
            frogsJumpedOver = [decoder decodeIntForKey:@"frogsJumpedOver"];
            
            
            hurdlesHit = [decoder decodeIntForKey:@"hurdlesHit"];
            cowsHit = [decoder decodeIntForKey:@"cowsHit"];
            dancersHit = [decoder decodeIntForKey:@"dancersHit"];
            birdsHit = [decoder decodeIntForKey:@"birdsHit"];
            dogsHit = [decoder decodeIntForKey:@"dogsHit"];
            zombiesHit = [decoder decodeIntForKey:@"zombiesHit"];
            viruesHit = [decoder decodeIntForKey:@"viruesHit"];
            fireDemonHit = [decoder decodeIntForKey:@"fireDemonHit"];
            frogsHit = [decoder decodeIntForKey:@"frogsHit"];
            fishHit = [decoder decodeIntForKey:@"fishHit"];
            batHit = [decoder decodeIntForKey:@"batHit"];
            gotHit=[decoder decodeIntForKey:@"gotHit"];
            
            timesWhooed = [decoder decodeIntForKey:@"timesWhooed"];
            timesFellIntoDeathPit = [decoder decodeIntForKey:@"timesFellIntoDeathPit"];
            timesFellDown = [decoder decodeIntForKey:@"timesFellDown"];
            
            
            completeStoryEasy = [ decoder decodeBoolForKey:@"completeStoryEasy"];
            completeStoryNormal = [ decoder decodeBoolForKey:@"completeStoryNormal"];
            completeStoryHard = [ decoder decodeBoolForKey:@"completeStoryHard"];
            completeStoryAll = [ decoder decodeBoolForKey:@"completeStoryAll"];
            flawlessRun =[ decoder decodeBoolForKey:@"flawlessRun"];
            
            facebook =[ decoder decodeBoolForKey:@"facebook"];  
            twitter =[ decoder decodeBoolForKey:@"twitter"];
             allGoldInNormal =[ decoder decodeBoolForKey:@"allGoldInNormal"];
             allGoldInInsane =[ decoder decodeBoolForKey:@"allGoldInInsane"];
             beatStoryAndAllGold =[ decoder decodeBoolForKey:@"beatStoryAndAllGold"];
             watchCredit =[ decoder decodeBoolForKey:@"watchCredit"];
            rateOurGame=[decoder decodeBoolForKey:@"rateOurGame"];
            
            
        }
    }
    return self;
}

@end
