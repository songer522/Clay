//
//  SoundEngine.h
//  Clay
//
//  Created by Brian Cable on 9/23/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundEngine : NSObject
{
    
}
+(id)instance;
+(void) playSound:(NSString*)sound;


@end
