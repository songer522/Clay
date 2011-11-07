//
//  GCDatabase.m
//  Clay
//
//  Created by Dustin Werner on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Database.h"

NSString * pathForFile(NSString *filename) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:filename];
}

id loadData(NSString * filename) {
    NSString *filepath = pathForFile(filename);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        NSData *data = [[[NSData alloc] initWithContentsOfFile:filepath] autorelease];
        NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        id retval = [unarchiver decodeObjectForKey:@"Data"];
        [unarchiver finishDecoding];
        return retval;
    }
    return nil;
}

void saveData(id theData, NSString *filename) {
    NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver encodeObject:theData forKey:@"Data"];
    [archiver finishEncoding];
    [data writeToFile:pathForFile(filename) atomically:YES];
}