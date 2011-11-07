//
//  PListLoader.m
//  Clay
//
//  Created by Dustin Werner on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PListLoader.h"

@implementation PListLoader

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(NSDictionary*)loadPlistWithName:(NSString*)plistName{
    
    NSString *fullFileName = [NSString stringWithFormat:@"%@.plist",plistName];
    NSString *plistPath;
    
    // Get the Path to the plist File
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    }
    
    // Read the plist File
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // verify file was found
    if (plistDictionary == nil) {
        NSLog(@"Error reading plist: %@.plist", plistName);
        return nil;
    }
    
    return plistDictionary;
    

}

@end
