//
//  Utilities.h
//  Clay
//
//  Created by Brian Cable on 8/30/11.
//  Copyright 2011 Xecudev, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities


+(bool)clampFloatMin:(float)min Value:(float*)value;
+(bool)clampFloatMax:(float)max Value:(float*)value;

@end