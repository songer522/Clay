//
//  GCState.h
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCState : NSObject <NSCoding> {
    int chickensKickedIntoCows;
}

+ (GCState *) sharedInstance;
- (void)save;

@property (assign) int chickensKickedIntoCows;

@end
