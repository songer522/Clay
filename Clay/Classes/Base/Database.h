//
//  GCDatabase.h
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 Xecudev, LLC. All rights reserved.
//
//  Class for loading and saving data. Currently used for recording your best time.

#import <Foundation/Foundation.h>

id loadData(NSString * filename);
void saveData(id theData, NSString *filename);
